---
id: PDR-0008
type: pdr
title: GDDと設計の文書はgraphの検証の外に置く
status: stable
tags: [template]
depends_on:
  - PDR-0006
decides: []
supersedes: []
related: []
---

# GDDと設計の文書はgraphの検証の外に置く

- 日付: 2026-10-23
- 状態: stable

## 背景

CCGSは、GDDや設計の文書を`design/`に置く。CCGSの文書の雛形にはフロントマターが無いので、そのままではgraphの検証にかけられない。setopic/game-template#2では、`design/`の文書をgraphで検証する案を挙げていた。検証するフォルダを`graph.toml`の`docs_dir`で変える機能は、上流に入っている（setopic/graph-doc-template#177）。ただし、`docs_dir`を変えた派生で`00-meta`の読み込みと共通のテストが通るようにする修正（setopic/graph-doc-template#183）は、まだ届いていない。

[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)で、決定の記録をPDR・TDR・ADR・DDRの4つの種別に分け、どれも`docs/`の下にgraphのノードとして置いた。GDDは`design/gdd/`に残し、DDRとGDDは両方から指すと決めた。graphで検証する文書を当面`docs/`に置くことも、[PDR-0002](./pdr-0002-ccgs-import.md)から引き継いだ。

## 決定

CCGSのGDDと設計の文書は、`design/`に置いたまま、graphの検証の外に置く。`design/`の文書にフロントマターは足さず、graphのノードにしない。

決定の経緯は、graphのノードであるDDR・TDR・ADRが持つ。DDRとGDDは、[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)の決定の2のとおり、両方から指す。GDDからDDRへの参照は、GDDがgraphの外にあるので、機械では確かめない。

graphで検証する文書は、当面ではなく、この決定のもとで`docs/`に置く。`graph.toml`の`docs_dir`は変えない。setopic/graph-doc-template#183が届いても、それだけを理由に`docs_dir`を`design`にしない。

## 理由

決定の経緯は、すでにDDR・TDR・ADRとしてgraphで検証している。GDDは、いまの仕様を書く文書で、経緯を持たない（[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)）。GDDまでgraphに載せなくても、決定の記録はリンク切れや`depends_on`の検査を受ける。

`design/`を検証の対象にするには、文書の置き場か上流の道具のどちらかを大きく動かす必要がある。どちらも、検証で得られるものに比べて手間が大きい。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| `docs_dir = "design"`にして、graphの文書を`design/`に移す | PDR・TDR・ADR・DDRの置き場と、それを指すCCGSのスキルのパスを、[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)のあとにまた動かすことになる。setopic/graph-doc-template#183が届くまでは、`00-meta`の読み込みと共通のテストも通らない |
| graphが複数の文書のフォルダを検証できるようにする | 上流（`graph-doc-template`）の道具の変更が大きい |
| setopic/game-template#2の本文の種類表（`concept`・`system`・`content`・`architecture`・`adr`を`design/`の下に置き、層を分ける）で、CCGSの文書をgraphのノードにする | CCGSの文書の雛形とスキルに、フロントマターを足して直し続けることになる。決定の記録は、[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)の4つの種別で`docs/`に置いている |

## 影響

`design/`の文書は、`python -m tools.graph check`の対象にならない。CCGSのスキルで作ったGDDは、フロントマターの無いまま`design/`に置く。`graph.toml`の`exclude`は、`docs/`の下にあるCCGSの文書だけを外す。`design/`は文書のフォルダの外なので、`exclude`に書かない。

## 見直しの条件

GDDの中身の食い違い（GDDとDDRのずれなど）を、機械で確かめる必要が出たとき。上流のgraphが、複数の文書のフォルダを検証できるようになったとき。CCGSが、文書の雛形にフロントマターを持つようになったとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`depends_on`: この文書が成立するために前提となるノード

- [PDR-0006 CCGSを丸ごと取り込み、決定の記録を4つの種別に分ける](./pdr-0006-ccgs-whole-import-dr-types.md)

<!-- graph:auto:end -->
