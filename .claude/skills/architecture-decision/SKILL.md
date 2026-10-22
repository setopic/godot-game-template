---
name: architecture-decision
description: "Create an ADR documenting a technical decision: context, alternatives considered, consequences."
argument-hint: "[title | retrofit <path> | accept <ADR-id|TDR-id>] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(wc -c *), Bash(bash "*/.claude/skills/architecture-decision/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/registry.sh *), Bash(bash .claude/scripts/adr-status.sh *), Bash(python -m tools.graph *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,workflow,docs.density,team.size`

Resolved above — use as-is; `--review` overrides `review_mode`. No block →
defaults in `.claude/docs/config-resolution.md`.

# Architecture Decision

When this skill is invoked:

## 0. Parse Arguments — Detect Retrofit / Acceptance Mode

See `.claude/docs/director-gates.md` for the full check pattern. Individual gate definitions live in `.claude/docs/director-gates/[gate-id].md` — the spawned agent reads its own gate file; do not read it in the parent session.

Every `AskUserQuestion` call follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

**`team.size`**: which agents validate this ADR (orthogonal to review_mode/workflow).
- **`individual`** (default): `technical-director` (TD-ADR) + the engine-specialist.
- **`small`** and **`studio`**: the same two. This skill spawns no engine
  sub-specialist and no adversarial reviewer at any size.

**`docs.density`** — it controls the *depth* of the ADR's prose sections, not
which sections the skeleton emits (that is fixed). `modes.rigor` sets it
alongside `workflow`; set `docs.density` explicitly to vary ADR verbosity alone:
`terse` (the default, via `rigor: minimal`) = decision + alternatives as bullets, one line of rationale each;
`balanced` = paragraph per section with light rationale (`rigor: standard`); `thorough` =
full prose with trade-offs and worked rationale in 決定, 検討した案, and
影響. Apply it to the prose sections; the エンジンとの互換, 前提のADR, and
対応するGDDの要件 tables are structural and stay whole at every
density.

**`workflow`** (see `.claude/docs/workflow-modes.md`):
- `full` — all ADRs on the required ADR list must be completed.
- `standard` — critical ADRs only (Foundation-layer systems).
- `minimal` — not required. Can still be run voluntarily.

**If the argument starts with `retrofit` followed by a file path**

**Read `references/0-retrofit.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

**If the argument starts with `accept` followed by an ADR id**

**Read `references/0-accept.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

If NOT in retrofit or acceptance mode, proceed to Step 1 below (normal ADR authoring).

**No-argument guard**: If no argument was provided (title is empty), ask before
running Phase 0:

> "What technical decision are you documenting? Please provide a short title
> (e.g., `event-system-architecture`, `physics-engine-choice`)."

Use the user's response as the title, then proceed to Step 1.

---

## 1. Load Engine Context (ALWAYS FIRST)

**Read `references/1-engine-context.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## 2. Choose the record kind, then the next number

game-template (PDR-0006) splits what this skill writes into two kinds. Each
kind has its own folder and its own numbers, from 0001:

| Kind | ID | File | What it records |
|---|---|---|---|
| TDR (Technology Decision Record) | `TDR-NNNN` | `docs/51-tdr/tdr-NNNN-[slug].md` | What the game uses from outside its own code: the engine and its version, the language, libraries, target platforms, build and export. Which physics engine to use is a TDR |
| ADR (Architecture Decision Record) | `ADR-NNNN` | `docs/52-adr/adr-NNNN-[slug].md` | How the inside of the game is built, where only the people building it see a difference and the player sees none: the event system, the save data format, how scenes are split |

Choose the kind before Step 3, from the title and what the user has said:

1. **Ask one question: does this decide what to use from outside the game's
   code (TDR), or how to build the inside of the game (ADR)?**
2. **A decision that does both is two records.** Example: "use library X for
   saving, and route every save through a SaveService built on it" is a TDR
   (library X) and an ADR (the SaveService). Tell the user it will be two
   records and write them one at a time, one full run of this skill each, the
   TDR first. The ADR's `**前提**` row in `## 前提のADR` names the
   TDR (`TDR-NNNN`), and so does the ADR's front matter `depends_on`: the ADR
   points at the TDR, never the other way round.
3. **When the kind is unclear, do not guess.** Ask with `AskUserQuestion`:
   - Prompt: "Is this a decision about what the game uses from outside its own
     code (TDR), or about how the inside of the game is built (ADR)?"
   - Options: `[A] TDR — [one line on why it could be a TDR]` /
     `[B] ADR — [one line on why it could be an ADR]` /
     `[C] Both — split it into a TDR and an ADR`
   In retrofit and acceptance mode the kind is already set by the file's folder
   and name: do not ask.

Then take the next number for that kind: the highest number among that kind's
files in its folder, plus one. Run `bash .claude/scripts/registry.sh next-id tdr`
or `bash .claude/scripts/registry.sh next-id adr`; it reads only that kind's
folder. The other kind's numbers do not count: TDR-0003 and ADR-0001 can both
be the newest.

From here on, "the ADR" in this skill means the record being written, of
either kind. Wherever a step shows `ADR-[NNNN]` or `adr-[NNNN]-[slug].md`, use
the chosen kind's ID and path from the table above.

---

## 3. Gather context

**Read `references/3-gather-context.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## 4. Guide the decision collaboratively

**Read `references/4-decide.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## 5. Generate the ADR

**Read `references/5-generate.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## 6. Closing Next Steps

After the ADR is written (and registry optionally updated), close with `AskUserQuestion`.

Before generating the widget:
1. Read the `## Required ADRs` section of `docs/architecture/architecture.md` (by section) and list `docs/51-tdr/tdr-*.md` and `docs/52-adr/adr-*.md`: a required ADR with no file in either folder is still unwritten. Without `architecture.md`, look for ADRs flagged in technical-preferences.md or systems-index.md as prerequisites
2. Check if all prerequisite ADRs are now written. If yes, include a "Start writing GDDs" option.
3. List ALL remaining priority ADRs as individual options — not just the next one or two.

Widget format:
```
[TDR|ADR]-[NNNN] written and registry updated. What would you like to do next?
[1] Write [next-priority-adr-name] — [brief description from prerequisites list]
[2] Write [another-priority-adr] — [brief description]  (include ALL remaining ones)
[N] Start writing GDDs — run `/design-system [first-undesigned-system]` (only show if all prerequisite ADRs are written)
[N+1] Stop here for this session
```

If there are no remaining priority ADRs and no undesigned GDD systems, offer only "Stop here" and suggest running `/architecture-review` in a fresh session.

**Always include this fixed notice in the closing output (do NOT omit it):**

> To validate ADR coverage against your GDDs, open a **fresh Claude Code session**
> and run `/architecture-review`.
>
> **Never run `/architecture-review` in the same session as `/architecture-decision`.**
> The reviewing agent must be independent of the authoring context to give an unbiased
> assessment. Running it here would invalidate the review.

**Do NOT unblock stories here.** This ADR is `Proposed` (`status: draft`) — Step 5 guarantees it,
and a story blocked *pending this decision* is still pending it. Unblocking on
authoring defeats the guard at the moment it becomes relevant: the pipeline
appears to flow while running on decisions nobody has accepted.

Instead, tell the user what is now waiting on acceptance:

> "[TDR|ADR]-NNNN is written and `Proposed` (`status: draft`). [N] stories remain `Blocked` pending it.
> Run `/architecture-decision accept [TDR|ADR]-NNNN` when the decision is settled —
> that is what moves them to `Ready`."

List the blocked stories by path so the cost of leaving it Proposed is visible.
(Acceptance has consequences enforced across many skills and an authority
recorded in only a few, so the route between them must stay explicit.)
