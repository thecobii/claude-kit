# claude-kit-verify-rules

**A strict rules-compliance gate for CODE** - audit a change (default) or the whole project (`--all`)
against the kit `rules/*`; every finding cites the exact rule it breaks. The final gate before "done",
so a rule that slipped (over-commenting, everything-in-one-file, a magic literal) is caught, not shipped.

The CODE counterpart of `install/claude-kit-audit.md` (which lints DOCS/skills). Don't duplicate the
other gates: a correctness/bug review and the design-boundary guard are separate concerns - this skill
checks *rule compliance only*. Invoke by name (e.g. `/claude-kit-verify-rules [--all] [--fix]`).

## Scope
- **Default = the CHANGE:** uncommitted diff, else the current branch vs its base. Smallest review surface.
- `--all` / "entire project": every source file. Heavier - only when asked.

## Rubric = the rule slices, invent nothing
Score ONLY against `rules/coding.md` + `rules/communication.md` + `rules/values.md` (plus the repo's own
CLAUDE.md/docs rules). Every finding MUST cite the exact rule clause it breaks. Can't cite a rule -> it's
an opinion, drop it.

## Checklist - walk ALL of it (a gate can't skip a non-negotiable)
Verdict each PASS / FAIL / N/A with `file:line` evidence:
1. **Comments near-zero** - none restating *what*, no instructional/how-to inline, no docs duplicated into code; templates/starters included.
2. **Organize by concern** - each thing in its right file; no lazy everything-in-`main`/`index`; no over-split (file-per-function, speculative layering).
3. **DRY & tight** - no duplication / duplicate entry points; repeated logic -> one named helper.
4. **No magic strings/numbers** - meaningful literals hoisted to named consts in a clear place.
4b. **No single-use locals** - a value used once is inlined (or extracted to a function if it carries much logic); named locals only when reused.
5. **Minimal surface** - UI/code/copy say the minimum; no over-worded labels/blurbs/empty states.
6. **Simplicity** - no speculative abstraction/flexibility/impossible-case handling; 200-that-could-be-50.
6b. **No dead code** - no unused funcs/vars/imports/params you introduced, no unreachable branches, no commented-out blocks.
7. **Surgical** - only what the task asked; no unrelated refactors; only the change's own unused imports removed.
8. **Self-documenting names** - intention-revealing; a comment you "need" usually means a bad name.
9. **Consistency global** - generic UI from the shared design system; section titles above the block; one primary button/view; overlays capped to viewport.
10. **Dates/times** - `dd.mm.yyyy` + 24h `HH:mm` in user-facing output; ISO only internally.
11. **Visual proof** (if UI/CSS touched) - a screenshot + a measured dimension exists, not just build-green.

## Output - a verdict table, report-first
`rule | verdict | file:line | what breaks it | fix`
Lead with FAILs; collapse PASS rows to a count. End with one line: **GATE: PASS** (zero FAILs) or **GATE: FAIL (n)**.
- Default **report-only**. `--fix` applies the safe, behavior-preserving fixes (comment trims, placement
  splits, literal-hoists) then re-reports; **never** weakens a test or auto-fixes a visual rule (those need
  the human + real proof).
- A FAIL the human chooses to keep = a documented exception, not re-flagged next run.

## Self-run
An agent runs this on its OWN change before reporting done - the "save it" gate. Cheap on a diff; just do it.
