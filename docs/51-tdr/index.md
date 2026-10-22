---
id: IDX-TDR
type: index
title: ゲームの外の技術の決定
status: stable
tags: [index]
---

# ゲームの外の技術の決定 / TDR（横断）

ゲームのコードの外から何を使うかの決定と、その理由と、却下した案を残す。エンジンとその版、言語、ライブラリ、対応する機種、ビルドと書き出しの決定がここに入る。TDRは層のルールの対象外なので、どの層のノードにも`decides`を張れる。

決定を変えるときは、既存のTDRを書き換えず、新しいTDRを起こして`supersedes`で繋ぐ。置き換えられた側は`status: deprecated`にする。番号は4桁のゼロ埋めで振り、欠番を作らない。番号は、PDR・TDR・ADRで1つの列を使う。

開発の進め方の決定は[IDX-PDR](../50-pdr/index.md)に、ゲームの中の構成の決定は[IDX-ADR](../52-adr/index.md)に置く。

## ノード一覧

<!-- graph:children:start -->
- [TDR-0002 Godotの版を4.7.2にする](./tdr-0002-godot-version.md)
- [TDR-0005 言語をGDScriptにする](./tdr-0005-gdscript.md)
<!-- graph:children:end -->

## 追加するとき

```bash
python -m tools.graph new --type tdr --id TDR-0008 --title "..." --slug some-slug
```
