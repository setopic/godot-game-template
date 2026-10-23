---
id: PDR-0011
type: pdr
title: CCGSの.gitignoreは、エンジンの節を除いてこの層の節に写す
status: stable
tags: [template]
depends_on:
  - PDR-0006
decides:
  - UC-02
supersedes: []
related: []
---

# CCGSの.gitignoreは、エンジンの節を除いてこの層の節に写す

- 日付: 2026-10-23
- 状態: stable

## 背景

[PDR-0006](./pdr-0006-ccgs-whole-import-dr-types.md)は、[PDR-0002](./pdr-0002-ccgs-import.md)の「写さなかったもの」の表をそのまま引き継いでいる。その表は、`.gitignore`を「graph側を残す」とし、理由に「CCGSのGodot用の行を足すのは、setopic/game-template#3で行う」と書いている。#3では、[TDR-0003](../51-tdr/tdr-0003-godot-git-settings.md)でGodot用の3行だけを足した。

CCGSの1.2.0の`.gitignore`には、注記と空行を除いて105行ある。そのうち96行が、このリポジトリの`.gitignore`に無かった（setopic/game-template#36）。無い行の中には、CCGSがGitに入れない前提で書き出すファイルの行がある。`production/session-state/`（セッションの記録の`active.md`）、`.claude/agent-memory/`（エージェントの記憶）、`project.local.yaml`と`CLAUDE.local.md`（個人の設定）、`docs/consistency-failures.md`（検査の結果）などである。表が扱っていたのはGodotの節だけで、これらの行は検討から漏れていた。

CCGSの`.gitignore`は、見出しの注記（`# === Engine: Godot ===`など）で節に分かれている。エンジンの節は、Godot・Unity・Unrealの3つである。

## 決定

PDR-0006が引き継いだ表のうち、`.gitignore`の行を改める。graph側の`.gitignore`を残すことは、そのまま引き継ぐ。改めるのは、CCGSの行のうち何を入れるかである。

CCGSの`.gitignore`は、エンジンの3つの節を除いて、節の見出しと注記ごとそのまま写す。写す先は、`.gitignore`の末尾にこの層が作る節である。graph側にすでにある行（`.idea/`、`node_modules/`など）も、CCGSの節の中にあれば重ねて写す。

| CCGSの節 | 扱い | 理由 |
| --- | --- | --- |
| `Engine: Godot` | 写さない | TDR-0003で決めた。`export_presets.cfg`はGitに入れ、`.godot/`は丸ごと外す |
| `Engine: Unity` | 写さない | このテンプレートはGodotだけを使う。`*.csproj`と`*.sln`は、GodotでC#を使うときにGitに入れるファイルを外してしまう |
| `Engine: Unreal` | 写さない | このテンプレートはGodotだけを使う。当たるファイルが無い |
| それ以外の節 | そのまま写す | CCGSのスキルとエージェントが、ここで外すことを前提にファイルを書き出す |

写す節の`bin/`と`*.dll`・`*.so`・`*.dylib`は、GDExtensionの追加機能が`addons/<名前>/bin/`に置く書き出し済みのファイルも外す。CCGSは`!addons/gdUnit4/bin/`でgdUnit4のものだけを戻している。これもCCGSのまま写し、GDExtensionの追加機能を入れるときに、その追加機能を戻す行を足す。

## 理由

エンジンの節のほかは、CCGSのスキル・エージェント・フックが書き出すものと、どのプロジェクトでもGitに入れないものである。これらを選ばずにそのまま写せば、CCGSの更新を取り入れるとき（[UC-02](../30-usecases/uc-02-ccgs-upgrade.md)）、節ごとに見比べるだけで済む。

エンジンの節は、エンジンごとに作りが違い、Godotの節はTDR-0003の決定と食い違う。そのため、エンジンの節はまとめて写さない。

GDExtensionの追加機能は、いまは入っていない。入れるときに戻す行を足せば足りるので、先には書かない。

## 却下した案

| 案 | 却下理由 |
| --- | --- |
| CCGSの`.gitignore`で置き換え、TDR-0003と食い違う行だけを消す | `.gitignore`は下の層と共通のファイルで、graph側の行が消える。TDR-0003の制約（下の層から届いた行を消さない）にも反する |
| issueで挙げたClaude Code用の行だけを足す | CCGSとの差が節の途中に残り、CCGSの更新のたびに、どの行を除いたのかを1行ずつ判断することになる |
| Unity・Unrealの節も写す | Unityの節の`*.csproj`と`*.sln`が、GodotのC#のプロジェクトのファイルを外す |
| 最後に`!/addons/**`を足し、`addons/`の下を何も外さない | GDExtensionの追加機能は、いまは入っていない。入れるときに、その追加機能を戻す行を足せば足りる |

## 影響

`.gitignore`の末尾に、この層のCCGSの節が増える。いまGitに入っているファイルで、新しく外れるものは無い。`production/session-state/.gitkeep`は当たるが、すでにGitに入っているので外れない。

UC-02の手順4では、`.gitignore`は「手で合わせる」に出る。CCGSの差のうち、エンジンの節の変更は写さず、それ以外の節の変更をこの層のCCGSの節に写す。

## 見直しの条件

このテンプレートで、Godot以外のエンジンを使えるようにするとき。CCGSの`.gitignore`が、節の分け方を変えたとき。

---

<!-- graph:auto:start -->

## 関連ドキュメント（自動生成 / 手で編集しない）

`depends_on`: この文書が成立するために前提となるノード

- [PDR-0006 CCGSを丸ごと取り込み、決定の記録を4つの種別に分ける](./pdr-0006-ccgs-whole-import-dr-types.md)

`decides`: この決定が影響を与えるノード（ADR用）

- [UC-02 CCGSの更新を取り込む](../30-usecases/uc-02-ccgs-upgrade.md)

<!-- graph:auto:end -->
