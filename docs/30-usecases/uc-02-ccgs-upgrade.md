---
id: UC-02
type: usecase
title: CCGSの更新を取り込む
status: review
tags: [template]
depends_on:
  - PDR-0006
related: []
---

# CCGSの更新を取り込む

## 概要

| 項目 | 内容 |
| --- | --- |
| 実行者 | game-templateを保守する人 |
| きっかけ | CCGS（Claude-Code-Game-Studios）が新しい版を出したとき。セッションの開始のときに、CCGSの`update-check.sh`が新しい版を知らせる |
| 完了したときに得られる状態 | CCGSの新しい版の変更が、game-templateに入っている。graph側のファイルと、この層でCCGSのファイルを直した箇所は残っている |
| 影響 | 作業はブランチで行うので、mainは止まらない。作品へは、game-templateをマージした後に`make update`で届く |

CCGSは、[PDR-0006](../50-pdr/pdr-0006-ccgs-whole-import-dr-types.md)のとおり丸ごと取り込み、更新は中身を読んで取り入れる。この層で直したCCGSのファイルの一覧は、手で持たない。いまの版のCCGSと手元を`git diff`で比べて見分ける。履歴が共通でないので、`git merge`は使わない。

## 事前条件

- [ ] remoteの`ccgs`がある（`git remote -v`）。無ければ`git remote add ccgs https://github.com/Donchitos/Claude-Code-Game-Studios.git`で足す
- [ ] いま入っているCCGSの版が分かる。`CHANGELOG.md`の最初の`## [`の見出しが、その版である（`grep -m1 '^## \[' CHANGELOG.md`）
- [ ] 作業ツリーに、コミットしていない変更が無い

## 手順

1. CCGSを取ってきて、新しい版の`UPGRADING.md`の、いまの版から新しい版までの節を読む。手で合わせるファイル（Merge Carefully）の指示は、手順4で使う。

   ```bash
   git fetch --tags ccgs main
   git show ccgs/main:UPGRADING.md
   ```

2. ブランチを切る。

   ```bash
   git switch -c chore/ccgs-<新しい版>
   ```

3. CCGSで変わったファイルを、手元で直したかどうかで分ける。`<いまの版>`には、`1.2.0`のようなCCGSの版を入れる。CCGSのタグは`v1.2.0`の形である。

   ```bash
   v=v<いまの版>
   git diff --name-only --no-renames "$v" ccgs/main -- . ':!README.md' ':!CONTRIBUTING.md' ':!CLAUDE.md' ':!SECURITY.md' ':!LICENSE' ':!.github' |
   while read -r f; do
     if ! git diff --quiet "$v" HEAD -- "$f"; then
       echo "手で合わせる: $f"
     elif git cat-file -e "ccgs/main:$f" 2>/dev/null; then
       git checkout ccgs/main -- "$f"
     else
       git rm -q -- "$f"
     fi
   done
   ```

   1行目の`git diff`は、いまの版から新しい版までにCCGSで変わったファイルを挙げる。`--no-renames`を付けているので、名前が変わったファイルは、消えたファイルと増えたファイルとして出る。`.github/`などのパスを外す理由は、手順5にある。

   ループは、挙がったファイルごとに、いまの版のCCGSと手元（`HEAD`）を比べる。差が無いファイルは、手元で直していない。新しい版にあれば`git checkout`で写し、新しい版で消えていれば`git rm`で消す。差があるファイルは、手元で直したか、graph側に同じパスのファイルがある。写さずに「手で合わせる」として名前を出す。

4. 手順3で「手で合わせる」と出たファイルを、1つずつ合わせる。CCGSの差は`git diff v<いまの版> ccgs/main -- <ファイル>`で、手元で直した箇所は`git diff v<いまの版> HEAD -- <ファイル>`で見る。CCGSの差を手元のファイルに写し、手元で直した箇所は残す。直した理由は、直した箇所の注記（`game-template (PDR-0005)`など）と、`git log -- <ファイル>`で分かる。

   `.gitignore`は、CCGSの差のうち、エンジンの節（`# === Engine: Godot ===`・`Unity`・`Unreal`）の変更は写さず、それ以外の節の変更を、この層のCCGSの節に写す（[PDR-0011](../50-pdr/pdr-0011-ccgs-gitignore.md)）。Godotの節の変更は、[TDR-0003](../51-tdr/tdr-0003-godot-git-settings.md)と食い違わないかを見てから、この層のGodotの節に入れるかを決める。

   CCGSの`UPGRADING.md`にMerge Carefullyの指示があるファイルは、その指示にも従う。`project.yaml`は、`framework.version`を新しい版にする。

5. 手順3で外したパスのうち、CCGSで変わったものを合わせる。手順3で外すのは、graph側に同じパスのファイルがあり、CCGSのものを入れないファイルである（[PDR-0006](../50-pdr/pdr-0006-ccgs-whole-import-dr-types.md)が引き継いだ、写さなかったものの表）。

   ```bash
   git diff --name-only v<いまの版> ccgs/main -- README.md CONTRIBUTING.md CLAUDE.md SECURITY.md LICENSE .github
   ```

   | CCGSのファイル | 合わせ方 |
   | --- | --- |
   | `CLAUDE.md` | CCGSの差を、`.claude/rules/ccgs-studio.md`に写す。`@`のパスは、このファイルからの相対（`@../docs/`、`@../../docs/`）に直す（[PDR-0003](../50-pdr/pdr-0003-claude-md-split.md)） |
   | `LICENSE` | `git show ccgs/main:LICENSE > LICENSE-CCGS`で写す。graph側の`LICENSE`は変えない |
   | `README.md`、`CONTRIBUTING.md`、`SECURITY.md`、`.github/`の下のファイル | 入れない |

6. 写さないファイルが入っていないことを確かめる。

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
| 事前条件 → 3 | 手順3のあとでは、`CHANGELOG.md`がもう新しい版になっていて、いまの版が分からなくなる。いまの版は、手順3より前に確かめておく |
| `.claude/hooks`と`.claude/scripts`は、同じPRでそろえる | フックが`.claude/scripts/`の補助を呼ぶ。片方だけ新しいと、フックが動かなくなる（CCGSの`UPGRADING.md`の1.2.0の節）。手順3で片方だけが「手で合わせる」に出たら、手順4で合わせ終えるまでPRにしない |
| 手順4と5は、どちらからでもよい | 互いに結果を使わない |
| 手順6と7は、どちらからでもよい | 互いに結果を使わない |

## つまずきやすい点

| 症状 | 原因 | 対処 |
| --- | --- | --- |
| `fatal: refusing to merge unrelated histories` | `git merge ccgs/main`を使った | mergeを取り消し、手順3のループで写す |
| `fatal: bad revision 'v<いまの版>'` | CCGSのタグを取ってきていない | 手順1の`git fetch --tags ccgs main`を回す |
| `check`が`docs/`のCCGSの文書で`G001`を出す | CCGSの`docs/`の文書は、フロントマターを持たない | `graph.toml`の`exclude`に、そのパスが入っているかを確かめる（[PDR-0006](../50-pdr/pdr-0006-ccgs-whole-import-dr-types.md)） |
| セッションの初めに、CCGSの読み込んだ文書の中身が出てこない | `.claude/rules/ccgs-studio.md`の`@`のパスが、ルートからの相対になっている | `@../docs/`、`@../../docs/`の形に直す |
| `project.yaml`の`engine.name`と読み込みの行が違っても、セッションの初めに`ENGINE REFERENCE MISMATCH`が出ない | `session-start.sh`の、`game-template (PDR-0005)`の注記の付いた箇所が、CCGSのもの（ルートの`CLAUDE.md`しか探さない）になっている | 手順4で、注記の付いた箇所を残して合わせ直す |
| graph側の`.claude/skills/`（`grill`、`lean`、`yomiyasu`）が、手順3で「手で合わせる」に出る | CCGSが同じ名前のスキルを配り始めた | 手元のものを残したまま、どちらを残すかを決める |

## 完了の確認

- [ ] `grep -m1 '^## \[' CHANGELOG.md`が、新しい版を出す
- [ ] `project.yaml`の`framework.version`が、新しい版である
- [ ] 手順3で「手で合わせる」と出たファイルを、すべて合わせた
- [ ] `git status --short`に、手順5で入れないとしたファイルが無い
- [ ] `claude -p`で`/start`を回し、最初の問いが返る

## 切り戻し

コミットする前なら、`git switch main`の前に、ブランチの変更を捨てれば戻る。マージした後なら、そのPRのマージコミットを`git revert`で戻す。作品が`make update`で取り込んだ後は、作品の側でも同じ取り消しが要る。

## 未確認

この手順は、版を上げる取り込みでまだ試していない。手順3のループは、Git Bashで動くことを前提にしている。手順3で消えたファイルを消すとき、作品の側に`make update`で消えたことが届くかは確かめていない。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`depends_on`: この文書が成立するために前提となるノード

- [PDR-0006 CCGSを丸ごと取り込み、決定の記録を4つの種別に分ける](../50-pdr/pdr-0006-ccgs-whole-import-dr-types.md)

このノードを参照しているノード

- (decides) [PDR-0002 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](../50-pdr/pdr-0002-ccgs-import.md)
- (decides) [PDR-0003 ルートのCLAUDE.mdはgraphのままにし、CCGSの内容はrulesへ移す](../50-pdr/pdr-0003-claude-md-split.md)
- (decides) [PDR-0004 ADRを役割で2か所に分け、CCGSのADRはgraphで検証しない](../50-pdr/pdr-0004-adr-location.md)
- (decides) [PDR-0005 CCGSのsession-start.shとsetup-engineを、rulesのファイルから読み込みの行を探す形に直す](../50-pdr/pdr-0005-engine-import-in-rules.md)
- (decides) [PDR-0006 CCGSを丸ごと取り込み、決定の記録を4つの種別に分ける](../50-pdr/pdr-0006-ccgs-whole-import-dr-types.md)
- (decides) [PDR-0011 CCGSの.gitignoreは、エンジンの節を除いてこの層の節に写す](../50-pdr/pdr-0011-ccgs-gitignore.md)
- (decides) [TDR-0002 言語をGDScriptにする](../51-tdr/tdr-0002-gdscript.md)

<!-- graph:auto:end -->
