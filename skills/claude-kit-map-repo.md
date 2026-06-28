---
name: claude-kit-map-repo
description: Generate or refresh an AGENTS.md workspace map for the current repo/workspace - scoped to the parts you actually own (git history) and seeded from your skills. Run in a new repo, when the map is stale, or when the user says "map this repo / make an AGENTS.md / build the workspace map / no map here". Portable - bash + git, zero install.
---

# claude-kit-map-repo - generate the workspace map

Writes/refreshes `AGENTS.md` - the standard agent-context map (~28 AI tools read it) - for the
current repo or workspace, **scoped to YOUR part**, so the inject hook can load it into context
every session and you stop grep-storming to rediscover layout.

## The generator (mechanical part)
`scripts/map-repo.sh` - bash + git, zero install (works on Mac + Windows Git Bash):
- `bash <claude-kit>/scripts/map-repo.sh --stdout` to **preview**, then drop `--stdout` to write.
- It scopes the GEN table to dirs you've git-committed to (partial ownership), **preserves an
  existing HAND block**, and seeds a fresh HAND from skills whose `description` names this repo.
- `--full` maps everything (ignore ownership). `--check` exits 1 if the map is stale (CI/pre-commit).

## Your job (the judgment the script can't do)
1. **Run it** (`--stdout` first; eyeball the GEN table + "Yours" column).
2. **Fill/refine the HAND block** - the facts a scan can't infer: what this repo is, **where YOUR
   part lives**, key entry points, cross-repo connections. Source them from the repo's
   README/CLAUDE.md, the parts you touch, and your relevant **skills** (their descriptions say what
   they cover). For a partially-owned repo, write ONLY your area.
3. **Ownership sanity:** if the `git log --author` scope looks wrong (owns too much/little), pass
   `--full` or hand-edit. Never map areas you don't touch - scope is the whole point.
4. **Workspace / multi-repo with no global map:** run it at the **parent of several repos** to get a
   global map that lists + links them; seed its HAND from the skills that describe those repos and
   their connections. This is how a work multi-repo system gets a global `AGENTS.md` when none ships.
5. **Slim the skill (DRY):** if a skill currently embeds repo facts you just moved into `AGENTS.md`,
   trim the skill to **link** to the map ("layout: see `AGENTS.md`") instead of duplicating it.

## Don't
- Don't map dirs you don't own (work repos) - scoping is the point.
- Don't convert `AGENTS.md` away from markdown - it must stay the portable standard every tool reads.
- This is the *writer*; the SessionStart inject hook is the *reader*. Keep them separate.
