# Boot-brief - one read-first digest of the team's standing docs

A pattern for a team (or solo) with **many standing docs** - rules, conventions, architecture
notes, an auth doc, a deploy doc, a roadmap. An agent that should "know all of it" can't afford to
read all of it every cold session: it's slow, it's expensive, and most of each doc is irrelevant
to the task at hand. The boot-brief solves this: **one short digest the agent reads first**,
distilled from the standing docs, kept honest by a staleness check.

This is the document-level cousin of the workspace map (`workspace-map-playbook.md`): the map
routes "where do things live"; the boot-brief carries "what are the rules and key facts" in
condensed form.

---

## 1. The problem

Standing docs are the source of truth, and they should be detailed. But detail is exactly what an
agent doesn't want up front - it wants the *load-bearing 10%*: the non-negotiables, the
ownership/convention facts, the one-liner per area plus a pointer to the full doc for when the task
actually needs it.

Reading every doc on boot is the over-read failure (slow, costly, dilutes attention). Reading
*none* and grepping on demand is the under-read failure (re-discovery every session, missed
rules). The boot-brief is the middle: read one curated digest, then deep-read only the specific
doc a task requires.

Don't confuse this with "let the LLM summarize all the docs into a context file." That's the
auto-generated bloat that measurably hurts. The boot-brief is **curated** (or mechanically
assembled from short, doc-authored summaries), not free-form LLM prose.

---

## 2. The design

One file, e.g. `BOOT.md` at the workspace root. Structure:

```markdown
# Boot brief
Read this FIRST. The 10% you need every session; each line points to the full doc for depth.

## Non-negotiables
- <rule one-liner> -> rules/coding.md
- <rule one-liner> -> rules/communication.md

## Ownership & conventions
- Auth owned by <X>; relying parties <Y>. Full: <doc>.
- Shared UI in <Z>; consume, never restyle. Full: <doc>.

## Pointers (read on demand, not now)
- Deploy: <doc>   - Roadmap/state: <doc>   - Per-repo layout: AGENTS.md

<!-- sources: rules/*.md, docs/auth.md, docs/deploy.md  |  generated: 2025-01-01 -->
```

Keep it to **one screen**. If it grows past ~1.5k tokens, it's no longer a brief - push detail
back into the source docs and shorten the lines.

---

## 3. Keep it honest (the `--check`)

A brief that silently drifts from its sources is worse than none. Two viable approaches, pick one:

- **Source-hash check (mechanical).** The brief footer records a hash (or mtime) of each source
  doc it was distilled from. A `--check` mode recomputes the hashes; if any source changed since
  the brief was built, it exits non-zero with "boot-brief stale: docs/deploy.md changed - re-distill".
  Wire it into pre-commit / CI exactly like the workspace map's check. This doesn't prove the
  *content* is still accurate, but it guarantees you're forced to re-review the brief whenever a
  source moves - which is where drift creeps in.
- **Doc-authored summaries (assemble, don't summarize).** Each source doc owns a short fenced
  "summary" block (3-5 lines). The brief is *assembled* by concatenating those blocks - so the
  brief can't say anything a doc author didn't write, and a `--check` just verifies the assembled
  output matches the committed brief (same diff-on-drift trick as the workspace map). This is the
  more robust option for a team.

Either way: the brief is regenerated/re-reviewed mechanically, never left to rot, and never
free-form LLM-written.

---

## 4. Make the agent consume it

One line in the standing instructions / boot routine:
> "Start every session by reading `BOOT.md` - the load-bearing rules and facts. Deep-read a full
> doc only when the task needs that area; don't read all docs up front."

Pair it with the workspace map: `BOOT.md` for rules/facts, `AGENTS.md` for repo routing. Two short
read-first files cover "what are the rules" and "where does everything live" - the bulk of cold-start
re-discovery - without reading the whole doc tree.

---

## 5. What NOT to do

- **Don't** let an LLM free-write the brief from the full docs - that's the bloat that reduces task
  success and inflates cost. Curate it, or assemble it from doc-authored summaries.
- **Don't** skip the staleness check - an unmaintained digest poisons context with confidently
  stale rules.
- **Don't** duplicate the full doc into the brief - it's a pointer-rich digest, not a copy. Each
  line earns its place or points elsewhere.
- **Don't** grow it past one screen - if it needs more, the detail belongs back in the source docs.
