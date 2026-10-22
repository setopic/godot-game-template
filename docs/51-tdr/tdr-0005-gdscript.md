---
id: TDR-0005
type: tdr
title: 言語をGDScriptにする
status: stable
tags: [engine]
decides:
  - UC-02
supersedes: []
related: []
---

# 言語をGDScriptにする

- 日付: 2026-10-22
- 状態: stable

## 背景

Godotでは、GDScriptとC#のどちらでもゲームを書ける。CCGSの`/setup-engine`は、Godotを選ぶと、GDScript、C#、両方の3つから言語を選ばせる。選んだ言語で、`.claude/rules/ccgs-studio.md`の「Technology Stack」、`.claude/docs/technical-preferences.md`の命名の決まりと専門のエージェントの割り振り、`project.yaml`の`engine.language`が決まる。

setopic/game-template#1の受け入れ条件は、`/setup-engine godot <版>`を実行し、言語をGDScriptにすることである。版は[TDR-0002](./tdr-0002-godot-version.md)で4.7.2に決めてある。

## 決定

game-templateの言語をGDScriptにする。`/setup-engine godot 4.7.2`のGDScriptの場合の値を、次のファイルに書く。

| ファイル | 書いたもの |
| --- | --- |
| `.claude/rules/ccgs-studio.md` | 「Technology Stack」のエンジン、言語、ビルド、素材の取り込み |
| `.claude/docs/technical-preferences.md` | エンジンと言語、GDScriptの命名の決まり、テストの道具（gdUnit4）、専門のエージェントの割り振り |
| `project.yaml` | `engine`、`specialists`、`naming`、`commands`の4つの節 |

`/setup-engine`は、ルートの`CLAUDE.md`の「Technology Stack」を書き換える前提で書かれている。[PDR-0004](../50-pdr/pdr-0004-claude-md-split.md)のとおり、書き換える先は`.claude/rules/ccgs-studio.md`に読み替えた。スキルの本体は書き換えない。

作品ごとに違う値は、決めずに`[TO BE CONFIGURED]`のまま残す。`engine.rendering`と`engine.physics`は、2Dか3Dかと、Webに出すかで決まる。`commands.build`は、作品の`export_presets.cfg`にある書き出しの設定の名前で決まる。`technical-preferences.md`の入力と対象の機種、性能の目安も、作品で決める。

## 理由

GDScriptは、Godotの中だけで書けて、別に.NET SDKを入れなくてよい。CCGSは、GDScriptを、Godotに組み込みで、最も早く試せる言語として挙げている。複数人で同じ環境をそろえるとき、入れる道具が少ないほうが、そろえる手間が少ない。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| C# | .NET SDKが要る。CCGSの説明では、C#はUnityから移る人と、IDEの補完を重く見る人に向く言語である。game-templateは、その事情を前提にしない |
| GDScriptとC#の両方 | CCGSの説明でも、上級者向けの組み方である。.NET SDKが要り、どの処理をどちらで書くかを毎回決めることになる |

## 影響

CCGSのエージェントは、`.gd`のファイルを`godot-gdscript-specialist`に回す。命名は、クラスがPascalCase、変数と関数がsnake_case、定数がSCREAMING_SNAKE（UPPER_SNAKE_CASE）になる。

作品は、`/settings`で`engine.rendering`、`engine.physics`、`commands.build`を決める。`project.godot`は、描画の方式が決まらないと書けないので、game-templateには置かない。作品で`/setup-engine`を回し直すか、Godotのエディタで作る。gdUnit4は、`/test-setup`で入れる（setopic/game-template#5）。

`.claude/docs/technical-preferences.md`は、CCGSの更新で`.claude/docs`ごと上書きされるので、取り込みのときに手で合わせる（[UC-02](../30-usecases/uc-02-ccgs-upgrade.md)）。

## 見直しの条件

C#でしか使えないライブラリが要る作品が出たとき。GDScriptでは処理が間に合わない部分があると分かったとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`decides`: この決定が影響を与えるノード（ADR用）

- [UC-02 CCGSの更新を取り込む](../30-usecases/uc-02-ccgs-upgrade.md)

<!-- graph:auto:end -->
