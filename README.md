# claude-kit

A portable, public-safe set of rules and patterns for AI coding agents (Claude Code and
compatible tools). Drop it into any project - personal or work - to give your agents a
consistent baseline: how to communicate, how to write code, what to value, how to stay
resume-ready, plus a few battle-tested workspace patterns.

## What's inside

```
rules/
  communication.md   - terse-by-default replies, decisions-as-table, background-task ETAs, writing style
  coding.md          - think-first, simplicity, surgical edits, DRY, no magic strings, self-documenting,
                       tool-use efficiency, decision rigor, minimal surface, visual proof, dates, rule capture
  values.md          - privacy-first, quality bar, show-don't-tell, keep-VCS-current
  context.md         - resume-ready docs + snapshot-when-large protocol
  security.md        - secret handling, untrusted-content / prompt-injection, no exfil
  workflow.md        - act-vs-ask boundaries (Always/Ask/Never), git + commit hygiene, verification
patterns/
  agent-tooling-standards.md   - agent-facing API design, visual-verify protocol, AST-over-regex
  workspace-map-playbook.md    - a generated AGENTS.md router kept honest by a --check hook
  boot-brief.md                - distill standing docs into one read-first digest with a staleness check
install/
  SETUP.md           - merge the kit INTO a target project (adopt the rules/patterns)
  audit.md           - lint a project's OWN skills/docs against the kit rules + propose lean rewrites
  kit-sync.md        - (maintainers) promote your evolving local config back into the kit, scrubbed
skills/
  brainstorm.md      - decision cascade: complexity gate -> fan by angle -> synthesize -> decision table
examples/
  AGENTS.md          - a filled workspace-map router (with an Always/Ask/Never boundaries block)
  BOOT.md            - a filled boot-brief digest
```

## Scope: principles, adapt to your project

These are **principles, not config you copy verbatim**. They encode *what good looks like*
and *why*, deliberately free of any one project's stack, infra, or names. Adapt the specifics
(your design system's name, your deploy command, your widths) to your project; keep the shape.

## Quickstart

- **Your own repo:** add as a submodule, then import the rule files into your agent config (below).
- **A work / foreign repo:** run [`install/SETUP.md`](install/SETUP.md) - it merges the kit in without clobbering the project's existing rules.
- **Adapt, don't copy blindly:** these are principles; swap in your stack's specifics, keep the shape.

## Install

Two modes - pick by who owns the target repo.

**1. Your own machine (symlink or submodule).** No merge logic needed - point your agent config
at the kit and go.

```bash
# submodule (pin to a commit you trust)
git submodule add <kit-repo-url> .claude-kit
# or symlink the rules into your agent config dir
ln -s "$PWD/.claude-kit/rules" ~/.claude/kit-rules
```

Then import them explicitly from your agent config (a symlinked folder of `.md` files isn't
auto-loaded). For Claude Code, add to your `CLAUDE.md`:

```
@.claude-kit/rules/coding.md
@.claude-kit/rules/communication.md
@.claude-kit/rules/values.md
@.claude-kit/rules/context.md
@.claude-kit/rules/security.md
@.claude-kit/rules/workflow.md
```

**2. A foreign or work repo (the merge skill).** When the target already has its own
`CLAUDE.md` / `AGENTS.md` / rules, do **not** blast over them. Run the integration skill in
[`install/SETUP.md`](install/SETUP.md): it inventories what's there, classifies each kit item
(adopt / keep-theirs / merge / conflict / skip), shows you an approval-gated merge table, then
applies only what you approve - inside delimited blocks that leave the project's own lines
untouched, pinned to a kit commit SHA for clean future updates.

## A note on safety

This kit is public-safe by construction: no personal names, no infrastructure details, no host
or network identifiers, no project-internal references. If you fork it, keep it that way - the
whole value is that it's portable and shareable.

## Keeping it current
The kit is a curated snapshot, not a live mirror of anyone's config. Maintainers update it from
their own evolving setup via [`install/kit-sync.md`](install/kit-sync.md) - run on demand; it
re-scrubs and gates on a deny-list so nothing personal can leak in.

## License
MIT - see [LICENSE](LICENSE).
