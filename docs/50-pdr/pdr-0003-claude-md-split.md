---
id: PDR-0003
type: pdr
title: ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す
status: stable
tags: [template]
decides:
  - UC-02
supersedes: []
related:
  - PDR-0002
  - PDR-0005
---

# ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す

- 日付: 2026-10-22
- 状態: stable

## 背景

graph側とCCGSの両方が、ルートに`CLAUDE.md`を持っている（setopic/game-template#1）。

graph側の`CLAUDE.md`は、「絶対に守ること」「issueとPR」「実装を書くときの決まり」など、リポジトリ全体の決まりを書いた共通ファイルである。`merge=ours`の指定が無く、`make update`でそのままmergeされる。

CCGSの`CLAUDE.md`は83行で、ほとんどが`@`による4つの読み込みである。読み込む先は、`.claude/docs/`の`directory-structure.md`、`coordination-rules.md`、`coding-standards.md`と、`docs/engine-reference/godot/VERSION.md`である。

Claude Codeは、`.claude/rules/`の下の`.md`を読む。`paths`の指定を持たないファイルは、セッションの初めに毎回読まれる。

## 決定

ルートの`CLAUDE.md`は、graphの共通ファイルのまま手を入れない。

CCGSのルートの`CLAUDE.md`の内容は、`.claude/rules/ccgs-studio.md`へ移す。`paths`の指定は持たせない。元の文から変えるのは、`@`の読み込みのパスだけにする。rulesのファイルの中の`@`は、そのファイルからの相対で解かれるので、`@../docs/`と`@../../docs/engine-reference/`の形にする。

`design/CLAUDE.md`、`src/CLAUDE.md`、`docs/CLAUDE.md`など、場所ごとの`CLAUDE.md`はCCGSのままにする。

## 理由

graph側の決まりはリポジトリ全体に当たるので、どこで作業しても読まれるルートに置く必要がある。ルートに手を入れなければ、graphの更新で競合しない。

rulesのファイルの中で`@`の読み込みが効くことは、2026-10-22に`claude -p`（Claude Codeの2.1.268）で確かめた。読み込む先の4つのファイルにしか無い文を、ツールを使わせずに答えさせ、4つとも正しく答えた。読み込まれた指示のファイルの一覧にも、4つが入っていた。比べるため、1行をルートからの相対（`@docs/engine-reference/godot/VERSION.md`）に変えると、その1つだけが読み込まれなかった。そのため、ルートの`CLAUDE.md`の末尾に`@`の行を足す案は使わない。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| ルートをCCGSにし、graphの決まりを`design/CLAUDE.md`に書く | `design/CLAUDE.md`は`design/`のファイルを扱うときにしか読まれない。issueとPRの流れなどの決まりが、`design/`の外の作業で読まれない。graphの更新のたびに、ルートの`CLAUDE.md`で競合する |
| ルートの`CLAUDE.md`の末尾に、CCGSの内容を読み込む`@`の行を足す | rulesのファイルの中で`@`が効いたので、要らない。足すと、graphが末尾を直したときに競合する |

## 影響

CCGSの更新でCCGSの`CLAUDE.md`が変わったら、`.claude/rules/ccgs-studio.md`へ手で写す（[UC-02](../30-usecases/uc-02-ccgs-upgrade.md)）。

CCGSには、ルートの`CLAUDE.md`を直接読み書きするものがある。`/setup-engine`は、ルートの`CLAUDE.md`の「Technology Stack」の節と、`ENGINE-REFERENCE-IMPORT`の印の付いた`@`の行を書き換える。`.claude/hooks/session-start.sh`は、ルートの`CLAUDE.md`の`@docs/engine-reference/<engine>/VERSION.md`の行から、読み込んでいるエンジンを読み取る。この形では、どちらも目当ての節と行を見つけられない。作品で`/setup-engine`を回すときは、書き換える先を`.claude/rules/ccgs-studio.md`に読み替える。`session-start.sh`の照合は、行が見つからないので何も出さない。この2つは、[PDR-0005](./pdr-0005-engine-import-in-rules.md)で`.claude/rules/`のファイルからも行を探す形に直した。

`docs/CLAUDE.md`は、CCGSのADRの書き方（`docs/architecture/`に、CCGSの雛形で置く）を案内している。graphで検証するADRは`docs/50-adr/`に置くので、ADRの置き場が2つになる。

## 見直しの条件

Claude Codeが、rulesのファイルの中の`@`を読み込まなくなったとき。CCGSが、ルートの`CLAUDE.md`を読み書きしない形に変わったとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`related`: 依存はしないが、一緒に読むべきノード

- [PDR-0002 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](./pdr-0002-ccgs-import.md)
- [PDR-0005 CCGSのsession-start.shとsetup-engineを、rulesのファイルから読み込みの行を探す形に直す](./pdr-0005-engine-import-in-rules.md)

`decides`: この決定が影響を与えるノード（ADR用）

- [UC-02 CCGSの更新を取り込む](../30-usecases/uc-02-ccgs-upgrade.md)

このノードを参照しているノード

- (related) [PDR-0002 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](./pdr-0002-ccgs-import.md)
- (related) [PDR-0005 CCGSのsession-start.shとsetup-engineを、rulesのファイルから読み込みの行を探す形に直す](./pdr-0005-engine-import-in-rules.md)

<!-- graph:auto:end -->
