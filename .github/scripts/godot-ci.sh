#!/usr/bin/env bash
# app-check.ymlのGodotの段が使う補助。TDR-0004。
#
# workflowのrun:に直接書かず、ここに切り出してある。手元で偽のログを渡して
# 確かめられるようにするためである。
#
#   detect                    project.godot・GdUnit4・テスト・書き出しの設定の有無を、
#                             GITHUB_OUTPUTの形（key=value）で標準出力に出す
#   checked <log> -- <cmd…>   cmdを回してログに写し、終了コードが0でなくても、
#                             ログにERRORの行があっても失敗にする。GODOT_CI_RETRY_SEGV=1なら、
#                             139（セグメンテーション違反）のときだけ1度回し直す
#   gdunit <log> -- <cmd…>    GdUnit4を回す。0と101（すべて通り、孤立したノードの警告だけ）を成功にする
#   presets                   export_presets.cfgのWindowsとWebの書き出しの設定を、
#                             「名前<TAB>種類」の行で出す（種類はwindowsかweb）
#
# 終了コード: 0 成功、1 検査の失敗、2 使い方の誤り。
set -u

# Godotのエラーの行。push_errorはUSER ERROR、スクリプトの誤りはSCRIPT ERRORで始まる。
ERROR_PATTERN='^[[:space:]]*(USER |SCRIPT )?ERROR:'

detect() {
  local project=false gdunit=false tests=false presets=false
  if [ -f project.godot ]; then
    project=true
  else
    echo "::notice title=app-check::project.godotが無いので、Godotの段を飛ばす" >&2
  fi
  [ -f addons/gdUnit4/bin/GdUnitCmdTool.gd ] && gdunit=true
  if [ -n "$(find tests -name '*.gd' -print -quit 2>/dev/null)" ]; then
    tests=true
  fi
  [ -f export_presets.cfg ] && presets=true
  if [ "$project" = true ]; then
    # テストがあるのにGdUnit4が無いなら、テストを回せないまま通ってしまうので落とす。
    if [ "$tests" = true ] && [ "$gdunit" = false ]; then
      echo "::error title=app-check::tests/にGDScriptのテストがあるのに、addons/gdUnit4/が無い。/test-setupでGdUnit4を入れる" >&2
      return 1
    fi
    [ "$gdunit" = false ] && echo "::notice title=app-check::addons/gdUnit4/もGDScriptのテストも無いので、テストの段を飛ばす" >&2
    [ "$presets" = false ] && echo "::notice title=app-check::export_presets.cfgが無いので、書き出しの段を飛ばす" >&2
  fi
  echo "project=$project"
  echo "gdunit=$gdunit"
  echo "presets=$presets"
}

# run <log> <cmd…>: cmdの出力を画面とログの両方に出し、cmdの終了コードを返す。
run() {
  local log="$1"; shift
  mkdir -p "$(dirname "$log")"
  "$@" 2>&1 | tee "$log"
  return "${PIPESTATUS[0]}"
}

checked() {
  local log="$1"; shift
  [ "${1:-}" = "--" ] && shift
  [ $# -gt 0 ] || { echo "godot-ci: checkedに回すコマンドが無い" >&2; return 2; }
  run "$log" "$@"
  local code=$?
  # 4.7.1と4.7.2では、新しいプロジェクトの最初の--importが、書き終えたあとの終了で
  # 落ちることがある（17回中3回、current-best-practices.md）。回し直すと0で終わる。
  # ERRORの行のときは回し直さない。2度目に出なくなったエラーを見逃すからである。
  if [ "$code" -eq 139 ] && [ "${GODOT_CI_RETRY_SEGV:-0}" = 1 ]; then
    echo "::warning title=app-check::終了コードが139だったので、1度だけ回し直す: $*" >&2
    run "$log" "$@"
    code=$?
  fi
  if [ "$code" -ne 0 ]; then
    echo "::error title=app-check::終了コードが${code}だった: $*" >&2
    return 1
  fi
  # Godotは、エラーがあっても終了コードを0にすることがある（setopic/game-template#5）。
  if grep -E -q "$ERROR_PATTERN" "$log"; then
    echo "::error title=app-check::終了コードは0だが、ログにERRORの行がある: $*" >&2
    grep -E -n "$ERROR_PATTERN" "$log" >&2
    return 1
  fi
  return 0
}

gdunit() {
  local log="$1"; shift
  [ "${1:-}" = "--" ] && shift
  [ $# -gt 0 ] || { echo "godot-ci: gdunitに回すコマンドが無い" >&2; return 2; }
  run "$log" "$@"
  local code=$?
  # ERRORの行では判定しない。--remote-debugが、毎回ERRORの行を2つ出すからである
  # （docs/engine-reference/godot/current-best-practices.md）。
  case "$code" in
    0) return 0 ;;
    101) echo "::warning title=app-check::GdUnit4の警告（孤立したノードなど）がある。テストはすべて通った" >&2; return 0 ;;
    *) echo "::error title=app-check::GdUnit4の終了コードが${code}だった（100 失敗、105 テストのスクリプトが読めない、1 GdUnit4が読み込めない）" >&2; return 1 ;;
  esac
}

presets() {
  [ -f export_presets.cfg ] || return 0
  awk '
    /^\[preset\.[0-9]+\]/ { flush(); in_preset = 1; name = ""; platform = ""; next }
    /^\[/ { flush(); in_preset = 0; next }
    in_preset && /^name=/ { name = value($0) }
    in_preset && /^platform=/ { platform = value($0) }
    function value(line) { sub(/^[^=]*="/, "", line); sub(/"[[:space:]]*\r?$/, "", line); return line }
    function flush() {
      if (name != "" && platform == "Windows Desktop") print name "\twindows"
      if (name != "" && platform == "Web") print name "\tweb"
      name = ""; platform = ""
    }
    END { flush() }
  ' export_presets.cfg
}

case "${1:-}" in
  detect) detect ;;
  checked) shift; [ $# -ge 1 ] || { echo "godot-ci: ログのパスが無い" >&2; exit 2; }; checked "$@" ;;
  gdunit) shift; [ $# -ge 1 ] || { echo "godot-ci: ログのパスが無い" >&2; exit 2; }; gdunit "$@" ;;
  presets) presets ;;
  *) echo "使い方: godot-ci.sh detect | checked <log> -- <cmd…> | gdunit <log> -- <cmd…> | presets" >&2; exit 2 ;;
esac
