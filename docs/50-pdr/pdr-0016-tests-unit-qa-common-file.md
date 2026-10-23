---
id: PDR-0016
type: pdr
title: tests/unit/qa/もこの層の共通ファイルにする
status: stable
tags: [template]
depends_on:
  - PDR-0006
decides: []
supersedes:
  - PDR-0014
related: []
---

# tests/unit/qa/もこの層の共通ファイルにする

- 日付: 2026-10-23
- 状態: stable

## 背景

[PDR-0014](./pdr-0014-game-template-common-files.md)は、この層の共通ファイルと作品のものを決めた。共通ファイルには、スクリーンショットの証拠を撮るautoloadの`src/qa/`を入れている。

この層は、`src/qa/evidence_capture.gd`のGdUnit4のテストとして、`tests/unit/qa/qa_evidence_capture_test.gd`も配っている（[ADR-0001](../52-adr/adr-0001-evidence-capture-autoload.md)）。しかし`tests/unit/qa/`は、共通ファイルにも作品のものにも挙げていなかった。

Godot 4.4からは、`.gd`ごとに`.uid`のファイルができる。[TDR-0003](../51-tdr/tdr-0003-godot-git-settings.md)は`.uid`をGitに入れると決めているが、この層は2つの`.gd`の`.uid`を配っていなかった。そのため作品は、最初の`--import`で作品ごとに別のuidを作ってコミットしていた（setopic/game-template#53）。この層が`.uid`を配ると、`tests/unit/qa/`の`.uid`がどちらのものかを決める必要がある。

## 決定

PDR-0014の決定をすべて引き継ぎ、共通ファイルに`tests/unit/qa/`を足す。改めるのはこの1点だけである。

| 共通ファイル | 中身 |
| --- | --- |
| `tests/unit/qa/` | `src/qa/`のGdUnit4のテストと、その`.uid` |

`src/qa/`と`tests/unit/qa/`の`.gd`に付く`.uid`は、この層で作って配る。作品が別のuidをすでにコミットしていて取り込みで競合したら、この層の側を採る。

## 理由

`tests/unit/qa/`のテストが確かめるのは、共通ファイルの`src/qa/`である。2つはいつも一緒に変わるので、片方だけを作品のものにすると、取り込みのたびにずれる。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| `tests/unit/qa/`を作品のものにする | `src/qa/`が変わっても、作品のテストが古いまま残る |

## 影響

game-templateから作った作品は、取り込みで`tests/unit/qa/`も上書きする。READMEの共通ファイルの表に`tests/unit/qa/`を足す。作品は、自分のテストを`tests/unit/qa/`の外に置く。

## 見直しの条件

作品で、`tests/unit/qa/`のテストを書き換えることが続くとき。この層が、`src/qa/`のほかにテストつきの実装を配るようになったとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`depends_on`: この文書が成立するために前提となるノード

- [PDR-0006 CCGSを丸ごと取り込み、決定の記録を4つの種別に分ける](./pdr-0006-ccgs-whole-import-dr-types.md)

`supersedes`: この決定が置き換える過去の決定（ADR用）

- [PDR-0014 この層の共通ファイルを、作品が書き換えないものに限る](./pdr-0014-game-template-common-files.md)

このノードを参照しているノード

- (depends_on) [PDR-0015 作品が書き換えるこの層のファイルも、merge=oursにしない](./pdr-0015-no-merge-ours-project-files.md)

<!-- graph:auto:end -->
