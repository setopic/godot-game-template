# game-templateの変更履歴

この層だけの履歴である。下の層の履歴は、[TEMPLATE_CHANGELOG.md](TEMPLATE_CHANGELOG.md)（`graph-doc-template`）と[PROJECT_TEMPLATE_CHANGELOG.md](PROJECT_TEMPLATE_CHANGELOG.md)（`graph-project-template`）にある。そのプロジェクト自身の履歴は、[PROJECT_CHANGELOG.md](PROJECT_CHANGELOG.md)に書く。

**派生プロジェクトはこのファイルを書き換えない。**

現在の版は、`tools/graph/layers/game-template.toml`の`version`に書く。版の付け方と見出しの書き方は、[PROJECT_TEMPLATE_CHANGELOG.md](PROJECT_TEMPLATE_CHANGELOG.md)の「版の付け方」に合わせる。

## 0.4.0（2026-10-22）

### 変更

決定の記録を、PDR・TDR・ADRの3つの種別に分けた（#16）。`graph.toml`に`[node_types]`を足し、`pdr`（開発の進め方の決定、`docs/50-pdr/`）、`tdr`（ゲームの外の技術の決定、`docs/51-tdr/`）、`adr`（ゲームの中の構成の決定、`docs/52-adr/`）を置いた。フォルダの50番台は、決定の記録に使う。3つとも層は90で、層のルールの対象外にし、確定したら書き換えない記録として扱う。必須の節は、既定の`adr`と同じにした。番号は種別ごとに0001から振る。ゲームデザインの決定（DDR）は`docs/53-ddr/`に置くが、雛形とGDDとのつなぎを含めて別のPRで足す。

種別を1つでも書くと、書いたものが種別の全体になる。そのため、`architecture`・`domain`・`usecase`・`contract`は、`tools/graph/schema.py`の既定の種別を同じ内容で書き写した。上流が既定の種別を変えても、`graph.toml`には届かない。上流の変更履歴を見て、手で合わせる。

これまでの決定の記録は、`rename`で振り直した。これまでのコミット・PRの題・変更履歴にある旧idは、次の表で読み替える。

| 旧id | 新id |
| --- | --- |
| ADR-0001 | PDR-0001 |
| ADR-0003 | PDR-0002 |
| ADR-0004 | PDR-0003 |
| ADR-0006 | PDR-0004 |
| ADR-0007 | PDR-0005 |
| ADR-0002 | TDR-0001 |
| ADR-0005 | TDR-0002 |

目次は、`docs/50-adr/index.md`（IDX-ADR）をIDX-PDRとして`docs/50-pdr/`へ移し、`docs/51-tdr/`（IDX-TDR）と`docs/52-adr/`（IDX-ADR）の目次を作った。`docs/52-adr/`には、まだノードが無い。`docs/50-adr/`は無くなった。

確定したDRのidの振り直しは、本文の中身を変えないので、書式の修正と同じ扱いにした。直したのは、フロントマターのid・type・エッジと、本文のidとリンクだけである。

`.gitattributes`の`merge=ours`の行は、`docs/50-pdr/pdr-0001-graph-driven-docs.md`に直した。UC-02、`README.md`、`.claude/rules/ccgs-studio.md`、`.claude/hooks/session-start.sh`、`/setup-engine`の手順4の注記にあった`docs/50-adr/`とidも、新しいものに直した。CCGSのスキルとスクリプトが書く`docs/architecture/`のADRは、まだ変えていない。

### 取り込む側の作業

`make update`で、`graph.toml`の`[node_types]`と、振り直したPDR-0001〜PDR-0005・TDR-0001・TDR-0002が届く。`graph.toml`を自分で書き換えていて競合したら、`[node_types]`の表はこの層のものに合わせ、自分で足した`exclude`の行は残す。

`.gitattributes`の`merge=ours`の行が、`docs/50-pdr/pdr-0001-graph-driven-docs.md`に変わる。派生で`.gitattributes`を書き換えていて競合したら、この行を新しいパスにする。

取り込んだあと、`docs/50-adr/`に自分のADR（ADR-0008から）が残っていれば、`check`が`G003`を出す。1つずつ、PDR・TDR・ADRのどれに当たるかを決め、`rename`でその種別の次の番号に振り直す。

```bash
python -m tools.graph rename --from ADR-0008 --to PDR-0006
```

ADRのままにするものも、ADR-0001から振り直す。振り直すと`docs/52-adr/`へ移る。

```bash
python -m tools.graph rename --from ADR-0009 --to ADR-0001
```

振り直したら`make all`を回し、`docs/50-adr/`が空なら消す。本文の地の文にある`docs/50-adr/`は、手で直す。確定したDRは、idとリンクのほかは変えない。

---

## 0.3.2（2026-10-22）

### 修正

CCGSの`.claude/hooks/session-start.sh`と`/setup-engine`が、エンジンの版の読み込みの行を`.claude/rules/ccgs-studio.md`から探すようにした（#11）。これまでは、ルートの`CLAUDE.md`しか探さなかったので、エンジンの照合が黙って行われず、`/setup-engine`を実行し直しても書き換える行を見つけられなかった。ルートの`CLAUDE.md`は、これまでどおり手を入れない。

決めたことは、ADR-0007に書いた。直したファイルはCCGSの更新で上書きされるので、UC-02に戻して合わせる手順を足した。

### 取り込む側の作業

無い。

---

## 0.3.1（2026-10-22）

### 修正

CCGSの`/architecture-decision`で`docs/architecture/`にADRを書くと、フロントマターが無いので`make check`が`G001`で落ちていた（#12）。`graph.toml`の`exclude`に`docs/architecture/`を足し、graphの検証から外した。

ADRの置き場は、役割で2か所に分けた。`docs/50-adr/`にはテンプレートと開発の進め方の決定をgraphの書き方で書き、`docs/architecture/`には作品のゲームの技術の決定をCCGSの書式で書く。番号は別々に数える。決めたことはADR-0006に書き、UC-02と`docs/50-adr/index.md`に案内を足した。

### 取り込む側の作業

無い。`graph.toml`の変更は`make update`で届く。

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
