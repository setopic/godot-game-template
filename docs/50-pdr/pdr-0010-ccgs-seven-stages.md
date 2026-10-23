---
id: PDR-0010
type: pdr
title: 開発の段階はCCGSの7段階をそのまま使う
status: stable
tags: [template, flow]
decides:
  - ARCH-03
supersedes: []
related: []
---

# 開発の段階はCCGSの7段階をそのまま使う

- 日付: 2026-10-23
- 状態: stable

## 背景

setopic/game-template#8で、一般的なゲーム会社の8段階（企画、プロトタイプ作成、プリプロダクション、本制作、テスト・調整、発売準備、リリース、運営・アップデート）と、Claudeと作るときの3つの変更点を、開発の流れとして組み込むことにした。

取り込んだCCGSには、すでに7段階（Concept、Systems Design、Technical Setup、Pre-Production、Production、Polish、Release）と、段階の間の関門（`/gate-check`）がある。今の段階は`project.yaml`の`project.stage`に記録する。段階ごとの手順は`.claude/docs/workflow-catalog.yaml`に、関門の中身は`/gate-check`の定義のファイルにある。多くのスキルが段階の名前を読んでいる。

## 決定

段階は、CCGSの7段階と`/gate-check`をそのまま使う。8段階は、CCGSの段階との対応表として[ARCH-03](../10-architecture/arch-03-dev-stages.md)に書く。3つの変更点と、関門の定義に無い人の判断の場面も、ARCH-03に書く。

今の段階は、CCGSどおり`project.yaml`の`project.stage`に記録する。運営・アップデートは、Releaseのあと`project.stage`をProductionに戻すくり返しとして扱う。

CCGSのファイルは、8段階に合わせて直さない。人が判断する場面でClaudeが止まって聞くことだけを、`.claude/rules/ccgs-studio.md`の「Collaboration Protocol」に1項目足す。

## 理由

CCGSの段階は、手順と関門とスキルが組みになっている。8段階は流れの説明としては分かりやすいが、段階の名前を変えると、それを読むスキルと関門をすべて直すことになる。対応表を置けば、8段階で考える人もCCGSの段階で作業できる。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| CCGSの段階を8段階に合わせて直す | `project.stage`の値、`workflow-catalog.yaml`の`phases`、`/gate-check`の関門の定義、段階の名前を読むスキルを、すべて直すことになる。CCGSを更新するたびに、その直しを合わせ直す手間が続く |
| 流れの文書をgraphの外の`docs/`に置く | 段階の対応と人の判断の場面は、テンプレートの構造の方針で、graphの`10-architecture`に置けば`check`の検査を受ける |
| 今の段階を`CLAUDE.md`に書く | CCGSのスキルとフックは`project.yaml`の`project.stage`を読む。`CLAUDE.md`は上流と共通のファイルでもある |

## 影響

ARCH-03が、8段階とCCGSの段階の対応、3つの変更点、人が判断する場面を持つ。`.claude/rules/ccgs-studio.md`に1項目増える。CCGSを更新するときは、その項目を残す。

## 見直しの条件

CCGSが段階の名前や数を変えたとき。CCGSの関門に、ストアへの登録や公開の判断のような人の判断の場面が入ったとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`decides`: この決定が影響を与えるノード（ADR用）

- [ARCH-03 CCGSの7段階に沿った開発の流れ](../10-architecture/arch-03-dev-stages.md)

<!-- graph:auto:end -->
