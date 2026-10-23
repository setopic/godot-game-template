---
id: TDR-0001
type: tdr
title: Godotの版を4.7.2にする
status: stable
tags: [engine]
decides: []
supersedes: []
related:
  - PDR-0002
---

# Godotの版を4.7.2にする

## 日付

2026-10-22

## 決めた人

なし

## 要約

なし

## エンジンとの互換

なし

## 前提のADR

なし

## 背景

game-templateは、Godotで作るゲームのテンプレートである。派生する作品がそろって使う版を、1つに決めておく必要があった（setopic/game-template#1）。

2026-10-22の時点で確かめた事実は次のとおりである。

| 版 | 状況 |
| --- | --- |
| 4.7.2 | 2026-08-18に公開された保守版。GitHubのreleasesでも、4.7.2-stableが最新である |
| 4.7.1 | 2026-07-14に公開された |
| 4.7 | 2026-06-18に公開された |
| 4.6.3 | 2026-05-20に公開された、4.6系の最後の版 |
| 4.8 | まだbetaである |

CCGS（Claude-Code-Game-Studios）の`docs/engine-reference/godot/VERSION.md`は、4.7を前提にしていて、最新の保守版として4.7.2を挙げている。`/setup-engine godot 4.7`の例もある。

テストに使うGdUnit4の最新版v6.2.2の対応表は、4.6から4.7.1までで、4.7.2はまだ載っていない。

## 決定

Godotの版を4.7.2にする。

### 理由

CCGSの前提（4.7）と同じ系列なので、`docs/engine-reference/godot/`を合わせ直さずに使える。4.7系の中では、保守版の修正をすべて取り込んだ版である。GdUnit4の対応表には載っていないが、保守版なので動く見込みである。動くかは、CIを作る作業（setopic/game-template#5）で確かめる。

## 検討した案

| 案 | 却下理由 |
| --- | --- |
| 4.7.1 | GdUnit4の対応表に載っている最後の版だが、4.7.2の保守版の修正を1つ取り込まないことになる |
| 4.6.3 | CCGSの前提（4.7）とずれ、`docs/engine-reference/godot/`を合わせ直す手間が出る |

## 影響

作品は、Godotの4.7.2で開く。CCGSの`/setup-engine`には、Godotの4.7を選ぶ。

## リスク

なし

## 対応するGDDの要件

なし

## 性能への影響

なし

## 移行の手順

なし

## 確かめ方

### 見直しの条件

GdUnit4が4.7.2で動かないと、setopic/game-template#5で分かったとき。4.8が安定版になり、CCGSの`docs/engine-reference/godot/`が4.8に移ったとき。

## 関連

なし

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`related`: 依存はしないが、一緒に読むべきノード

- [PDR-0002 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](../50-pdr/pdr-0002-ccgs-import.md)

このノードを参照しているノード

- (depends_on) [ADR-0001 スクリーンショットの証拠を1つのautoloadで撮る](../52-adr/adr-0001-evidence-capture-autoload.md)
- (depends_on) [TDR-0003 Godot用のGitの設定をそろえる](./tdr-0003-godot-git-settings.md)
- (depends_on) [TDR-0004 GodotのCIをapp-check.ymlで回す](./tdr-0004-godot-ci.md)
- (related) [PDR-0002 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](../50-pdr/pdr-0002-ccgs-import.md)

<!-- graph:auto:end -->
