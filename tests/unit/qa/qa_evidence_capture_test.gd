## スクリーンショットの証拠を撮るautoloadの、引数とパスの決まりのテスト。ADR-0001。
##
## 画面を撮る部分は、--headlessでは描かないので、ここでは確かめない（run-and-observe.md）。
extends GdUnitTestSuite

const Capture := preload("res://src/qa/evidence_capture.gd")


func test_parse_args_without_capture_returns_empty() -> void:
	# Arrange
	var args := PackedStringArray(["--story=story-001-title"])

	# Act
	var request := Capture.parse_args(args)

	# Assert
	assert_bool(request.is_empty()).is_true()


func test_parse_args_with_capture_uses_default_frames() -> void:
	# Arrange
	var args := PackedStringArray(["--capture=shop", "--story=story-003-light-pickup"])

	# Act
	var request := Capture.parse_args(args)

	# Assert
	assert_str(request.error).is_empty()
	assert_str(request.name).is_equal("shop")
	assert_str(request.story).is_equal("story-003-light-pickup")
	assert_int(request.frames).is_equal(Capture.DEFAULT_WAIT_FRAMES)


func test_parse_args_capture_frames_overrides_default() -> void:
	# Arrange
	var args := PackedStringArray(["--capture=shop", "--capture-frames=60"])

	# Act
	var request := Capture.parse_args(args)

	# Assert
	assert_str(request.error).is_empty()
	assert_int(request.frames).is_equal(60)


func test_parse_args_zero_frames_is_error() -> void:
	# Arrange
	var args := PackedStringArray(["--capture=shop", "--capture-frames=0"])

	# Act
	var request := Capture.parse_args(args)

	# Assert
	assert_str(request.error).is_not_empty()


func test_parse_args_name_with_path_separator_is_error() -> void:
	# Arrange
	var args := PackedStringArray(["--capture=../shop"])

	# Act
	var request := Capture.parse_args(args)

	# Assert
	assert_str(request.error).is_not_empty()


func test_parse_args_capture_without_name_is_error() -> void:
	# Arrange
	var args := PackedStringArray(["--capture"])

	# Act
	var request := Capture.parse_args(args)

	# Assert
	assert_str(request.error).is_not_empty()


func test_story_from_checkpoint_reads_current_task_story() -> void:
	# Arrange
	var text := "**Updated:** 2026-10-23\n**Current task:** implementing `production/epics/core/story-003-light-pickup.md`\n"

	# Act
	var story := Capture.story_from_checkpoint(text)

	# Assert
	assert_str(story).is_equal("story-003-light-pickup")


func test_story_from_checkpoint_without_story_returns_empty() -> void:
	# Arrange
	var text := "**Current task:** reviewing the art bible\n"

	# Act
	var story := Capture.story_from_checkpoint(text)

	# Assert
	assert_str(story).is_empty()


func test_evidence_path_puts_datetime_before_name() -> void:
	# Arrange
	var stamp := {"year": 2026, "month": 10, "day": 3, "hour": 9, "minute": 5, "second": 7}

	# Act
	var path := Capture.evidence_path("/p/production/qa/evidence", "story-003-light-pickup", "shop", stamp)

	# Assert
	assert_str(path).is_equal("/p/production/qa/evidence/story-003-light-pickup/20261003-090507-shop.png")
