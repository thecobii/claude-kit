# Agent-tooling standards

Universal, dependency-light practices that make an AI-agent-driven project faster, cheaper, and
more correct. Each is measured, not folklore (numbers are inline). Hand this to your agents.

Scope note: these are principles, not mandated dependencies or endpoints. Adopt the shape; build
the concrete thing only when a consumer needs it (no speculative endpoints).

---

## 1. Agent-facing API design (the AXI principles)

Any tool an agent calls - an HTTP API, a CLI, a control script - should be designed for the
agent, not just for humans. Apply these to every agent-facing surface:

- **Minimal default schema.** Return the 3-4 load-bearing fields per list item; full detail
  behind `?detail=1`. Don't make the agent wade through (and pay tokens for) fields it didn't ask
  for.
- **Pre-computed aggregates.** Return the *answer*, not raw rows the agent must fetch-then-count.
  A status endpoint returns `{total, running, stopped, runningItems:[...]}` - one call, done.
  *Measured: a "how many running" query was 34 tokens / 1 call as an aggregate vs 345 tokens plus
  a parse/count step against a verbose list = -91%.*
- **Definitive empty states.** Print `no results` explicitly, never a blank line or a bare `[]`
  the agent has to interpret.
- **Structured errors + clean exit codes.** Emit `{error, code, hint}` and a non-zero exit, never
  a prose stack dump the agent has to re-parse. Make the next step obvious.
- **No interactive prompts.** Agent-facing commands must be non-interactive (flags/env, not stdin
  questions) - a prompt hangs a background agent forever.
- **Idempotent mutations.** start/stop/deploy safe to re-run; re-running returns the current
  state, not an error.
- **Content-first + next-step hints.** On no args, show live data, not help text; end output with
  the likely next command.
- **Combine multi-step operations.** If the agent always does A-then-B, ship one command that does
  both and returns B's result (`open --query` = navigate+snapshot+filter in one call; `deploy --wait`
  = trigger+poll+final status). Each merge is one fewer round-trip. *AXI's browser tool cut a 9-turn
  extraction to 2 this way.*
- **Caller-filtered output (`--query` / `--fields`).** Let the caller name the slice it wants and
  return only that - every command becomes a targeted view. Lean by default; `--fields x,y` or
  `--query term` for more.
- **Truncate long output, with an escape hatch.** Cap big lists/blobs by default (first N + "...M
  more, use `--all`"); never dump 10k tokens the agent must scroll. The flag keeps it complete when needed.
- **Shell-composable.** Emit clean line-oriented text so the agent can pipe through `grep`/`head`/`jq`
  to filter further - don't force a bespoke query language for simple slicing.

Don't: blanket-adopt a new wire format (e.g. TOON) - it only pays on large *uniform* tabular
payloads; on small or nested data it's churn for no gain. Don't build aggregate endpoints speculatively.

> Source: these are the **AXI** (Agent eXperience Interface) principles - [axi.md](https://axi.md),
> externally benchmarked (425 GitHub-API + 490 browser runs) at ~100% success with lower cost/latency
> than raw CLI or MCP. Adopt the *shape*; the reference CLIs (`gh-axi`, `chrome-devtools-axi`) are the
> creator's tools, not drop-ins for Claude Code.

## 2. Preview / visual verification protocol

A UI change isn't done until it's proven at the real width. But the verify loop is slow if done
wrong.

- **Measure with the DOM, not pixels, for dimensions.** `getBoundingClientRect()` or
  computed-style via the preview eval returns the exact number in milliseconds. *~30 tokens vs
  ~1.5k for a screenshot* - and it's what catches "renders at 477px when it should be 1480".
- **Keep the dev server warm.** Start it once and reuse it across checks; don't pay the
  cold-start cost every iteration. HMR covers most edits; restart only when a change can't
  hot-apply.
- **Screenshot for what only pixels show.** Opacity, scrim/backdrop, z-index, layering bleed - a
  structure/measurement check passes on those while they're visibly broken. A screenshot is
  required for overlays/modals/sheets and as the final appearance proof. So: measure for
  dimensions, screenshot for layering - both, for their own jobs. Not "screenshot only at the
  end".
- Frame UI tasks as outcomes with acceptance criteria ("fills the width; >=1376px at a 1440
  viewport"), not "change value Y".
- Watch for environment artifacts: if a screenshot or a rAF-based eval hangs, a backgrounded or
  hidden tab pauses paint and timers - verify via DOM/computed-styles instead of pixels. That's
  an env quirk, not a bug in your change.

## 3. Structural code search over regex

For "where is X *called / defined / shaped* like this", use an AST tool (e.g. `ast-grep`), not
regex. Regex matches text - imports, types, comments, and strings inflate the count and mislead.

*Measured: counting a hook's call sites, an AST query was 1 call and correct (50/16); a
regex-only agent took 5 calls and fabricated a wrong answer (114/22, including a file with zero
matches).*

- Use plain text search (ripgrep) for string/config/log hunts - it's fine and fast there.
- Reach for the AST tool the moment the question is structural (call sites, definitions, JSX
  usage, call shapes) or you're doing a safe codemod/rename.
- Treat the AST tool as **agent tooling installed globally** (like ripgrep / the VCS CLI), not a
  project dependency - it never enters the manifest or the runtime tree, so it doesn't violate
  lean-deps.

---

These three are dependency-free principles (or global agent tooling), safe to require on every
project. Project-specific mechanisms (a generated workspace map, a boot-brief digest) live with
the workspace that needs them - see `workspace-map-playbook.md` and `boot-brief.md`.
