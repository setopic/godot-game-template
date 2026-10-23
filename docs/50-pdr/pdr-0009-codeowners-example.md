---
id: PDR-0009
type: pdr
title: CODEOWNERSは雛形として配り、作品が担当者を入れる
status: stable
tags: [template, team]
decides: []
supersedes: []
related: []
---

# CODEOWNERSは雛形として配り、作品が担当者を入れる

- 日付: 2026-10-23
- 状態: stable

## 背景

CCGSは、1つのセッションを1つのスタジオにする作りで、1人がClaudeを何体も使う前提である。graph-project-templateの開発の流れ（[META-05](../00-meta/dev-flow.md)）も、1人で開発し、mainへ直接pushしてよい前提である。どちらにも、複数人で開発するときの持ち主の分け方が無い（setopic/game-template#4）。

GitHubは、`.github/CODEOWNERS`に書いたパスと持ち主を読み、そのパスを変えるPRに持ち主をレビュアーとして付ける。持ち主にはGitHubのユーザーかチームの名前を書く。担当者の名前は作品ごとに違う。

`.tscn`はテキストだが、同じシーンを2人が同時に直すと、結合がとても難しくなる。`project.godot`には入力の設定とautoloadが集まっているので、競合しやすい。

## 決定

テンプレートの層では、本物の`.github/CODEOWNERS`を配らない。分け方と役割の名前を書いた`.github/CODEOWNERS.example`を配る。役割の名前は`@<企画のリード>`のように書き、GitHubのユーザーの名前にならない形にする。作品は、この雛形を`.github/CODEOWNERS`に写し、役割の名前を担当者の名前に置き換える。

分け方は次のとおりにする。

| パス | 持ち主 |
| --- | --- |
| `design/concept/`、`design/gdd/`、`docs/53-ddr/` | 企画のリード |
| `src/core/`、`src/networking/`、`addons/`、`docs/52-adr/` | プログラムのリード |
| `assets/` | アートのリード |
| `project.godot`、`export_presets.cfg`、`CLAUDE.md`、`project.yaml`、`.claude/`、`design/registry/`、`docs/50-pdr/`、`docs/51-tdr/`、`graph.toml`、`tools/` | テンプレートの管理者 |

決定の記録の置き場は、記録の種別を決める人に持たせる。ゲームデザインの決定（DDR）は企画のリード、ゲームの中の構成の決定（ADR）はプログラムのリードが持つ。開発の進め方の決定（PDR）と、ゲームの外の技術の決定（TDR）は、テンプレートの管理者が持つ。

シーンの担当は、そのシーンを直すissueの担当者が、そのissueが開いている間だけ持つ。同じシーンを直すissueを、同時に2つ開かない。`project.godot`は、テンプレートの管理者だけが直す。

`.github/CODEOWNERS.example`は、`.gitattributes`で`merge=ours`にしない。作品はこのファイルを書き換えず、写した`.github/CODEOWNERS`を書き換えるので、取り込みで競合しない。テンプレートが分け方を変えたときに、作品へ届くほうを取る。

複数人で開発するときの手順（mainの保護、ストーリーとissueとPRの対応、PRの本文に書くこと）は、[META-05](../00-meta/dev-flow.md)の「複数人で開発するとき」に書く。

## 理由

担当者の名前は作品にしか分からないので、テンプレートが配れるのは分け方までである。分け方は、どの作品でもCCGSのフォルダの構成とgraphの決定の記録の置き場で決まるので、テンプレートが書いておけば作品ごとに考え直さずに済む。

シーンは、担当をファイルに書いて固定すると、人の入れ替わりのたびにCODEOWNERSを直すことになる。直す作業はissueで始まるので、issueの担当者をシーンの担当にすれば、別に記録を持たずに済む。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| テンプレートの層で本物の`.github/CODEOWNERS`を配る | 担当者の名前が作品ごとに違う。役割の名前のままでは、GitHubが知らない持ち主としてエラーにする。作品が書き換えると、取り込みのたびに競合する |
| テンプレートは何も配らず、作品だけでCODEOWNERSを書く | 分け方が作品ごとにばらつく。決定の記録の置き場や`project.godot`のように、どの作品でも同じ持ち主になるものまで、作品ごとに考え直すことになる |
| `.tscn`をGit LFSの`lockable`にして、編集の前にロックする | `.tscn`はテキストのまま差分を見ると決めている（[TDR-0003](../51-tdr/tdr-0003-godot-git-settings.md)）。LFSに入れると、レビューで差分が読めなくなる |

## 影響

テンプレートの層に`.github/CODEOWNERS.example`が増える。GitHubはこのファイルを読まないので、game-template自身のPRにはレビュアーが付かない。

1人で開発する作品は、`.github/CODEOWNERS`を作らなくてよい。

## 見直しの条件

CCGSのフォルダの構成や、決定の記録の置き場が変わったとき。シーンの担当をissueで持つやり方で、同じシーンの競合が減らないとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

_まだリンクが無い。孤立ノードのままにしないこと。_

<!-- graph:auto:end -->
