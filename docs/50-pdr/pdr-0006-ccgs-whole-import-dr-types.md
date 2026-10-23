---
id: PDR-0006
type: pdr
title: CCGSを丸ごと取り込み、決定の記録を4つの種別に分ける
status: stable
tags: [template]
decides:
  - UC-02
supersedes:
  - PDR-0002
  - PDR-0004
related: []
---

# CCGSを丸ごと取り込み、決定の記録を4つの種別に分ける

- 日付: 2026-10-23
- 状態: stable

## 背景

[PDR-0002](./pdr-0002-ccgs-import.md)で、CCGSは選んだパスだけを`git checkout`で写して取り込むと決めた（CCGSの`UPGRADING.md`のA2）。更新のときは、UC-02の「上書きしてよいファイル」をそのまま写す。そのため、CCGSのファイルに手を入れると、更新のたびに直し直すことになる。

[PDR-0004](./pdr-0004-adr-location.md)で、決定の記録の置き場を役割で2か所に分けた。graphのADRは`docs/50-adr/`に置いてgraphで検証し、CCGSの`/architecture-decision`が書くADRは`docs/architecture/`に置いて検証から外した。番号は別々に数える。そのため、「ADR-0001」がどちらを指すのかが分からなくなる（setopic/game-template#16）。

CCGSのADRをgraphで検証するには、CCGSのファイルを直す必要がある。`.claude/`の下で、`docs/architecture/`のADRのパスを指すファイルは29本ある。ADRの英語の節（`## Status`、`## Summary`、`Last Verified`）を読むスキルは33本ある。CCGSは2026年9月から10月に5回版を出した。1.1.0から1.2.0では、`.claude/skills`と`.claude/scripts`の219ファイルが変わった。

0.4.0で、決定の記録をPDR・TDR・ADRの種別に分け、これまでのADRを振り直した。この記録は、その分け方と、CCGSの取り込み方を決める。

## 決定

[PDR-0002](./pdr-0002-ccgs-import.md)と[PDR-0004](./pdr-0004-adr-location.md)を置き換える。引き継ぐものと改めるものは、次のとおりである。

[PDR-0002](./pdr-0002-ccgs-import.md)の3つの決定は、次のように扱う。

1. graph-project-templateの履歴の上に作り、graph側の更新は`make update`で取り込む（そのまま）
2. CCGSはA2で取り込む（改める。下記の1）。最初に写したパスの表と、写さなかったものの表は、そのまま引き継ぐ
3. graphで検証する文書は当面`docs/`に置き、CCGSのフロントマターの無い文書は`graph.toml`の`exclude`で検証から外す（そのまま）

[PDR-0004](./pdr-0004-adr-location.md)の4つの決定は、次のように扱う。

1. ADRを役割で2か所に分ける（改める。下記の2）
2. `docs/architecture/`をgraphの検証から外す（フォルダの扱いはそのまま。ADRはここに書かなくなる。CCGSがこのフォルダに書くほかの文書は、フロントマターを持たないからである）
3. 番号を2か所で別々に数える（改める。下記の3）
4. CCGSのADRに、フロントマターを付けず書式もgraphに合わせない（改める。下記の4）

### 1. CCGSは丸ごと取り込み、更新は中身を読んで取り入れる

CCGSは丸ごと取り込む。CCGSのファイルも、必要ならこのテンプレートの書き方に合わせて直す。CCGSの更新は、上書きで写すのではなく、更新の中身を読んで取り入れる。

直したファイルの一覧は、手で持たない。`git diff v<いまの版> HEAD -- <ファイル>`で、いまの版のCCGSと手元を比べて見分ける。差が無いファイルは、新しい版をそのまま写す。差があるファイルだけ、`git diff v<いまの版> ccgs/main -- <ファイル>`を読んで手で合わせる。手順は[UC-02](../30-usecases/uc-02-ccgs-upgrade.md)に書く。

### 2. 決定の記録を4つの種別に分ける

決定の記録（DR）を、中身で4つの種別に分ける。4つをまとめて指すときは「DR」と呼ぶ。「土台」「決定記録」は、どの種別にも当てはまるので使わない。

| 種別 | 接頭辞 | 書くもの | フォルダ | 必須の節 |
| --- | --- | --- | --- | --- |
| 開発の進め方の決定 | `PDR`（Process Decision Record） | 道具、テンプレート、手順、文書の置き場 | `docs/50-pdr/` | 背景・決定・理由・却下した案・影響・見直しの条件 |
| ゲームの外の技術の決定 | `TDR`（Technology Decision Record） | ゲームのコードの外から何を使うか。エンジンとその版、言語、ライブラリ、対応する機種、ビルドと書き出し | `docs/51-tdr/` | CCGSのADRの雛形の節を日本語にしたもの（下記の4） |
| ゲームの中の構成の決定 | `ADR`（Architecture Decision Record） | ゲームの中をどう組むか。プレイヤーには同じで、作る側にだけ違いがあるもの。イベントの仕組み、セーブデータの形、シーンの分け方など | `docs/52-adr/` | CCGSのADRの雛形の節を日本語にしたもの（下記の4） |
| ゲームデザインの決定 | `DDR`（Design Decision Record） | プレイヤーができること、見るもの、感じることが変わるもの。ルールや仕様の判断と、却下した案 | `docs/53-ddr/` | PDRと同じ6節 |

フォルダの50番台は、決定の記録に使う。4つとも、どれもgraphのノードとして検証する。層は90で、層のルールの対象外にし、確定したら書き換えない記録として扱う。

境は、次のように決める。

- TDRとADRは、「ゲームのコードの外から何を使うか」か「ゲームの中をどう組むか」で分ける。どの物理エンジンを使うかはTDRである
- ADRとDDRは、「プレイヤーから違いが分かるか」で分ける。敵の動き方はDDRで、敵のAIを状態機械で書くかビヘイビアツリーで書くかはADRである
- 1つの話が2つにまたがるときは、2つの記録に分け、ADRからDDR（またはTDR）を`depends_on`で指す。CCGSのADRの「GDD Requirements Addressed」の節も、デザインを前提に構成を決める向きである

CCGSの`/architecture-decision`が書くものは、TDRとADRにまたがる。スキルに、どちらの種別かを選ぶ手順を足す。

DDRは`docs/53-ddr/`にgraphのノードとして置き、GDDは`design/gdd/`に残す。DDRとGDDは両方から指す。DDRの本文に対応するGDDのパスを書き、GDDにも関するDDRを書く欄を足す。そのため、CCGSのGDDの雛形とスキルも直す。

### 3. 番号は種別ごとに0001から振る

番号は、種別ごとに0001から振る。ADRは中身が「ゲームの中の構成」に変わり、これまでのADRはどれもPDRかTDRに移ったので、ADRの列は新しく始める。CCGSの採番は、種別ごとのフォルダだけを見ればよい。

0.4.0で、これまでのADRを次のとおり振り直した。過去のコミット・PRの題・変更履歴にある旧idは、この表で読み替える。

| 旧id | 新id |
| --- | --- |
| ADR-0001 | PDR-0001 |
| ADR-0003 | PDR-0002 |
| ADR-0004 | PDR-0003 |
| ADR-0006 | PDR-0004 |
| ADR-0007 | PDR-0005 |
| ADR-0002 | TDR-0001 |
| ADR-0005 | TDR-0002 |

確定したDRのidの振り直しは、本文の中身を変えないので、書式の修正と同じ扱いにする。

### 4. TDRとADRは、CCGSの雛形の節を日本語にし、状態はフロントマターに持つ

TDRとADRの本文の節は、CCGSのADRの雛形の節を1対1で日本語にする。`graph.toml`の`tdr`と`adr`の`required_sections`は、この日本語の節にする。節の下の`###`の見出しも、同じ方針で日本語にする。名前の細部は、雛形を直すPRで決める。

| CCGSの節 | 日本語の節 |
| --- | --- |
| Date | 日付 |
| Last Verified | 最終確認日 |
| Decision Makers | 決めた人 |
| Summary | 要約 |
| Engine Compatibility | エンジンとの互換 |
| ADR Dependencies | 前提のADR |
| Context | 背景 |
| Decision | 決定 |
| Alternatives Considered | 検討した案 |
| Consequences | 影響 |
| Risks | リスク |
| GDD Requirements Addressed | 対応するGDDの要件 |
| Performance Implications | 性能への影響 |
| Migration Plan | 移行の手順 |
| Validation Criteria | 確かめ方 |
| Related | 関連 |

状態は、本文の`## Status`をやめ、フロントマターの`status`だけに持つ。CCGSのスクリプトとスキルは、フロントマターを読み書きするように直す。

| CCGSの状態 | `status` |
| --- | --- |
| Proposed | `draft`か`review` |
| Accepted | `stable` |
| Deprecated | `deprecated` |
| Superseded | `deprecated`。後継は`supersedes`のエッジで指す |

## 理由

CCGSのADRをgraphで検証すると、ゲームの技術の決定も、リンク切れや`decides`の辺の検査を受ける。種別ごとに接頭辞を変えれば、「ADR-0001」がどれを指すかで迷わない。意味の違うものは、違う名前にする。

検証に載せるには、CCGSのスキルとスクリプトを直す必要がある。上書きで写す取り込み方のままでは、直したファイルを更新のたびに直し直すことになる。更新の中身を読んで取り入れる形にすれば、CCGSのファイルにも手を入れられる。直したファイルは`git diff`で見分けられるので、一覧を手で持つ必要は無い。

ゲームの外の技術とゲームの中の構成は、別のものである。エンジンの版や言語は、ゲームのコードの外から何を使うかを決める。イベントの仕組みやセーブデータの形は、ゲームの中をどう組むかを決める。ゲームデザインの決定は、プレイヤーから違いが分かるかで構成の決定と分けられる。CCGSにはデザインの決定に当たる記録が無く、CCGSはデザインの決定をGDDの中に書く。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| CCGSのADRを、graphの検証から外したままにする（[PDR-0004](./pdr-0004-adr-location.md)） | 「ADR-0001」がgraphのADRとCCGSのADRのどちらを指すのか分からない。作品のゲームの技術の決定が、graphの検証を受けない |
| CCGSの更新を、「上書きしてよいファイル」で写し続ける（[PDR-0002](./pdr-0002-ccgs-import.md)） | CCGSのファイルに手を入れると、更新のたびに直し直すことになる。CCGSのADRを検証に載せるには、29本のパスと33本の節の読み取りを直す必要がある |
| 直したファイルの一覧を、手で持つ | `git diff v<いまの版> HEAD`で見分けられる。手で持つ一覧は、書き忘れると古くなる |
| PDRとADRの2種別にする | ゲームの外の技術と、ゲームの中の構成は別のものである。ゲームデザインの決定の置き場も無い |
| PDR・ADR・DDRの3種別にし、TDRを分けない | ゲームの外の技術と、ゲームの中の構成は別のものである。境は「ゲームのコードの外から何を使うか」か「ゲームの中をどう組むか」で決められる |
| 番号を種別で1つの列にし、接頭辞だけを変える（次は0008） | ADRは中身が「ゲームの中の構成」に変わり、これまでのADRはどれもPDRかTDRに移る。そのため、ADRの列は新しく始める。旧idは振り直しの表で読み替える |

## 影響

[UC-02](../30-usecases/uc-02-ccgs-upgrade.md)の手順を、「上書きしてよいファイル」で写す形から、更新の中身を読んで取り入れる形に書き直す。

このほかに、setopic/game-template#16の次のPRで、CCGSのファイルと`graph.toml`を直す。それまでは、`/architecture-decision`はCCGSの書式で`docs/architecture/`にADRを書き、そのADRはgraphの検証を受けない。

| 直すもの | 中身 |
| --- | --- |
| CCGSのスキルとスクリプトのADRの置き場 | TDRとADRのフォルダに直し、`/architecture-decision`にどちらの種別かを選ぶ手順を足す |
| CCGSのADRの雛形・スキル・スクリプト | 日本語の節と`status`に合わせる。`graph.toml`の`tdr`と`adr`の`required_sections`を、日本語の節にする |
| DDRの種別と雛形、GDDの雛形とスキル | `graph.toml`にDDRの種別を足し、GDDにDDRの欄を足す |

TDR-0001とTDR-0002は、PDRと同じ6節で書いてある。`required_sections`を変えるPRで、この2つの扱いを決める。

## 見直しの条件

CCGSが、ADRの置き場や書式を設定で変えられるようにしたとき。setopic/graph-doc-template#183が届き、`docs_dir`でgraphの文書を`docs/`の外へ出せるようになったとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`supersedes`: この決定が置き換える過去の決定（ADR用）

- [PDR-0002 graph-project-templateから作り、CCGSを選んだファイルのcheckoutで取り込む](./pdr-0002-ccgs-import.md)
- [PDR-0004 ADRを役割で2か所に分け、CCGSのADRはgraphで検証しない](./pdr-0004-adr-location.md)

`decides`: この決定が影響を与えるノード（ADR用）

- [UC-02 CCGSの更新を取り込む](../30-usecases/uc-02-ccgs-upgrade.md)

このノードを参照しているノード

- (depends_on) [PDR-0007 TDRとADRの最終確認日をフロントマターに持つ](./pdr-0007-last-verified-front-matter.md)
- (depends_on) [UC-02 CCGSの更新を取り込む](../30-usecases/uc-02-ccgs-upgrade.md)

<!-- graph:auto:end -->
