# TDR and ADR format (game-template)

**This is not the template to copy.** In game-template (PDR-0006) a TDR or ADR
is a graph node. Create it with the graph tool, which copies
`docs/00-meta/templates/tdr.md` or `docs/00-meta/templates/adr.md` (the two have
the same sections), numbers nothing for you, and lists it in its folder's
`index.md`:

```bash
python -m tools.graph new --type tdr --id TDR-NNNN --title "..." --slug some-slug --status draft
python -m tools.graph new --type adr --id ADR-NNNN --title "..." --slug some-slug --status draft
```

Then fill the sections and run `python -m tools.graph check`. A missing section
fails the check (`G014`): write 「なし」 in a section with nothing to say.

`/architecture-decision` does all of this. This file maps CCGS's ADR template
onto the Japanese one, for any skill or person who knows the English names.

## Status

There is no `## Status` section. The status is the front matter's `status:`.

| CCGS status | `status:` |
|---|---|
| Proposed | `draft` or `review` |
| Accepted | `stable` |
| Deprecated | `deprecated` |
| Superseded by ADR-XXXX | `deprecated`; ADR-XXXX names this record in its front matter `supersedes` |

> **Who may move a record to `stable` (Accepted): the user, or
> `technical-director` on the user's explicit confirmation. No other agent, and
> no skill on its own.** Stories referencing a Proposed ADR are set `Blocked`,
> and epics require Accepted, so the field needs a named owner. This narrows
> *which agent* may set it once the user has confirmed; it does not relax the
> rule that `stable` is never set without explicit user confirmation.

`bash .claude/scripts/adr-status.sh` reads the status, layer, dates and
dependencies of every TDR and ADR.

## Sections

| CCGS section | Section |
|---|---|
| Date | `## 日付` |
| Last Verified | `## 最終確認日` |
| Decision Makers | `## 決めた人` |
| Summary | `## 要約` |
| Engine Compatibility | `## エンジンとの互換` |
| ADR Dependencies | `## 前提のADR` |
| Context | `## 背景` (`### 解決したい問題`, `### いまの状態`, `### 制約`, `### 要件`) |
| Decision | `## 決定` (`### 構成の図`, `### 主なインタフェース`, `### 実装の指針`) |
| Alternatives Considered | `## 検討した案` (`### 案1: [名前]`, with 説明, 利点, 欠点, 見積もりの手間, 採らなかった理由) |
| Consequences | `## 影響` (`### 良い影響`, `### 悪い影響`, `### どちらでもない影響`) |
| Risks | `## リスク` |
| GDD Requirements Addressed | `## 対応するGDDの要件` |
| Performance Implications | `## 性能への影響` (CPU, メモリ, 読み込みの時間, ネットワーク) |
| Migration Plan | `## 移行の手順` (with **戻す手順**, the Rollback plan) |
| Validation Criteria | `## 確かめ方` |
| Related | `## 関連` |

## Table rows

| CCGS row | Row |
|---|---|
| Engine Compatibility: **Engine** | **エンジン** |
| **Domain** | **分野** |
| **Layer** | **層** (values stay Foundation / Core / Feature / Presentation) |
| **Knowledge Risk** | **知識のリスク** (values stay LOW / MEDIUM / HIGH) |
| **References Consulted** | **参照した資料** |
| **Post-Cutoff APIs Used** | **学習の範囲より後のAPI** |
| **Verification Required** | **確かめること** |
| ADR Dependencies: **Depends On** | **前提** (every TDR or ADR named here also goes into the front matter's `depends_on`) |
| **Enables** | **可能にするもの** |
| **Blocks** | **止めているもの** |
| **Ordering Note** | **順序の注意** |

A value of "None" is written 「なし」.
