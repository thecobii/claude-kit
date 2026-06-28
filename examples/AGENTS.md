# Workspace map (example AGENTS.md)

Read this first - it routes to what exists and where, so you don't grep to rediscover layout.
This is a filled example of the `patterns/workspace-map-playbook.md` router. The GEN table is
generated from disk; the HAND block + Boundaries are authored.

<!-- HAND (irreducible facts; edit by hand only when architecture changes) -->
- **Auth / IdP:** `auth` owns login/sessions. Relying parties: `web`, `mobile`. Doc: `auth/docs/auth.md`.
- **Shared UI:** `packages/ui` - consume it, never restyle per app.
- **Deploys:** `scripts/deploy.sh` + `docs/deploy.md`; CI -> registry -> cluster.
- **Package managers:** `web` uses pnpm; the rest use npm. (Mixing corrupts the lockfile.)
<!-- /HAND -->

<!-- Boundaries (Always / Ask-first / Never) - the highest-signal section -->
## Boundaries
- **Always:** read/search, run tests + lint + build, scoped edits in `apps/*/src` and `packages/*/src`.
- **Ask first:** DB migrations (`db/migrations/`), new dependencies, anything under `infra/`, a deploy, editing CI.
- **Never:** commit `.env*` or secrets, force-push `main`, edit `packages/ui` chrome without a design sign-off.
<!-- /Boundaries -->

<!-- GEN (generated from disk by your gen-map script; do not hand-edit) -->
| Repo / package | Purpose | Ver | Stack | Has agent doc? |
|----------------|---------|-----|-------|----------------|
| auth | Identity provider - login, sessions, tokens | 2.3.1 | Go | yes |
| api | Core REST API | 1.9.0 | Go | yes |
| web | Customer web app | 1.8.0 | pnpm | yes |
| mobile | Mobile client | 0.4.2 | RN | no |
| packages/ui | Shared design system | 3.1.0 | pnpm | yes |
<!-- /GEN -->
