---
id: ARCH-03
type: architecture
title: CCGSの7段階に沿った開発の流れ
status: stable
tags: [flow]
depends_on: []
related: []
---

# CCGSの7段階に沿った開発の流れ

## 解決したい構造上の問題

ゲームを作る段階と、段階ごとにすることと、次へ進む条件を決める。一般的なゲーム会社の8段階（企画、プロトタイプ作成、プリプロダクション、本制作、テスト・調整、発売準備、リリース、運営・アップデート）は、人数の多いチームで手戻りを減らすための作りである。Claudeと少人数で作るときは、そのままでは進めにくい。

CCGSは、段階を7つに分け、段階の間に関門（`/gate-check`）を置いている。段階ごとの手順と関門の中身は、CCGSのスキルとファイルが持っている。

## 構成

段階は、CCGSの7段階をそのまま使う。今の段階は、`project.yaml`の`project.stage`に記録する。`/gate-check`が関門を通ったときに、人の承認を得て書き換える（`.claude/scripts/set-stage.sh`）。

段階ごとにすることは、`.claude/docs/workflow-catalog.yaml`の`phases`の各段階の`steps`にある。次へ進む条件は、`/gate-check`の各関門の定義（`.claude/skills/gate-check/references/gate-*.md`）にある。どちらもこの文書に写さない。

| 段階（`project.stage`） | すること（`workflow-catalog.yaml`の`phases`） | 次へ進む関門 |
| --- | --- | --- |
| Concept | `concept`。発想、エンジンの設定、企画書、コンセプトのレビュー、アートの指針、システムの一覧 | `gate-systems-design.md` |
| Systems Design | `systems-design`。システムごとのGDD、そのレビュー、GDDどうしの突き合わせ | `gate-technical-setup.md` |
| Technical Setup | `technical-setup`。アーキテクチャの文書、TDRとADR、その見直し、テストの枠組み | `gate-pre-production.md` |
| Pre-Production | `pre-production`。素材と画面の一覧と仕様、プロトタイプ、エピックとストーリー、最初のスプリント、バーティカルスライス | `gate-production.md` |
| Production | `production`。スプリントごとにストーリーを作って閉じる | `gate-polish.md` |
| Polish | `polish`。性能、バランス、素材の確認、プレイテスト、仕上げ、リリースの確認 | `gate-release.md` |
| Release | `release`。発売の確認と、リリースの段取り | 無い。アップデートはProductionに戻る |

### 8段階との対応

| 8段階 | CCGSの段階 |
| --- | --- |
| 1. 企画 | Concept |
| 2. プロトタイプ作成 | `/prototype`。GDDを書く前に回すスキルで、`workflow-catalog.yaml`ではPre-Productionの手順に載っている |
| 3. プリプロダクション（設計） | Systems Design、Technical Setup、Pre-Production |
| 4. 本制作 | Production |
| 5. テスト・調整 | Productionの中のストーリーごとの確認と、Polish |
| 6. 発売準備 | Polish（`/release-checklist`）と、Release（`/launch-checklist`） |
| 7. リリース | Release |
| 8. 運営・アップデート | Releaseのあと、Productionに戻ってくり返す |

### Claudeと作るときの3つの変更点

1つめは、段階を一方通行にせず、小さくくり返すことである。Claudeはコードを書くのが速く、作り直しの手間が小さい。プロトタイプを早く何回も作り、面白さを最初に確かめる。Productionでは、ストーリーごとに`/dev-story`で作り、`/story-done`で証拠を確かめて閉じる。本制作とテスト・調整は、このくり返しの中で行き来する。リリースしたあとにアップデートを作るときは、人の承認を得て`project.stage`をProductionに戻し（`bash .claude/scripts/set-stage.sh "Production"`）、このくり返しに戻る。

2つめは、設計をClaudeが読む文書として残すことである。Claudeは前の会話を覚えていない。企画書は`.claude/docs/templates/game-concept.md`の雛形で`design/gdd/game-concept.md`に、システムごとの仕様書は`.claude/docs/templates/game-design-document.md`の雛形で`design/gdd/`に書く。技術・フォルダの構成・書き方の決まりは`CLAUDE.md`と`.claude/`に、決定の経緯はPDR・TDR・ADR・DDRに残す。

3つめは、人にしかできない判断の場面で、Claudeが止まって聞くことである。止まる場面は、下の「人が判断する場面」にある。この決まりは、`.claude/rules/ccgs-studio.md`の「Collaboration Protocol」にも書いてある。

### 人が判断する場面

| 判断 | 段階と関門 | 関門の定義にあるか |
| --- | --- | --- |
| 面白いか（中心の仕組みが楽しいか、人が通して遊んだか） | Pre-Production → Productionの関門 | ある（`gate-production.md`の「Core loop fun is validated」など） |
| 企画の面白さの仮説が確かめられたか、プレイテストで見つかった面白さの問題に手を打ったか | Production → Polishの関門 | ある（`gate-polish.md`） |
| ストアへの登録、規約への同意、価格の決定 | Releaseの段階。関門は無い | 無い。`gate-release.md`はストアの情報の用意を見るだけである |
| 公開するかどうか | Releaseの段階。関門は無い | 無い |

関門の定義にある判断では、`/gate-check`が人の答えかプレイテストの記録で確かめ、確かめられなければ関門を通さない。関門の定義に無い判断では、Claudeは自分で行わず、その場で止まって人に聞く。

## 境界

段階を書き換えるのは、`/gate-check`の関門を通ったときと、アップデートのためにProductionに戻すときだけである。どちらも人の承認を得てから書く。

段階ごとの手順と関門の中身は、CCGSの側にある。この文書は、どこを見ればよいかと、CCGSに無い人の判断の場面だけを持つ。

## 前提と制約

CCGSの段階の名前、`workflow-catalog.yaml`の`phases`、`/gate-check`の関門の定義のファイル名が変わったら、この文書を直す。この文書は依存を持たないので、`G015`が挙げない。CCGSを取り込んだときに、手で確かめる。

## 未決事項

無い。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

このノードを参照しているノード

- (decides) [PDR-0010 開発の段階はCCGSの7段階をそのまま使う](../50-pdr/pdr-0010-ccgs-seven-stages.md)

<!-- graph:auto:end -->
