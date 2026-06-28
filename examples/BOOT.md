# BOOT - boot brief (example)

A filled example of `patterns/boot-brief.md`: the stable rules/roster/gotchas a session needs,
distilled into one read-first digest. Repo locations live in `AGENTS.md` (don't duplicate them here).
Live state (versions, what's deployed) lives in `STATE.md`. Go deep via the linked docs.

## Read order
1. `AGENTS.md` (where things are). 2. This file (rules/gotchas digest). 3. `STATE.md` (live state).
4. Task-specific doc (e.g. `auth/docs/auth.md` for anything touching login).

## Core rules (full text in the team's rule docs)
- One writer per area at a time; don't let two agents edit the same files (see workflow boundaries).
- Verify before done: run tests + lint + build; a skip is not a pass.
- Commit small + atomic; never push a shared branch without sign-off; never commit secrets.
- Reuse the shared `packages/ui` - never restyle generic UI per app.

## Gotcha index (id -> one-line rule -> full doc)
- pm-mismatch -> `web` is pnpm, others npm; mixing corrupts the lockfile. (docs/setup.md)
- migration-gate -> DB migrations are Ask-first + need a backup. (db/README.md)
- auth-field -> read the user as `req.session.user.id`, not `req.user`. (auth/docs/auth.md)

## Deep docs
`AGENTS.md` (map) - `STATE.md` (live) - team rule docs - `docs/deploy.md`.
