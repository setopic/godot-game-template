---
id: ADR-0007
type: adr
title: CCGSのsession-start.shとsetup-engineを、rulesのファイルから読み込みの行を探す形に直す
status: stable
tags: [template]
decides:
  - UC-02
supersedes: []
related:
  - ADR-0004
---

# CCGSのsession-start.shとsetup-engineを、rulesのファイルから読み込みの行を探す形に直す

- 日付: 2026-10-22
- 状態: stable

## 背景

[ADR-0004](./adr-0004-claude-md-split.md)で、CCGSのルートの`CLAUDE.md`の内容を`.claude/rules/ccgs-studio.md`へ移した。エンジンの版の読み込みの行（`ENGINE-REFERENCE-IMPORT`の印の付いた`@`の行）も、`@../../docs/engine-reference/godot/VERSION.md`の形でこのファイルにある。

CCGSのうち2つが、この行がルートの`CLAUDE.md`にあることを前提にしていた（setopic/game-template#11）。

- `.claude/hooks/session-start.sh`は、ルートの`CLAUDE.md`から`^@docs/engine-reference/<engine>/VERSION.md`の行を探し、`project.yaml`の`engine.name`と照らし合わせる。行が見つからないので、照合が黙って行われなかった。
- `/setup-engine`は、手順4でルートの`CLAUDE.md`の「Technology Stack」の節と読み込みの行を書き換え、手順8で確かめる。書き換える先がルートに無く、行のパスの形も違う。

## 決定

このリポジトリで、次の3つのファイルを直す。上流のCCGSには出さない。

- `.claude/hooks/session-start.sh`：ルートの`CLAUDE.md`を探し、見つからなければ`.claude/rules/*.md`を探す。行の頭の`../`の繰り返しも受ける。警告には、行を見つけたファイルの名前を出す
- `.claude/skills/setup-engine/references/4-claude-md-stack.md`：書き換える先を、`ENGINE-REFERENCE-IMPORT`の印を持つファイル（ルートの`CLAUDE.md`、なければ`.claude/rules/*.md`）にする。rulesのファイルでは、行の`../../`を残して`<engine>`の部分だけを書き換える
- `.claude/skills/setup-engine/references/8-verify.md`：確かめる先を、手順4で書いたファイルにする

ルートの`CLAUDE.md`の末尾に`@`の行を足す案は、採らない。ADR-0004は置き換えない。

## 理由

直したあとの形は、ルートの`CLAUDE.md`に行がある場合（CCGSのそのままの配置）でも、これまでどおりに働く。

ルートの`CLAUDE.md`に`@`の行を足しても、直るのは読み込みの行だけである。`/setup-engine`が書き換える「Technology Stack」の節は、`.claude/rules/ccgs-studio.md`に残る。graphがルートの`CLAUDE.md`の末尾を直したときの競合も残る。

上流に出さないのは、ルートの`CLAUDE.md`を別のテンプレートと分け合う配置が、CCGSの想定の外だからである。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| 上流のCCGSに、読み込みの行をルートの`CLAUDE.md`の外にも置けるようにする変更を出す | ルートの`CLAUDE.md`を別のテンプレートと分け合う配置は、CCGSの想定の外である。出しても、このリポジトリは取り込まれるまで直らない |
| ルートの`CLAUDE.md`の末尾に、`ENGINE-REFERENCE-IMPORT`の印と`@docs/engine-reference/godot/VERSION.md`の行を足す | 「Technology Stack」の節の書き換えが直らない。graphが末尾を直したときに競合する（ADR-0004） |

## 影響

直した3つのファイルは、`.claude/hooks`と`.claude/skills`の下にあり、[UC-02](../30-usecases/uc-02-ccgs-upgrade.md)の手順4で上書きされる。UC-02では、上書きのあとにこの3つを戻し、CCGSの差を手で合わせるファイルに足した。直した箇所には、`game-template (ADR-0007)`の注記を付けてある。

## 見直しの条件

CCGSが、ルートの`CLAUDE.md`の外にある読み込みの行を探すように変わったとき。ADR-0004を見直して、CCGSの内容をルートの`CLAUDE.md`に戻したとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`related`: 依存はしないが、一緒に読むべきノード

- [ADR-0004 ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す](./adr-0004-claude-md-split.md)

`decides`: この決定が影響を与えるノード（ADR用）

- [UC-02 CCGSの更新を取り込む](../30-usecases/uc-02-ccgs-upgrade.md)

このノードを参照しているノード

- (related) [ADR-0004 ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す](./adr-0004-claude-md-split.md)

<!-- graph:auto:end -->
