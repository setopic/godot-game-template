# game-templateの変更履歴

この層だけの履歴である。下の層の履歴は、[TEMPLATE_CHANGELOG.md](TEMPLATE_CHANGELOG.md)（`graph-doc-template`）と[PROJECT_TEMPLATE_CHANGELOG.md](PROJECT_TEMPLATE_CHANGELOG.md)（`graph-project-template`）にある。そのプロジェクト自身の履歴は、[PROJECT_CHANGELOG.md](PROJECT_CHANGELOG.md)に書く。

**派生プロジェクトはこのファイルを書き換えない。**

現在の版は、`tools/graph/layers/game-template.toml`の`version`に書く。版の付け方と見出しの書き方は、[PROJECT_TEMPLATE_CHANGELOG.md](PROJECT_TEMPLATE_CHANGELOG.md)の「版の付け方」に合わせる。

## 0.3.1（2026-10-22）

### 修正

CCGSの`.claude/hooks/session-start.sh`と`/setup-engine`が、エンジンの版の読み込みの行を`.claude/rules/ccgs-studio.md`から探すようにした（#11）。これまでは、ルートの`CLAUDE.md`しか探さなかったので、エンジンの照合が黙って行われず、`/setup-engine`を実行し直しても書き換える行を見つけられなかった。ルートの`CLAUDE.md`は、これまでどおり手を入れない。

決めたことは、ADR-0007に書いた。直したファイルはCCGSの更新で上書きされるので、UC-02に戻して合わせる手順を足した。

### 取り込む側の作業

無い。

---

## 0.3.0（2026-10-22）

### 追加

CCGSの`/setup-engine godot 4.7.2`に当たる設定をし、言語をGDScriptにした（#1）。`.claude/rules/ccgs-studio.md`の「Technology Stack」、`.claude/docs/technical-preferences.md`、`project.yaml`の`engine`・`specialists`・`naming`・`commands`の節に、GDScriptの場合の値を書いた。描画の方式、物理エンジン、書き出しの設定のように作品ごとに違う値は、`[TO BE CONFIGURED]`のまま残した。

決めたことは、ADR-0005に書いた。UC-02には、CCGSの更新で上書きされる`technical-preferences.md`を戻して合わせる手順を足した。

### 取り込む側の作業

無い。設定は`make update`で届く。`[TO BE CONFIGURED]`のまま残した`engine.rendering`、`engine.physics`、`commands.build`は、作品を作るときに`/settings`で決める。

---

## 0.2.0（2026-10-22）

### 追加

CCGS（Claude-Code-Game-Studios、MITライセンス）の1.2.0を取り込んだ（#1）。CCGSの`UPGRADING.md`のStrategy A2で、`.claude/`、`design/`、`src/`、`docs/`、`production/`、`studio-tests/`、`project.yaml`、`.worktreeinclude`、`UPGRADING.md`、`CHANGELOG.md`を写した。CCGSの`LICENSE`は`LICENSE-CCGS`として残した。`README.md`、`CONTRIBUTING.md`、`.gitignore`、ルートの`CLAUDE.md`、`.github/`の下のファイル、`SECURITY.md`は写していない。

CCGSの`docs/`にあるフロントマターの無いMarkdownは、`graph.toml`の`exclude`でgraphの検証から外した。

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
