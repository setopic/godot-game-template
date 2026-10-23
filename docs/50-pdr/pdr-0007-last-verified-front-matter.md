---
id: PDR-0007
type: pdr
title: TDRとADRの最終確認日をフロントマターに持つ
status: stable
tags: [template]
depends_on:
  - PDR-0006
decides: []
supersedes: []
related: []
---

# TDRとADRの最終確認日をフロントマターに持つ

- 日付: 2026-10-23
- 状態: stable

## 背景

[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)の決定の4で、TDRとADRの本文の節を、CCGSのADRの雛形の節を1対1で日本語にしたものにした。CCGSのLast Verifiedは、本文の「最終確認日」の節になった。0.7.0で、`graph.toml`の`tdr`と`adr`の`required_sections`を、この16節にした。

最終確認日は、いまのエンジンの版と設計に照らして、正しいと最後に確かめた日である。読み直して確かめたら、何も変わらなくても更新する。CCGSの`/create-stories`は、ストーリーの`ADR Version`に最終確認日（無ければ日付）を写す。`/dev-story`は、ストーリーの`ADR Version`と記録のいまの版を比べ、違えば記録を読み直す。

一方で、確定した記録（`stable`）の本文は書き換えない（ルートの`CLAUDE.md`の「確定したADRは不変の記録である」）。最終確認日が本文の節にあると、確定した記録を確かめ直しても、その日を書けない（setopic/game-template#24）。

## 決定

TDRとADRの最終確認日は、本文の「最終確認日」の節をやめ、フロントマターの`last_verified`に持つ。値は`YYYY-MM-DD`の日付で、まだ確かめていない記録では空にする。

確定した記録を書き換えない決まりは、本文のものである。そのため、`stable`のTDRやADRでも、フロントマターの`last_verified`は更新してよい。更新してよいのは`last_verified`だけで、本文は変えない。状態を本文ではなくフロントマターの`status`に持つのと同じ形である。

[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)は置き換えない。[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)の決定のうち、この記録が改めるのは、決定の4の対応の表の「Last Verified」の行（本文の「最終確認日」の節）だけである。ほかの決定と、決定の4のほかの節と状態の扱いは、そのまま生きている。そのため、この記録は[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)を`supersedes`ではなく`depends_on`で指す。

これに合わせて、次のものを直す。

| 直すもの | 中身 |
| --- | --- |
| `graph.toml`の`tdr`と`adr`の`required_sections` | 「最終確認日」を外し、15節にする |
| `docs/00-meta/templates/tdr.md`と`adr.md` | 「最終確認日」の節を外し、フロントマターに`last_verified:`を足す。書き方は雛形の注記で説明する |
| TDR-0001とTDR-0002 | 「なし」と書いた「最終確認日」の節を消す。`last_verified`は書かない（確かめていないため） |
| 最終確認日を読み書きするCCGSのスクリプトとスキル | フロントマターの`last_verified`を読み書きする |

`adr-status.sh`の`last_verified`の列は、フロントマターの`last_verified`の日付を出す。`version`の列は、これまでどおり`last_verified`、無ければ日付、無ければ`unversioned`である。

GDDの`Last Verified`は、GDDのものなので変えない。

## 理由

最終確認日は、記録の中身ではなく、記録をいつ確かめたかの印である。確かめ直しても決定は変わらないので、確定した記録の本文を変えない決まりとぶつけずに書ける場所に置く。状態を`status`に持つのと同じ理由で、フロントマターに持てば、本文を変えずに更新できる。

graphのツールは、フロントマターの知らないキーを受け付ける。`last_verified`を足しても`check --strict`は通るので、上流（`graph-doc-template`）の道具を直さずに済む。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| 本文の「最終確認日」の節に残し、この節だけは確定した記録でも直してよいという例外にする | 本文を変えない決まりに、節ごとの例外ができる。例外を知らない人やスキルは、確定した記録の本文を直してよいのかを、節ごとに判断することになる |
| 最終確認日をやめ、日付だけで版を決める | 確定した記録を確かめ直したことを、記録に残せない。エンジンの版を上げて確かめ直しても、ストーリーの`ADR Version`と比べる日付が変わらない |

## 影響

TDRとADRの必須の節は15になる。派生プロジェクトが自分で書いたTDRとADRに「最終確認日」の節があれば、その日付をフロントマターの`last_verified`に移し、節を消す。移さなくても`check`は通る。ただし、`adr-status.sh`が節の日付を読まなくなり、記録の版は日付で決まる。`/architecture-decision retrofit`は、この節を見つけたら`last_verified`に移す。

`last_verified`を更新すると、それより前に書いたストーリーで、`/dev-story`が版の食い違いを出す。確かめ直した記録をプログラマーが読み直すための動きなので、そのままにする。

## 見直しの条件

graphのツールが、フロントマターの知らないキーを拒むようになったとき。CCGSが、Last Verifiedを本文の外に持つ形に変えたとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`depends_on`: この文書が成立するために前提となるノード

- [PDR-0006 CCGSを丸ごと取り込み、決定の記録を4つの種別に分ける](./pdr-0006-ccgs-whole-import-dr-types.md)

<!-- graph:auto:end -->
