---
id: IDX-DDR
type: index
title: ゲームデザインの決定
status: stable
tags: [index]
---

# ゲームデザインの決定 / DDR（横断）

ゲームデザインの決定と、その理由と、却下した案を残す。プレイヤーができること、見るもの、感じることが変わる決定（セーブの仕方、敵の動き方など）がここに入る。DDRは層のルールの対象外なので、どの層のノードにも`decides`を張れる。

決定を変えるときは、既存のDDRを書き換えず、新しいDDRを起こして`supersedes`で繋ぐ。置き換えられた側は`status: deprecated`にする。番号は4桁のゼロ埋めで振り、欠番を作らない。番号は種別ごとに0001から振る。

ゲームの中の構成の決定（ADR）との境は、「プレイヤーから違いが分かるか」である。1つの話が両方にまたがるときは2つに分け、ADRの`depends_on`でDDRを指す。

GDD（`design/gdd/`）はいまの仕様だけを書き、決定の経緯はDDRが持つ。DDRの「背景」の節にはGDDのパスを書き、GDDの`Related DDRs`の欄にはDDRのidを書く。GDDはgraphの外にあるので、GDDからDDRへの参照は`check`が確かめない。

開発の進め方の決定は[IDX-PDR](../50-pdr/index.md)に、ゲームの外の技術の決定は[IDX-TDR](../51-tdr/index.md)に、ゲームの中の構成の決定は[IDX-ADR](../52-adr/index.md)に置く。

## ノード一覧

<!-- graph:children:start -->
<!-- graph:children:end -->

## 追加するとき

```bash
python -m tools.graph new --type ddr --id DDR-0001 --title "..." --slug some-slug
```
