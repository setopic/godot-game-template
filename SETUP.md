# 開発環境を用意する

game-templateから作った作品で、開発を始めるまでの手順である。作品に参加した人は「1. 前提ツール」と「2. 参加した人がすること」を行う。作品のリポジトリを作った人は、その前に「3. 作品を作った人が1回だけすること」を行う。

この文書はgame-templateの共通ファイルなので、作品は書き換えない。テンプレートが手順を直すと、`make update`で作品にも届く。作品に固有の手順は、作品の`README.md`に書き、この文書へのリンクを残す。

この文書を含むこの層の日本語の文書と、CCGSから取り込んだ英語の文書（`docs/WORKFLOW-GUIDE.md`・`UPGRADING.md`など）が食い違うときは、日本語の文書に従う。CCGSの文書の食い違う箇所には、`game-template (…)`で始まる注記を付けて、日本語の文書を指している。

作品を起こす手順と開発環境の手順では、確定したTDR・PDR・ADRの「影響」などに書いた手順と食い違うときも、この文書に従う。確定した記録は本文を後から直さないので、書いた時点の手順が残っていることがある。たとえば[TDR-0002](docs/51-tdr/tdr-0002-gdscript.md)の「影響」は、`/setup-engine`を回し直し、gdUnit4を`/test-setup`で入れると書いているが、下の「3. 作品を作った人が1回だけすること」に従う。

## 1. 前提ツール

どのOSでも、次の3つを入れる。

- Godot 4.7.2の標準版（.NETでない版）。[GitHubのreleases](https://github.com/godotengine/godot/releases)の4.7.2-stableか、公式サイトから入れる。版の理由は[TDR-0001](docs/51-tdr/tdr-0001-godot-version.md)にある。`project.yaml`の`commands`はPATHの`godot`を呼ぶので、PATHに通す。`/settings`で`engine.path`にエディタのパスを設定する方法もある。`make ci`は、PATHに`godot`が無ければ`engine.path`のエディタを使う。
- Python 3.12以上。`python -m tools.graph check`と`make ci`が使う。
- GitとClaude Code。入れ方は、[setup-requirements.md](.claude/docs/setup-requirements.md)の「Required」にある。

Windowsでは、さらに次のものを入れる。bash・jq・Pythonの入れ方は、[setup-requirements.md](.claude/docs/setup-requirements.md)にある。

| ツール | 使うもの | 入れ方 |
| --- | --- | --- |
| Git for Windows（gitとbash） | `.claude/hooks/`のフック、`make ci`のGodotの段（`scripts/local_ci.py`） | [setup-requirements.md](.claude/docs/setup-requirements.md)の「Platform Notes」 |
| git-lfs | 素材の取り出し（下の`git lfs install`） | Git for Windowsに含まれる |
| gh | ラベルの作成（`gh label clone`）、`make ci PR=<番号>` | `winget install GitHub.cli`のあと、`gh auth login` |
| make | `make ci`・`make update`・`make readme` | `winget install ezwinports.make` |
| jq | `.claude/hooks/`のフックが入力のJSONを読む。無ければ、フックは`grep`で代わりに読む | [setup-requirements.md](.claude/docs/setup-requirements.md)の「Installing jq」 |

Windowsでは、Godotの実行ファイルは`Godot_v4.7.2-stable_win64.exe`という名前なので、そのままでは`godot`として呼べない。そのため、Godotを置いたフォルダに次の2つのファイルを作り、そのフォルダをPATHに足す。`godot`はbashから、`godot.cmd`はPowerShellとPythonから呼ぶためのものである。どちらも、ウィンドウを開かずに標準出力へ書く`_console.exe`のほうを呼ぶ。

```sh
#!/bin/sh
exec "$(dirname "$0")/Godot_v4.7.2-stable_win64_console.exe" "$@"
```

```bat
@"%~dp0Godot_v4.7.2-stable_win64_console.exe" %*
```

上が`godot`（拡張子なし）、下が`godot.cmd`の中身である。

次のコマンドで、入ったことを確かめる。Windowsでは、PowerShellとbashの両方で確かめる。`godot --version`は`4.7.2.stable`で始まる。

```bash
godot --version
python --version
```

## 2. 参加した人がすること

1. 上の「1. 前提ツール」を入れる。
2. `gh auth login`を回す。作品のリポジトリが非公開なら、HTTPSでcloneするのに、この認証が要る。`make ci PR=<番号>`がPRの題と本文を読むのにも使う。
3. 素材（画像・音・モデル・フォント）はGit LFSに入っている。取り出す前に、1度だけ`git lfs install`を回してから、作品のリポジトリをcloneする。Windowsでは、cloneの前に`git config --global core.longpaths true`も1度回す。`.claude/`の下に名前の長いファイルがあり、深いフォルダの下にcloneすると「Filename too long」で取り出しに失敗するからである。
4. `.godot/`はGitに入れないので、cloneした直後に`godot --headless --import`を1度回す。`project.godot`がまだ無い作品では要らない。
5. Claude Codeを、リポジトリの根で起動する。CCGSのフックと、書く前に確認する設定は、根で起動したときにだけ読み込まれる。参加した人は`/start`を回さない。`/start`は、作品の段階などを決めて`project.yaml`に保存するもので、作品を作った人が下の「3. 作品を作った人が1回だけすること」の3で1度だけ回す。また`/start`は、エンジンが決まっていると`project.godot`を作る手順を案内するが、`project.godot`を作るのはテンプレートの管理者である（下の「3」の5）。次に何をするかは、`/help`で分かる。
6. `make ci`が通ることを確かめる（下の「4. Godotのテスト」）。

`project.godot`か`addons/gdUnit4/`がまだ無い作品では、作品を作った人が下の「3. 作品を作った人が1回だけすること」の7までを済ませるまで、シーン・スクリプト・テストの作業を始めない。そのあいだの`make ci`は、`project.godotが無いので、Godotの段を飛ばす`と出して文書の検査だけを回すので、通ってもテストは回っていない。作品を作った人が7まで済ませたら、`git pull`してから、上の4と6を回し直す。

`*.blend`・`*.psd`・`*.kra`・`*.aseprite`は差分をマージできないので、編集の前にロックし、pushしたら外す。

```bash
git lfs lock <パス>
git lfs unlock <パス>
```

どのファイルをLFSに入れ、どのフォルダをGodotに読み込ませないかは、[TDR-0003](docs/51-tdr/tdr-0003-godot-git-settings.md)にある。ブランチ・PR・シーンの担当の決まりは、[META-05](docs/00-meta/dev-flow.md)にある。

## 3. 作品を作った人が1回だけすること

作品のリポジトリは、GitHubの"Use this template"で作る。[META-08](docs/00-meta/template-upgrade.md)の初回の手順は、"Use this template"で作ったリポジトリを前提にしている。`git clone`で作ると、`origin`がこのテンプレートを指したまま残る。CCGSの案内の`docs/WORKFLOW-GUIDE.md`は`git clone`を勧めているが、作品を起こすときはこの節に従う。

作ったあとは、上の「2. 参加した人がすること」の1〜3を行い、Claude Codeをリポジトリの根で起動してから、次の順に進める。各手順の中身は、リンク先にある。この節の「PR」は、1人でmainへ直接pushする作品（[META-05](docs/00-meta/dev-flow.md)の「5. PRを出すか、mainへ直接出すか」）では、その変更だけを入れたコミットに読み替える。

1. テンプレートと繋ぐ。[META-08](docs/00-meta/template-upgrade.md)の「1. 最初に一度だけ」を行う。upstreamのURLとラベルの作り方は、この層の値に置き換える（根の`README.md`の「テンプレートの更新を取り込む」の表）。"Use this template"で作った直後は、共通ファイルがテンプレートと同じなので、META-08の手順1（共通ファイルの上書き）は要らない。手順2から行う。
2. サンプルノードを消し、表紙を書き換える。根の`README.md`の下の段にある「自分のプロジェクトに合わせる」に従い、`python -m tools.graph reset-samples --yes`もここで回す。`README.md`を作品の説明に書き換えるときも、この文書へのリンクは残す。そのあと`make all`を回す。`check`が参照切れ（`G004`）を挙げたら、それを直してから回し直す。
3. 最初のセッションで`/start`を回す。`/start`は`project.yaml`を書き換えることがあり、`project.yaml`は`merge=ours`ではない。1の取り込みより前に回すと、取り込みで`project.yaml`が競合するおそれがあるので、ここで回す。`/start`が`project.yaml`に保存するかを聞いたら、「Save them」を選ぶ。`project.yaml`はテンプレートの管理者が持つファイルで、作品を作った人はその管理者だからである（下の段落）。書き換わった`project.yaml`と`production/stage.txt`は、その変更だけのPRにする。
4. GdUnit4を入れ、`addons/gdUnit4/`だけのPRを出す（下の「4. Godotのテスト」）。
5. `project.godot`を作る。`/setup-engine`は回さず、その7.5（[7.5-scaffold.md](.claude/skills/setup-engine/references/7.5-scaffold.md)）の手順だけを行う。7.5が使う`project.yaml`の`engine.rendering`は、先に`/settings`で決める。値は`Compatibility`・`Forward+`・`Mobile`のどれかで、`/settings engine.rendering=Forward+`のように書く。Webに書き出す作品では`Compatibility`、それ以外では`Forward+`が既定である（[5.5-project-yaml.md](.claude/skills/setup-engine/references/5.5-project-yaml.md)の表）。7.5は、この値から`project.godot`の描画の設定を書く。同じときに、`engine.physics`も`/settings`で決める。2Dの作品では`Godot Physics 2D`、3Dの作品では`Jolt`が既定である（同じ表）。値に空白があるときは、`/settings "engine.physics=Godot Physics 2D"`のように引用符で囲む。7.5は`engine.physics`を使わないが、`[TO BE CONFIGURED]`のまま残さないために、ここで決める。
6. 5のPRで、`EvidenceCapture`のautoloadの登録（[ADR-0001](docs/52-adr/adr-0001-evidence-capture-autoload.md)）と、GdUnit4のプラグインの有効化も行う。
7. `godot --headless --import`を1度回し、`make ci`が通ることを確かめる。

4より5を後にするのは、`project.godot`ができた時点で、CIが`tests/unit/qa/`のテストを回そうとするからである。`addons/gdUnit4/`が無いと、`.github/scripts/godot-ci.sh`がそこで落とす。

`/setup-engine`の全体を回さないのは、1〜7が共通ファイルを書き換えるからである。エンジンと版は、このテンプレートで決めてある。5と6は、テンプレートの管理者が`project.godot`だけを変えるPRで行う（[META-05](docs/00-meta/dev-flow.md)の「シーンと`project.godot`」）。作品では、`.github/CODEOWNERS`で`project.godot`の持ち主にした人を、テンプレートの管理者と呼ぶ。`CODEOWNERS`を置かない作品では、作品のリポジトリを作った人がテンプレートの管理者である。役割の分け方の雛形は`.github/CODEOWNERS.example`にある。

複数人で開発するなら、mainの保護も設定する（[META-05](docs/00-meta/dev-flow.md)の「複数人で開発するとき」）。

## 4. Godotのテスト

テストは、[GdUnit4](https://github.com/godot-gdunit-labs/gdUnit4)で書いて回す。このテンプレートは`addons/gdUnit4/`を配っていないので、作品ごとに入れる。Godot 4.7.2で動くことを確かめた版は6.2.2である（[current-best-practices.md](docs/engine-reference/godot/current-best-practices.md)）。

1. [GdUnit4のreleases](https://github.com/godot-gdunit-labs/gdUnit4/releases)から版を選び、中の`addons/gdUnit4/`をリポジトリの根の`addons/gdUnit4/`に置く。`gdUnit4`のUは大文字である。
2. `addons/gdUnit4/bin/GdUnitCmdTool.gd`があることを確かめ、`addons/gdUnit4/`だけのPRを出す。
3. プラグインの有効化（Project Settings → Plugins → GdUnit4）は`project.godot`を書き換えるので、上の「3. 作品を作った人が1回だけすること」の6で、`project.godot`だけのPRに入れる。エディタを使わずに有効にするときは、`project.godot`に次の節を書く。

   ```ini
   [editor_plugins]

   enabled=PackedStringArray("res://addons/gdUnit4/plugin.cfg")
   ```

エディタのAsset Storeから入れる手順は、[3-directories.md](.claude/skills/test-setup/references/3-directories.md)の「Installing GdUnit4」にある。ただしAsset Storeは`project.godot`のある状態で開くので、上の順番では使えない。

作品を作った人は、「3. 作品を作った人が1回だけすること」の7のあとに、`docs/WORKFLOW-GUIDE.md`の「Step 3.6: Test Framework」で`/test-setup`を回してよい。`/test-setup`はGdUnit4を入れないので、手で置いた`addons/gdUnit4/`はそのまま残る。作るのは、`tests/README.md`や`tests/smoke/critical-paths.md`など、まだ無いファイルだけで、すでにあるファイルは書き換えない。`.github/workflows/tests.yml`も作らない（[TDR-0004](docs/51-tdr/tdr-0004-godot-ci.md)）。例のテストは作らないので、Phase 3の関門が求める例のテストは、自分で`tests/unit/<system>/`に書く。

手元では、次のどちらかで回す。

| 回し方 | 何を回すか |
| --- | --- |
| `project.yaml`の`commands.test` | GdUnit4のテストだけ。`tests/`の下を全部回す |
| `make ci` | `graph-check.yml`と`app-check.yml`（書き出しを除く）と同じ検査。GdUnit4のテストも含む（[META-05](docs/00-meta/dev-flow.md)） |

`make ci PR=<番号>`のように番号を渡すと、PRのときにしか走らない検査も回す。`project.godot`が無いあいだは、`make ci`はGodotの段を飛ばす。

Windowsでは、`make ci`をGit Bashで回す。Godotの段は`bash`を呼ぶので、PowerShellで回すと、Git for Windowsの`bin`をPATHに足していない限り、`bashがPATHに無いので、Godotの段を回せない`と出て失敗する。`project.godot`が無いあいだは、Godotの段を飛ばすので、PowerShellでも通る。全部の段が通ると、最後の行に`local_ci: すべて通った`と出る。途中の段が落ちると、`local_ci: 失敗した（終了コード…）`などと出て、終了コードが0でなくなる。

自分のテストは、`tests/unit/<system>/`に置く（統合のテストは`tests/integration/<system>/`）。`tests/unit/qa/`はこの層の共通ファイルなので、そこには足さない（[PDR-0016](docs/50-pdr/pdr-0016-tests-unit-qa-common-file.md)）。テストの名前の付け方は、[test-standards.md](.claude/rules/test-standards.md)にある。
