---
id: PDR-0015
type: pdr
title: 作品が書き換えるこの層のファイルも、merge=oursにしない
status: stable
tags: [template]
depends_on:
  - PDR-0014
decides: []
supersedes: []
related: []
---

# 作品が書き換えるこの層のファイルも、merge=oursにしない

- 日付: 2026-10-23
- 状態: stable

## 背景

[PDR-0014](./pdr-0014-game-template-common-files.md)は、`project.yaml`・`graph.toml`・`graph.mk`・`docs/templates/`を作品のものとし、作品が書き換えてよいとした。4つともこの層が足したファイルで、下の2つの層は配っていない。どれも`.gitattributes`で`merge=ours`にしていないので、作品が書き換えたあとに`make update`で取り込むと、競合することがある（setopic/game-template#43）。

この層も、4つを変えることがある。`project.yaml`の`framework.version`は、CCGSの更新のたびに上げる（[UC-02](../30-usecases/uc-02-ccgs-upgrade.md)）。`graph.toml`の種別の`required_sections`と、`docs/templates/`の雛形の節は対になっていて、片方だけが変わると`G014`が出る。`graph.mk`には、この層の`make ci`がある。下の層の`Makefile`は「テンプレートは`graph.mk`を配らない」と説明しているが、この層は配っている。

`merge=ours`にしたファイルは、取り込みのときにテンプレート側の変更が捨てられる。`merge=ours`にしなければ、作品が触っていない行にはテンプレートの変更がそのまま入り、両方が同じ行を変えたときだけ競合する。下の層は、`.gitignore`を同じ理由で`merge=ours`にしていない。

## 決定

`project.yaml`・`graph.toml`・`graph.mk`・`docs/templates/`は、`merge=ours`にしない。この層の変更は、取り込みのマージで作品に届く。競合したら、作品の変更とこの層の変更の両方を残して、手で解く。

`graph.toml`と`graph.mk`の末尾に、「ここから下は作品が足すもの」の注記を置く。作品が足す種別や`README_GRAPH_ARGS`は、その下に書く。`exclude`のように、この層の行を直す必要があるものは、その場で直す。

`.gitattributes`のこの層の節に、4つを`merge=ours`にしないことと、その理由を書く。READMEの共通ファイルの表の下にも、競合したときの扱いを書く。

## 理由

4つとも、この層の変更が作品に届かないと困る。`framework.version`が古いままだと、CCGSの更新の知らせや移行の判定が間違う。必須の節と雛形の節の片方だけが届くと、作品で`G014`が出る。`make ci`の直しが届かないと、作品の手元の検査がCIとずれる。

この層と作品が変えるのは、たいてい別の行である。`project.yaml`では、この層が`framework`や`engine.version`を変え、作品は`engine.rendering`・`modes`・`project.stage`などを変える。`graph.toml`と`graph.mk`では、作品の書き足しを末尾の節にまとめれば、この層の変更と行が離れる。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| 4つとも`merge=ours`にし、この層の変更は変更履歴の「取り込む側の作業」で手で写す | テンプレート側の変更が取り込みで捨てられ、写し忘れても気づけない。`framework.version`は、CCGSの更新のたびに写すことになる |
| `graph.toml`と`docs/templates/`だけを`merge=ours`にする | 必須の節を変えたとき、雛形か種別の片方を写し忘れると、作品で`G014`が出る |
| `graph.mk`だけを`merge=ours`にする | `make ci`の直しが作品に届かなくなる |
| 作品の書き足しの場所を決めない | この層の変更と同じ場所に書くと、取り込みのたびに競合しやすくなる |

## 影響

`.gitattributes`・`graph.toml`・`graph.mk`・READMEに注記が増える。取り込みで4つが競合したら、作品の側で手で解く。この層が4つを変えたときは、変更履歴の「取り込む側の作業」に、競合しうることを書く。

## 見直しの条件

取り込みのたびに、4つのどれかで競合することが続くとき。下の層が、`graph.toml`か`graph.mk`を配るようになったとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`depends_on`: この文書が成立するために前提となるノード

- [PDR-0014 この層の共通ファイルを、作品が書き換えないものに限る](./pdr-0014-game-template-common-files.md)

<!-- graph:auto:end -->
