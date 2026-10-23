# game-templateの変更履歴

この層だけの履歴である。下の層の履歴は、[TEMPLATE_CHANGELOG.md](TEMPLATE_CHANGELOG.md)（`graph-doc-template`）と[PROJECT_TEMPLATE_CHANGELOG.md](PROJECT_TEMPLATE_CHANGELOG.md)（`graph-project-template`）にある。そのプロジェクト自身の履歴は、[PROJECT_CHANGELOG.md](PROJECT_CHANGELOG.md)に書く。

**派生プロジェクトはこのファイルを書き換えない。**

現在の版は、`tools/graph/layers/game-template.toml`の`version`に書く。版の付け方と見出しの書き方は、[PROJECT_TEMPLATE_CHANGELOG.md](PROJECT_TEMPLATE_CHANGELOG.md)の「版の付け方」に合わせる。

## 上流と共通のファイルを書き換えたもの

この層は、下の層と共通のファイル（[META-08](docs/00-meta/template-upgrade.md)の「共通ファイル」）のうち、次のものを書き換えている。上流がこのファイルを変えると、`make update`で競合することがある。

| ファイル | この層での書き換え | 取り込みでの扱い |
| --- | --- | --- |
| `.gitattributes` | PDR-0001の`merge=ours`の行のパスを変え（0.4.0）、末尾にこの層の行を足した | 競合した部分だけを解き、この層の行と上流の行の両方を残す |
| `.gitignore` | 末尾に、この層のGodotの節（0.11.0）とCCGSの節（0.16.0）を足した | 競合した部分だけを解き、この層の節と上流の行の両方を残す |

`docs/00-meta/templates/`は、0.10.0から書き換えていない。この層の`adr.md`・`tdr.md`・`pdr.md`・`ddr.md`は`docs/templates/`に置き、`graph.toml`の各種別の`template`で指している。`docs/00-meta/dev-flow.md`と`PROJECT_CHANGELOG.md`の雛形（0.22.7）もこの層で書き足している。どちらも`merge=ours`なので、この層と上流の両方が変えたときはこの層の側が残り、競合しない。そのときは上流の変更が入らないので、上流の変更履歴の「取り込む側の作業」を見て手で合わせる。

## 0.23.4（2026-10-24）

### 変更

0.23.3の直しのあと、何も知らないエージェント（Sonnet）に同じ試しを回し直したところ、`SETUP.md`の「3. 作品を作った人が1回だけすること」に2つの穴が見つかったので直した。

- 最初のセッションの`/start`を、テンプレートと繋いでサンプルを消したあとに回す順番にした。`/start`は`project.yaml`を書き換えることがあり、`project.yaml`は`merge=ours`ではない。そのため、初回の取り込みより前に回すと、取り込みで`project.yaml`が競合するおそれがあった。手順の番号が1つずつずれたので、節の中と「4. Godotのテスト」の参照も合わせた。
- サンプルノードを消したあとに`make all`を回し、`check`が挙げた参照切れ（`G004`）を直すと書いた。これまでは、ルートの`CLAUDE.md`とMETA-08を読まないと分からなかった。

### 取り込む側の作業

なし。

## 0.23.3（2026-10-24）

### 変更

何も知らないエージェント（Sonnet）に、`SETUP.md`だけを手がかりに作品への参加と作品の作成の手順を組み立てさせたところ、迷う箇所と誤りが見つかったので直した。

- `SETUP.md`の前提ツールの表で、jqが無いと「フックの検査が抜ける」と書いていたのは誤りだった。`setup-requirements.md`のとおり、無ければフックは`grep`で代わりに読む。
- `SETUP.md`の前提ツールに、GitとClaude Codeを足した。入れ方は`setup-requirements.md`にしか無かった。
- Windowsでは、cloneの前に`git config --global core.longpaths true`を回すと書いた。`.claude/`の下に名前の長いファイルがあり、深いフォルダの下にcloneすると取り出しに失敗する。
- 作品を作った人の手順に、"Use this template"で作った直後はMETA-08の手順1（共通ファイルの上書き）が要らないことと、1人でmainへ直接pushする作品では「PR」をその変更だけのコミットに読み替えることを書いた。
- GdUnit4のプラグインを、エディタを使わずに有効にするときに`project.godot`へ書く節を足した。
- `/start`は、エンジンが決まっていても、道筋の最初に`/setup-engine`を挙げていた。この層ではエンジンは決めてあり、`/setup-engine`の全体を回すと共通ファイルを書き換える。エンジンが決まっているときは、その一歩を`SETUP.md`の「3」に沿った`project.godot`の作成に置き換えるようにした（`game-template (SETUP.md, TDR-0001)`の注記）。`studio-tests/`の`/start`の仕様にも、この場合を足した。

### 取り込む側の作業

なし。

## 0.23.2（2026-10-24）

### 変更

Godotの作品で、関門とスキルが`.github/workflows/tests.yml`をテストのCIとして求めていたのを直した（#69）。この層のGodotのテストのCIは`.github/workflows/app-check.yml`で（TDR-0004）、`/test-setup`は`tests.yml`を作らない。そのため、関門の項目が満たされず、`/help`などが`test-setup`の段を終わっていないと見ていた。直した箇所には`game-template (TDR-0004)`の注記を付けたので、CCGSを更新するときはUC-02の`git diff`で見分けられる。UnityとUnrealの扱いは変えていない。

- `.claude/docs/workflow-catalog.yaml`の`test-setup`の段は、`tests.yml`のglobだけで判定していた。`any_of`で、GdUnit4の`addons/gdUnit4/bin/GdUnitCmdTool.gd`と`tests.yml`のどちらかがあれば終わったとみなすようにした。`any_of`は`artifact-check.sh`がすでに読める書き方である。Godotで`app-check.yml`を判定に使わないのは、`app-check.yml`がテンプレートから最初から届くからである。それで判定すると、GdUnit4を入れる前からこの段が終わったことになり、`/help`などがこの段を案内しなくなる。GdUnit4を入れるのは、作品ごとの手順である（`SETUP.md`の「4」）。
- `/gate-check`のPre-Productionの関門（`gate-pre-production.md`）に、Godotでは`app-check.yml`がこの項目を満たすと書いた。
- `.claude/scripts/test-scaffold.sh`は、Godotのときに`tests.yml`を作らないようにした。代わりに、`app-check.yml`があるかを`CI`の行で知らせ、無ければ`NEEDS`の行で`make update`から取り込むよう案内する。Godotの`tests/README.md`のCIの行も`app-check.yml`にした。
- `/test-setup`の`SKILL.md`と、`references/`の`2-plan.md`・`3-directories.md`・`6-summary.md`の計画と報告に、Godotでは`tests.yml`の代わりに`app-check.yml`を挙げると書いた。
- `/architecture-review`の`9-handoff.md`の関門の前の確認と、`docs/WORKFLOW-GUIDE.md`のStep 3.6と関門の説明にも、同じ注記を足した。
- `studio-tests/`の`test-setup.md`と`architecture-review.md`の期待する動作を合わせた。

### 取り込む側の作業

なし。直したファイルは共通ファイルなので、取り込みで届く。

## 0.23.1（2026-10-23）

### 変更

作品のセッションで、CCGSのスキルとフックが、作品の人をCCGSの上流から直接取り込む手順に向かわせていたのを直した（#68）。作品は、game-templateが取り入れたCCGSを`make update`で受け取る（META-08）。直した箇所には`game-template (…)`の注記を付けたので、CCGSを更新するときはUC-02の`git diff`で見分けられる。

- `/start`（`.claude/skills/start/SKILL.md`）は、`origin`がテンプレートを指していると、`UPGRADING.md`で`template`から取り込むよう案内していた。`UPGRADING.md`の手順は`git merge`で、`make update`を通らないので`merge=ours`が効かない。案内の先を、`SETUP.md`の「3. 作品を作った人が1回だけすること」と、META-08の「1. 最初に一度だけ」に変えた。`studio-tests/skills/utility/start.md`の期待する動作も合わせた。
- `.claude/hooks/update-check.sh`は、CCGSの新しい版を作品のセッションでも知らせていた。作品では知らせないようにした。game-template自身では、UC-02のきっかけになるので知らせる。2つは、`tools/graph/layers/game-template.toml`の`repository`と`origin`が同じかで見分ける。同じなのはgame-template自身だけで、`origin`がまだ無い作品は作品として扱う。`.claude/docs/effects-map.md`の`updates.check`にも、このことを書いた。

### 取り込む側の作業

なし。直したファイルは共通ファイルなので、取り込みで届く。

## 0.23.0（2026-10-23）

### 追加

開発環境を用意する手順を、根の`SETUP.md`にまとめた。作品を起こしてから最初のテストが通るまでの手順が、README・META-08・スキルの資料に散らばっていて、作品に参加した人がすることだけを抜き出した一覧も無かったからである。`SETUP.md`はこの層の共通ファイルにした。`README.md`は`merge=ours`で、作品が作品の説明に書き換えるので、READMEに書くと作品の参加者に届かない。`docs/`の下はグラフのノードとして扱われるので、根に置いた。

`SETUP.md`には、次の4つの節を置いた。

- 「1. 前提ツール」に、GodotとPythonに加えて、Windowsで要るbash・git-lfs・gh・make・jqの入れ方と、`godot`という名前でPATHに通すための2つのファイルを書いた。`make ci`は`engine.path`を読まないので、PATHに通す。
- 「2. 参加した人がすること」に、clone・`--import`・`gh auth login`・Claude Codeの起動・`make ci`の順番を書いた。
- 「3. 作品を作った人が1回だけすること」に、"Use this template"で作ってから`make ci`が通るまでの順番を、各手順へのリンクで並べた。`project.godot`は`/setup-engine`の7.5の手順だけで作り、`/setup-engine`の全体は回さない。`addons/gdUnit4/`は`project.godot`より先に入れる。`project.godot`ができた時点で、`godot-ci.sh`が`tests/unit/qa/`のテストを回そうとして落ちるからである。
- 「4. Godotのテスト」に、GdUnit4の入れ方、手元での回し方（`commands.test`と`make ci`）、自分のテストの置き場（`tests/unit/<system>/`。PDR-0016）を書いた。

`README.md`の「Godotで開く前に」は`SETUP.md`に移し、代わりに「開発環境を用意する」の節から`SETUP.md`を指した。共通ファイルの表にも`SETUP.md`を足した。

CCGSから取り込んだ案内の文書のうち、この層の決まりと食い違う箇所に、`game-template (…)`の注記を足した。食い違うときは、この層の日本語の文書に従うことも`SETUP.md`に書いた。CCGSのファイルを直すのはPDR-0006の範囲内で、CCGSを更新するときはUC-02の`git diff`で見分ける。

- `docs/WORKFLOW-GUIDE.md`のQuick Startで、前提ツールの一覧と作品の作り方（"Use this template"）は`SETUP.md`にあると書いた。CCGSの手順は`git clone`だけを書いていて、cloneすると`origin`がテンプレートを指したまま残る。
- 同じ文書のディレクトリの構成で、`docs/architecture/`をADRの置き場としていたのを直し、`docs/50-pdr/`〜`docs/53-ddr/`を足した。
- `UPGRADING.md`の冒頭に、作品はこの文書に従わず、META-08の`make update`で取り込むと書いた。CCGSの手順は、CCGSを直接`git merge`するもので、`merge=ours`のドライバも、この層がCCGSのファイルに入れた直しも素通りする。

### 取り込む側の作業

`SETUP.md`は取り込みで届く。作品の`README.md`が作品の説明に書き換えてあるなら、`SETUP.md`へのリンクを手で足す。`README.md`は`merge=ours`なので、この層の「開発環境を用意する」の節は、作品が書き換えていれば届かない。

## 0.22.7（2026-10-23）

### 変更

この層の変更で古くなっていた3か所を、いまの構成に合わせた。

- `README.md`の「この層が足しているもの」の表にあるARCH-03へのリンクを、いまのファイル名`arch-03-dev-stages.md`に直した。
- `src/CLAUDE.md`の「Coding Standards」で、決定の記録の置き場を`docs/architecture/`から`docs/51-tdr/`と`docs/52-adr/`に直した（PDR-0006）。`docs/CLAUDE.md`と`design/CLAUDE.md`は直してあり、このファイルだけが残っていた。
- `docs/00-meta/dev-flow.md`の「リリースと配置」と、`PROJECT_CHANGELOG.md`の雛形の冒頭は、履歴を3つと書いていた。この層の`GAME_TEMPLATE_CHANGELOG.md`と、CCGSの`CHANGELOG.md`を足して、5つにした。

`.gitattributes`の`PROJECT_CHANGELOG.md`の行の注記は直していない。この注記は下の層の文で、`merge=ours`にする理由を述べるために下の層の履歴の名前を挙げている。履歴の数を言い切ってはいないので、このままにした。

### 取り込む側の作業

`docs/00-meta/dev-flow.md`と`PROJECT_CHANGELOG.md`は`merge=ours`なので、作品が書き換えていれば、この修正は届かない。作品の`dev-flow.md`の「リリースと配置」が履歴を3つと書いていたら、上の2行を手で足す。`PROJECT_CHANGELOG.md`は、雛形の説明ごと書き換えていれば何もしなくてよい。

## 0.22.6（2026-10-23）

### 変更

`README.md`の「テンプレートの更新を取り込む」の表にある`merge=ours`のファイルの行に、「プロジェクトが書き換えたあとは」を足した。この行は、`dev-flow.md`・`app-check.yml`・`config.yml`について「取り込みでは変わらない」と言い切っていた。graph-project-templateの0.16.5（#101）が直した文言と同じである。この層は`README.md`を書き換えているので、0.16.5を取り込んだとき`merge=ours`でこの層の側が残り、手で合わせた。

### 取り込む側の作業

`README.md`は`merge=ours`なので、作品が書き換えていれば、この修正は届かない。文言だけの修正なので、手で合わせなくても動作は変わらない。

## 0.22.5（2026-10-23）

### 変更

`merge=ours`のファイルには取り込みが届かない、という言い切りを直した（#61）。下の層のMETA-08（graph-doc-templateの1.54.1）のとおり、`merge=ours`のドライバが呼ばれるのは、基点のあと作品とテンプレートの両方がそのファイルを変えたときだけである。作品が書き換えていないファイルには、この層の側の内容がそのまま入る。試しの作品に0.21.0〜0.22.4を取り込んだとき、`docs/00-meta/dev-flow.md`の変更は取り込みで届いていた。

直したのは、この文書の冒頭の「上流と共通のファイルを書き換えたもの」の下の段落、`docs/00-meta/dev-flow.md`の2か所、`README.md`の「テンプレートの更新を取り込む」の段落、`.github/workflows/app-check.yml`の冒頭の注記である。`dev-flow.md`と`README.md`の文言は、graph-project-templateの0.16.4に合わせた。この層が2つを書き換えているので、0.16.4を取り込んだとき`merge=ours`でこの層の側が残り、手で合わせた。

0.21.0の「ログは作業ツリーではなく、一時フォルダに置く」は、Godotのログのことである。`make ci`のGdUnit4は、報告を作業ツリーの`reports/`に書く。`reports/`は`.gitignore`にあるので、コミットには混ざらない。GdUnit4 6.2.2には報告の置き場を変える`-rd`があるが、`/`で始まるパスを`res://`の下と読むので、macOSやLinuxの一時フォルダを渡せない。そのため`scripts/local_ci.py`は変えず、注記にこのことを書いた。

過去の項の「取り込む側の作業」は書き換えていない。変更履歴の項は記録として残す。過去の項を直しても、その版をすでに取り込んだ作品の`upgrade`には出ない。過去の項の誤りと抜けは、下の「取り込む側の作業」にまとめた。

### 取り込む側の作業

過去の項で「`merge=ours`なので届かない」と書いたもの（0.17.0・0.19.0・0.20.0・0.21.0・0.22.0・0.22.2・0.22.3）は、作品がそのファイルを書き換えていれば届かない、と読む。作品が書き換えていなければ、取り込みでもう入っているので、手で足さない。二重に足していないかは、`git diff HEAD template/main -- README.md docs/00-meta/dev-flow.md`で確かめる。

作品が書き換えていて届かなかったときは、過去の項に書いた作業に加えて、次のものを手で合わせる。

| 版 | ファイル | 抜けていたこと、誤っていたこと |
| --- | --- | --- |
| 0.21.0 | `README.md` | コマンドの表の`make ci`の行を、「GitHub Actionsが動かないときに、`graph-check.yml`と`app-check.yml`（書き出しを除く）と同じ検査を手元で回す（[META-05](docs/00-meta/dev-flow.md)）」にする |
| 0.22.0 | `README.md` | 共通ファイルの表に行を足すのではなく、左の列の既存のセルの`src/qa/`の後ろに`tests/unit/qa/`を足す。表の上の「分け方の理由は」のリンクを、PDR-0014から[PDR-0016](docs/50-pdr/pdr-0016-tests-unit-qa-common-file.md)に替える |
| 0.22.3 | `README.md` | 足す文のGodotの行で、「公式サイトから入れる。」の後ろに「版の理由は[TDR-0001](docs/51-tdr/tdr-0001-godot-version.md)にある。」を足す |

この版の`docs/00-meta/dev-flow.md`・`README.md`・`.github/workflows/app-check.yml`の文言の修正も、作品が書き換えていれば届かない。文言だけの修正なので、手で合わせなくても動作は変わらない。`.gitignore`と`scripts/local_ci.py`は変えていない。

## 0.22.4（2026-10-23）

### 変更

0.22.1で`.claude/scripts/project-state.sh`を直したのと同じ考え方を、段階を推すほかの3か所に当てた（#57）。この層の配るADR（フロントマターの`tags`に`template`を持つもの。いまはADR-0001）と、この層の共通ファイルである`src/qa/`を、作品の進み具合に数えない。

`.claude/hooks/detect-gaps.sh`は、check 1・3・5と段階の食い違いの警告で使うソースのファイルとADRの数を、`project-state.sh`の`source_files`と`adr`から読むようにした。同じ判定を2か所に書かないためである。これまでは、作ったばかりの作品でも`src/qa/`とADR-0001を数えていた。作品かどうかを見る冒頭の判定は、コードの置き場を決める前に走るので`project-state.sh`を使えない。そこでは`src/qa/`を`find`の`-prune`で外した。`project-state.sh`が無いときは、そのことを1行出し、数は0として扱う。

`/project-stage-detect`の`SKILL.md`は、ソースのファイルを数える指示に`src/qa/`を除く断りを、ADRを数える指示に`template`のタグを持つADRを除く断りを足した。`/adopt`の`references/1-detect.md`は、TDRとADRをまとめて数えていた。これをADRだけにし、`template`のタグを持つADRも除いた。TDRは別に数え、段階の推定には使わない。この層がエンジンのTDRを配るからである。段階を推す基準のソースのファイルからも、`src/qa/`を除いた。

この版で直したCCGSのファイルは、UC-02の手順3で、CCGSの更新のときに「手で合わせる」に出る。

### 取り込む側の作業

無い。`.claude/`は取り込みで届く。

## 0.22.3（2026-10-23）

### 変更

`README.md`の「Godotで開く前に」の節に、Godot 4.7.2の標準版とPython 3.12以上を入れる手順を足した（#51）。#7の試しで、READMEだけで準備を進めたとき、この2つが書いていなかった。Godotは、PATHの`godot`で呼べるようにし、`godot --version`が`4.7.2.stable`で始まることを確かめる。Pythonは、`python -m tools.graph check`と`make ci`が使う。

### 取り込む側の作業

作品の`README.md`は`merge=ours`なので、この変更は取り込みで届かない。「Godotで開く前に」の節の頭に、次の文を手で足す。節が無い作品は、同じ内容を使い始めの手順に足す。

````markdown
次の2つを入れる。

- Godot 4.7.2の標準版（.NETでない版）。[GitHubのreleases](https://github.com/godotengine/godot/releases)の4.7.2-stableか、公式サイトから入れる。`project.yaml`の`commands`はPATHの`godot`を呼ぶので、PATHに通す。通せないときは、`/settings`で`engine.path`にエディタのパスを設定する。
- Python 3.12以上。`python -m tools.graph check`と`make ci`が使う。

次のコマンドで、入ったことを確かめる。

```bash
godot --version
python --version
```

`godot --version`は`4.7.2.stable`で始まる。
````

## 0.22.2（2026-10-23）

### 変更

META-05の「シーンと`project.godot`」に、作品を作った直後の準備と、最初の画面の登録も、`project.godot`をテンプレートの管理者だけが直す決まりに従うと書いた（#49）。`project.godot`の作成、`EvidenceCapture`のautoloadの登録、GdUnit4のプラグインの有効化は、テンプレートの管理者が`project.godot`だけを変えるPRで行う。最初の画面のストーリーでは、シーンのPRが先にマージされ、そのあとに`run/main_scene`を登録する。試しの作品では、最初のストーリーのPRで`run/main_scene`を設定していた。1人で開発していたので、決まりには反していない。新しい決まりではなく、PDR-0009の決定の当てはめなので、PDRは起こしていない。

### 取り込む側の作業

作品の`docs/00-meta/dev-flow.md`は`merge=ours`なので、この変更は取り込みで届かない。複数人で開発する作品は、「シーンと`project.godot`」の節の末尾に、次の段落を手で足す。

```markdown
作品を作った直後の準備と、最初の画面の登録も、この決まりに従う。`project.godot`の作成（`/setup-engine`の7.5）、`EvidenceCapture`のautoloadの登録、GdUnit4のプラグインの有効化は、テンプレートの管理者が`project.godot`だけを変えるPRで行う。最初の画面のストーリーでは、シーンのPRが先にマージされ、そのあとにテンプレートの管理者が`run/main_scene`を登録する。シーンのPRの受け入れ条件に「起動すると最初に開く」があれば、登録のPRがマージされてから確かめる。
```

## 0.22.1（2026-10-23）

### 変更

`.claude/scripts/project-state.sh`が、この層の配るものを作品の進み具合に数えないようにした（#48）。これまでは、作ったばかりの作品でも`adr 1`・`source_files 1`・`phase_inferred technical-setup`が出ていた。この層がADR-0001と`src/qa/evidence_capture.gd`を配っているからである。そのため/startは、Phase 4の経路Dで段階を`Technical Setup`にし、Phase 2で経路Aを選ぶと「コードがある」と問い返していた。

`adr`は、フロントマターの`tags`に`template`を持つADRを数えない。この層の配るADRには、このタグを付ける。いまはADR-0001だけで、`tags`を`[qa, template]`にした。ADR-0001の本文は変えていない。`source_files`は、この層の共通ファイルである`src/qa/`を数えない。どちらも、TDRを数えないのと同じ理由である。スクリプトの冒頭の説明に、その理由を書いた。

この版で直したCCGSのファイルは、UC-02の手順3で、CCGSの更新のときに「手で合わせる」に出る。

### 取り込む側の作業

無い。`.claude/`とADR-0001は取り込みで届く。作品がADR-0001の`tags`を自分で変えていて競合したら、`template`を残す。

## 0.22.0（2026-10-23）

### 変更

`src/qa/evidence_capture.gd`と`tests/unit/qa/qa_evidence_capture_test.gd`に付く`.uid`のファイルを配るようにした（#53）。TDR-0003は`.uid`をGitに入れると決めているが、この層は配っていなかった。そのため作品は、最初の`--import`で作品ごとに別のuidを作っていた。`.uid`は、Godot 4.7.2の`--import`で作った。

`tests/unit/qa/`を、この層の共通ファイルにした。テストが確かめる`src/qa/`が共通ファイルで、2つはいつも一緒に変わるからである。理由と却下した案は、PDR-0016に書いた。PDR-0016はPDR-0014を置き換え、PDR-0014の決定をすべて引き継ぐ。READMEの共通ファイルの表に`tests/unit/qa/`を足した。

### 取り込む側の作業

`.uid`と`tests/unit/qa/`は共通ファイルなので、取り込みで届く。作品が2つの`.uid`をすでにコミットしていると、取り込みで`add/add`の競合になる。この層の側を採る。

```bash
git checkout --theirs src/qa/evidence_capture.gd.uid tests/unit/qa/qa_evidence_capture_test.gd.uid
git add src/qa/evidence_capture.gd.uid tests/unit/qa/qa_evidence_capture_test.gd.uid
```

作品のシーンやリソース（`.tscn`・`.tres`）が、作品で作った古いuidを`uid://`で指していることがある。`git grep <古いuid>`で探し、見つかったらこの層のuidに書き換える。`--import`を回し直しても、シーンの中のuidは書き換わらない。書き換えないと、Godotは読み込むたびに`invalid UID`の警告を出して、パスで読み込む。書き換えたら`godot --headless --import`を1度回す。作品の`README.md`は`merge=ours`なので、共通ファイルの表への1行は届かない。手で足す。

## 0.21.1（2026-10-23）

### 変更

`.gitattributes`の`production/qa/evidence/**`の行を、画像と動画の拡張子（`png`・`jpg`・`jpeg`・`webp`・`gif`・`mp4`・`webm`）の行に分けた（#50）。これまでは証拠のフォルダの全部がLFSに入り、`stamp.txt`や`<story>-evidence.md`もLFSのポインタになっていた。TDR-0003は`*.md`をLFSに入れずにテキストのまま扱うと決めているので、実装をその決定に合わせた。試しの作品では、`stamp.txt`の差分がGitHubのPRで見えなかった。

### 取り込む側の作業

`.gitattributes`は共通ファイルなので、取り込みで届く。証拠のフォルダの文字のファイルがすでにLFSに入っていて、テキストに戻すなら、取り込んだあとに`git add --renormalize production/qa/evidence`を回してコミットする。属性を変えただけでは、Gitは入っているファイルを入れ直さない。

## 0.21.0（2026-10-23）

### 変更

`make ci`が、`project.godot`のある作品では`app-check.yml`のGodotの段も回すようにした（#7）。読み込み・スクリプトの読み込みの確認・GdUnit4の3つを、`.github/scripts/godot-ci.sh`の同じ判定で、PATHの`godot`を使って回す。書き出しの段は、mainへのpushのときだけの段なので回さない。ログは作業ツリーではなく、一時フォルダに置く。

試しの作品で1本のストーリーを通したとき、GitHub Actionsが動かないあいだは、Godotのテストをだれも回していないと分かった。`make ci`は`graph-check.yml`の検査だけを回していたからである。同じ試しで、GdUnit4 6.2.2がWindowsのGodot 4.7.2で動くことも確かめた。

META-05の「6. コミットとマージ」と、READMEの`make ci`の行を合わせて直した。

### 取り込む側の作業

`scripts/local_ci.py`は共通ファイルなので、取り込みで届く。`docs/00-meta/dev-flow.md`と`README.md`は`merge=ours`なので届かない。META-05の「6. コミットとマージ」の`make ci`の段落に、`project.godot`があればGodotの段も回すという2文を手で足す。`make ci`を回すPCには、Godot 4.7.2をPATHの`godot`で呼べるように入れる。

## 0.20.1（2026-10-23）

### 変更

`docs/engine-reference/godot/VERSION.md`の版の表示を、TDR-0001で決めた4.7.2に合わせた（#13）。`Engine Version`を`Godot 4.7`から`Godot 4.7.2`にした。`Installed at pin time`には、`/setup-engine`の§3の手順でテンプレートのPCのエディタを調べた結果（`4.7.2.stable.official.ed1daf0bf`、Windows、2026-10-23）を書いた。これまでは`NOT DETERMINED`だった。

### 取り込む側の作業

無い。

## 0.20.0（2026-10-23）

### 変更

作品が書き換えてよいこの層のファイル（`project.yaml`・`graph.toml`・`graph.mk`・`docs/templates/`）を、`merge=ours`にしないと決めた（#43）。この層の変更（CCGSの更新の`framework.version`、種別の必須の節と雛形、`make ci`）が、取り込みで作品に届くようにするためである。理由と却下した案は、PDR-0015に書いた。

`.gitattributes`のこの層の節に理由を書いた。`graph.toml`と`graph.mk`の末尾に「ここから下は作品が足すもの」の注記を置いた。READMEの共通ファイルの表の下に、競合したときの扱いを書いた。

### 取り込む側の作業

`graph.toml`と`graph.mk`に作品で書き足したものがあれば、末尾の「ここから下は作品が足すもの」の下へ移す。取り込みで4つのファイルが競合したら、作品の変更とこの層の変更の両方を残して手で解く。`README.md`は`merge=ours`なので、READMEの1文は届かない。

## 0.19.0（2026-10-23）

### 変更

`README.md`の先頭に、この層の説明を足した（#40）。題を`# game-template`にし、この層が足しているもの、使い始め方、この層の共通ファイルと作品のもの、取り込みのときのupstreamのURLとラベルを書いた。#3で足した「Godotで開く前に」の節は、この層の説明の中へ移した。下の層の説明は、`---`の下にそのまま残している。

この層の共通ファイルの範囲を、PDR-0014に決めた。これまでどの文書にも決めておらず、PDR-0002は`README.md`を「graphの共通ファイル」としていたが、`README.md`は`merge=ours`である。

### 取り込む側の作業

`README.md`は`merge=ours`なので、取り込んでもこの変更は届かない。game-templateから作った作品は、`git diff HEAD template/main -- README.md`で差を見て、初回に上書きする共通ファイルの一覧とupstreamのURLを確かめる。

## 0.18.0（2026-10-23）

### 変更

`.github/CODEOWNERS.example`に、`*`の行（既定の持ち主）を置かないと決めた（#39）。どの行にも当たらないパス（`tests/`、`production/`など）を変えるPRは、mainの保護の「承認1人以上」により、誰か1人が承認すればマージできる。このことを`CODEOWNERS.example`の冒頭の注記に書いた。理由と却下した案は、PDR-0013に書いた。

### 取り込む側の作業

無い。`.github/CODEOWNERS`を写したあとなら、注記だけを写してもよい。

## 0.17.0（2026-10-23）

### 変更

複数人で開発するときは、mainの保護で「Require review from Code Owners」を有効にし、持ち主のパスを変えるPRは持ち主の承認を必須にすると決めた（#38）。META-05の「mainを保護する」の表に設定を足した。PRを出した人は自分のPRを承認できないので、役割が1人だけなら、`CODEOWNERS`のその行に代わりの持ち主を並べる。このやり方を、META-05の「持ち主を決める」と`.github/CODEOWNERS.example`の冒頭の注記に書いた。理由と却下した案は、PDR-0012に書いた。

1人で開発する作品には当たらない。

### 取り込む側の作業

`docs/00-meta/dev-flow.md`は`merge=ours`なので、取り込んでもMETA-05の変更は届かない。複数人で開発するなら、この層のMETA-05の「mainを保護する」と「持ち主を決める」から手で写し、mainの保護に設定を足す。

## 0.16.0（2026-10-23）

### 変更

CCGSの1.2.0の`.gitignore`を、エンジンの3つの節（Godot・Unity・Unreal）を除いて、`.gitignore`の末尾のこの層の節に写した（#36）。これで、CCGSが書き出すセッションの記録（`production/session-state/`、`production/session-logs/`）、エージェントの記憶（`.claude/agent-memory/`）、個人の設定（`project.local.yaml`、`CLAUDE.local.md`）、検査の結果（`docs/consistency-failures.md`）が、Gitに入らなくなる。

これまで入っていなかったのは、PDR-0002の「写さなかったもの」の表が、Godotの節しか検討していなかったからである。PDR-0006はこの表をそのまま引き継いでいた。写す節と写さない節、却下した案は、PDR-0011に書いた。UC-02の手順4に、`.gitignore`の合わせ方を足した。

写した節の`bin/`と`*.dll`・`*.so`・`*.dylib`は、`addons/<名前>/bin/`にあるGDExtensionの書き出し済みのファイルも外す。CCGSのとおり、gdUnit4のものだけを戻している。

### 取り込む側の作業

無い。いまGitに入っているファイルは、`.gitignore`に当たっても外れない。セッションの記録などをすでにコミットしているなら、`git rm --cached`で外す。

## 0.15.0（2026-10-23）

### 変更

開発の流れを、CCGSの7段階（Concept、Systems Design、Technical Setup、Pre-Production、Production、Polish、Release）と`/gate-check`に沿ってARCH-03に書いた（#8）。8段階との対応表、Claudeと作るときの3つの変更点、段階ごとにすること（`workflow-catalog.yaml`の`phases`）と次へ進む関門（`/gate-check`の定義のファイル）への案内、関門の定義に無い人の判断の場面を書いた。運営・アップデートは、Releaseのあと`project.stage`をProductionに戻すくり返しとして書いた。企画書と仕様書は、CCGSの`game-concept.md`と`game-design-document.md`の雛形を指し、新しくは作っていない。

8段階にCCGSを合わせる案を却下したことは、PDR-0010に書いた。

CCGSの`.claude/rules/ccgs-studio.md`の「Collaboration Protocol」に、面白いかの判断、ストアへの登録、規約への同意、価格の決定、公開の判断では、Claudeが止まって聞く項目を足した。この版で直したCCGSのファイルは、UC-02の手順3で、CCGSの更新のときに「手で合わせる」に出る。

### 取り込む側の作業

無い。

## 0.14.0（2026-10-23）

### 変更

複数人で開発するための決まりを、META-05（`docs/00-meta/dev-flow.md`）の「複数人で開発するとき」の節に書いた（#4）。mainの保護の設定（PRを必須にする、承認1人以上、必須のチェック、force pushの禁止）、1つのストーリーをissue1件・ブランチ1本・PR1本にすること、PRの本文にストーリーのパスとスクリーンショットの証拠のパスを書くこと、シーンの担当と`project.godot`を変えるPRを分けることを決めた。PRの雛形は下の層と共通なので、欄は足していない。

CODEOWNERSの雛形を`.github/CODEOWNERS.example`に置き、分け方と雛形にした理由をPDR-0009に書いた。`merge=ours`にはしていない。

CCGSの`/story-done`が、閉じたストーリーのパスと証拠のパスを、PRの本文に書く節の形で出すようにした。

CCGSの`validate-commit.sh`はコミットメッセージの形を見ず、`validate-push.sh`はmainへのpushを警告するだけなので、graphの決まりで書いたコミットとpushは止められない。

### 取り込む側の作業

`docs/00-meta/dev-flow.md`は`merge=ours`なので、取り込んでも「複数人で開発するとき」の節は届かない。複数人で開発するなら、この層のMETA-05から手で写す。そのうえで、`.github/CODEOWNERS.example`を`.github/CODEOWNERS`に写して担当者の名前を入れ、mainの保護を設定する。

## 0.13.0（2026-10-23）

### 変更

スクリーンショットの証拠を撮るautoloadを`src/qa/evidence_capture.gd`に作り、決めたことをADR-0001に書いた（#6）。Claudeは起動の引数（`-- --capture=<名前> --story=<ストーリーのid>`）で、人は遊びながらF12で撮る。どちらも`production/qa/evidence/<ストーリーのid>/<日時>-<名前>.png`に置く。引数で撮るときは既定で10フレーム待ち（`--capture-frames=N`で変える）、撮ったらゲームを終え、終了コードで結果を返す。`--story`が無いときとキーで撮るときは、`production/session-state/active.md`の`**Current task:**`の行からストーリーを読む。書き出したゲームでは動かない。

引数とパスの決まりのGdUnit4のテストを、`tests/unit/qa/qa_evidence_capture_test.gd`に書いた。Godotが無い環境で書いたので、autoloadもテストもまだGodotで回していない。

CCGSの`.claude/docs/run-and-observe.md`のGodotの手順と、`/dev-story`の撮る手順を、このautoloadを使う形に直した。autoloadの登録の仕方（`project.godot`の行）は、`run-and-observe.md`に書いた。

### 取り込む側の作業

Godotのプロジェクトがあるなら、`project.godot`の`[autoload]`に`EvidenceCapture="*res://src/qa/evidence_capture.gd"`を足す。F12をゲームの操作に使っているなら、`src/qa/evidence_capture.gd`の`CAPTURE_KEY`を変える。

## 0.12.0（2026-10-23）

### 変更

GodotのCIを`.github/workflows/app-check.yml`に書き、決めたことをTDR-0004に書いた（#5）。Godotは`chickensoft-games/setup-godot`で4.7.2を入れ、pushとPRのたびに、素材の読み込み・スクリプトの読み込みの確認・GdUnit4のテストを回す。読み込みは、終了コードが0でも、ログに`ERROR`の行があれば失敗にする。mainへのpushのときだけ、WindowsとWebに書き出して成果物に置く。判定は`.github/scripts/godot-ci.sh`に切り出した。`project.godot`が無いリポジトリ（game-template自身）では、Godotの段を飛ばして成功にする。

CCGSの`/test-setup`の`references/4-ci.md`に、Godotでは`tests.yml`を作らないという注記を足した。

GitHub Actionsが支払いの問題で動かないので、game-templateではこのworkflowを回していない。書式はactionlintとshellcheckで、判定の部分は偽のログで確かめた。

### 取り込む側の作業

`app-check.yml`は`merge=ours`なので、取り込んでもこの版の`app-check.yml`は届かない。Godotの検査を使うなら、この層の`app-check.yml`を手で写す。`.github/scripts/godot-ci.sh`は取り込みで届く。

## 0.11.0（2026-10-23）

### 変更

Godot用のGitの設定をそろえ、決めたことをTDR-0003に書いた（#3）。LFSと`lockable`の対象は、`.gitattributes`のこの層の行のとおりにする。`export_presets.cfg`はGitに入れる。CIでの書き出しに要り、Godot 4.1以降はパスワードなどを`.godot/export_credentials.cfg`に分けて書くからである。

`.gitignore`の末尾に、この層の節を足して`.godot/`・`/android/`・`*.translation`を書いた。`design/`・`docs/`・`tools/`・`studio-tests/`・`scripts/`に`.gdignore`を置き、Godotに読み込ませないようにした。`tests/`には置いていない。Godotのテストを`tests/unit/`と`tests/integration/`に置くので、`tests/`に置くとそれも読み込まれなくなるからである。`.claude/`と`.github/`は、名前が`.`で始まるのでGodotが読み込まない。READMEに、`git lfs install`とロックの使い方を書いた。

### 取り込む側の作業

`README.md`は`merge=ours`なので、取り込んでも「Godotで開く前に」の節は届かない。要るなら、この層のREADMEから手で写す。根にGodotの素材を置かないフォルダを自分で足していたら、そこにも`.gdignore`を置く。

## 0.10.1（2026-10-23）

### 変更

CCGSのGDDと設計の文書を、`design/`に置いたままgraphの検証の外に置く決定を、PDR-0008に書いた（#2）。決定の経緯はgraphのノードであるDDR・TDR・ADRが持ち、DDRとGDDは両方から指す（PDR-0006）。`docs_dir = "design"`にして文書を`design/`に移す案、graphが複数の文書のフォルダを検証できるようにする案、#2の本文の種類表でCCGSの文書をノードにする案は採らなかった。`graph.toml`の`exclude`の注記に、`design/`を書かない理由としてPDR-0008を足した。

### 取り込む側の作業

無い。

## 0.10.0（2026-10-23）

### 変更

`graph.toml`の一番上に`extend_default_types = true`を置き、既定の種別を書き写さないようにした（PDR-0006、上流の1.54.0）。`architecture`・`domain`・`usecase`・`contract`の`[node_types.*]`は、`tools/graph/schema.py`の既定と同じ内容だったので消した。`pdr`・`tdr`・`adr`・`ddr`は残した。`adr`は既定と同じ名前なので丸ごと上書きになり、`immutable`と`required_sections`を書いたままにしてある。これで、上流が既定の種別に入れた変更が、手で合わせなくても届く。

`pdr`・`tdr`・`adr`・`ddr`の雛形を、上流と共通の`docs/00-meta/templates/`から`docs/templates/`に移し、各種別に`template = "docs/templates/<名前>.md"`を書いた（上流の1.53.0）。共通のフォルダの`adr.md`は上流の内容に戻した。`.claude/`の下と`docs/`の中で、雛形のパスを指していた箇所（`architecture-decision`のスキル、`adr-status.sh`、`adr-dep-graph.sh`、`design-decision-records.md`など）は、新しいパスに直した。これで、上流が`adr.md`を変えても取り込みで競合しなくなり、前の版で書いた`adr.md`を取り込むときの手順は要らなくなった。

PDR-0007の本文は、確定した記録なので、雛形の古いパスのまま残してある。

### 取り込む側の作業

`docs/00-meta/templates/`に自分で雛形を置いていたら、`docs/templates/`に移し、`graph.toml`のその種別に`template`を書く。

1. 自分で直した`adr.md`・`tdr.md`・`pdr.md`・`ddr.md`があれば、中身を`docs/templates/`の同じ名前のファイルに移す。取り込みで`docs/00-meta/templates/adr.md`が競合したら、上流の内容を取る
2. `graph.toml`の各種別に、`template = "docs/templates/<名前>.md"`を書く。パスはリポジトリの根から書く
3. `graph.toml`で`architecture`などの既定の種別を書き写していたら、一番上に`extend_default_types = true`を置き、既定と同じ内容のものを消す（上流の1.54.0の「取り込む側の作業」にある）
4. `.claude/`の下や`docs/`の中で、自分で書いた箇所が`docs/00-meta/templates/adr.md`などを指していれば、新しいパスに直す
5. `python -m tools.graph check --strict`を回す

## 0.9.1（2026-10-23）

### 変更

上流と共通の`docs/00-meta/templates/adr.md`が`make update`で競合したときの手順を、このファイルの「上流と共通のファイルを書き換えたもの」に書いた（#25）。この層は0.7.0で、このファイルをこの層のADRの雛形に差し替えた。差し替えはそのままにし、上流がこのファイルを変えたら、この層の内容を残して、上流の差分から要るものだけを取り入れる。同じく書き換えている`.gitattributes`も、同じ表に挙げた。META-08と`docs/00-meta/`は下の層と共通のファイルなので、手順はこの層のファイルに置いた。種別ごとの雛形を層の側に置くしくみは、上流の`graph-doc-template`にissueで求める。

### 取り込む側の作業

無い。`adr.md`を自分の雛形に差し替えている派生は、「上流と共通のファイルを書き換えたもの」の手順で取り込む。

## 0.9.0（2026-10-23）

### 変更

TDRとADRの最終確認日（CCGSのLast Verified）を、本文の「最終確認日」の節をやめ、フロントマターの`last_verified`（`YYYY-MM-DD`）に持つようにした（PDR-0007、#24）。確定した記録を書き換えない決まりは本文のものなので、`stable`のTDRやADRでも`last_verified`は更新してよい。更新してよいのは`last_verified`だけで、本文は変えない。状態を`status`に持つのと同じ形である。PDR-0007は、PDR-0006の決定の4のうち「最終確認日」の節だけを改めるので、PDR-0006を置き換えずに`depends_on`で指す。

`graph.toml`の`tdr`と`adr`の`required_sections`から「最終確認日」を外し、15節にした。`docs/00-meta/templates/tdr.md`と`adr.md`は、節を外してフロントマターに`last_verified:`を足し、書き方を雛形の注記に書いた。まだ確かめていない記録では、値を空のままにする。graphのツールは、フロントマターの知らないキーを受け付けるので、上流の道具は直していない。

`adr-status.sh`の`last_verified`の列は、フロントマターの`last_verified`の日付を出す。値が無ければ`-`、日付でなければ`UNFILLED`である。`version`の列は、これまでどおり`last_verified`、無ければ日付、無ければ`unversioned`である。これに合わせて、`/architecture-decision`（`CONTRACT.md`、`accept`、`retrofit`、記録を書く手順）、`/create-stories`、`/dev-story`（`CONTRACT.md`と版の食い違いの手順）、`.claude/docs/templates/`の`architecture-decision-record.md`と`story.md`、`docs/CLAUDE.md`を直した。`architecture-decision-record.md`には、`stable`の記録で`last_verified`を更新する手順を書いた。`retrofit`は、「最終確認日」の節を見つけたら、その日付を`last_verified`に移して節を消す。`studio-tests/`の`/architecture-decision`と`/dev-story`の仕様も直した。GDDの`Last Verified`はGDDのものなので、変えていない。CCGSの英語のファイルの中の説明文は、英語で書いた。

TDR-0001とTDR-0002から、「なし」と書いた「最終確認日」の節を消した。確定した記録を書き換えない決まりの例外で、0.7.0の組み替えで足した「なし」の節を外すだけなので、中身は変わらない。0.7.0と同じ扱いである。確かめていないので、`last_verified`は書いていない。

この版で直したCCGSのファイルは、UC-02の手順3で、CCGSの更新のときに「手で合わせる」に出る。

### 取り込む側の作業

`docs/51-tdr/`か`docs/52-adr/`に自分で書いた記録に「最終確認日」の節があれば、1つずつフロントマターに移す。

1. 節の日付を、フロントマターの`last_verified:`に写す。節が「なし」なら、`last_verified:`を値の無いまま足す
2. 「最終確認日」の節を消す。ほかの節は変えない
3. `python -m tools.graph check`を回す

移さなくても`check`は通る。ただし、`adr-status.sh`は節の日付を読まなくなり、記録の版は「日付」の節で決まる。最終確認日に合わせて版を写したストーリーは、`/dev-story`で版の食い違いが出る。`/architecture-decision retrofit <パス>`でも移せる。

`docs/00-meta/templates/tdr.md`か`adr.md`を自分で直していて競合したら、この層のもの（15節と`last_verified:`）に合わせる。`.claude/`の下のCCGSのファイルを自分で直していて競合したら、最終確認日の読み方はこの層のものに合わせ、自分で足した行は残す。

## 0.8.0（2026-10-23）

### 変更

ゲームデザインの決定を、DDR（Design Decision Record）として書く種別を足した（PDR-0006、#16）。DDRに書くのは、プレイヤーができること、見るもの、感じることが変わる決定である。ルールや仕様の判断と、却下した案を書く。`graph.toml`に`ddr`の種別（接頭辞`DDR`、`docs/53-ddr/`、層90、`exempt_layer`、`immutable`）を足した。節はPDRと同じ6節（背景・決定・理由・却下した案・影響・見直しの条件）で、状態はフロントマターの`status`に持つ。番号は種別ごとに0001から振る。雛形は`docs/00-meta/templates/ddr.md`、目次は`docs/53-ddr/index.md`である。

ADRとDDRの境は、「プレイヤーから違いが分かるか」である。1つの話が両方にまたがるときは2つに分け、ADRの`depends_on`でDDRを指す。`/architecture-decision`の種別を選ぶ手順（Step 2）に、この境を足した。ADRに書こうとしたものがデザインの決定なら、ADRに書かずにDDRへ回す。

GDD（`design/gdd/`）とDDRは、両方から指す。DDRは「背景」の節の「対応するGDD」の行にGDDのパスを書く。GDDは、先頭の`> **Related DDRs**:`の行にDDRのidを書く。この行は、CCGSのGDDの雛形（`.claude/docs/templates/game-design-document.md`）と、`/design-system`が作る骨組みに足した。GDDはいまの仕様だけを書き、決定の経緯はDDRが持つ。GDDはgraphの外にあるので、GDDからDDRへの参照は`check`が確かめない。`/design-review`の完全性の確認で、目で確かめる。

DDRを書く手順は、`.claude/docs/design-decision-records.md`に1か所にまとめた。`/design-system`（5b-bis）、`/design-review`（Revise nowの手順）、`/propagate-design-change`（Phase 3b）は、デザインの決定が出たらこの手順でDDRを書き、GDDの`Related DDRs`の行に足す。DDRは`python -m tools.graph new --type ddr`で作る。`registry.sh next-id`には`ddr`を足した。`/propagate-design-change`は、置き換えたDDRを`depends_on`で指しているADRも、影響を受けるADRに数える。`minimal`の進め方では、DDRを確かめない。

`adr-status.sh`と`adr-dep-graph.sh`は、DDRを依存の一覧に入れない。DDRは実装の順を決めるものではなく、ADRの外の前提だからである。`adr-status.sh`の依存の列には出ない。DDRだけを指すADRは`none`になる。`adr-dep-graph.sh`は、ADRが指すDDRを`DDR_DEPS`の行に分けて出し、`EDGES`・`ORDER`・循環の判定には入れない。DDRの循環と状態は、graphの`check`が確かめる。

これに合わせて、`graph.toml`の注記、`docs/index.md`とREADMEのフォルダの表、PDR・TDR・ADRの目次、TDRとADRの雛形の注記を直した。`.claude/`の下の`coding-standards.md`、`rules/design-docs.md`、`design/CLAUDE.md`、`docs/CLAUDE.md`にもDDRを足した。`studio-tests/`には、`/architecture-decision`・`/design-system`・`/design-review`・`/propagate-design-change`のDDRの場合と、`/architecture-review`の`DDR_DEPS`の場合を足した。CCGSの英語のファイルの中の説明文は、英語で書いた。

この版で直したCCGSのファイルは、UC-02の手順3で、CCGSの更新のときに「手で合わせる」に出る。

### 取り込む側の作業

`docs/53-ddr/`を自分で別の用途に使っていたら、取り込む前に別のフォルダへ移す。

`.claude/`の下のGDDの雛形やスキルを自分で直していて競合したら、`Related DDRs`の行とDDRの手順はこの層のものに合わせ、自分で足した行は残す。

いまあるGDDに、`Related DDRs`の行は自動では足されない。GDDに決定の経緯（却下した案など）を書いているなら、DDRに移し、GDDの先頭に`> **Related DDRs**:`の行を足す。`/design-review`は、行が無いGDDを推奨の指摘として挙げる。

## 0.7.0（2026-10-23）

### 変更

TDRとADRの本文の節を、CCGSのADRの雛形の`##`の節を1対1で日本語にしたものに変えた（PDR-0006、#16）。節は、日付・最終確認日・決めた人・要約・エンジンとの互換・前提のADR・背景・決定・検討した案・影響・リスク・対応するGDDの要件・性能への影響・移行の手順・確かめ方・関連の16個である。`###`の見出しと、表の行の名前（`**層**`、`**前提**`など）も日本語にした。`graph.toml`の`tdr`と`adr`の`required_sections`は、この16節にした。英語の名前との対応は、`.claude/docs/templates/architecture-decision-record.md`に表で書いた。

状態は本文の`## Status`に書かず、フロントマターの`status`だけに持つ。CCGSのProposedは`draft`か`review`、Acceptedは`stable`、DeprecatedとSupersededは`deprecated`である。Supersededの後継は、後継の側の`supersedes`で指す。前提にするTDRとADRは、「前提のADR」の節の「前提」の行に加えて、フロントマターの`depends_on`にも書く。

`docs/00-meta/templates/`に、`tdr.md`と`adr.md`（16節）と`pdr.md`（これまでの6節）の雛形を足した。`adr.md`は、上流の既定の雛形を差し替えている。`pdr.md`が無いと、`new --type pdr`が雛形が無いと言って止まっていた。`/architecture-decision`は、`python -m tools.graph new --type tdr|adr`で記録を作ってから、本文を埋める。`/reverse-document`の`architecture`も同じ道で作る。`detect-gaps.sh`の「`docs/52-adr/`を作る」という案内も、`/architecture-decision`を回す案内に直した。

CCGSのスクリプトとスキルは、フロントマターの`status`と日本語の節を読み書きするように直した。`adr-status.sh`の状態の列は、`status`の値（`draft`・`review`・`stable`・`deprecated`）を出す。件数の行は、`tdrs`と`adrs`に分けた。行の頭は、TDRなら`TDR`、ADRなら`ADR`になる。`superseded_by`の列には、`supersedes`でその記録を指している記録を出す。日付の節が「なし」なら、`-`を出す。`adr-dep-graph.sh`は、件数を`TDRS`と`ADRS`に分け、「前提」の行と`depends_on`から依存を読む。「前提のADR」の節が「なし」だけなら、依存の無い記録として扱う。`/architecture-decision`の`accept`と`/propagate-design-change`は、`## Status`の行ではなく、フロントマターの`status`を書き換える。`retrofit`は、日本語の節と`status`を足す。

これに合わせて、`.claude/`の下のスキル・エージェント・文書がADRの英語の節と`## Status`を読んでいた箇所を直した。`studio-tests/`のテストの前提と期待も直した。CCGSの英語のファイルの中の説明文は、英語のままにしてある。

TDR-0001とTDR-0002は、これまでの6節（背景・決定・理由・却下した案・影響・見直しの条件）から、新しい16節に組み替えた。確定した記録を書き換えない決まりの例外で、setomさんが決めた。中身の文は変えていない。idと決定もそのままである。

| これまでの節 | 組み替えた先 |
| --- | --- |
| 本文の先頭の「日付」の行 | 日付の節 |
| 本文の先頭の「状態」の行 | 消した。状態はフロントマターの`status`にある |
| 背景 | 背景 |
| 決定 | 決定 |
| 理由 | 決定の節の`### 理由` |
| 却下した案 | 検討した案 |
| 影響 | 影響 |
| 見直しの条件 | 確かめ方の節の`### 見直しの条件` |

書くことの無い節（最終確認日・決めた人・要約・エンジンとの互換・前提のADR・リスク・対応するGDDの要件・性能への影響・移行の手順・関連）は「なし」にした。

`docs/registry/architecture.yaml`と`registry.sh`の`status`は、登録した方針の状態（`active`か`superseded_by`）で、記録の状態ではない。そのため変えていない。

この版で直したCCGSのファイルは、UC-02の手順3で、CCGSの更新のときに「手で合わせる」に出る。

### 取り込む側の作業

0.6.0で書いた「次の版が出るまで、`/architecture-decision`を使わない」は解けた。この版から使える。

`docs/51-tdr/`か`docs/52-adr/`に、CCGSの書式（英語の節と`## Status`）で自分が書いた記録があれば、`check`が`G014`で落ちる。1つずつ、日本語の節と`status`に移す。

1. フロントマターが無ければ、`docs/00-meta/templates/adr.md`のフロントマターを写し、`id`・`type`・`title`を埋める
2. `## Status`の値を、上の対応で`status`に移し、`## Status`の節を消す。Supersededなら、後継の記録の`supersedes`にこの記録のidを書く
3. 英語の節の名前を、`.claude/docs/templates/architecture-decision-record.md`の表で日本語に変える。`###`の見出しと表の行の名前も変える。節の中の文は変えない
4. 「前提のADR」の「前提」の行にあるTDRとADRを、`depends_on`にも書く
5. 足りない節を「なし」で足し、`python -m tools.graph sync`と`check`を回す

`/architecture-decision retrofit <パス>`でも、足りない節と`status`を足せる。

`docs/00-meta/templates/adr.md`を自分で直していて競合したら、この層のもの（16節）に合わせる。`.claude/`の下のCCGSのファイルを自分で直していて競合したら、ADRの節と状態の読み方はこの層のものに合わせ、自分で足した行は残す。

## 0.6.0（2026-10-23）

### 変更

CCGSのスキルとスクリプトが書き、読むADRの置き場を、`docs/architecture/`からTDRとADRのフォルダに移した（PDR-0006、#16）。TDRは`docs/51-tdr/tdr-NNNN-[slug].md`に、ADRは`docs/52-adr/adr-NNNN-[slug].md`に置く。番号は種別ごとに、そのフォルダの最大の番号に1を足して振る。`docs/architecture/`のほかの文書（`architecture.md`、`control-manifest.md`、`tr-registry.yaml`など）の置き場は変えていない。

`/architecture-decision`に、書く前にTDRかADRかを選ぶ手順（Step 2）を足した。ゲームのコードの外から何を使うかを決めるならTDR、ゲームの中をどう組むかを決めるならADRにする。1つの話が両方にまたがるときは、TDRとADRの2つに分けてTDRから先に書き、ADRの`**Depends On**`の行でTDRを指す。どちらか決めきれないときは、推測せずに利用者に聞く。書くidとパスは、選んだ種別に合わせる。

スクリプトは、`TDR-NNNN`と`ADR-NNNN`の両方を読み、2つのフォルダを見るようにした。`adr-dep-graph.sh`、`adr-status.sh`、`story-facts.sh`は、依存の行やストーリーの行にあるTDRのidも読む。`adr-status.sh`に番号だけを渡すと、ADRとして探す。`registry.sh next-id`には`tdr`を足した。`registry.sh`は、アーキテクチャの登録簿の`status`に`superseded_by: TDR-NNNN`も認める。`read-guard.sh`と`validate-read.sh`は、2つのフォルダの大きな文書も丸ごとの読み込みを止める。

プロジェクトの段階を推し量る箇所は、ADRだけを数え、TDRを数えない。このテンプレートは、固定したエンジンのTDR（TDR-0001、TDR-0002）を配っているので、TDRを数えると、作り始めたばかりの派生も先の段階にあると判定される。当たるのは、`project-state.sh`の`phase_inferred`、`statusline.sh`、`detect-gaps.sh`、`workflow-catalog.yaml`のADRの段、`/help`、`/project-stage-detect`、`/gate-check`の「ADRが3つ以上」の項目である。`project-state.sh`は、ADRの数とは別にTDRの数を`tdr`の行に出す。

これに合わせて、`.claude/`の下のスキル・エージェント・文書のADRのパスと、`studio-tests/`のテストの前提と期待、`docs/registry/architecture.yaml`と`docs/WORKFLOW-GUIDE.md`の例のパスを直した。`studio-tests/skills/authoring/architecture-decision.md`には、種別を選ぶ手順を確かめるCase 7を足した。`graph.toml`の`exclude`の注記は、`docs/architecture/`がADRの置き場ではなくなったので書き直した。

ADRの本文の節（`## Status`などの英語の節）・状態の書き方・フロントマターは、まだCCGSのままである。そのため、`/architecture-decision`でいまADRやTDRを書くと、フロントマターの無いファイルが`docs/51-tdr/`か`docs/52-adr/`に入り、`check`が落ちる。節と`status`を合わせるのは、次の版である。

この版で直したCCGSのファイルは、UC-02の手順3で、CCGSの更新のときに「手で合わせる」に出る。

### 取り込む側の作業

次の版が出るまで、`/architecture-decision`を使わない。使うと、上に書いたとおり`check`が落ちる。

`docs/architecture/`に自分のADR（`adr-NNNN-*.md`）があれば、CCGSのスキルとスクリプトからはもう見えない。1つずつ、TDRかADRかを決めて、その種別のフォルダに移す。番号は種別ごとに0001から振り直し、そのADRを指しているストーリー・ADR・`docs/registry/architecture.yaml`のidとパスも直す。移したファイルは、次の版で節と`status`を合わせるまで`check`が落ちる。

`.claude/`の下のCCGSのファイルを自分で直していて競合したら、ADRのパスとidの読み方はこの層のものに合わせ、自分で足した行は残す。

## 0.5.2（2026-10-23）

### 変更

UC-02（CCGSの更新を取り込む）を、PDR-0006に沿って書き直した（#16）。これまでは、「上書きしてよいファイル」の一覧を`git checkout`でまとめて写し、この層で直したファイルを戻していた。いまは、CCGSで変わったファイルごとに、いまの版のCCGSと手元を`git diff v<いまの版> HEAD`で比べる。差が無いファイルは新しい版をそのまま写し、差があるファイルだけ`git diff v<いまの版> ccgs/main`を読んで手で合わせる。直したファイルの一覧は、手で持たない。

### 取り込む側の作業

無い。UC-02は、game-templateを保守する人の手順である。

## 0.5.1（2026-10-23）

### 追加

CCGSの取り込み方と、決定の記録の分け方の決定を、PDR-0006に書いた（#16）。CCGSは丸ごと取り込み、CCGSのファイルも必要なら直す。CCGSの更新は、上書きで写すのではなく、更新の中身を読んで取り入れる。決定の記録は、PDR・TDR・ADR・DDRの4つの種別に分け、番号は種別ごとに0001から振る。TDRとADRの節はCCGSのADRの雛形の節を日本語にし、状態はフロントマターの`status`だけに持つ。

PDR-0006は、PDR-0002（CCGSの取り込み方）とPDR-0004（ADRの置き場）を置き換えた。2つの`status`を`deprecated`にし、UC-02と`graph.toml`の注記の参照をPDR-0006に直した。`graph.toml`の`exclude`の注記は、0.4.0の振り直しでPDR-0003を指していたが、PDR-0006に直した。

### 取り込む側の作業

自分の文書がPDR-0002かPDR-0004を指していれば、取り込んだあとに`check`が`G020`を出す。PDR-0006の決定の節で、引き継ぐものと改めるものを確かめ、PDR-0006に差し替える。

## 0.5.0（2026-10-23）

### 追加

`make ci`を足した。GitHub Actionsが動かないときに、`graph-check.yml`と同じ検査を手元で回す。`make ci PR=<番号>`とPRの番号を渡すと、PRのときにしか走らない`refs`と`names`も、ghでPRの題・本文・ブランチ・コミットを読んで回す。ターゲットはプロジェクト側の`graph.mk`に置き、中身は`scripts/local_ci.py`に書いた。`Makefile`はテンプレートと共通なので書き換えていない。META-05の「6. コミットとマージ」に、Actionsが動かないときはこれを回して通ればマージしてよいことを書いた。

### 取り込む側の作業

`graph.mk`を自分で置いていて競合したら、両方の行を残す。`graph.mk`は`-include`で読まれるので、`.DEFAULT_GOAL := help`の行も残す。残さないと、引数なしの`make`が`ci`を回す。META-05（`docs/00-meta/dev-flow.md`）は`merge=ours`なので届かない。使うなら、追加した段落を手で写す。

## 0.4.0（2026-10-22）

### 変更

決定の記録を、PDR・TDR・ADRの3つの種別に分けた（#16）。`graph.toml`に`[node_types]`を足し、`pdr`（開発の進め方の決定、`docs/50-pdr/`）、`tdr`（ゲームの外の技術の決定、`docs/51-tdr/`）、`adr`（ゲームの中の構成の決定、`docs/52-adr/`）を置いた。フォルダの50番台は、決定の記録に使う。3つとも層は90で、層のルールの対象外にし、確定したら書き換えない記録として扱う。必須の節は、既定の`adr`と同じにした。番号は種別ごとに0001から振る。ゲームデザインの決定（DDR）は`docs/53-ddr/`に置くが、雛形とGDDとのつなぎを含めて別のPRで足す。

種別を1つでも書くと、書いたものが種別の全体になる。そのため、`architecture`・`domain`・`usecase`・`contract`は、`tools/graph/schema.py`の既定の種別を同じ内容で書き写した。上流が既定の種別を変えても、`graph.toml`には届かない。上流の変更履歴を見て、手で合わせる。

これまでの決定の記録は、`rename`で振り直した。これまでのコミット・PRの題・変更履歴にある旧idは、次の表で読み替える。

| 旧id | 新id |
| --- | --- |
| ADR-0001 | PDR-0001 |
| ADR-0003 | PDR-0002 |
| ADR-0004 | PDR-0003 |
| ADR-0006 | PDR-0004 |
| ADR-0007 | PDR-0005 |
| ADR-0002 | TDR-0001 |
| ADR-0005 | TDR-0002 |

目次は、`docs/50-adr/index.md`（IDX-ADR）をIDX-PDRとして`docs/50-pdr/`へ移し、`docs/51-tdr/`（IDX-TDR）と`docs/52-adr/`（IDX-ADR）の目次を作った。`docs/52-adr/`には、まだノードが無い。`docs/50-adr/`は無くなった。

確定したDRのidの振り直しは、本文の中身を変えないので、書式の修正と同じ扱いにした。直したのは、フロントマターのid・type・エッジと、本文のidとリンクだけである。

`.gitattributes`の`merge=ours`の行は、`docs/50-pdr/pdr-0001-graph-driven-docs.md`に直した。UC-02、`README.md`、`.claude/rules/ccgs-studio.md`、`.claude/hooks/session-start.sh`、`/setup-engine`の手順4の注記にあった`docs/50-adr/`とidも、新しいものに直した。CCGSのスキルとスクリプトが書く`docs/architecture/`のADRは、まだ変えていない。

### 取り込む側の作業

`make update`で、`graph.toml`の`[node_types]`と、振り直したPDR-0001〜PDR-0005・TDR-0001・TDR-0002が届く。`graph.toml`を自分で書き換えていて競合したら、`[node_types]`の表はこの層のものに合わせ、自分で足した`exclude`の行は残す。

`.gitattributes`の`merge=ours`の行が、`docs/50-pdr/pdr-0001-graph-driven-docs.md`に変わる。派生で`.gitattributes`を書き換えていて競合したら、この行を新しいパスにする。

取り込んだあと、`docs/50-adr/`に自分のADR（ADR-0008から）が残っていれば、`check`が`G003`を出す。1つずつ、PDR・TDR・ADRのどれに当たるかを決め、`rename`でその種別の次の番号に振り直す。

```bash
python -m tools.graph rename --from ADR-0008 --to PDR-0006
```

ADRのままにするものも、ADR-0001から振り直す。振り直すと`docs/52-adr/`へ移る。

```bash
python -m tools.graph rename --from ADR-0009 --to ADR-0001
```

振り直したら`make all`を回し、`docs/50-adr/`が空なら消す。本文の地の文にある`docs/50-adr/`は、手で直す。確定したDRは、idとリンクのほかは変えない。

---

## 0.3.2（2026-10-22）

### 修正

CCGSの`.claude/hooks/session-start.sh`と`/setup-engine`が、エンジンの版の読み込みの行を`.claude/rules/ccgs-studio.md`から探すようにした（#11）。これまでは、ルートの`CLAUDE.md`しか探さなかったので、エンジンの照合が黙って行われず、`/setup-engine`を実行し直しても書き換える行を見つけられなかった。ルートの`CLAUDE.md`は、これまでどおり手を入れない。

決めたことは、ADR-0007に書いた。直したファイルはCCGSの更新で上書きされるので、UC-02に戻して合わせる手順を足した。

### 取り込む側の作業

無い。

---

## 0.3.1（2026-10-22）

### 修正

CCGSの`/architecture-decision`で`docs/architecture/`にADRを書くと、フロントマターが無いので`make check`が`G001`で落ちていた（#12）。`graph.toml`の`exclude`に`docs/architecture/`を足し、graphの検証から外した。

ADRの置き場は、役割で2か所に分けた。`docs/50-adr/`にはテンプレートと開発の進め方の決定をgraphの書き方で書き、`docs/architecture/`には作品のゲームの技術の決定をCCGSの書式で書く。番号は別々に数える。決めたことはADR-0006に書き、UC-02と`docs/50-adr/index.md`に案内を足した。

### 取り込む側の作業

無い。`graph.toml`の変更は`make update`で届く。

---

## 0.3.0（2026-10-22）

### 追加

CCGSの`/setup-engine godot 4.7.2`に当たる設定をし、言語をGDScriptにした（#1）。`.claude/rules/ccgs-studio.md`の「Technology Stack」、`.claude/docs/technical-preferences.md`、`project.yaml`の`engine`・`specialists`・`naming`・`commands`の節に、GDScriptの場合の値を書いた。描画の方式、物理エンジン、書き出しの設定のように作品ごとに違う値は、`[TO BE CONFIGURED]`のまま残した。

決めたことは、ADR-0005に書いた。UC-02には、CCGSの更新で上書きされる`technical-preferences.md`を戻して合わせる手順を足した。

### 取り込む側の作業

無い。設定は`make update`で届く。`[TO BE CONFIGURED]`のまま残した`engine.rendering`、`engine.physics`、`commands.build`は、作品を作るときに`/settings`で決める。

---

## 0.2.0（2026-10-22）

### 追加

CCGS（Claude-Code-Game-Studios、MITライセンス）の1.2.0を取り込んだ（#1）。CCGSの`UPGRADING.md`のStrategy A2で、`.claude/`、`design/`、`src/`、`docs/`、`production/`、`studio-tests/`、`project.yaml`、`.worktreeinclude`、`UPGRADING.md`、`CHANGELOG.md`を写した。CCGSの`LICENSE`は`LICENSE-CCGS`として残した。`README.md`、`CONTRIBUTING.md`、`.gitignore`、ルートの`CLAUDE.md`、`.github/`の下のファイル、`SECURITY.md`は写していない。

CCGSの`docs/`にあるフロントマターの無いMarkdownは、`graph.toml`の`exclude`でgraphの検証から外した。

CCGSのルートの`CLAUDE.md`の内容は、`.claude/rules/ccgs-studio.md`へ移した。ルートの`CLAUDE.md`はgraphの共通ファイルのままである。`.gitattributes`の末尾に、CCGSの指定を5行足した。

決めたことは、ADR-0002（Godotの版）、ADR-0003（取り込み方）、ADR-0004（`CLAUDE.md`の扱い）に書いた。CCGSの更新を取り込む手順は、UC-02に書いた。

### 取り込む側の作業

無い。CCGSのファイルは、`make update`で届く。

---

## 0.1.0（2026-10-22）

### 追加

graph-project-templateの上に、game-templateの層を作った。Godotの素材をGit LFSで扱う設定を`.gitattributes`に足した。

### 取り込む側の作業

無い。
