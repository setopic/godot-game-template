# /architecture-decision — Handoff Contract

## Role in Pipeline
Authors a new Architecture Decision Record (ADR) by guiding a collaborative design session, cross-referencing the engine reference library and existing architectural stances, and writing a fully-structured ADR file as `Proposed`: a TDR (technology from outside the game's code) to `docs/51-tdr/`, or an ADR (how the inside of the game is built) to `docs/52-adr/`, by the kind Step 2 chooses (game-template, PDR-0006). Its `accept` mode is the only route to `Accepted`, and acceptance is what unblocks the stories and epics that depend on the decision.

Two checks inside the run emit `NOT ASSESSED` rather than passing silently, and
a reader of the resulting ADR should expect them: **engine validation** when no
engine is configured (`engine.name` unset and no legacy fallback), and **GDD
sync** when the referenced design docs cannot be read. A skipped check that says
nothing is indistinguishable from a check that passed.

## Inputs Required

### Files That Must Exist
| File | Required Fields / Sections | Read-Only? |
|------|---------------------------|-----------|
| `docs/engine-reference/[engine]/VERSION.md` | Engine name + version, LLM knowledge cutoff date, post-cutoff risk levels per domain | Yes |
| `docs/engine-reference/[engine]/modules/[domain].md` | Domain-specific API reference (read if exists for the decision's domain) | Yes |
| `docs/engine-reference/[engine]/breaking-changes.md` | Post-cutoff breaking changes in the relevant domain | Yes |
| `docs/engine-reference/[engine]/deprecated-apis.md` | APIs that must not be referenced in the new ADR | Yes |
| `docs/registry/architecture.yaml` | All existing architectural stances (state ownership, interface contracts, forbidden patterns, performance budgets) — checked for conflicts before the design begins | Yes |
| `docs/51-tdr/` (existing TDRs) and `docs/52-adr/` (existing ADRs) | The chosen kind's folder is scanned to determine its next sequential number | Yes |
| `design/gdd/[system].md` (GDDs relevant to the decision) | Specific rules, formulas, performance constraints, or integration points that motivate the decision | Yes |
| `project.yaml` | `engine.name` — derives the primary specialist (`<engine>-specialist`) to spawn for validation (Step 5.5) | Yes |
| `.claude/docs/technical-preferences.md` | `Engine Specialists` section — legacy fallback, used only when `engine.name` is absent or empty in `project.yaml` | Yes — required only when `engine.name` is absent |

### Preconditions
- An engine must be configured (`docs/engine-reference/[engine]/VERSION.md` must exist) — if not, the skill prompts to run `/setup-engine` first
- The title or subject of the decision must be provided by the user before Step 0 proceeds (if no argument is given, the skill asks)
- If in **retrofit mode** (`retrofit [path]` argument), the target ADR file must already exist on disk
- Any conflict with a registered architectural stance in `docs/registry/architecture.yaml` must be resolved or explicitly accepted as an exception before the ADR is drafted (Step 3a is a BLOCKING gate)

## Outputs Produced

### Files Written
| File | Guaranteed Fields / Sections | Notes |
|------|------------------------------|-------|
| `docs/51-tdr/tdr-NNNN-[slug].md` (a TDR) or `docs/52-adr/adr-NNNN-[slug].md` (an ADR) | front matter `status: draft` and an empty `last_verified:`, then the 15 sections of `docs/00-meta/templates/adr.md`: `## 日付`, `## 決めた人`, `## 要約`, `## エンジンとの互換` (table with engine, domain, layer, knowledge risk, post-cutoff APIs, verification required), `## 前提のADR` (table with 前提, 可能にするもの, 止めているもの, 順序の注意), `## 背景` (problem statement, current state, constraints, requirements), `## 決定` (+ architecture diagram + key interfaces + `### 実装の指針`), `## 検討した案`, `## 影響` (positive, negative, neutral), `## リスク`, `## 対応するGDDの要件` (table), `## 性能への影響`, `## 移行の手順`, `## 確かめ方`, `## 関連` | created with `python -m tools.graph new` after user approves ("May I write this ADR to docs/52-adr/adr-NNNN-[slug].md?", or the TDR path) |
| `docs/registry/architecture.yaml` | New stance entries (state ownership, interface contracts, performance budgets, forbidden patterns) derived from the ADR; existing entries marked `status: superseded_by` if overridden | appended after separate user approval ("May I update docs/registry/architecture.yaml with these N new stances?") |

### Output Guarantees
- The kind (TDR or ADR) is chosen before Step 3, and asked of the user when it is unclear; a decision that is both is written as two records, the ADR depending on the TDR
- The number is the next sequential integer after the highest existing filename of the chosen kind: `tdr-NNNN-*` in `docs/51-tdr/`, or `adr-NNNN-*` in `docs/52-adr/`. The two kinds are numbered apart
- The front matter's `status:` is always present (game-template, PDR-0006: there is no `## Status` section; Proposed is `draft` or `review`, Accepted is `stable`, Deprecated and Superseded are `deprecated`). Authoring writes `draft`; retrofit writes the status the user gives, except that an `Accepted` answer is written as `draft` and handed to acceptance mode. Only acceptance mode writes `stable`, after its dependency check and the user's confirmation
- `## エンジンとの互換` is always populated using verified data from the engine reference docs — never from training data alone when the domain carries MEDIUM or HIGH risk
- `## 対応するGDDの要件` is always present (if no GDD motivated the decision, it documents which GDDs the decision will constrain or enable)
- `## 前提のADR` is always present (fields set to 「なし」 if no ordering constraints exist), and every TDR or ADR on its `**前提**` row is in the front matter's `depends_on` too
- `python -m tools.graph check` passes after the write
- Engine specialist validation (Step 5.5) runs before the file is written if an engine specialist is configured; blocking issues found by the specialist cause the 決定 section to be revised before saving

## Immutability Rules
- READS but does NOT modify: all existing TDR and ADR files in `docs/51-tdr/` and `docs/52-adr/` (including in retrofit mode — existing sections are never touched), all GDD files in `design/gdd/`, `docs/engine-reference/**`, `project.yaml`, `.claude/docs/technical-preferences.md` (legacy fallback)
- MODIFIES: `docs/51-tdr/tdr-NNNN-[slug].md` or `docs/52-adr/adr-NNNN-[slug].md` (new file created; or missing sections appended in retrofit mode), `docs/registry/architecture.yaml` (append only; existing entries get `status: superseded_by` annotation, never deleted or rewritten)
- In retrofit mode: appends only the missing sections — never modifies any section that is already present in the target ADR file

## Hard Constraints (Never Violate)
- Never sets `status: stable` (Accepted) without explicit user confirmation — the default on creation is always `status: draft` (Proposed)
- **Acceptance route: `/architecture-decision accept ADR-NNNN`** (or `TDR-NNNN`) — the only path that sets `stable` (Accepted). It refuses when a dependency is still Proposed (`draft` or `review`), and prompts for confirmation regardless of `modes.automation`. Retrofit mode's `Accepted` answer, for a decision already in force, is written as `draft` and handed to this route. Without this route acceptance would be enforced by ten skills, owned per the authority below, and reachable by nobody.
- **Acceptance authority: the user, or `technical-director` on the user's explicit confirmation — no other agent, and not this skill on its own.** Recorded here because every consumer enforces the consequences of acceptance, and without this line nothing would say who can produce it. This narrows *who* may set the field; it does not relax the confirmation rule above.
- Never assigns a number that is already in use for the chosen kind — always scan that kind's folder (`docs/51-tdr/` or `docs/52-adr/`) first and use the next sequential number
- Never proceeds past the architectural stance conflict check (Step 3a) if a conflict exists — surface the conflict and require resolution or explicit exception acknowledgment before drafting
- Never references APIs listed in `docs/engine-reference/[engine]/deprecated-apis.md` in the 決定 section or its 主なインタフェース
- Never writes the ADR file without asking: "May I write this ADR to docs/52-adr/adr-NNNN-[slug].md?" (or the TDR path in `docs/51-tdr/`)
- Never writes to `docs/registry/architecture.yaml` without a separate ask: "May I update docs/registry/architecture.yaml with these N new stances?"
- In retrofit mode: never modifies any existing section — only appends absent sections

## Downstream Skill Expects
**Next skills:** `/create-epics`, `/create-stories`, `/dev-story`, `/architecture-review`

### `/create-epics` reads ADRs expecting:
- front matter `status:` — value must be `stable` (Accepted) for epics to reference it
- `## 対応するGDDの要件` table — used to link epics to GDD traceability
- `## エンジンとの互換` section — checked during the Technical Setup → Pre-Production gate

### `/create-stories` reads ADRs expecting:
- `### 実装の指針` (under `## 決定`) — the concrete "must / must never" patterns programmer agents follow; the ADR template carries this subsection
- `## 前提のADR` table — stories referencing a `前提` ADR that is still Proposed (`draft` or `review`) are automatically set `Status: Blocked`

### `/dev-story` reads ADRs expecting:
- `## 決定` (full text, verbatim — not summarized)
- `### 実装の指針` (under `## 決定`, verbatim)
- `## エンジンとの互換` (post-cutoff API risks, verification required)
- `## 前提のADR` (to detect if this ADR's dependencies are unresolved)

### `/architecture-review` reads ADRs expecting:
- All required sections present (it flags gaps)
- front matter `status:` is set (required for coverage matrix)
- `## エンジンとの互換` is stamped with the correct engine version

## Known Fragile Points
- If the number scan misses a file (e.g., a file in a subdirectory, or with a non-standard naming pattern), a duplicate number can be assigned — TDR files must follow the `tdr-NNNN-[slug].md` naming convention at the top level of `docs/51-tdr/`, and ADR files `adr-NNNN-[slug].md` at the top level of `docs/52-adr/`
- If the kind is chosen wrong, the record sits in the wrong folder with the wrong prefix. Moving it later changes its id, and every story and ADR that names the old id must be updated
- Acceptance mode moves a story from `Blocked` to `Ready` only when the story file, under `production/epics/`, contains a Blocked Status line in any of the forms `/create-stories` writes (`> **Status**: Blocked`, `**Status:** Blocked`, `Status: Blocked`) and this ADR's id. A story blocked pending this ADR that never names its id is not found, and stays `Blocked` until it is updated by hand
- The `## 対応するGDDの要件` table is populated based on what the user tells the skill during the collaborative session; if the user does not know which GDDs motivated the decision, this table may be incomplete — `/create-epics` and `/gate-check` both rely on this linkage for traceability
- Engine specialist validation (Step 5.5) is skipped only when **both** sources are unset — `engine.name` absent or empty in `project.yaml` **and** `.claude/docs/technical-preferences.md` still reading `[TO BE CONFIGURED]`. A project configured solely via `project.yaml` **does** get specialist validation. When both are unset, post-cutoff engine API risks are not caught before the ADR is written
- `docs/registry/architecture.yaml` is append-only by design; if a stance entry becomes permanently invalid (not superseded by another ADR), it must be manually removed — there is no cleanup mechanism
- In retrofit mode, if the existing ADR has sections present but empty (e.g., a `## 日付` heading with no value), the skill treats the section as present and does not fill it — an empty section is effectively invisible to downstream skills like `/story-readiness`
