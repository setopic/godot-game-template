# /architecture-decision — Retrofit Mode

> Part of `/architecture-decision`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

**If the argument starts with `retrofit` followed by a file path**

(e.g., `/architecture-decision retrofit docs/52-adr/adr-0001-event-system.md`, or
a TDR such as `docs/51-tdr/tdr-0003-physics-engine.md`):

Enter **retrofit mode**:

1. Read the existing ADR file completely. This step needs the whole ADR: read it
   in ranges by its headings (found with the Grep tool: pattern `^#`, content
   mode), since a whole-file Read over 40 KB is refused.
2. Identify which template sections are present by scanning headings and the
   front matter (game-template, PDR-0006: the sections are the Japanese ones of
   `docs/00-meta/templates/adr.md`, and the status is the front matter's
   `status:`, never a `## Status` section):
   - front matter `status:` — **BLOCKING if missing**: `/story-readiness` cannot check ADR acceptance.
     A file with no front matter at all is not a graph node, and `python -m tools.graph check` fails on it
   - `## 前提のADR` — HIGH if missing: dependency ordering breaks
   - `## エンジンとの互換` — HIGH if missing: post-cutoff risk unknown. A
     present table with no **層** row is HIGH too: the ADR counts as critical
     wherever it is read, so at `standard` its advisory items become blockers
   - `## 対応するGDDの要件` — MEDIUM if missing: traceability lost
   - `## 日付` — MEDIUM if missing, and no front matter `last_verified:` date
     (nor a `## 最終確認日` section, moved there below) either: `/create-stories`
     stamps stories with it and `/dev-story` compares against it, so without it a
     story can never tell whether the ADR changed
   - every other `##` section of the template (`python -m tools.graph check`
     reports a missing one as `G014`) — LOW: add it with 「なし」 when there is
     nothing to say
   An ADR written in CCGS's English sections (`## Status`, `## Context`, ...)
   is moved section by section to the Japanese ones, its text unchanged; the
   English heading is renamed, which is the one change to existing content
   this mode makes.
3. Present to the user:
   ```
   ## Retrofit: [ADR title]
   File: [path]

   Sections already present (will not be touched):
   ✓ status: [current value, or "MISSING — will add"]
   ✓ [section]

   Missing sections to add:
   ✗ status — BLOCKING (stories cannot validate ADR acceptance without this)
   ✗ 前提のADR — HIGH
   ✗ エンジンとの互換 — HIGH
   ```
4. Ask: "Shall I add the [N] missing sections? I will not modify any existing content."
   If no: write nothing, and report the missing sections by name.
5. If yes:
   - For **status**: ask the user — "What is the current status of this decision?"
     Options: "Proposed", "Accepted", "Deprecated", "Superseded by ADR-XXXX"
     Write it to the front matter's `status:`: Proposed is `draft`, Deprecated
     is `deprecated`, and Superseded is `deprecated` with `ADR-XXXX` given this
     ADR's id in its own `supersedes`. An `Accepted` answer — a decision already
     in force — is not written as given: write `draft`, add the other missing
     sections, then run acceptance mode (below) on this ADR. Its dependency
     check, confirmation and story unblocking apply here too; it stays the only
     path that sets `stable`. A file with no front matter gets the template's
     (`id`, `type`, `title`, `status`, `tags`, `depends_on`, `decides`,
     `supersedes`, `related`).
   - For **前提のADR**: ask — "Does this decision depend on any other ADR?
     Does it enable or block any other ADR or epic?" Accept 「なし」 for each field.
     Every TDR or ADR in the `**前提**` row goes into the front matter's
     `depends_on` too.
   - For **エンジンとの互換**: read the engine reference docs (same as Step 1 below)
     and ask the user to confirm the domain. Then generate the table with verified data,
     its 層 row included.
   - For a present エンジンとの互換 table with no **層** row: find the
     layer as `references/5-generate.md` says under "Always write the 層 row",
     and add the row under **分野**. It adds a row and changes none.
   - For **対応するGDDの要件**: ask — "Which GDD systems motivated this decision?
     What specific requirement in each GDD does this ADR address?"
   - Append each missing section to the ADR file using the Edit tool.
   - For a `## 最終確認日` section (a record written before game-template 0.9.0,
     PDR-0007): move its date to the front matter's `last_verified:` and delete
     the section; if it says 「なし」, delete it and leave `last_verified:` empty.
     The date is not changed, only where it is kept, so this is the one
     exception to the rule below, also on a `stable` record.
   - For **日付** (counted only when there is no front matter `last_verified:` date): append
     `## 日付` with today's date — even when it is the only missing section, the
     case `/dev-story` sends you here for — and say that it records the retrofit,
     not when the decision was made.
   - **Never modify any existing section.** Only append or fill absent sections.
6. Run `python -m tools.graph check`, then suggest: "Run `/architecture-review`
   to re-validate coverage now that this ADR has its status and 前提のADR."
