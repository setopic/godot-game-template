# Design Decision Records (DDR)

game-template (PDR-0006). A game design decision is recorded as a DDR, a graph
node in `docs/53-ddr/`. The GDD in `design/gdd/` and the DDR point at each other.
Skills that author or change a GDD read this file when a design decision comes up.

## What is a DDR

A DDR records a decision that changes what the player can do, see or feel: a
rule or a specification, the reasons, and the options that were rejected.
Examples: whether saving uses checkpoints or works anywhere; how an enemy moves.

**The line with an ADR is "can the player tell the difference?"** How an enemy
moves is a DDR. Whether the enemy AI is a state machine or a behaviour tree is an
ADR (`/architecture-decision`). A topic that has both is two records: the DDR
first, then the ADR, whose front matter `depends_on` names the DDR. The ADR
points at the DDR, never the other way round.

| Kind | ID | File |
|---|---|---|
| DDR (Design Decision Record) | `DDR-NNNN` | `docs/53-ddr/ddr-NNNN-[slug].md` |

## When to write one

Write a DDR when the user chooses between real alternatives and the choice
changes what the player can do, see or feel: the Options step of a GDD section,
a review finding that changes a rule, a GDD revision that reverses an earlier
rule. Moving a value inside the range a Tuning Knob already documents is not a
DDR. Writing down a rule nobody chose between is not a DDR either.

**The GDD holds the current specification only.** Why it is so, what was
rejected and what it replaced belong in the DDR. Do not write decision history
("we considered X but rejected it") into the GDD; write the DDR and list its ID
in the GDD's `Related DDRs` line.

## How to write one

Ask "May I write a DDR for [decision] to `docs/53-ddr/`?" first, as with any
write. Then:

1. Take the next number: `bash .claude/scripts/registry.sh next-id ddr`
   (the highest number in `docs/53-ddr/` plus one; DDRs are numbered from 0001,
   separately from TDRs and ADRs).
2. Create the file with the graph tool. Never place it by hand:

   ```bash
   python -m tools.graph new --type ddr --id DDR-NNNN --title "[decision, in Japanese]" --slug [ascii-slug]
   ```

   It uses `docs/00-meta/templates/ddr.md` and adds the DDR to
   `docs/53-ddr/index.md`.
3. Fill the six sections in Japanese, following the template's comments:
   背景, 決定, 理由, 却下した案, 影響, 見直しの条件. In `## 背景`, write the GDD
   path on the `対応するGDD` line (`design/gdd/[system].md`).
4. Add the DDR's ID to the GDD's `> **Related DDRs**:` header line
   (comma-separated; replace `None`).
5. Run `python -m tools.graph sync` and `python -m tools.graph check`.
   Do not report the DDR as written while `check` fails.

The DDR starts as `status: draft`. Only the user moves it to `stable`. A stable
DDR is not edited: to change the decision, write a new DDR whose `supersedes`
names the old one, set the old one's `status` to `deprecated`, and replace the
old ID with the new one in the GDD's `Related DDRs` line.

## What is not checked

`python -m tools.graph check` validates the DDR, including that it is a valid
node. **The GDD is outside the graph, so nothing checks the GDD's `Related DDRs`
line or the DDR's `対応するGDD` line.** After writing, confirm by eye that the
GDD lists the DDR and the DDR names the GDD.
