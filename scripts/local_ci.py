"""GitHub Actionsが動かないときに、graph-check.ymlとapp-check.ymlと同じ検査を手元で回す。

PRの番号を渡すと、PRのときにしか走らないrefsとnamesも、ghでPRの題・本文・
ブランチ・コミットを読んで回す。渡さなければcheckのジョブだけを回す。
project.godotがあれば、app-check.ymlのGodotの段（読み込み・スクリプトの読み込みの確認・
GdUnit4）も、PATHのgodotで回す（TDR-0004）。書き出しはmainへのpushのときだけの段なので回さない。

    python scripts/local_ci.py [PRの番号]

makeのレシピに書かないのは、Windowsのmakeが使うシェルで引用符の扱いが崩れるからである。
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

PY = sys.executable
GODOT_CI = ".github/scripts/godot-ci.sh"
GDUNIT = (
    "godot", "--headless", "-s", "-d", "--remote-debug", "tcp://127.0.0.1:0",
    "res://addons/gdUnit4/bin/GdUnitCmdTool.gd", "-a", "res://tests", "--ignoreHeadlessMode",
)


def run(*cmd: str, env: dict[str, str] | None = None) -> None:
    print("$ " + " ".join(cmd), flush=True)
    subprocess.run(cmd, check=True, env=env)


def out(*cmd: str) -> str:
    return subprocess.run(cmd, check=True, capture_output=True, text=True, encoding="utf-8").stdout.strip()


def godot() -> bool:
    """app-check.ymlのGodotの段を、同じ順番と同じ判定（godot-ci.sh）で回す。"""
    if not Path("project.godot").is_file():
        print("project.godotが無いので、Godotの段を飛ばす")
        return True
    # Windowsでは、"bash"とだけ書くとSystem32のWSLのbashが先に見つかることがある。
    bash = shutil.which("bash")
    if bash is None or shutil.which("godot") is None:
        print("bashかgodotがPATHに無いので、Godotの段を回せない", file=sys.stderr)
        return False
    # detectの注記と誤りは標準エラーに出るので、標準出力だけを読む。
    detected = subprocess.run(
        (bash, GODOT_CI, "detect"), check=True, stdout=subprocess.PIPE, text=True, encoding="utf-8"
    ).stdout
    found = dict(line.split("=", 1) for line in detected.splitlines() if "=" in line)
    # ログは作業ツリーに置かない。.gitignoreに無いので、コミットに混ざる。
    # GdUnit4の報告は、GdUnit4の既定のreports/に書く。こちらは.gitignoreにある。
    # 6.2.2の-rdは、/で始まるパスをres://の下と読む。macOSやLinuxの一時フォルダを渡せないので、使わない（#61）。
    logs = Path(tempfile.mkdtemp(prefix="local_ci-")).as_posix()
    print(f"Godotのログ: {logs}")
    env = dict(os.environ, GODOT_CI_RETRY_SEGV="1")
    run(bash, GODOT_CI, "checked", f"{logs}/import.log", "--", "godot", "--headless", "--path", ".", "--import", env=env)
    scripts = sorted(
        "res://" + p.as_posix() for d in ("src", "tests") if Path(d).is_dir() for p in Path(d).rglob("*.gd")
    )
    if scripts:
        run(bash, GODOT_CI, "checked", f"{logs}/parse.log", "--",
            "godot", "--headless", "--path", ".", "-s", "res://.claude/scripts/godot-parse-check.gd", "--", *scripts)
    if found.get("gdunit") == "true":
        run(bash, GODOT_CI, "gdunit", f"{logs}/gdunit.log", "--", *GDUNIT)
    return True


def main() -> int:
    pr = sys.argv[1] if len(sys.argv) > 1 else ""
    info: dict = {}
    if pr:
        info = json.loads(
            out("gh", "pr", "view", pr, "--json", "title,body,headRefName,headRefOid,baseRefName")
        )
        head = out("git", "rev-parse", "HEAD")
        if head != info["headRefOid"]:
            print(f"作業ツリーがPR {pr}の先頭（{info['headRefOid']}）ではない。pushしてから回す", file=sys.stderr)
            return 1
        run("git", "fetch", "-q", "origin", info["baseRefName"])

    run(PY, "-m", "unittest", "discover", "-s", "tests", "-t", ".")
    if pr:
        run(PY, "-m", "tools.graph", "check", "--since", f"origin/{info['baseRefName']}")
    run(PY, "-m", "tools.graph", "check", "--strict")
    run(PY, "-m", "tools.graph", "sync", "--check")
    run(PY, "-m", "tools.graph", "linkify", "--check")
    run("make", "--no-print-directory", "readme-check")

    if pr:
        env = dict(os.environ)
        env.update(
            PR_TITLE=info["title"],
            PR_BODY=info["body"],
            HEAD_REF=info["headRefName"],
            HEAD_SHA=info["headRefOid"],
            BASE_SHA=out("git", "merge-base", info["headRefOid"], f"origin/{info['baseRefName']}"),
            GITHUB_REPOSITORY=out("gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"),
        )
        run(PY, ".github/scripts/check_refs.py", env=env)
        run(PY, ".github/scripts/check_names.py", env=env)

    if not godot():
        return 1
    print("local_ci: すべて通った")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.CalledProcessError as e:
        print(f"local_ci: 失敗した（終了コード{e.returncode}）", file=sys.stderr)
        sys.exit(1)
