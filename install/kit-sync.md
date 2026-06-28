# kit-sync - promote your local config into claude-kit (on demand)

Run this **by wish** when you've improved your local rules/patterns/skills and want the public
kit to catch up. It does NOT run automatically - you invoke it. It re-scrubs your evolving local
config and updates the kit, with a hard safety gate so nothing personal can leak into a public repo.

## Inputs
- **Your local config** (the source of truth you actually edit): `~/.claude/CLAUDE.md`,
  `~/.claude/rules/*`, any local pattern docs, and your skills (only genuinely portable ones).
- **The scrub map** `.kit-scrub.local.json` (gitignored - see `.kit-scrub.example.json` for the
  shape). It maps your real identity/infra -> placeholders/removals and holds the deny-list. This
  file NEVER enters the repo, so the kit and this skill stay free of your real data.

## Steps
1. **DIFF** - for each kit `rules/*` and `patterns/*` file, compare against its local source; list
   what changed (or is new / was removed) locally since the last sync. Match local<->kit by the
   scrub map's `filemap` (e.g. local `comms.md` <-> kit `communication.md`), NOT by filename - a
   renamed file matched by name reads as a false add + delete.
2. **SCRUB** - apply `.kit-scrub.local.json` to every changed/new chunk: `replace` real tokens with
   placeholders, drop lines matching `remove_lines_matching` (hosts, IPs, infra, project names).
3. **SAFETY GATE (hard)** - grep the resulting kit content for every term in the map's `deny` list.
   **If ANY hit, ABORT** and show it - never write a leak into the public kit.
4. **UPDATE** - write the scrubbed content into the kit files; add new portable items, drop removed
   ones. Bump `VERSION` (semver) and note the change.
5. **REVIEW GATE** - show a summary table (`file | changed | safe?`) and STOP for approval. Never
   auto-commit. On approval: commit + push.

## What NOT to sync
- Lyra/stack-specific skills (anything tied to your Pi/IdP/fleet) - they don't port; leave them out.
- Anything the deny-list catches that the scrub map didn't anticipate - extend the map, don't force it.

Keep the kit principle-level: if a local edit added a stack-specific example, generalize it on the
way in (that's a judgment step, not a pure find-replace).
