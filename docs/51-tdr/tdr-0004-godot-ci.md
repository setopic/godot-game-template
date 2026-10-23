---
id: TDR-0004
type: tdr
title: GodotのCIをapp-check.ymlで回す
status: stable
tags: [engine, ci]
depends_on:
  - TDR-0001
  - TDR-0003
decides: []
supersedes: []
related: []
last_verified:
---

# GodotのCIをapp-check.ymlで回す

## 日付

2026-10-23

## 決めた人

setom

## 要約

CCGSのhooksは手元でしか動かず、hooksを通らなかった変更をだれも確かめていない。`app-check.yml`で、Godotを`chickensoft-games/setup-godot`で入れ、読み込みとGdUnit4のテストをpushとPRのたびに回し、mainへのpushのときだけWindowsとWebに書き出す。

## エンジンとの互換

| 項目 | 値 |
| --- | --- |
| **エンジン** | Godot 4.7.2（[TDR-0001](./tdr-0001-godot-version.md)） |
| **分野** | Core |
| **層** | Foundation |
| **知識のリスク** | HIGH（`docs/engine-reference/godot/VERSION.md`） |
| **参照した資料** | `docs/engine-reference/godot/current-best-practices.md`の「Command Line — Tests and Parse Check」 |
| **学習の範囲より後のAPI** | なし |
| **確かめること** | GitHub Actionsで、`project.godot`のある派生で各段が通ること。game-templateでは、GitHub Actionsが支払いの問題で動かず、まだ回していない |

## 前提のADR

| 項目 | 値 |
| --- | --- |
| **前提** | [TDR-0001](./tdr-0001-godot-version.md)、[TDR-0003](./tdr-0003-godot-git-settings.md) |
| **可能にするもの** | なし |
| **止めているもの** | なし |
| **順序の注意** | なし |

## 背景

### 解決したい問題

CCGSにはGitHubのworkflowが無く、CCGSのhooksはそれぞれの手元でしか動かない。Claudeを使わない人が入れた変更や、hooksを通らなかった変更は、だれも確かめていない（setopic/game-template#5）。

### いまの状態

`app-check.yml`は、下の層（`graph-project-template`）から届いた中身の無い雛形で、警告を出すだけである。CCGSの`/test-setup`は、`gdUnit4-action`を使う`tests.yml`を作る手順を持っている。

### 制約

- `graph-check.yml`はテンプレートが配るファイルなので、実装の検査を書き足さない
- game-templateには`project.godot`を置かない（[TDR-0002](./tdr-0002-gdscript.md)）。テンプレート自身にはGodotのプロジェクトが無い
- Godotは、エラーがあっても終了コードを0にすることがある
- 取り出した直後は`.godot/`が無く、`class_name`を使うスクリプトが読めない（[TDR-0003](./tdr-0003-godot-git-settings.md)）

### 要件

- pushとPRのときに、`godot --headless --path . --import`で読み込みを確かめる
- pushとPRのときに、GdUnit4のテストを回し、JUnitの形式の結果を成果物に残す
- mainへのpushのときに、ゲームを書き出して成果物に残す
- LFSのファイルと`.godot/imported/`をキャッシュする
- Godotの版を、[TDR-0001](./tdr-0001-godot-version.md)の4.7.2に固定する

## 決定

`.github/workflows/app-check.yml`に、Godotの検査を書く。Godotは`chickensoft-games/setup-godot`で4.7.2を指定して入れ、GdUnit4は`coding-standards.md`のコマンドで、`addons/gdUnit4/`にあるものを回す。判定は`.github/scripts/godot-ci.sh`に切り出し、偽のログで手元から確かめられるようにする。

各段と、それを回すときは次のとおりである。

| 段 | 回すとき | 失敗にするもの |
| --- | --- | --- |
| 素材の読み込み（`--import`） | pushとPR | 終了コードが0でないこと。0でも、ログに`ERROR:`・`SCRIPT ERROR:`・`USER ERROR:`で始まる行があること |
| スクリプトの読み込みの確認 | pushとPR | `src/`と`tests/`の`.gd`を`godot-parse-check.gd`で読み、上と同じ決まりで判定する |
| GdUnit4のテスト | pushとPR | 0と101のほかの終了コード。101は、テストはすべて通り、孤立したノードの警告だけがあるときの値なので通す |
| 書き出し | mainへのpush | 上と同じ決まりで判定する。`export_presets.cfg`の`Windows Desktop`と`Web`の書き出しの設定を、すべて書き出す |

`--import`は、スクリプトの構文の誤りがあっても0で終わる（`current-best-practices.md`）。そのため、読み込みの確認には、CCGSが持っている`godot-parse-check.gd`の段を足した。

GdUnit4の段は、ログの`ERROR`の行では判定しない。`--remote-debug`が、毎回`ERROR:`の行を2つ出すからである。テストの結果は`reports/`（JUnitの形式の`results.xml`を含む）とログを`test-results`の成果物に、書き出したものは`build/`を`build`の成果物に置く。

LFSのファイルは、`actions/checkout`の`lfs: true`では取らない。`lfs: true`だとキャッシュを戻す前に全部を落とすので、キャッシュが役に立たない。`lfs: false`で取り出し、LFSのファイルの一覧から作ったキーで`.git/lfs`をキャッシュから戻してから、`git lfs pull`で足りない分を落とす。`.godot/imported/`は、Godotの版と`*.import`の中身から作ったキーでキャッシュする。

次のときは、その段を飛ばして成功にし、飛ばしたことを`::notice`でログに出す。

| 状態 | 飛ばす段 |
| --- | --- |
| `project.godot`が無い（game-template自身） | Godotの段のすべて |
| `addons/gdUnit4/`も、`tests/`の`.gd`も無い | GdUnit4のテスト |
| `src/`と`tests/`に`.gd`が無い | スクリプトの読み込みの確認 |
| `export_presets.cfg`が無い | 書き出し |

`tests/`に`.gd`があるのに`addons/gdUnit4/`が無いときは、失敗にする。テストを回せないまま通ってしまうからである。`export_presets.cfg`にWindowsとWebの書き出しの設定が1つも無いときは、警告を出して通す。

### 構成の図

    push / PR
      checkout（lfs: false）
      godot-ci.sh detect ── project.godotが無い → 以下を飛ばす
      LFSのキャッシュ → git lfs pull
      .godot/importedのキャッシュ
      setup-godot（mainへのpushでは書き出しの雛形も）
      --import ─ godot-ci.sh checked
      godot-parse-check.gd ─ godot-ci.sh checked
      GdUnit4 ─ godot-ci.sh gdunit → test-results
      （mainへのpushだけ）--export-release ─ godot-ci.sh checked → build

### 主なインタフェース

`.github/scripts/godot-ci.sh`の4つの命令（`detect`・`checked`・`gdunit`・`presets`）である。使い方はファイルの冒頭にある。

### 実装の指針

- 使うactionは、出てから2週間以上たった版を、コミットのshaで固定し、行末にタグを書く
- Godotの版を変えるときは、`app-check.yml`の`GODOT_VERSION`を[TDR-0001](./tdr-0001-godot-version.md)の後継の記録と合わせる
- 新しい環境で、`--import`の前にGdUnit4やスクリプトの読み込みを回してはならない
- `--import`が終了コード139（セグメンテーション違反）で終わったときだけ、1度回し直す。`ERROR`の行のときは回し直してはならない。2度目に出なくなったエラーを見逃すからである
- `/test-setup`で`tests.yml`を作ってはならない。同じテストを2度回すことになる

## 検討した案

### 案1: gdUnit4-actionでGodotを入れてテストを回す

- **説明**: `godot-gdunit-labs/gdUnit4-action`が、Godotを入れてGdUnit4を回し、結果をcheck runに出す。CCGSの`/test-setup`の手順はこれを使う
- **利点**: 書くことが少なく、結果がPRの画面に出る
- **欠点**: 画面の無いCIでは遅くなるという報告がある（gdUnit4Netのdiscussions/350）。`version: installed`を書き忘れると、`addons/`のGdUnit4を消して最新を入れる。check runに出すため`checks: write`の権限が要る
- **見積もりの手間**: 選んだ案より小さい
- **採らなかった理由**: 書き出しのためにGodotを別に入れることになり、Godotを入れる手段が2つになる。手元と同じコマンドで回すほうが、CIだけで落ちたときに手元で同じことを試せる

### 案2: 終了コードだけで判定する

- **説明**: `--import`や書き出しの終了コードが0なら通す
- **利点**: ログを読む部分が要らない
- **欠点**: Godotは、エラーがあっても終了コードを0にすることがある。`--import`は、スクリプトの構文の誤りがあっても0で終わる
- **見積もりの手間**: 選んだ案より小さい
- **採らなかった理由**: 読み込めていないプロジェクトが通ってしまう

### 案3: Windowsだけを書き出す

- **説明**: 書き出しの対象をWindowsに絞る
- **利点**: 書き出しが短く、成果物も小さい
- **欠点**: Webで動かない変更に、遊んで確かめるまで気づかない
- **見積もりの手間**: 選んだ案より少し小さい
- **採らなかった理由**: Webは、ブラウザで開くだけで遊べるので、試してもらうときに使いやすい。書き出しの設定が無ければ飛ばすので、Webに出さない作品で手間は増えない

### 案4: PRでも書き出す

- **説明**: pushとPRのたびに書き出す
- **利点**: 書き出せなくなる変更を、マージの前に見つけられる
- **欠点**: 書き出しの雛形を毎回入れることになり、PRのCIが長くなる
- **見積もりの手間**: 選んだ案と同じ
- **採らなかった理由**: 読み込みとテストはPRで回すので、書き出しでだけ落ちる変更は少ない。書き出しはmainへのpushで回し、落ちたらそのとき直す

## 影響

### 良い影響

- hooksを通らなかった変更も、pushとPRのたびに読み込みとテストを確かめる
- mainのWindowsとWebの書き出しが、成果物として残る
- 判定が`godot-ci.sh`にあるので、手元で偽のログを渡して確かめられる

### 悪い影響

- `app-check.yml`は`merge=ours`なので、game-templateがこのファイルを直しても、派生には取り込みで届かない。派生は、変更履歴を見て手で写す
- LFSのキャッシュのために、checkoutのあとに段が3つ増える

### どちらでもない影響

- 判定の補助の`godot-ci.sh`は、`.github/scripts/`に置く。名前が`.`で始まるフォルダなので、Godotは読み込まない

## リスク

- GitHub Actionsが支払いの問題で動かないため、game-templateではこのworkflowを回していない。書式はactionlintとshellcheckで、判定の部分は偽のログで確かめた。最初に`project.godot`を持つ派生でCIが動いたとき、各段を確かめる
- GdUnit4の最新版の対応表に、4.7.2がまだ載っていない（[TDR-0001](./tdr-0001-godot-version.md)）。CCGSの`current-best-practices.md`には、Windowsの手元で4.7.2とGdUnit4 6.2.2が動いた記録がある。Linuxのrunnerで動くかは、上と同じときに確かめる
- 新しいプロジェクトの最初の`--import`が、Godotの終了のときに落ちることがある。対策は、139のときだけ1度回し直すことである
- 素材の読み込みで、プロジェクトの誤りではない`ERROR`の行が出ると、CIが落ちる。出たら、その行を見て、プロジェクトを直すか、この記録を置き換えて除く行を決める

## 対応するGDDの要件

基盤の決定で、GDDの要件は無い。可能にするもの: なし

## 性能への影響

- **CPU**: なし
- **メモリ**: なし
- **読み込みの時間**: なし
- **ネットワーク**: CIで、Godotと書き出しの雛形とLFSのファイルを落とす。どれもキャッシュする

## 移行の手順

なし

**戻す手順**: `app-check.yml`を下の層の雛形に戻し、`.github/scripts/godot-ci.sh`を消す

## 確かめ方

`project.godot`を持つ派生でPRを出し、読み込み・スクリプトの読み込みの確認・GdUnit4の段が回って`test-results`が残ることを確かめる。mainへのpushで、`build`にWindowsとWebの書き出したものが入ることを確かめる。game-template自身では、Godotの段を飛ばしたという`notice`が出て成功することを確かめる。

### 見直しの条件

`--import`で、プロジェクトの誤りではない`ERROR`の行が出るとき。gdUnit4-actionの遅さが直り、書き出しにも使えるようになったとき。

## 関連

- [TDR-0001](./tdr-0001-godot-version.md)（前提にする）
- [TDR-0003](./tdr-0003-godot-git-settings.md)（前提にする）
- `.github/workflows/app-check.yml`、`.github/scripts/godot-ci.sh`、`.claude/skills/test-setup/references/4-ci.md`

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`depends_on`: この文書が成立するために前提となるノード

- [TDR-0001 Godotの版を4.7.2にする](./tdr-0001-godot-version.md)
- [TDR-0003 Godot用のGitの設定をそろえる](./tdr-0003-godot-git-settings.md)

<!-- graph:auto:end -->
