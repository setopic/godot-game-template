---
id: PDR-0014
type: pdr
title: この層の共通ファイルを、作品が書き換えないものに限る
status: stable
tags: [template]
depends_on:
  - PDR-0006
decides: []
supersedes: []
related: []
---

# この層の共通ファイルを、作品が書き換えないものに限る

- 日付: 2026-10-23
- 状態: stable

## 背景

[META-08](../00-meta/template-upgrade.md)は、共通ファイルを、テンプレートと作品で中身が同じで、作品が書き換えないファイルと決めている。上の層のテンプレートから作った作品は、初回の取り込みで、その層が足した共通ファイルも上書きする。どれを足したかは、その層のREADMEに書く。

game-templateは、CCGSを丸ごと取り込み（[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)）、`.claude/`・`studio-tests/`・`docs/engine-reference/`などを足した。しかし、どれがこの層の共通ファイルかは、どの文書にも決めていなかった。READMEも、下の層のgraph-project-templateの説明のままだった（setopic/game-template#40）。PDR-0002の「写さなかったもの」の表は、`README.md`を「graphの共通ファイルである」としていたが、`README.md`は`merge=ours`で、共通ファイルではない。

CCGSのスキルは、作品の中で次のファイルを書き換える。

| ファイル | 書き換えるスキル |
| --- | --- |
| `project.yaml` | `/setup-engine`、`/start`、`/gate-check`、`/settings`など |
| `.claude/docs/technical-preferences.md` | `/setup-engine` |
| `.claude/rules/ccgs-studio.md`のエンジンの読み込みの行 | `/setup-engine` |
| `docs/engine-reference/<engine>/`の`VERSION.md`とその隣の文書 | `/setup-engine` |
| `.claude/skills/<名前>/SKILL.md` | `/skill-improve` |
| `studio-tests/catalog.yaml`、`studio-tests/results/` | `/skill-test` |
| `docs/architecture/`、`docs/registry/`、`design/registry/` | `/create-architecture`、`/architecture-review`、`/architecture-decision`、`/design-system`など |

## 決定

この層の共通ファイルは、次のとおりにする。

| 共通ファイル | 中身 |
| --- | --- |
| `.claude/`（`.claude/docs/technical-preferences.md`を除く） | CCGSのエージェント・スキル・フック・スクリプト・決まり・案内 |
| `studio-tests/` | スキルとエージェントのテスト |
| `docs/engine-reference/` | エンジンのAPIの資料 |
| `docs/CLAUDE.md`、`docs/WORKFLOW-GUIDE.md`、`docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`、`docs/skill-flow-diagrams.md`、`docs/migration-guide-v1.1.md` | CCGSの案内の文書 |
| `design/CLAUDE.md`、`src/CLAUDE.md` | 場所ごとの決まり |
| `src/qa/` | スクリーンショットの証拠を撮るautoload（[ADR-0001](../52-adr/adr-0001-evidence-capture-autoload.md)） |
| `scripts/` | `make ci`が使うスクリプト |
| 各フォルダの`.gdignore` | Godotに読み込ませないフォルダの印（[TDR-0003](../51-tdr/tdr-0003-godot-git-settings.md)） |
| `.github/CODEOWNERS.example` | CODEOWNERSの雛形（[PDR-0009](./pdr-0009-codeowners-example.md)） |
| `GAME_TEMPLATE_CHANGELOG.md` | この層の変更履歴 |
| `LICENSE-CCGS`、`UPGRADING.md`、`CHANGELOG.md` | CCGSのライセンス、更新の手順、変更履歴 |

次のものは、作品のものとし、作品が書き換えてよい。

| 作品のもの | 書き換える理由 |
| --- | --- |
| `project.yaml`、`.claude/docs/technical-preferences.md` | 作品の設定である。`technical-preferences.md`は、`project.yaml`に無い値を読むときの予備である |
| `docs/architecture/`、`docs/registry/`、`design/registry/` | スキルが作品の中身を書く |
| `graph.toml`、`graph.mk`、`docs/templates/` | 作品が、語彙・図の描き方・記録の書式を合わせる |
| ノード本体 | 作品の文書である |

`/setup-engine`と`/skill-improve`が書き換える共通ファイルは、テンプレートの側で直す。エンジンの版は、この層の[TDR-0001](../51-tdr/tdr-0001-godot-version.md)が決めていて、作品も同じ版を使う。版を上げるときは、テンプレートで`/setup-engine`を回し、取り込みで作品へ届ける。作品だけでエンジンの版を上げるなら、その作品では`docs/engine-reference/`と`.claude/rules/ccgs-studio.md`を作品のものとして扱い、取り込みのときに手で合わせる。

`README.md`は、ほかの層と同じく先頭にこの層の説明を足し、その下に下の層の説明を残す。この層の説明には、足したもの・共通ファイル・取り込みの例外を書く。

## 理由

共通ファイルを作品が書き換えると、取り込みのたびに競合し、作品の変更とテンプレートの変更を手で合わせることになる。CCGSの`.claude/`は400個余りのファイルがあるので、共通にしないと、取り込みのたびにその全部を見比べることになる。

`docs/engine-reference/`と`.claude/rules/ccgs-studio.md`は`/setup-engine`が書き換えるが、エンジンの版はこの層で決めている。テンプレートで書き換えれば、新しい版の資料が作品にも届く。

`studio-tests/`は、スキルとエージェントそのもののテストである。スキルの改善をテンプレートの側で行うので、作品で`/skill-test`を回す場面は無い。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| `.claude/`を共通ファイルにしない | 取り込みのたびに、400個余りのファイルを手で合わせることになる |
| `docs/engine-reference/`を作品のものにし、作品ごとに`/setup-engine`で版を固定する | テンプレートが直した資料（新しい版の変更点など）が、作品に届かなくなる |
| `studio-tests/`を作品のものにする | テンプレートが足したテストが届かなくなる。作品でスキルを改善しないので、作品にテストの結果を残す場面も無い |
| READMEを、下の層の説明も含めて1つの説明に書き直す | 下の層のREADMEが変わったときに見比べにくくなる。ほかの層は、先頭に自分の説明を足している |

## 影響

game-templateから作った作品は、初回の取り込みで、META-08とgraph-project-templateの一覧に加えて、この層の共通ファイルを上書きする。READMEの「テンプレートの更新を取り込む」に、この層の共通ファイルとupstreamのURLを書く。

作品のもののうち、`project.yaml`・`graph.toml`・`graph.mk`は`merge=ours`になっていないので、取り込みで競合することがある。この扱いはsetopic/game-template#43で決める。

## 見直しの条件

作品で、共通ファイルを書き換えることが続くとき。CCGSの更新で、作品の中で書き換えるファイルが増えたとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`depends_on`: この文書が成立するために前提となるノード

- [PDR-0006 CCGSを丸ごと取り込み、決定の記録を4つの種別に分ける](./pdr-0006-ccgs-whole-import-dr-types.md)

このノードを参照しているノード

- (depends_on) [PDR-0015 作品が書き換えるこの層のファイルも、merge=oursにしない](./pdr-0015-no-merge-ours-project-files.md)

<!-- graph:auto:end -->
