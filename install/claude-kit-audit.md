# claude-kit-audit

**Lint a project's OWN skills/docs against the kit rules** - score each file against the rules, flag verbose / rule-breaking ones, propose lean rewrites; approval-gated, report-only in a repo you don't own.

Run this to check a project's OWN skills/docs (CLAUDE.md, AGENTS.md, skill files, rule files)
against the kit's `rules/*` and propose lean rewrites. Distinct from the other two skills:

| Skill | Reads | Judged against | Writes |
|-------|-------|----------------|--------|
| SETUP | kit items | the target's existing rules | the target (adds kit) |
| kit-sync | your local config | portability/safety | the kit |
| **audit** | **the target's own skills/docs** | **the kit `rules/*` as rubric** | **the target's own files (rewrite)** |

Use it when files you already have (especially verbose work skills) drift from the standard the
kit encodes - terse prose, minimal surface, no magic strings, self-documenting, one entry point.

## Rubric = the kit's own rules (invent nothing)
Score ONLY against `rules/coding.md` + `rules/communication.md` + `rules/values.md`. Every finding
must cite the exact rule it breaks. If a finding can't cite a rule, it's an opinion - drop it.

## Phases (approval-gated; report-first)
1. **INVENTORY** - enumerate the target's skills + docs (CLAUDE.md, AGENTS.md, skill files, rule files).
2. **SCORE** each file against the checkable rules, priority order: magic strings/numbers ·
   verbosity vs minimal-surface · duplicated entry points / DRY · comments restating *what* ·
   missing structure (no states / no verification checkpoint) · inconsistent terminology.
3. **FINDINGS TABLE** (report-only by default): `file | line/region | rule violated | severity |
   proposed lean rewrite (diff)`. Severity gates noise: HIGH = rule-breaking (magic string,
   contradiction); LOW = stylistic verbosity (opt-in).
4. **APPROVAL** - per-finding accept/reject. **In any repo you don't own, default to report-only -
   never auto-rewrite.** A flagged item the human keeps = a documented exception, not re-flagged next run.
5. **APPLY** - rewrite only approved findings, in place (these are the human's own files - show the
   old/new diff and require sign-off; optionally drop a one-line `audited against kit @<SHA>` marker).

## Must NOT do
- **Never auto-apply** in a foreign/work repo.
- **Lossless by default** - every original directive must survive the rewrite. "Shorter" means fewer
  WORDS per rule, never fewer rules. Show old vs new side by side; this is the killer risk.
- **No criteria beyond the kit rules** - no invented "best practices".
- **Never delete a team's own standards** as "bloat" - that's a CONFLICT for the human to decide
  (same posture as SETUP), not an audit deletion.
- **No semantic compression** that drops a load-bearing clause.
