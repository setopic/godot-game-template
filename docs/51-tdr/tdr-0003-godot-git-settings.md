---
id: TDR-0003
type: tdr
title: Godot用のGitの設定をそろえる
status: stable
tags: [engine]
depends_on:
  - TDR-0001
decides: []
supersedes: []
related: []
last_verified:
---

# Godot用のGitの設定をそろえる

## 日付

2026-10-23

## 決めた人

setom

## 要約

Godotのプロジェクトで、どのファイルをGit LFSに入れ、どのファイルをGitから外し、どのフォルダをGodotに読み込ませないかを決める。LFSと`lockable`の対象は`.gitattributes`のとおりにし、`export_presets.cfg`はGitに入れ、`.godot/`は`.gitignore`で外し、Godotの素材を置かないフォルダには`.gdignore`を置く。

## エンジンとの互換

| 項目 | 値 |
| --- | --- |
| **エンジン** | Godot 4.7（[TDR-0001](./tdr-0001-godot-version.md)） |
| **分野** | Core |
| **層** | Foundation |
| **知識のリスク** | HIGH（`docs/engine-reference/godot/VERSION.md`） |
| **参照した資料** | GodotのドキュメントのVersion control systems（4.6） |
| **学習の範囲より後のAPI** | なし |
| **確かめること** | Godotのエディタで開いたとき、`.gdignore`を置いたフォルダが読み込まれないこと |

## 前提のADR

| 項目 | 値 |
| --- | --- |
| **前提** | [TDR-0001](./tdr-0001-godot-version.md) |
| **可能にするもの** | なし |
| **止めているもの** | 素材の最初のコミット。CIでの書き出し（setopic/game-template#5） |
| **順序の注意** | LFSの設定は、素材の最初のコミットより前に入れる |

## 背景

### 解決したい問題

Godotのプロジェクトには、画像・音・モデルのような大きなファイルが入る。LFSの設定は、最初のコミットより前に入れないと、後から`git lfs migrate`で履歴を書き換えることになる（setopic/game-template#3）。

Godotは、プロジェクトの下にあるファイルをすべて読み込もうとする。このリポジトリには、graphの文書・CCGSの設計の文書・Pythonの道具のような、ゲームの素材ではないファイルが多い。

### いまの状態

`.gitattributes`には、LFSと`lockable`の行が入っている。`.gitignore`には、Godot用の行が無い。`.gdignore`は、CCGSが置いた`production/.gdignore`だけである。

### 制約

- CCGSの`.gitignore`は`export_presets.cfg`を外しているが、CIでの書き出しにはこのファイルが要る
- `.gitignore`は`merge=ours`ではないので、下の層から届いた行を消さない
- `.gdignore`はフォルダの下のすべてを外すので、Godotのテストを置くフォルダには置けない

### 要件

- `.godot/`と`*.translation`はGitに入らず、`.import`と`.uid`はGitに入る
- Godotのエディタで開いたとき、`design/`と`tools/`が読み込まれない

## 決定

LFSに入れるものと`lockable`を付けるものは、`.gitattributes`のこの層の行のとおりにする。画像・音・モデル・フォントと`production/qa/evidence/**`はLFSに入れ、`*.blend`・`*.psd`・`*.kra`・`*.aseprite`には`lockable`も付ける。`*.gd`・`*.tscn`・`*.tres`・`*.import`・`*.uid`・`*.md`は、LFSに入れずにテキストのまま扱う。

`export_presets.cfg`はGitに入れる。Godot 4.1以降は、パスワードなどを`.godot/export_credentials.cfg`に分けて書くからである。

`.gitignore`には、この層の節を足して次の3行を書く。

| 行 | 外すもの |
| --- | --- |
| `.godot/` | エディタが作る置き場（読み込んだ素材の写し、キャッシュ、`export_credentials.cfg`） |
| `/android/` | Androidのビルドの雛形 |
| `*.translation` | CSVの翻訳から読み込みのときに作られるファイル |

Godotの素材を置かないフォルダには、`.gdignore`を置く。

| フォルダ | 置くか |
| --- | --- |
| `design/`、`docs/`、`tools/`、`studio-tests/`、`scripts/` | 置く |
| `production/` | CCGSがすでに置いている |
| `tests/` | 置かない。Godotのテストを`tests/unit/`と`tests/integration/`に置くので、`tests/`に置くとそれも読み込まれなくなる |
| `.claude/`、`.github/` | 置かない。Godotのエディタは、名前が`.`で始まるフォルダを読み込まない |

`tests/`の直下にあるPythonのテスト（graphの道具のもの）は、Godotが素材として扱う拡張子ではないので、読み込まれても素材にはならない。

### 構成の図

なし

### 主なインタフェース

なし

### 実装の指針

- 素材を最初にコミットする前に、`git lfs install`を回す
- `*.blend`・`*.psd`・`*.kra`・`*.aseprite`は、編集の前に`git lfs lock <パス>`でロックし、コミットしてpushしたら`git lfs unlock <パス>`で外す
- `export_presets.cfg`に、パスワードや鍵を書いてはならない
- Godotの素材を置かないフォルダを根に足したら、`.gdignore`も置く

## 検討した案

### 案1: CCGSの`.gitignore`の形で、`export_presets.cfg`を外す

- **説明**: CCGSの`.gitignore`のとおり、`export_presets.cfg`をGitに入れない
- **利点**: 古い版のGodotで、書き出しの設定にパスワードが書かれても漏れない
- **欠点**: CIで書き出すとき、書き出しの設定を別の手段で渡す必要がある
- **見積もりの手間**: 選んだ案より大きい
- **採らなかった理由**: Godot 4.1以降は、パスワードなどを`export_presets.cfg`に書かない。このプロジェクトのGodotは4.7である（[TDR-0001](./tdr-0001-godot-version.md)）

### 案2: CCGSの`.gitignore`の形で、`.godot/`の中身を外し、`global_script_class_cache.cfg`だけを入れる

- **説明**: `**/.godot/*`で中身を外し、`!**/.godot/global_script_class_cache.cfg`でクラスの一覧だけをGitに入れる
- **利点**: 取り出した直後でも、`class_name`を使うスクリプトを読み込める
- **欠点**: エディタが書き換えるファイルがGitに入り、差分と競合が増える
- **見積もりの手間**: 選んだ案と同じ
- **採らなかった理由**: `.godot/`はエディタが作り直す置き場なので、まとめて外す。取り出した直後は、`godot --headless --import`を1度回して作る

## 影響

### 良い影響

- 素材を最初からLFSに入れられる
- CIで、Gitにある`export_presets.cfg`を使って書き出せる
- Godotのエディタが、ゲームの素材ではない文書や道具を読み込まない

### 悪い影響

- 取り出した直後は、`.godot/`が無いので、`godot --headless --import`を1度回すまで`class_name`を使うスクリプトが読み込めない

### どちらでもない影響

- 根に`.gdignore`のファイルが5つ増える

## リスク

- `export_presets.cfg`に、手でパスワードを書いてしまう。対策は、実装の指針の決まりと、書き出しの設定をGodotのエディタで書くことである
- CIや新しく取り出した環境で、`--import`を回し忘れる。対策は、CIでの書き出し（setopic/game-template#5）の手順に`godot --headless --import`を入れることである

## 対応するGDDの要件

基盤の決定で、GDDの要件は無い。可能にするもの: なし

## 性能への影響

- **CPU**: なし
- **メモリ**: なし
- **読み込みの時間**: Godotのエディタが読み込むファイルが減る
- **ネットワーク**: LFSのファイルは、取り出すときに別に落とす

## 移行の手順

なし

**戻す手順**: `.gitignore`のこの層の節と`.gdignore`を消す。LFSから外すときは、`git lfs migrate export`で履歴を書き換える

## 確かめ方

`git check-ignore -v`で、`.godot/`の下と`*.translation`が外れ、`export_presets.cfg`・`.import`・`.uid`が外れないことを確かめる。Godotのエディタでプロジェクトを開き、ファイルシステムのドックに`.gdignore`を置いたフォルダが出ないことを確かめる。

## 関連

- [TDR-0001](./tdr-0001-godot-version.md)（前提にする）
- `.gitattributes`、`.gitignore`、各フォルダの`.gdignore`

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`depends_on`: この文書が成立するために前提となるノード

- [TDR-0001 Godotの版を4.7.2にする](./tdr-0001-godot-version.md)

このノードを参照しているノード

- (depends_on) [TDR-0004 GodotのCIをapp-check.ymlで回す](./tdr-0004-godot-ci.md)

<!-- graph:auto:end -->
