---
id: IDX-ADR
type: index
title: ゲームの中の構成の決定
status: stable
tags: [index]
---

# ゲームの中の構成の決定 / ADR（横断）

ゲームの中をどう組むかの決定と、その理由と、却下した案を残す。プレイヤーには同じで、作る側にだけ違いがあるもの（イベントの仕組み、セーブデータの形、シーンの分け方など）がここに入る。ADRは層のルールの対象外なので、どの層のノードにも`decides`を張れる。

決定を変えるときは、既存のADRを書き換えず、新しいADRを起こして`supersedes`で繋ぐ。置き換えられた側は`status: deprecated`にする。番号は4桁のゼロ埋めで振り、欠番を作らない。番号は種別ごとに0001から振る。

開発の進め方の決定は[IDX-PDR](../50-pdr/index.md)に、ゲームの外の技術の決定は[IDX-TDR](../51-tdr/index.md)に置く。

## ノード一覧

<!-- graph:children:start -->
<!-- graph:children:end -->

## 追加するとき

```bash
python -m tools.graph new --type adr --id ADR-0001 --title "..." --slug some-slug
```
