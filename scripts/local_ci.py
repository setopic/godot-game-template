"""GitHub Actionsが動かないときに、graph-check.ymlと同じ検査を手元で回す。

PRの番号を渡すと、PRのときにしか走らないrefsとnamesも、ghでPRの題・本文・
ブランチ・コミットを読んで回す。渡さなければcheckのジョブだけを回す。
app-check.ymlは、いまは警告を出すだけなので回さない。

    python scripts/local_ci.py [PRの番号]

makeのレシピに書かないのは、Windowsのmakeが使うシェルで引用符の扱いが崩れるからである。
"""

from __future__ import annotations

import json
import os
import subprocess
import sys

PY = sys.executable


def run(*cmd: str, env: dict[str, str] | None = None) -> None:
    print("$ " + " ".join(cmd), flush=True)
    subprocess.run(cmd, check=True, env=env)


def out(*cmd: str) -> str:
    return subprocess.run(cmd, check=True, capture_output=True, text=True, encoding="utf-8").stdout.strip()


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

    print("local_ci: すべて通った")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.CalledProcessError as e:
        print(f"local_ci: 失敗した（終了コード{e.returncode}）", file=sys.stderr)
        sys.exit(1)
