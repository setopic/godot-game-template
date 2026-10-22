---
id: PDR-0004
type: pdr
title: ADRを役割で2か所に分け、CCGSのADRはgraphで検証しない
status: stable
tags: [template]
decides:
  - UC-02
supersedes: []
related:
  - PDR-0002
---

# ADRを役割で2か所に分け、CCGSのADRはgraphで検証しない

- 日付: 2026-10-22
- 状態: stable

## 背景

ADRの置き場が2つある（setopic/game-template#12）。

- graphのADRは`docs/50-adr/`にあり、graphのノードとして検証される（[PDR-0001](./pdr-0001-graph-driven-docs.md)）。フロントマターと、日本語の必須の節（背景、決定、理由、却下した案、影響、見直しの条件）を持つ
- CCGSの`/architecture-decision`は、`docs/architecture/`の中を見て次の番号を決め、`docs/architecture/adr-NNNN-*.md`に書く（`.claude/skills/architecture-decision/SKILL.md`の「2. Determine the next ADR number」）。書式は`references/5-generate.md`の雛形で、フロントマターは無く、節は`## Status`、`## Summary`、`## Engine Compatibility`、`## Decision`などの英語である

`docs/architecture/`は`docs/`の下にあるので、graphの検証の対象に入っている。2026-10-22に`docs/architecture/adr-0001-test.md`を置いて`check`を回すと、`G001`（フロントマターが無い）で落ちた。`/architecture-decision`を使うと、そのたびに`make check`が落ちる状態だった。CCGSが`docs/architecture/`に書く`architecture.md`、`control-manifest.md`、`requirements-traceability.md`、`architecture-review-*.md`も、フロントマターを持たないので同じである。

`.claude/`の下で、`docs/architecture/`のADRのパスを指すファイルは29本ある。ADRの英語の節（`## Status`、`## Summary`、`Last Verified`）を読むスキルは33本ある。どれもCCGSの「上書きしてよいファイル」である（[UC-02](../30-usecases/uc-02-ccgs-upgrade.md)の手順4）。

## 決定

### 1. ADRを役割で2か所に分ける

| 置き場 | 書くもの | 書き方 |
| --- | --- | --- |
| `docs/50-adr/` | テンプレートと開発の進め方の決定。どのテンプレートや道具をどう取り込むか、エンジンの版や言語など | graphのADR。`python -m tools.graph new --type adr`で作る |
| `docs/architecture/` | 作品のゲームの技術の決定。`/architecture-decision`が書くもの | CCGSの書式のまま |

`/architecture-decision`で書くADRの置き場は、`docs/architecture/`に決める。CCGSのスキルは直さない。

### 2. `docs/architecture/`は、graphの検証から外す

`graph.toml`の`exclude`に`docs/architecture/`を足す。ADRだけでなく、フォルダごと外す。CCGSがこのフォルダに書くほかの文書も、フロントマターを持たないからである。

### 3. 番号は2か所で別々に数える

graphのADRとCCGSのADRは、同じ`ADR-NNNN`の形の番号を、それぞれの置き場の中で振る。同じ番号が2つできうる。graphのノードからは`docs/50-adr/`のADRだけをidで指し、CCGSのADRはパスで指す。

### 4. front matterと書式は対応させない

CCGSのADRにはgraphのフロントマターを付けず、節の名前もgraphに合わせない。graphのノードからCCGSのADRに触れたいときは、本文にパスで書く。

## 理由

CCGSのADRをgraphの検証に載せるには、29本のパスと、33本が読む英語の節を、graphの書き方に合わせる必要がある。どれもCCGSの「上書きしてよいファイル」なので、CCGSの更新を取り込むたびに直し直すことになる。UC-02の手順4の`git checkout`で写せなくなり、取り込みが手作業になる。

逆に、graphのADRを`docs/architecture/`へ移すと、`graph.toml`に種別を全部書き直して`adr`の`dir`を変え、必須の節を英語にし、PDR-0001からTDR-0002も書き直すことになる。CCGSの雛形にフロントマターを足す手直しも、取り込みのたびに残る。

分けるのは、2つのADRが決めるものも違うからである。graphのADRは、このテンプレートの形を決める。CCGSのADRは、作品ごとのゲームの作りを決め、CCGSのストーリーやレビューのスキルが`Accepted`かどうかを読んで進める。CCGSのADRがCCGSの書式のままなら、CCGSのスキルがそのまま動く。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| `docs/50-adr/`にそろえる。CCGSのスキルのパスと雛形を直す | 29本のパスと33本の節の読み取りを、CCGSの更新のたびに直し直すことになる |
| `docs/architecture/`にそろえる。graphの`adr`の置き場を`graph.toml`で変える | 種別を全部書き直し、必須の節を英語にし、既存のPDR-0001からTDR-0002も書き直すことになる。CCGSの雛形にフロントマターを足す手直しも、取り込みのたびに残る |
| 置き場は分けず、`docs/architecture/`を検証から外すだけにする | `/architecture-decision`の`make check`は通るが、どちらに何を書くかが決まらない |

## 影響

`/architecture-decision`で書いたADRで、`make check`が落ちなくなる。そのかわり、作品のゲームの技術の決定は、graphの検証（リンク切れ、`decides`の辺など）を受けない。CCGSの`/architecture-review`などのスキルが、CCGSのADRの整合を見る。

[UC-02](../30-usecases/uc-02-ccgs-upgrade.md)の`docs/architecture/`の行と、「つまずきやすい点」に、検証から外していることを書く。

## 見直しの条件

CCGSが、ADRの置き場や書式を設定で変えられるようにしたとき。graphの検証で、フロントマターの無い文書や英語の節をノードとして読めるようになったとき。`docs_dir`を`design`にしたとき（[PDR-0002](./pdr-0002-ccgs-import.md)）は、`docs/architecture/`が文書のフォルダの外になるので、`exclude`の`docs/architecture/`を消す。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`related`: 依存はしないが、一緒に読むべきノード

- [PDR-0002 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](./pdr-0002-ccgs-import.md)

`decides`: この決定が影響を与えるノード（ADR用）

- [UC-02 CCGSの更新を取り込む](../30-usecases/uc-02-ccgs-upgrade.md)

このノードを参照しているノード

- (related) [PDR-0002 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](./pdr-0002-ccgs-import.md)

<!-- graph:auto:end -->
