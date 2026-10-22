---
id: IDX-ADR
type: index
title: 決定記録
status: stable
tags: [index]
---

# 決定記録 / ADR（横断）

決定と、その理由と、却下した案を残す。ADRは層のルールの対象外なので、
どの層のノードにも`decides`を張れる。

決定を変えるときは、既存のADRを書き換えず、新しいADRを起こして`supersedes`で繋ぐ。
置き換えられた側は`status: deprecated`にする。番号は4桁のゼロ埋めで振り、欠番を作らない。

## ノード一覧

<!-- graph:children:start -->
- [ADR-0001 設計文書をグラフとして管理する](./adr-0001-graph-driven-docs.md)
- [ADR-0002 Godotの版を4.7.2にする](./adr-0002-godot-version.md)
- [ADR-0003 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](./adr-0003-ccgs-import.md)
- [ADR-0004 ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す](./adr-0004-claude-md-split.md)
<!-- graph:children:end -->

## 追加するとき

```bash
python -m tools.graph new --type adr --id ADR-0002 --title "..." --slug some-slug
```
