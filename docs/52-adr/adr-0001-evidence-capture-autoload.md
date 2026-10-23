---
id: ADR-0001
type: adr
title: スクリーンショットの証拠を1つのautoloadで撮る
status: stable
tags: [qa]
depends_on:
  - TDR-0001
  - TDR-0002
  - TDR-0003
decides: []
supersedes: []
related: []
implemented_by:
  - src/qa/evidence_capture.gd
last_verified:
---

# スクリーンショットの証拠を1つのautoloadで撮る

## 日付

2026-10-23

## 決めた人

setom

## 要約

CCGSはプレイヤーに見える変更を閉じるときにスクリーンショットを残すことを求めるが、撮り方が決まっておらず、人によってばらばらになる。`src/qa/evidence_capture.gd`のautoloadが、起動の引数（Claude）とF12のキー（人）の両方で撮り、どちらも`production/qa/evidence/<ストーリーのid>/<日時>-<名前>.png`に置く。

## エンジンとの互換

| 項目 | 値 |
| --- | --- |
| **エンジン** | Godot 4.7（[TDR-0001](../51-tdr/tdr-0001-godot-version.md)） |
| **分野** | Core |
| **層** | Foundation |
| **知識のリスク** | HIGH（`docs/engine-reference/godot/VERSION.md`） |
| **参照した資料** | `docs/engine-reference/godot/breaking-changes.md`、`deprecated-apis.md`、`modules/input.md`、`.claude/docs/run-and-observe.md` |
| **学習の範囲より後のAPI** | なし |
| **確かめること** | Godot 4.7.2で、引数で撮ると終了コード0でPNGができること。F12で撮れること。書き出したゲームで動かないこと |

## 前提のADR

| 項目 | 値 |
| --- | --- |
| **前提** | [TDR-0001](../51-tdr/tdr-0001-godot-version.md)、[TDR-0002](../51-tdr/tdr-0002-gdscript.md)、[TDR-0003](../51-tdr/tdr-0003-godot-git-settings.md) |
| **可能にするもの** | なし |
| **止めているもの** | なし |
| **順序の注意** | 作品は、最初に見た目の変わるストーリーを閉じる前に、`project.godot`にautoloadを登録する |

## 背景

### 解決したい問題

CCGSは、プレイヤーに見える変更を完了にするとき、実際に動かして撮ったスクリーンショットを`production/qa/evidence/`に残すことを求める。撮り方が決まっていないと、人によって撮り方がばらばらになり、Claudeも撮れない（setopic/game-template#6）。

### いまの状態

CCGSの`run-and-observe.md`は、Godotでは`--write-movie`で連番の画像を書き出し、最後の1枚を使う手順を書いている。ファイル名にフレームの番号が付き、人が遊びながら撮る手順は無い。

### 制約

- `--headless`では画面を描かないので、CIでは撮れない
- 書き出したゲームには、このautoloadが入らないか、入っても動かない
- `production/qa/evidence/**`はLFSに入る（[TDR-0003](../51-tdr/tdr-0003-godot-git-settings.md)）
- game-templateには`project.godot`を置かない（[TDR-0002](../51-tdr/tdr-0002-gdscript.md)）

### 要件

- ClaudeがBashから起動して、スクリーンショットを1枚撮れる
- 人が手元で撮るときも、同じやり方で撮れる
- 撮り方が、QAの文書に書いてある

## 決定

`src/qa/evidence_capture.gd`をautoloadにし、作品が`project.godot`に`EvidenceCapture="*res://src/qa/evidence_capture.gd"`の行で登録する。撮るきっかけは、起動の引数とキーの両方にする。Claudeは引数で、人は遊びながらキーで撮り、どちらも同じautoloadとファイル名の決まりを使う。

| 項目 | 引数で撮る（Claude） | キーで撮る（人） |
| --- | --- | --- |
| きっかけ | `--`のあとの`--capture=<名前>` | F12 |
| 待つフレーム | 既定で10。`--capture-frames=N`で変える | 押したフレームを撮る |
| ストーリーのid | `--story=<id>`。無ければ`active.md`の`**Current task:**`の行 | `active.md`の`**Current task:**`の行。分からなければ`no-story` |
| 撮ったあと | ゲームを終える | ゲームを続ける |
| 結果 | 終了コード。0 撮れた、1 撮れなかった、2 引数の誤り | ログの行 |

ファイルは`production/qa/evidence/<ストーリーのid>/<日時>-<名前>.png`に置く。日時は`YYYYMMDD-HHMMSS`で、キーで撮ったときの名前は`key`にする。ストーリーのidは、ストーリーのファイルの名前から`.md`を除いたもので、CCGSの`[story-slug]`と同じである。そのため、`/story-done`が証拠を探すフォルダと一致する。

キーで撮るときの「今のストーリー」は、CCGSが持っている場所に合わせ、`production/session-state/active.md`の`**Current task:**`の行から読む。`project.local.yaml`は、`/settings --local`が決めた鍵だけを受け付けるので使わない。

書き出したゲームでは、autoloadが自分を消す。書き出しの雛形には`editor`の機能（`OS.has_feature("editor")`）が無いからである。

### 構成の図

    起動の引数 ─┐
                ├→ EvidenceCapture（autoload）→ 描き終えたフレーム → PNG
    F12 ────────┘          ↑
                    active.md（今のストーリー）

### 主なインタフェース

起動の引数は`--capture=<名前>`・`--capture-frames=N`・`--story=<id>`の3つである。名前とidには、英数字と`-`と`_`だけを使う。静的な関数の`parse_args`・`story_from_checkpoint`・`evidence_path`は、GdUnit4のテスト（`tests/unit/qa/qa_evidence_capture_test.gd`）から呼ぶ。

### 実装の指針

- 証拠のスクリーンショットは、このautoloadで撮る。OSの画面の写しは、autoloadが使えないときだけ使い、そのことを`Run result:`に書く
- 引数で撮るときは、`timeout`の下で起動する。登録が無いと、引数が読まれず、ゲームが終わらないからである
- 名前とidに、パスの区切りや`..`を入れてはならない
- 撮る前に、`RenderingServer.frame_post_draw`を待たなければならない。待たないと、描き終える前の画像になる

## 検討した案

### 案1: 起動の引数だけで撮る

- **説明**: `--capture`のときだけ撮り、キーは使わない
- **利点**: 入力を見る部分が要らない
- **欠点**: 人が遊びながら撮れない。人は、別の道具で撮ることになる
- **見積もりの手間**: 選んだ案より少し小さい
- **採らなかった理由**: 人とClaudeで、撮り方とファイル名がずれる

### 案2: キーだけで撮る

- **説明**: 遊んでいる人がキーを押したときだけ撮る
- **利点**: 起動の引数を読む部分が要らない
- **欠点**: ClaudeはBashから起動するので、キーを押せない
- **見積もりの手間**: 選んだ案より少し小さい
- **採らなかった理由**: Claudeが撮れない

### 案3: `--write-movie`のまま撮る

- **説明**: CCGSの`run-and-observe.md`のとおり、Movie Makerで連番の画像を書き出す
- **利点**: スクリプトが要らない
- **欠点**: 1枚のために連番の画像と音のファイルができ、ファイル名にフレームの番号が付く。人が遊びながら撮れない
- **見積もりの手間**: 選んだ案より小さい
- **採らなかった理由**: 証拠のフォルダに要らないファイルが残り、ファイル名の決まりも人とそろわない

### 案4: ストーリーのidを`project.local.yaml`に置く

- **説明**: キーで撮るときの今のストーリーを、手元の設定の`project.local.yaml`に書く
- **利点**: 設定の置き場が1つになる
- **欠点**: `project.local.yaml`は`/settings --local`が決めた鍵だけを受け付け、ほかの鍵は無視される。今のストーリーを書くスキルが無い
- **見積もりの手間**: 選んだ案より大きい
- **採らなかった理由**: CCGSは、今のストーリーを`active.md`の`**Current task:**`の行に持っている。`/dev-story`と`/story-done`もそこを読む

## 影響

### 良い影響

- Claudeと人が、同じフォルダと名前の決まりで証拠を残す
- 引数で撮るときは、終了コードで撮れたかが分かる
- 証拠のフォルダが`/story-done`の探す場所と一致する

### 悪い影響

- 作品ごとに、`project.godot`にautoloadの登録が要る
- F12は、ゲームの中では別の操作に使えない

### どちらでもない影響

- `run-and-observe.md`と`/dev-story`のGodotの手順を、このautoloadを使う形に直した

## リスク

- Godotが無い環境で書いたので、まだGodotで動かしていない。使ったAPIのうち、`breaking-changes.md`と`deprecated-apis.md`に変更の記録が無いものも、4.7で変わっていないことは確かめていない。最初に見た目の変わるストーリーを閉じるときに、「確かめること」の3つを確かめる
- `active.md`の`**Current task:**`の行の書き方が変わると、キーで撮ったものが`no-story`に入る。対策は、引数で撮るときは`--story`を渡すことである

## 対応するGDDの要件

基盤の決定で、GDDの要件は無い。可能にするもの: なし

## 性能への影響

- **CPU**: 撮るときだけ、画面の画像をPNGにする
- **メモリ**: 撮るときだけ、画面の画像を1枚持つ
- **読み込みの時間**: なし
- **ネットワーク**: なし

## 移行の手順

なし

**戻す手順**: `project.godot`のautoloadの行と`src/qa/evidence_capture.gd`を消し、`run-and-observe.md`のGodotの手順を戻す

## 確かめ方

作品で`timeout 120 godot --path . --windowed --resolution 1280x720 <scene>.tscn -- --capture=check --story=<id>`を回し、終了コードが0で、`production/qa/evidence/<id>/`にPNGができることを確かめる。遊びながらF12を押し、同じフォルダにできることを確かめる。書き出したゲームでF12を押しても、何もできないことを確かめる。引数とパスの決まりは、GdUnit4のテストで確かめる。

### 見直しの条件

F12を、ゲームの操作に使いたい作品が出たとき。CCGSが、Godotの証拠の撮り方を自分で持ったとき。

## 関連

- [TDR-0003](../51-tdr/tdr-0003-godot-git-settings.md)（証拠のフォルダをLFSに入れる）
- `src/qa/evidence_capture.gd`、`tests/unit/qa/qa_evidence_capture_test.gd`、`.claude/docs/run-and-observe.md`、`.claude/skills/dev-story/SKILL.md`

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`depends_on`: この文書が成立するために前提となるノード

- [TDR-0001 Godotの版を4.7.2にする](../51-tdr/tdr-0001-godot-version.md)
- [TDR-0002 言語をGDScriptにする](../51-tdr/tdr-0002-gdscript.md)
- [TDR-0003 Godot用のGitの設定をそろえる](../51-tdr/tdr-0003-godot-git-settings.md)

<!-- graph:auto:end -->
