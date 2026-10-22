# Docs Directory

When authoring or editing files in this directory, follow these standards.

## TDRs and ADRs (`docs/51-tdr/`, `docs/52-adr/`)

game-template (PDR-0006): TDRs (what the game uses from outside its own code)
and ADRs (how the inside of the game is built) are graph nodes. Create one with
`/architecture-decision`, which runs `python -m tools.graph new --type tdr|adr`
on the template `docs/00-meta/templates/tdr.md` or `adr.md`. Never place the
file by hand.

**Required sections:** the 16 Japanese sections of the template (日付, 最終確認日,
決めた人, 要約, エンジンとの互換, 前提のADR, 背景, 決定, 検討した案, 影響, リスク,
対応するGDDの要件, 性能への影響, 移行の手順, 確かめ方, 関連). CCGS's English
names are mapped in `.claude/docs/templates/architecture-decision-record.md`.
`python -m tools.graph check` fails on a missing one (`G014`).

**Status lifecycle:** the front matter's `status:`, never a `## Status`
section: `draft` (Proposed) → `stable` (Accepted) → `deprecated` (Superseded,
with the successor's `supersedes` naming it)
- Never skip `stable` — stories referencing a `draft` ADR are auto-blocked
- Use `/architecture-decision accept <id>` to move a record to `stable`

## Other architecture documents (`docs/architecture/`)

**TR Registry:** `docs/architecture/tr-registry.yaml`
- Stable requirement IDs (e.g. `TR-movement-001`) that link GDD requirements to stories
- Never renumber existing IDs — only append new ones
- Updated by `/architecture-review` Phase 8

**Control Manifest:** `docs/architecture/control-manifest.md`
- Flat programmer rules sheet: Required / Forbidden / Guardrails per layer
- Date-stamped `Manifest Version:` in header
- Stories embed this version; `/story-done` checks for staleness

**Validation:** Run `/architecture-review` after completing a set of ADRs.

## Engine Reference (`docs/engine-reference/`)

Version-pinned engine API snapshots. **Always check here before using any
engine API** — the LLM's training data predates the pinned engine version.

Current engine: see `docs/engine-reference/<engine>/VERSION.md` (`<engine>` is `godot`, `unity` or `unreal`, matching `engine.name` in `project.yaml`)
