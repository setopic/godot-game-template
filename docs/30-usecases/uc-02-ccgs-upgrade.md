---
id: UC-02
type: usecase
title: CCGSの更新を取り込む
status: review
tags: [template]
depends_on: []
related: []
---

# CCGSの更新を取り込む

## 概要

| 項目 | 内容 |
| --- | --- |
| 実行者 | game-templateを保守する人 |
| きっかけ | CCGS（Claude-Code-Game-Studios）が新しい版を出したとき。セッションの開始のときに、CCGSの`update-check.sh`が新しい版を知らせる |
| 完了したときに得られる状態 | CCGSの新しい版のファイルが、game-templateに入っている。graph側のファイルと、この層で手を入れたファイルは残っている |
| 影響 | 作業はブランチで行うので、mainは止まらない。作品へは、game-templateをマージした後に`make update`で届く |

CCGSは、[ADR-0003](../50-adr/adr-0003-ccgs-import.md)のとおり、選んだパスだけを`git checkout`で写して取り込む（CCGSの`UPGRADING.md`のStrategy A2）。履歴が共通でないので、`git merge`は使わない。

## 事前条件

- [ ] remoteの`ccgs`がある（`git remote -v`）。無ければ`git remote add ccgs https://github.com/Donchitos/Claude-Code-Game-Studios.git`で足す
- [ ] いま入っているCCGSの版が分かる。`CHANGELOG.md`の最初の`## [`の見出しが、その版である（`grep -m1 '^## \[' CHANGELOG.md`）
- [ ] 作業ツリーに、コミットしていない変更が無い

## 手順

1. CCGSを取ってきて、新しい版の`UPGRADING.md`の、いまの版から新しい版までの節を読む。手で合わせるファイル（Merge Carefully）の指示は、手順5で使う。

   ```bash
   git fetch --tags ccgs main
   git show ccgs/main:UPGRADING.md
   ```

2. ブランチを切る。

   ```bash
   git switch -c chore/ccgs-<新しい版>
   ```

3. CCGSで消えたファイルを調べて、こちらでも消す。`git checkout`は、写すだけで消さないからである。`<いまの版>`には、`v1.2.0`のようなCCGSのタグを入れる。

   ```bash
   git diff --name-status --diff-filter=DR v<いまの版> ccgs/main
   ```

4. 上書きしてよいパスを写す。

   ```bash
   git checkout ccgs/main -- .claude/agents .claude/skills .claude/hooks .claude/scripts .claude/docs .claude/rules .claude/statusline.sh docs/engine-reference docs/WORKFLOW-GUIDE.md docs/COLLABORATIVE-DESIGN-PRINCIPLE.md docs/skill-flow-diagrams.md docs/migration-guide-v1.1.md docs/CLAUDE.md design/CLAUDE.md src/CLAUDE.md studio-tests/CLAUDE.md studio-tests production/.gdignore .worktreeinclude UPGRADING.md CHANGELOG.md
   git show ccgs/main:LICENSE > LICENSE-CCGS
   git checkout HEAD -- .claude/docs/technical-preferences.md
   ```

   2行目は、CCGSの`LICENSE`を`LICENSE-CCGS`に写す。graph側の`LICENSE`は写さない。3行目は、1行目で上書きした`technical-preferences.md`を、この層で書いたものに戻す。このファイルには、`/setup-engine`の値を書いてある（[ADR-0005](../50-adr/adr-0005-gdscript.md)）。

   CCGSの版に、上の一覧に無い新しいパスがあれば、`UPGRADING.md`の「Safe to Overwrite」で確かめてから足す。

5. 手で合わせるファイルを、1つずつ合わせる。CCGSの側の差は、`git diff v<いまの版> ccgs/main -- <CCGSのパス>`で見る。

   | このリポジトリのファイル | 比べるCCGSのファイル | 合わせ方 |
   | --- | --- | --- |
   | `.claude/rules/ccgs-studio.md` | `CLAUDE.md` | CCGSの差を写す。`@`のパスは、このファイルからの相対（`@../docs/`、`@../../docs/`）に直す（[ADR-0004](../50-adr/adr-0004-claude-md-split.md)） |
   | `.claude/settings.json` | `.claude/settings.json` | この層で手を入れていなければ、CCGSのもので上書きする。入れていれば、`UPGRADING.md`のMerge Carefullyの指示に従う |
   | `project.yaml` | `project.yaml` | CCGSの差を写す。`framework.version`を新しい版にする |
   | `.claude/docs/technical-preferences.md` | 同じパス | CCGSの差のうち、節や項目の増減を写す。`/setup-engine`で書いた値は残す |
   | `.gitattributes` | `.gitattributes` | CCGSで増えた行を、末尾のCCGSの節に足す |
   | `.gitignore` | `.gitignore` | CCGSで増えた行のうち、要るものを足す |
   | `docs/architecture/`、`docs/registry/`、`design/registry/` | 同じパス | 作品が書き足すファイルである。この層では手を入れていないので、CCGSのもので上書きしてよい |

6. 写さないファイルが入っていないことを確かめる。CCGSの`README.md`、`CONTRIBUTING.md`、ルートの`CLAUDE.md`、`SECURITY.md`、`.github/`の下のファイルは入れない（[ADR-0003](../50-adr/adr-0003-ccgs-import.md)）。

   ```bash
   git status --short
   ```

7. 検証する。

   ```bash
   make check
   python -m unittest discover -s tests -t .
   ```

8. `GAME_TEMPLATE_CHANGELOG.md`に項目を足し、`tools/graph/layers/game-template.toml`の`version`を上げて、PRにする。

## 順序の制約

| 制約 | 理由 |
| --- | --- |
| 1 → 3 | 手順3で使う`v<いまの版>`のタグは、手順1の`git fetch --tags`で取ってくる |
| 3 → 4 | 手順4のあとでは、`CHANGELOG.md`がもう新しい版になっていて、いまの版が分からなくなる。手順3でいまの版を使い終えてから写す |
| 4 → 5 | 手順4は`.claude/docs`ごと写し、`technical-preferences.md`をコミットした状態に戻す。手順5で合わせた変更を先に作ると、手順4で消える |
| `.claude/hooks`と`.claude/scripts`は同じ手順で写す | フックが`.claude/scripts/`の補助を呼ぶ。片方だけ新しいと、フックが動かなくなる（CCGSの`UPGRADING.md`の1.2.0の節） |
| 手順6と7は、どちらからでもよい | 互いに結果を使わない |

## つまずきやすい点

| 症状 | 原因 | 対処 |
| --- | --- | --- |
| `fatal: refusing to merge unrelated histories` | `git merge ccgs/main`を使った | mergeを取り消し、手順4の`git checkout`で写す |
| `check`が`docs/`のCCGSの文書で`G001`を出す | CCGSの`docs/`の文書は、フロントマターを持たない | `graph.toml`の`exclude`に、そのパスが入っているかを確かめる（[ADR-0003](../50-adr/adr-0003-ccgs-import.md)） |
| セッションの初めに、CCGSの読み込んだ文書の中身が出てこない | `.claude/rules/ccgs-studio.md`の`@`のパスが、ルートからの相対になっている | `@../docs/`、`@../../docs/`の形に直す |
| graph側の`.claude/skills/`（`grill`、`lean`、`yomiyasu`）が変わった | CCGSが同じ名前のスキルを配り始めた | `git checkout HEAD -- .claude/skills/<名前>`で戻し、どちらを残すかを決める |

## 完了の確認

- [ ] `grep -m1 '^## \[' CHANGELOG.md`が、新しい版を出す
- [ ] `project.yaml`の`framework.version`が、新しい版である
- [ ] `git status --short`に、手順6で挙げた写さないファイルが無い
- [ ] `claude -p`で`/start`を回し、最初の問いが返る

## 切り戻し

コミットする前なら、`git switch main`の前に、ブランチの変更を捨てれば戻る。マージした後なら、そのPRのマージコミットを`git revert`で戻す。作品が`make update`で取り込んだ後は、作品の側でも同じ取り消しが要る。

## 未確認

この手順は、CCGSの1.2.0を最初に取り込んだときの手順から書いたもので、版を上げる取り込みはまだ試していない。手順3で消えたファイルを消すとき、作品の側に`make update`で消えたことが届くかは確かめていない。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

このノードを参照しているノード

- (decides) [ADR-0003 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](../50-adr/adr-0003-ccgs-import.md)
- (decides) [ADR-0004 ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す](../50-adr/adr-0004-claude-md-split.md)
- (decides) [ADR-0005 言語をGDScriptにする](../50-adr/adr-0005-gdscript.md)

<!-- graph:auto:end -->
