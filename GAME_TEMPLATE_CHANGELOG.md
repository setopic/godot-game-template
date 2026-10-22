# game-templateの変更履歴

この層だけの履歴である。下の層の履歴は、[TEMPLATE_CHANGELOG.md](TEMPLATE_CHANGELOG.md)（`graph-doc-template`）と[PROJECT_TEMPLATE_CHANGELOG.md](PROJECT_TEMPLATE_CHANGELOG.md)（`graph-project-template`）にある。そのプロジェクト自身の履歴は、[PROJECT_CHANGELOG.md](PROJECT_CHANGELOG.md)に書く。

**派生プロジェクトはこのファイルを書き換えない。**

現在の版は、`tools/graph/layers/game-template.toml`の`version`に書く。版の付け方と見出しの書き方は、[PROJECT_TEMPLATE_CHANGELOG.md](PROJECT_TEMPLATE_CHANGELOG.md)の「版の付け方」に合わせる。

## 0.2.0（2026-10-22）

### 追加

CCGS（Claude-Code-Game-Studios、MITライセンス）の1.2.0を取り込んだ（#1）。CCGSの`UPGRADING.md`のStrategy A2で、`.claude/`、`design/`、`src/`、`docs/`、`production/`、`studio-tests/`、`project.yaml`、`.worktreeinclude`、`UPGRADING.md`、`CHANGELOG.md`を写した。CCGSの`LICENSE`は`LICENSE-CCGS`として残した。`README.md`、`CONTRIBUTING.md`、`.gitignore`、ルートの`CLAUDE.md`、`.github/`の下のファイル、`SECURITY.md`は写していない。

CCGSのルートの`CLAUDE.md`の内容は、`.claude/rules/ccgs-studio.md`へ移した。ルートの`CLAUDE.md`はgraphの共通ファイルのままである。`.gitattributes`の末尾に、CCGSの指定を5行足した。

決めたことは、ADR-0002（Godotの版）、ADR-0003（取り込み方）、ADR-0004（`CLAUDE.md`の扱い）に書いた。CCGSの更新を取り込む手順は、UC-02に書いた。

### 取り込む側の作業

無い。CCGSのファイルは、`make update`で届く。

---

## 0.1.0（2026-10-22）

### 追加

graph-project-templateの上に、game-templateの層を作った。Godotの素材をGit LFSで扱う設定を`.gitattributes`に足した。

### 取り込む側の作業

無い。
