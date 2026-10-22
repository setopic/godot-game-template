---
id: ADR-0003
type: adr
title: graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む
status: review
tags: [template]
decides:
  - UC-02
supersedes: []
related:
  - ADR-0002
  - ADR-0004
---

# graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む

- 日付: 2026-10-22
- 状態: review

## 背景

game-templateは、2つのテンプレートを合わせて作る（setopic/game-template#1）。1つは、設計文書をグラフで検証するgraph-project-templateである。もう1つは、ゲーム開発のエージェントとスキルを集めたCCGS（Claude-Code-Game-Studios、MITライセンス）である。どちらも更新が続くので、両方の更新を取り込める形にする必要があった。

graph側の更新は、`make update`で取り込む。`make update`は`git -c merge.ours.driver=true merge template/main`で上流をmergeする仕組みで、履歴が共通であることを前提にしている。graph側は更新が多く、graph-doc-templateの`CLAUDE.md`だけで、6月から57回変わっている。

CCGSには、`Makefile`も`merge=ours`の指定も無い。CCGSの`UPGRADING.md`は、取り込み方の1つとしてA2（Selective checkout）を挙げている。A2は、履歴が共通でないリポジトリへ、選んだパスだけを`git checkout`で写す方法である。

層の仕組みが3段にできることは、コードで確かめた。`tools/graph/upgrade.py`の`_order`は、層の宣言の`below`をたどって下から並べ、層の数を決め打ちしていない。ただし、土台はgraph-doc-templateに固定されていて、その下には層を置けない。

## 決定

### 1. graph-project-templateの履歴の上に作る

game-templateは、graph-project-templateのmainの上に作る。`tools/graph/layers/game-template.toml`に`below = "graph-project-template"`を書き、3段目の層にする。graph側の更新は、これまでどおり`make update`のmergeで取り込む。

### 2. CCGSはA2で取り込む

CCGSは、remoteの`ccgs`から、選んだパスだけを`git checkout ccgs/main -- <パス>`で写す。最初に写したのは、CCGSの1.2.0（`05ad7c8`）の次のパスである。

| 写したもの | 中身 |
| --- | --- |
| `.claude/` | agents、skills、hooks、scripts、rules、docs、`settings.json`、`statusline.sh` |
| `design/`、`src/`、`production/` | 場所ごとの`CLAUDE.md`と、空のフォルダの印 |
| `docs/` | `engine-reference/`、`architecture/`、`registry/`、`CLAUDE.md`、案内の文書 |
| `studio-tests/` | スキルとエージェントのテストの仕様 |
| `project.yaml`、`.worktreeinclude` | CCGSの設定と、worktreeへ写すファイルの一覧 |
| `UPGRADING.md`、`CHANGELOG.md` | CCGSの更新の手順と履歴 |

次のものは写さず、graph側を残すか、別の形で入れた。

| CCGSのもの | 扱い | 理由 |
| --- | --- | --- |
| `README.md`、`CONTRIBUTING.md` | graph側を残す | graphの共通ファイルである |
| ルートの`CLAUDE.md` | graph側を残し、内容を`.claude/rules/ccgs-studio.md`へ移す | [ADR-0004](./adr-0004-claude-md-split.md)で決めた |
| `.gitignore` | graph側を残す | CCGSのGodot用の行を足すのは、setopic/game-template#3で行う |
| `LICENSE` | `LICENSE-CCGS`として写す | MITライセンスの表示を残す |
| `.gitattributes` | CCGSの指定5行を、graph側のファイルの末尾に手で足す | 両方にある。CCGSの行は、graph側の`* text=auto eol=lf`と結果が同じだが、更新のときに見比べられるよう行を揃える |
| `.github/PULL_REQUEST_TEMPLATE.md` | 入れない | graphの`pull_request_template.md`と大文字小文字だけが違い、Windowsでは同じ名前になる |
| `.github/ISSUE_TEMPLATE/`の2つ | 入れない | issueの型は、graphの雛形と`config.yml`が決めている |
| `.github/CODEOWNERS`、`.github/FUNDING.yml`、`SECURITY.md` | 入れない | 中身がCCGSの作者のリポジトリ宛てである |

`.claude/settings.json`は、graph側に無いので、CCGSのものをそのまま使う。

### 3. graphで検証する文書は、当面`docs/`に置く

graphの検証の対象は、いまも`docs/`である。CCGSの`docs/`も同じフォルダに並ぶ。graphで検証する文書（ADRなど）は、`docs/`にgraphの書き方で置く。

`graph.toml`の`docs_dir = "design"`は、入れない。`docs_dir`を変えると、`00-meta`とその雛形の読み込みと、共通のテスト2件が通らないからである。上流の修正（setopic/graph-doc-template#183）が届いてから入れる。

CCGSの`docs/`にある文書は、フロントマターを持たないので、`check`が`G001`を出す（2026-10-22の時点で52件）。検証から外すパスを`graph.toml`に書けるキー（`exclude`）を、上流のgraph-doc-templateに足す。それが`make update`で届いたら、このリポジトリの`graph.toml`に、CCGSの`docs/`のパスを書く。困る点は、setopic/game-template#2に書いた。

## 理由

graph側は更新が多いので、mergeで取り込める側にする。CCGSの更新は、A2で写すパスを決めておけば、履歴が共通でなくても取り込める。A2は、CCGSが自分で案内している方法なので、CCGSの`UPGRADING.md`の版ごとの手順をそのまま使える。

CCGSの`docs/`を別のフォルダへ移すと、graphの検証からは外れる。しかし、`.claude/`の69個のファイルが`docs/engine-reference`などのパスを決め打ちで指していて、移すと動かなくなる。そのため、CCGSの`docs/`はそのままの場所に置き、検証から外す設定をgraph側に足す。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| CCGSから作り、graphを`--allow-unrelated-histories`で取り込む | 最初に`.gitattributes`と`CLAUDE.md`が競合する。そのあとも、graphの更新のたびに共通ファイルの競合を解く手間が残りやすい |
| CCGSの`docs/`を別のフォルダへ移す | CCGSのスキルやフックが、`docs/`の下のパスを決め打ちで読むので、動かなくなる |

## 影響

CCGSの更新は、[UC-02](../30-usecases/uc-02-ccgs-upgrade.md)の手順で取り込む。上書きしてよいファイルと、手で合わせるファイルを、そこで分ける。

`exclude`が届くまで、`check`はCCGSの`docs/`の文書で`G001`を出す。

## 見直しの条件

CCGSが、履歴を共通にして取り込める形（graph側に合わせた`merge=ours`の指定など）を配るようになったとき。setopic/graph-doc-template#183が届き、`docs_dir`でgraphの文書を`docs/`の外へ出せるようになったとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`related`: 依存はしないが、一緒に読むべきノード

- [ADR-0002 Godotの版を4.7.2にする](./adr-0002-godot-version.md)
- [ADR-0004 ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す](./adr-0004-claude-md-split.md)

`decides`: この決定が影響を与えるノード（ADR用）

- [UC-02 CCGSの更新を取り込む](../30-usecases/uc-02-ccgs-upgrade.md)

このノードを参照しているノード

- (related) [ADR-0002 Godotの版を4.7.2にする](./adr-0002-godot-version.md)
- (related) [ADR-0004 ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す](./adr-0004-claude-md-split.md)

<!-- graph:auto:end -->
