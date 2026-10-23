---
id: IDX-PDR
type: index
title: 開発の進め方の決定
status: stable
tags: [index]
---

# 開発の進め方の決定 / PDR（横断）

開発の進め方の決定と、その理由と、却下した案を残す。道具、テンプレート、手順、文書の置き場の決定がここに入る。PDRは層のルールの対象外なので、どの層のノードにも`decides`を張れる。

決定を変えるときは、既存のPDRを書き換えず、新しいPDRを起こして`supersedes`で繋ぐ。置き換えられた側は`status: deprecated`にする。番号は4桁のゼロ埋めで振り、欠番を作らない。番号は種別ごとに0001から振る。

ゲームの外の技術の決定は[IDX-TDR](../51-tdr/index.md)に、ゲームの中の構成の決定は[IDX-ADR](../52-adr/index.md)に、ゲームデザインの決定は[IDX-DDR](../53-ddr/index.md)に置く。

## ノード一覧

<!-- graph:children:start -->
- [PDR-0001 設計文書をグラフとして管理する](./pdr-0001-graph-driven-docs.md)
- [PDR-0002 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](./pdr-0002-ccgs-import.md)
- [PDR-0003 ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す](./pdr-0003-claude-md-split.md)
- [PDR-0004 ADRを役割で2か所に分け、CCGSのADRはgraphで検証しない](./pdr-0004-adr-location.md)
- [PDR-0005 CCGSのsession-start.shとsetup-engineを、rulesのファイルから読み込みの行を探す形に直す](./pdr-0005-engine-import-in-rules.md)
- [PDR-0006 CCGSを丸ごと取り込み、決定の記録を4つの種別に分ける](./pdr-0006-ccgs-whole-import-dr-types.md)
- [PDR-0007 TDRとADRの最終確認日をフロントマターに持つ](./pdr-0007-last-verified-front-matter.md)
- [PDR-0008 GDDと設計の文書はgraphの検証の外に置く](./pdr-0008-design-docs-outside-graph.md)
- [PDR-0009 CODEOWNERSは雛形として配り、作品が担当者を入れる](./pdr-0009-codeowners-example.md)
- [PDR-0010 開発の段階はCCGSの7段階をそのまま使う](./pdr-0010-ccgs-seven-stages.md)
- [PDR-0011 CCGSの.gitignoreは、エンジンの節を除いてこの層の節に写す](./pdr-0011-ccgs-gitignore.md)
- [PDR-0012 複数人で開発するときは、持ち主の承認を必須にする](./pdr-0012-codeowners-review-required.md)
<!-- graph:children:end -->

## 追加するとき

```bash
python -m tools.graph new --type pdr --id PDR-0006 --title "..." --slug some-slug
```
