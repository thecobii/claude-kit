# Workspace Map (`AGENTS.md`) - playbook

A portable, battle-tested pattern for making an AI coding agent **stop burning tokens
re-discovering where things live** in a multi-repo (or large mono-) workspace - and for keeping
that map **correct forever** instead of letting it rot.

Hand this whole file to your agents. It is self-contained: the problem, the ideology, the
evidence, the design, and copy-paste implementation steps.

---

## 1. The problem

Every cold session, an agent re-derives the same facts: which service owns auth, where the shared
UI lives, where deploy scripts are, what package manager each repo uses, which repos even exist.
It does this by fanning out `grep`/`glob`/`read` calls - 10-20 round-trips of pure
re-exploration, repeated *every* session, and it still misses things.

The naive fix - a hand-written "map" doc - **rots**. Someone adds a repo or a feature, nobody
updates the map, and now the agent trusts a stale map (worse than no map: stale info actively
*poisons* the context). This is the failure to design against.

Two further traps, both measured in the wild:
- **Fully LLM-generated context files hurt.** Auto-written, bloated context docs *reduce* task
  success (~3%), add ~20% inference cost, and add reasoning steps. The map must be high-signal and
  mostly mechanical, not an essay an LLM regurgitates.
- **Heavy machinery is overkill.** Embeddings/code-graph indexes and bespoke MCP servers add a
  process to babysit, fail silently when stale, and answer "fuzzy similarity" when you need a
  *deterministic fact*. Don't reach for them to solve repo-level routing.

---

## 2. The ideology (the five rules)

1. **Generate the volatile half; hand-author the irreducible half.** Facts that live on disk
   (repo list, version, package manager, language, "has a CLAUDE.md/AGENTS.md") are **generated**
   from disk on every run - they can't drift. Facts no scan can infer (which service is the
   identity provider, where shared UI lives, deploy/host pointers) are a **small hand-authored
   block**, fenced so the generator never clobbers it.

2. **Make drift mechanically impossible, not a discipline.** A `--check` mode regenerates in
   memory and diffs against the committed file, exiting non-zero on any difference. Wire it into
   the place changes actually happen (pre-commit / CI) so a stale map **cannot land**.

3. **Read-first, one file, ~1-1.5k tokens.** The agent reads this one file at session start
   instead of grep-storming. Deep reads still happen - but *targeted* (jump straight to the right
   doc), not exploratory.

4. **Use the standard name: `AGENTS.md`.** It's the cross-tool convention (read by many agents,
   not just one vendor). Same generator, zero extra cost, free interoperability. Don't invent a
   bespoke filename.

5. **Lean beats deep.** A "what/where" router wins. Adding per-symbol / per-function detail costs
   more for no routing gain - add it later, scoped to a *single* huge repo, only if that repo
   becomes a symbol-level token sink.

---

## 3. The evidence (why this, measured)

A/B/C/baseline test: identical 12-question cold-navigation suite, four fresh agents, each given a
different starting map, graded for accuracy and metered for cost.

| Path | Tool calls | Tokens | Accuracy | Note |
|------|:---:|:---:|:---:|------|
| No map (baseline) | 9 | 36.1k | ~10/12 | most expensive; still missed/misclassified repos |
| Hand-written map (incomplete) | 5 | 33.2k | ~9.5/12 | incompleteness *forced* exploration that introduced errors |
| **Generated router (`AGENTS.md`)** | **3** | **29.0k** | **12/12** | cheapest + only fully correct |
| Generated router + per-repo key paths | 4 | 30.0k | 12/12 | +cost, no accuracy gain -> don't |

Takeaways: vs baseline, the generated router cut tool calls **~67%** and was the **only** path
that was fully correct. The decisive win isn't raw tokens (~20% there) - it's **fewer round-trips
plus correctness on the long-tail repos** a stale/absent map silently gets wrong. Going "deeper"
than a router measurably did not pay.

---

## 4. The design

One file at the workspace root: `AGENTS.md`. Two fenced regions.

```markdown
# Workspace map (AGENTS.md)
Read this FIRST. Routes to what exists and where. The GEN table is generated - do not hand-edit.

<!-- HAND (irreducible facts; edit by hand only when architecture changes) -->
- Auth / IdP: `auth` owns login. Relying parties: `web`, `mobile`. Canonical: `auth/docs/auth.md`.
- Shared UI: `packages/design` - consume it, never restyle per-app.
- Deploys: `scripts/deploy.sh` + `docs/deploy.md`; CI -> registry -> cluster.
- Package managers: `web` uses pnpm; the rest use npm.
<!-- /HAND -->

<!-- GEN (generated from disk; do not hand-edit) -->
| Repo | Purpose | Ver | Stack | AGENTS.md? |
|------|---------|-----|-------|-----------|
| api  | Core REST API | 2.3.1 | Go | yes |
| web  | Customer web app | 1.8.0 | pnpm | no |
| ...  | ...           | ...   | ...   | ... |
<!-- /GEN -->
```

- **HAND** is tiny and slow-changing. It carries exactly the facts a disk scan can't produce -
  ownership, conventions, off-disk/submodule entries (so they're never "deleted by absence").
- **GEN** is rebuilt every run. New repo? It appears. Version bump? Updated. Missing per-repo doc?
  Surfaced as a visible `no` you can act on.
- **Purpose** column is sourced from each repo's `README.md` first non-heading line - so keep that
  line a real one-liner (the generator is only as good as that line; flag bare `# name` READMEs as
  a TODO).

---

## 5. Implementation steps

### 5.1 Write the generator
A ~120-line script that:
1. Lists direct children of the workspace root; keeps a dir if it has `.git` **or** a manifest
   (`package.json`/`go.mod`/`*.csproj`/`pyproject.toml`/...), plus an **allowlist** for real dirs
   that lack those, minus an **ignore-list** (`node_modules`, vendored deps, backups, asset dirs).
2. For each repo derives: **purpose** (README first non-`#` line), **version** (manifest),
   **stack/package-manager** (lockfile/manifest type), **has-AGENTS.md/CLAUDE.md** (file exists).
3. **Preserves** the existing `<!-- HAND -->...<!-- /HAND -->` block verbatim (or seeds a default
   on first run); regenerates only the `<!-- GEN -->...<!-- /GEN -->` block.
4. Supports `--check`: regenerate in memory, diff vs the committed file, exit 1 on drift.
5. Writes UTF-8 (no BOM); normalize fancy punctuation to ASCII for clean diffs.

A portable Node reference is in section 7 below.

### 5.2 Make it stay correct (pick the trigger that matches your setup)
- **Team / CI (most robust):** a **git pre-commit hook** (or a CI job) runs `gen-map --check` and
  fails on drift. Since people commit on every change, the map can never go stale silently.
- **On repo creation:** call the generator from your "scaffold/onboard a new repo" script, so a
  new repo lands in the map the moment it's created (this is the #1 rot cause - kill it here).
- **Solo / local:** regenerate at session boot (it's sub-second). Acceptable alone only if you
  reliably boot the same way each time; otherwise pair it with the pre-commit hook.

### 5.3 Make the agent consume it
A passive rule ("read `AGENTS.md` first") is necessary but **not sufficient** - in practice agents
skip it and grep-storm anyway. The robust fix is to **inject the map into context automatically**,
so reading it is not a choice. See section 9 (the SessionStart inject hook). Keep the passive line
too, in the repo's `AGENTS.md`/`CLAUDE.md` convention file and/or shared agent config.

### 5.4 Retire the old map
If a hand-written map already exists, don't delete its *prose* (ownership/infra notes are
valuable) - just **replace its repo table with a pointer** to the generated `AGENTS.md` so there's
one source of truth for "what repos exist."

---

## 6. What NOT to do

- **Don't** auto-generate the prose/ownership facts with an LLM - that's the bloat that measurably
  hurts. Generate only mechanical facts; hand-write the ~6 irreducible ones.
- **Don't** build an MCP server / embeddings index for repo-level routing - a static generated
  file has no runtime to babysit and gives deterministic answers.
- **Don't** keep per-repo copies of the global map - that's N files to sync = the rot you're
  escaping. One root file; per-repo `AGENTS.md` only for *local* repo facts.
- **Don't** go symbol-level (function/class maps) up front - it costs more for no routing gain.
- **Don't** let `--check` be optional in a team - if it's not enforced where commits happen, it
  will silently stop running and you're back to rot.

---

## 7. Portable Node reference generator

Drop in as `scripts/gen-map.mjs`; run `node scripts/gen-map.mjs` or `... --check`. Adjust `ROOT`,
the ignore/allow lists, and stack detection to your stack.

```js
#!/usr/bin/env node
import { readdirSync, statSync, existsSync, readFileSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'

const ROOT = process.cwd()                         // workspace root
const OUT = join(ROOT, 'AGENTS.md')
const IGNORE = new Set(['node_modules', 'vendor', '.git', 'dist', 'build'])
const IGNORE_PREFIX = ['backup', '.']
const ALLOWLIST = new Set(['tools'])               // real dirs lacking a manifest
const isCheck = process.argv.includes('--check')

const DEFAULT_HAND = `<!-- HAND (irreducible facts; edit by hand only when architecture changes) -->
- Auth / IdP: <which repo owns login; who are the relying parties; canonical doc>
- Shared UI: <where it lives; "consume, never restyle per-app">
- Deploys: <script + doc; the pipeline>
- Package managers: <any per-repo exceptions>
<!-- /HAND -->`

const isProject = (dir) => {
  const name = dir.split(/[\\/]/).pop()
  if (IGNORE.has(name) || IGNORE_PREFIX.some(p => name.startsWith(p))) return false
  if (ALLOWLIST.has(name)) return true
  return ['.git', 'package.json', 'go.mod', 'pyproject.toml']
    .some(m => existsSync(join(dir, m))) ||
    readdirSync(dir).some(f => f.endsWith('.csproj'))
}
const purpose = (dir) => {
  const r = join(dir, 'README.md')
  if (!existsSync(r)) return '(no README)'
  for (const raw of readFileSync(r, 'utf8').split(/\r?\n/)) {
    const t = raw.trim()
    if (!t || t.startsWith('#')) continue
    const s = t.replace(/\*\*/g, '').replace(/`/g, '').replace(/\|/g, '/')
      .replace(/[–—]/g, '-').replace(/→/g, '->').trim()
    return s.length > 78 ? s.slice(0, 75) + '...' : s
  }
  return '(no description)'
}
const version = (dir) => {
  const p = join(dir, 'package.json')
  if (existsSync(p)) { try { return JSON.parse(readFileSync(p, 'utf8')).version || '-' } catch {} }
  return '-'
}
const stack = (dir) => {
  if (existsSync(join(dir, 'go.mod'))) return 'Go'
  if (readdirSync(dir).some(f => f.endsWith('.csproj'))) return '.NET'
  if (existsSync(join(dir, 'pnpm-lock.yaml'))) return 'pnpm'
  if (existsSync(join(dir, 'package-lock.json'))) return 'npm'
  if (existsSync(join(dir, 'pyproject.toml'))) return 'py'
  if (existsSync(join(dir, 'package.json'))) return 'node'
  return 'ops'
}
const hasAgents = (dir) =>
  existsSync(join(dir, 'AGENTS.md')) || existsSync(join(dir, 'CLAUDE.md')) ? 'yes' : 'NO'

const rows = readdirSync(ROOT)
  .map(n => join(ROOT, n))
  .filter(p => { try { return statSync(p).isDirectory() && isProject(p) } catch { return false } })
  .sort()
  .map(d => `| ${d.split(/[\\/]/).pop()} | ${purpose(d)} | ${version(d)} | ${stack(d)} | ${hasAgents(d)} |`)

const gen = ['| Repo | Purpose | Ver | Stack | AGENTS.md? |',
             '|------|---------|-----|-------|-----------|', ...rows].join('\n')

let hand = DEFAULT_HAND
if (existsSync(OUT)) {
  const m = readFileSync(OUT, 'utf8').match(/<!-- HAND[\s\S]*?<!-- \/HAND -->/)
  if (m) hand = m[0]
}
const body = `# Workspace map (AGENTS.md)

Read this FIRST every session. Routes to what exists and where. The GEN table is generated by
\`scripts/gen-map.mjs\` from disk - do not hand-edit it; edit the HAND block for facts a scan can't infer.

${hand}

<!-- GEN (generated from disk; do not hand-edit) -->
${gen}
<!-- /GEN -->
`
if (isCheck) {
  const cur = existsSync(OUT) ? readFileSync(OUT, 'utf8') : ''
  if (cur.trim() !== body.trim()) { console.error('[DRIFT] AGENTS.md stale. Run: node scripts/gen-map.mjs'); process.exit(1) }
  console.log(`[OK] AGENTS.md current (${rows.length} repos).`); process.exit(0)
}
writeFileSync(OUT, body); console.log(`[OK] wrote AGENTS.md (${rows.length} repos).`)
```

### CI / pre-commit one-liners
```yaml
# CI (GitHub Actions step)
- run: node scripts/gen-map.mjs --check
```
```yaml
# .pre-commit-config.yaml
- repo: local
  hooks:
    - id: gen-map
      name: workspace map fresh
      entry: node scripts/gen-map.mjs --check
      language: system
      pass_filenames: false
```

---

## 9. Active injection, ownership scoping, and the skill (the install-free path)

Sections 1-8 cover the *file* + a Node generator. This section adds the three things that make it
actually fire for the *main* agent, work in *partial-ownership* repos, and ship install-free. The
kit ships runnable versions: `scripts/map-repo.sh`, `hooks/inject-workspace-map.{sh,ps1}`, and the
`claude-kit-map-repo` skill. All are **bash + git, zero `npm install`** (runs on macOS + Windows
Git Bash) - important where corporate policy forbids installing dependencies.

### 9.1 Inject the map (the reader) - the fix for "the agent skips it"
A **global SessionStart hook** prints the cwd's `AGENTS.md` to stdout; Claude Code injects a
SessionStart hook's stdout as session context, so the map is loaded *before* the first tool call -
no choice to skip. It walks root->cwd collecting every `AGENTS.md` (nearest-wins cascade) and
appends a 2-line search protocol (ast-grep for structural, ripgrep for text). No map -> no-op.
Wire it once in global settings (`hooks.SessionStart` -> `bash .../inject-workspace-map.sh`).
This is the only piece that's tool-specific - Claude Code's native file is `CLAUDE.md`, so the hook
is what makes it use the `AGENTS.md` standard your other tools read natively. Keep a thin
`CLAUDE.md -> AGENTS.md` pointer so both agree.

### 9.2 Three levels (mono- AND multi-repo)
`AGENTS.md` nests; agents read the nearest file up the tree, closest wins. So:
- **workspace/global** map (parent of several repos) - cross-repo connections + a list/links. This
  is the answer for a *multi-repo* system: run the generator at the parent to get a global map.
- **repo** map - one repo, scoped to your part.
- **package** map - nested inside a monorepo, per package.
The inject hook loads the whole root->cwd chain, so the agent gets global connections *and* local
detail at once.

### 9.3 Ownership scoping (the work-repo case)
A blind full-repo scan is wrong when you own only *part* of a repo. `map-repo.sh` derives your
scope from **git history** (`git log --author=you` -> the top-level dirs you've actually committed
to) and scopes the GEN table to those, marking a `Yours` column. The HAND block (the facts a scan
can't infer) is **seeded from your skills** - any skill whose `description` names the repo is
matched (the description *is* the registry; no per-repo config). `--full` overrides; no git history
+ no matching skill -> a `TODO` stub, never a blind guess.

### 9.4 Skills link into the map (don't duplicate)
Once a repo's facts live in `AGENTS.md`, a skill that used to embed "service X is in /foo, configs
in /bar" should be **trimmed to link** ("layout: see `AGENTS.md`") and keep only its unique
workflow. One source of truth, no drift between skill-prose and reality, shorter skills.

### 9.5 Reader vs writer - keep them separate
The inject hook is the *only reader*; `map-repo.sh` / `claude-kit-map-repo` is the *only writer*.
Don't have skills self-write maps or hooks generate them blind - one writer, one reader, one file.

---

## 8. One-paragraph summary (for a busy reviewer)

Put a single `AGENTS.md` at the workspace root with a tiny hand-authored facts block (auth/UI/
deploy ownership) and a disk-generated repo table (purpose/version/stack/has-doc). Regenerate the
table with a small script; enforce freshness with a `--check` mode wired into pre-commit/CI so it
can never go stale. Tell the agent to read it first. Measured result vs no map: ~67% fewer
exploration calls and the only fully-correct answers. Don't auto-write the prose, don't build an
index server, don't go symbol-level - lean router, mechanically kept honest.
