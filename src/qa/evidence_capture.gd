## スクリーンショットの証拠を撮るautoload。ADR-0001。
##
## 起動の引数で撮るとき（Claude）は、`--`のあとに渡す。
##
##   godot --path . --windowed --resolution 1280x720 res://<scene>.tscn -- --capture=<名前> --story=<ストーリーのid>
##
## 待つフレームの数は既定で10で、`--capture-frames=N`で変える。撮ったらゲームを終え、
## 終了コードで結果を返す（0 撮れた、1 撮れなかった、2 引数の誤り）。
## 遊びながら撮るとき（人）は、F12を押す。ゲームは終えない。
##
## ファイルは`production/qa/evidence/<ストーリーのid>/<日時>-<名前>.png`に置く。
## `--story`が無いときは、`production/session-state/active.md`の
## `**Current task:**`の行が指すストーリーを使う。
extends Node

const DEFAULT_WAIT_FRAMES := 10
const CAPTURE_KEY := KEY_F12
## キーで撮ったときの名前。
const KEY_CAPTURE_NAME := "key"
## ストーリーが分からないときの置き場。キーで撮るときだけ使う。
const NO_STORY := "no-story"
const EVIDENCE_DIR := "res://production/qa/evidence"
const CHECKPOINT_FILE := "res://production/session-state/active.md"

const EXIT_OK := 0
const EXIT_NOT_SAVED := 1
const EXIT_BAD_ARGS := 2

var _busy := false


func _ready() -> void:
	# 書き出したゲームでは動かさない（setopic/game-template#6の受け入れ条件）。
	# 書き出しの雛形には"editor"の機能が無い。
	if not OS.has_feature("editor"):
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	var request := parse_args(OS.get_cmdline_user_args())
	if request.is_empty():
		return
	_capture_from_args(request)


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or key.keycode != CAPTURE_KEY:
		return
	var story := story_from_checkpoint(_read_text(CHECKPOINT_FILE))
	if story.is_empty():
		story = NO_STORY
	var path := await _capture(story, KEY_CAPTURE_NAME)
	if path.is_empty():
		push_warning("evidence_capture: 撮れなかった")


## 起動の引数から、撮る指示を読む。撮る指示（`--capture`）が無ければ空の辞書を返す。
## 返す辞書は`name`・`frames`・`story`・`error`を持つ。`error`が空でなければ引数の誤りである。
static func parse_args(args: PackedStringArray) -> Dictionary:
	var request := {"name": "", "frames": DEFAULT_WAIT_FRAMES, "story": "", "error": ""}
	var asked := false
	for arg: String in args:
		if arg == "--capture" or arg.begins_with("--capture="):
			asked = true
			request.name = arg.trim_prefix("--capture").trim_prefix("=")
		elif arg.begins_with("--capture-frames="):
			var value := arg.trim_prefix("--capture-frames=")
			if not value.is_valid_int() or value.to_int() < 1:
				request.error = "--capture-framesは1以上の整数にする: " + value
			else:
				request.frames = value.to_int()
		elif arg.begins_with("--story="):
			request.story = arg.trim_prefix("--story=")
	if not asked:
		return {}
	if request.error.is_empty() and not is_valid_part(request.name):
		request.error = "--captureの名前には、英数字と-と_だけを使う: " + request.name
	if request.error.is_empty() and not request.story.is_empty() and not is_valid_part(request.story):
		request.error = "--storyには、英数字と-と_だけを使う: " + request.story
	return request


## ファイル名とフォルダ名に使えるか。パスの区切りや`..`を入れさせないために、英数字と`-`と`_`に限る。
static func is_valid_part(part: String) -> bool:
	if part.is_empty():
		return false
	var pattern := RegEx.create_from_string("^[A-Za-z0-9_-]+$")
	return pattern.search(part) != null


## セッションの記録（active.md）の`**Current task:**`の行から、ストーリーのidを取り出す。
## idは、ストーリーのファイルの名前から`.md`を除いたものである（run-and-observe.mdの`[story-slug]`）。
## 行が無いか、ストーリーのファイルを指していなければ空を返す。
static func story_from_checkpoint(text: String) -> String:
	var pattern := RegEx.create_from_string("production/epics/(?:[^/\\s`]+/)*([A-Za-z0-9_-]+)\\.md")
	for line: String in text.split("\n"):
		if not line.contains("**Current task:**"):
			continue
		var found := pattern.search(line)
		return found.get_string(1) if found != null else ""
	return ""


## 証拠のファイルのパスを作る。`stamp`は`Time.get_datetime_dict_from_system()`の形の辞書である。
static func evidence_path(root: String, story: String, shot_name: String, stamp: Dictionary) -> String:
	var when := "%04d%02d%02d-%02d%02d%02d" % [
		stamp.year, stamp.month, stamp.day, stamp.hour, stamp.minute, stamp.second,
	]
	return "%s/%s/%s-%s.png" % [root, story, when, shot_name]


func _capture_from_args(request: Dictionary) -> void:
	if request.error.is_empty() and request.story.is_empty():
		request.story = story_from_checkpoint(_read_text(CHECKPOINT_FILE))
		if request.story.is_empty():
			request.error = "--storyが無く、active.mdのCurrent taskもストーリーを指していない"
	if not request.error.is_empty():
		printerr("evidence_capture: ", request.error)
		get_tree().quit(EXIT_BAD_ARGS)
		return
	for _i in request.frames:
		await get_tree().process_frame
	var path := await _capture(request.story, request.name)
	get_tree().quit(EXIT_OK if not path.is_empty() else EXIT_NOT_SAVED)


## 1枚撮って保存し、保存したパスを返す。撮れなければ空を返す。
func _capture(story: String, shot_name: String) -> String:
	if _busy:
		return ""
	_busy = true
	# 描き終えたフレームを撮る。待たないと、前のフレームか空の画像になる。
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	_busy = false
	if image == null or image.is_empty():
		# --headlessでは描かないので、ここに来る（run-and-observe.md）。
		printerr("evidence_capture: 画面の画像が取れない。--headlessでは撮れない")
		return ""
	var root := ProjectSettings.globalize_path(EVIDENCE_DIR)
	var path := evidence_path(root, story, shot_name, Time.get_datetime_dict_from_system())
	var error := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if error == OK:
		error = image.save_png(path)
	if error != OK:
		printerr("evidence_capture: 保存できない（", error_string(error), "）: ", path)
		return ""
	print("evidence_capture: ", path)
	return path


func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	return FileAccess.get_file_as_string(path)
