---
id: IDX-PDR
type: index
title: 開発の進め方の決定
status: stable
tags: [index]
---

# 開発の進め方の決定 / PDR（横断）

開発の進め方の決定と、その理由と、却下した案を残す。道具、テンプレート、手順、文書の置き場の決定がここに入る。PDRは層のルールの対象外なので、どの層のノードにも`decides`を張れる。

決定を変えるときは、既存のPDRを書き換えず、新しいPDRを起こして`supersedes`で繋ぐ。置き換えられた側は`status: deprecated`にする。番号は4桁のゼロ埋めで振り、欠番を作らない。番号は、PDR・TDR・ADRで1つの列を使う。

ゲームの外の技術の決定は[IDX-TDR](../51-tdr/index.md)に、ゲームの中の構成の決定は[IDX-ADR](../52-adr/index.md)に置く。

## ノード一覧

<!-- graph:children:start -->
- [PDR-0001 設計文書をグラフとして管理する](./pdr-0001-graph-driven-docs.md)
- [PDR-0003 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](./pdr-0003-ccgs-import.md)
- [PDR-0004 ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す](./pdr-0004-claude-md-split.md)
- [PDR-0006 ADRを役割で2か所に分け、CCGSのADRはgraphで検証しない](./pdr-0006-adr-location.md)
- [PDR-0007 CCGSのsession-start.shとsetup-engineを、rulesのファイルから読み込みの行を探す形に直す](./pdr-0007-engine-import-in-rules.md)
<!-- graph:children:end -->

## 追加するとき

```bash
python -m tools.graph new --type pdr --id PDR-0008 --title "..." --slug some-slug
```
