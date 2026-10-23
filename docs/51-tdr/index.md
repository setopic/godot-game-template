---
id: IDX-TDR
type: index
title: ゲームの外の技術の決定
status: stable
tags: [index]
---

# ゲームの外の技術の決定 / TDR（横断）

ゲームのコードの外から何を使うかの決定と、その理由と、却下した案を残す。エンジンとその版、言語、ライブラリ、対応する機種、ビルドと書き出しの決定がここに入る。TDRは層のルールの対象外なので、どの層のノードにも`decides`を張れる。

決定を変えるときは、既存のTDRを書き換えず、新しいTDRを起こして`supersedes`で繋ぐ。置き換えられた側は`status: deprecated`にする。番号は4桁のゼロ埋めで振り、欠番を作らない。番号は種別ごとに0001から振る。

開発の進め方の決定は[IDX-PDR](../50-pdr/index.md)に、ゲームの中の構成の決定は[IDX-ADR](../52-adr/index.md)に、ゲームデザインの決定は[IDX-DDR](../53-ddr/index.md)に置く。

## ノード一覧

<!-- graph:children:start -->
- [TDR-0001 Godotの版を4.7.2にする](./tdr-0001-godot-version.md)
- [TDR-0002 言語をGDScriptにする](./tdr-0002-gdscript.md)
- [TDR-0003 Godot用のGitの設定をそろえる](./tdr-0003-godot-git-settings.md)
<!-- graph:children:end -->

## 追加するとき

```bash
python -m tools.graph new --type tdr --id TDR-0003 --title "..." --slug some-slug
```
