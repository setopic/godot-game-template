# /architecture-decision — Step 5: Generate the ADR

> Part of `/architecture-decision`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 5. Generate the ADR

**In this file:**

- The ADR template
- 5.5 Engine Specialist Validation
- 5.6 Technical Director Strategic Review, with the review mode check
- 5.7 GDD Sync Check: found, none found, could not check
- Write approval
- Update Architecture Registry, and the registry append logic

Following the template `docs/00-meta/templates/tdr.md` (a TDR) or
`docs/00-meta/templates/adr.md` (an ADR). The two have the same sections.

> **game-template (PDR-0006): a TDR or ADR is a graph node.** Its sections are
> CCGS's ADR template sections in Japanese, one for one: 日付 (Date), 決めた人
> (Decision Makers), 要約 (Summary), エンジンとの互換
> (Engine Compatibility), 前提のADR (ADR Dependencies), 背景 (Context), 決定
> (Decision), 検討した案 (Alternatives Considered), 影響 (Consequences), リスク
> (Risks), 対応するGDDの要件 (GDD Requirements Addressed), 性能への影響
> (Performance Implications), 移行の手順 (Migration Plan), 確かめ方 (Validation
> Criteria), 関連 (Related). There is no `## Status`: the status is the front
> matter's `status:`, and a new record is always `draft` (Proposed). There is no
> Last Verified section either: it is the front matter's `last_verified:`
> (game-template PDR-0007), which a new record leaves empty. Rows and
> subsections are Japanese too: the エンジンとの互換 table's rows are **エンジン**,
> **分野** (Domain), **層** (Layer), **知識のリスク** (Knowledge Risk),
> **参照した資料**, **学習の範囲より後のAPI**, **確かめること**; the 前提のADR
> table's are **前提** (Depends On), **可能にするもの** (Enables),
> **止めているもの** (Blocks), **順序の注意** (Ordering Note); 背景 holds
> `### 解決したい問題`, `### いまの状態`, `### 制約`, `### 要件`; 決定 holds
> `### 構成の図`, `### 主なインタフェース` (Key Interfaces), `### 実装の指針`
> (Implementation Guidelines); 検討した案 holds `### 案1: [名前]`; 影響 holds
> `### 良い影響`, `### 悪い影響`, `### どちらでもない影響`. A section with
> nothing to say is 「なし」, never left out: `python -m tools.graph check`
> reports a missing one (`G014`).

Draft every section of the template in the conversation. On the write approval
below, create the file with the graph tool — never with Write, and never by
creating the directory yourself:

```bash
python -m tools.graph new --type tdr --id TDR-NNNN --title "[Title]" --slug [slug] --status draft
python -m tools.graph new --type adr --id ADR-NNNN --title "[Title]" --slug [slug] --status draft
```

It copies the template, numbers nothing (the id is Step 2's), and lists the
record in its folder's `index.md`. Then fill the sections with Edit. Every TDR
or ADR named on the `**前提**` row also goes into the front matter's
`depends_on`; a record this one replaces goes into `supersedes` (and that
record's `status:` becomes `deprecated`, as `/propagate-design-change` does).
Then run `python -m tools.graph sync` and `python -m tools.graph check`.

**Always write the 層 row.** An ADR with no 層 row counts as critical
(Foundation) wherever it is read, so at `standard` its advisory items become
blockers. The value is the ADR's own layer, how early in the build it must
exist: the layer `docs/architecture/architecture.md`'s layer map gives the
system this decision governs. With no layer map, or no system in it, ask the
user, with the four values as options. Never take it from an epic that
references the ADR, and never reuse a **分野** value (the template's note under
エンジンとの互換 says why).

5.5. **Engine Specialist Validation** — Before saving, spawn the **primary engine specialist** via `Agent` to validate the drafted ADR:
   - Resolve the primary specialist: `<engine>-specialist` derived from `engine.name` in `project.yaml` (Godot→`godot-specialist`, Unity→`unity-specialist`, Unreal→`unreal-specialist`); if `engine.name` is absent or empty, read the Primary line of the `## Engine Specialists` section in `.claude/docs/technical-preferences.md`
   - If no engine is configured (neither source yields an engine), skip this step **Record ``Engine validation: NOT ASSESSED — no engine configured (`engine.name` unset in `project.yaml`)`` in this run's output.** A skipped check that says nothing is indistinguishable from a check that passed; the reader cannot tell engine guidance was never sought.
   - Spawn `subagent_type: [primary specialist]` with: the ADR's エンジンとの互換 section, 決定 section, 主なインタフェース, and the engine reference docs path. Ask them to:
     1. Confirm the proposed approach is idiomatic for the pinned engine version
     2. Flag any APIs or patterns that are deprecated or changed post-training-cutoff
     3. Identify engine-specific risks or gotchas not captured in the current ADR draft
   - If the specialist identifies a **blocking issue** (wrong API, deprecated approach, engine version incompatibility): revise the 決定 and エンジンとの互換 sections accordingly, then confirm the changes with the user before proceeding
   - If the specialist finds **minor notes** only: incorporate them into the ADR's リスク section

**Review mode check** — apply before spawning TD-ADR:
- `solo` → skip. Note: "TD-ADR skipped — Solo mode." Proceed to Step 5.7 (GDD sync check).
- `lean` → skip (not a PHASE-GATE). Note: "TD-ADR skipped — Lean mode." Proceed to Step 5.7 (GDD sync check).
- `full` → spawn as normal.

5.6. **Technical Director Strategic Review** — After the engine specialist validation, spawn `technical-director` via `Agent` using gate **TD-ADR** (`.claude/docs/director-gates/td-adr.md`):
   - Pass: the ADR file path (or draft content), engine version, domain, any existing ADRs in the same domain
   - The TD validates architectural coherence (is this decision consistent with the whole system?) — distinct from the engine specialist's API-level check
   - On CONCERNS: show them to the user verbatim and ask with the standard options from `director-gates.md` — `Revise flagged items` / `Accept and proceed` / `Discuss further`. Revise the flagged 決定 or 検討した案 sections only on `Revise flagged items`.
   - On REJECT: show the blockers verbatim and revise the 決定 or 検討した案 sections before proceeding.
   - A revised draft still reaches the user through the write approval below; nothing is written before it. A `NOT ASSESSED` answer is not an approval — name the missing input (`director-gates.md`).

5.7. **GDD Sync Check** — Before presenting the write approval, scan all GDDs
referenced in the "対応するGDDの要件" section for naming inconsistencies
with the ADR's 主なインタフェース and 決定 sections (renamed signals, API methods,
or data types). If any are found, surface them as a **prominent warning block**
immediately before the write approval — not as a footnote:

```
⚠️ GDD SYNC REQUIRED
[gdd-filename].md uses names this ADR has renamed:
  [old_name] → [new_name_from_adr]
  [old_name_2] → [new_name_2_from_adr]
The GDD must be updated before or alongside writing this ADR to prevent
developers reading the GDD from implementing the wrong interface.
```

**This check has three outcomes, not two.** The two above are "found" and "none
found"; the third is **could not check**, which must never take the silent
branch and render like a clean result.

- **None found** — print one line, do not stay silent:
  `GDD sync: checked [N] referenced GDD(s), no naming inconsistencies.`
  A silent pass is indistinguishable from a check that never ran, and this one
  guards against developers implementing the wrong interface from a stale GDD.
- **Could not check** — the ADR has no `対応するGDDの要件` section, it
  names no GDDs, or a named GDD does not exist on disk. Print:
  `GDD sync: NOT ASSESSED — [which reason, and which files]`
  Do **not** treat an ADR that references no GDDs as one whose GDDs are
  consistent. Nothing was compared.

Only the warning block itself is conditional; the check always reports.

5. **Write approval** — Use `AskUserQuestion`:

If GDD sync issues were found:
- "ADR draft is complete. How would you like to proceed?"
  - [A] Write ADR + update GDD in the same pass
  - [B] Write ADR only — I'll update the GDD manually
  - [C] Not yet — I need to review further

If no GDD sync issues:
- "ADR draft is complete. May I write it?"
  - [A] Write ADR to `docs/51-tdr/tdr-[NNNN]-[slug].md` (a TDR) or `docs/52-adr/adr-[NNNN]-[slug].md` (an ADR), as Step 2 chose
  - [B] Not yet — I need to review further

If yes to any write option, create the file with `python -m tools.graph new` as
above, fill it, and run `python -m tools.graph check`.
For option [A] with GDD update: also update the GDD file(s) to use the new names.

6. **Update Architecture Registry**

Scan the written ADR for new architectural stances that should be registered:
- State it claims ownership of
- Interface contracts it defines (signal signatures, method APIs)
- Performance budget it claims
- API choices it makes explicitly
- Patterns it bans (影響 → 悪い影響, or an explicit "do not use X")

Present candidates:
```
Registry candidates from this ADR:
  NEW state ownership:      player_stamina → stamina-system
  NEW interface contract:   stamina_depleted signal
  NEW performance budget:   stamina-system: 0.5ms/frame
  NEW forbidden pattern:    polling stamina each frame (use signal instead)
  EXISTING (referenced_by update only): player_health → already registered ✅
```

**Registry append logic**: When writing to `docs/registry/architecture.yaml`, do NOT assume sections are empty. The file may already have entries from previous ADRs written in this session. Before each Edit call:
1. Read the current state of `docs/registry/architecture.yaml`
2. Find the correct section (state_ownership, interfaces, forbidden_patterns, api_decisions)
3. If the section is still the empty list (`state_ownership: []`), replace `[]` with the first entry: the key alone on its line, the entry below it indented two spaces as in the file's commented example. An entry appended after `[]` makes the file invalid YAML. Otherwise append the new entry AFTER the last existing entry in that section
4. If the section has entries already, use the closing content of the last entry as the `old_string` anchor, and append the new entry after it

**BLOCKING — do not write to `docs/registry/architecture.yaml` without explicit user approval.**

Ask using `AskUserQuestion`:
- "May I update `docs/registry/architecture.yaml` with these [N] new stances?"
  - Options: "Yes — update the registry", "Not yet — I want to review the candidates", "Skip registry update"

Only proceed if the user selects yes. If yes: append new entries. Never modify existing entries — if a stance is
changing, set the old entry to `status: "superseded_by: [TDR|ADR]-[NNNN]"` and add the new entry. Keep the quotes:
unquoted, the second colon makes the file invalid YAML.

After writing, run `bash .claude/scripts/registry.sh validate` and fix every row about an entry this write added
or changed (a DUPLICATE, STATUS or LAYOUT row, an UNQUOTED row (quote the value it names), or a PATH_MISSING row for a path it named) before you go on; name
rows about other entries to the user rather than fixing them unasked. If the script is missing or prints nothing,
say the registry check did not run, then re-read the entries you wrote against the rules in the file's header.

---
