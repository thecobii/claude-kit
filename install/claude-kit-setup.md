# claude-kit-setup

**Merge the kit INTO a target project** - inventory the project's existing rules, classify each kit item (adopt / keep-theirs / merge / conflict / skip / defer / bloat), show an approval-gated table, then apply only what's approved inside managed blocks, SHA-pinned for clean updates.

Run this skill when claude-kit has been dropped into a **target project that already has its own**
`CLAUDE.md` / `AGENTS.md` / rules / skills. It safely merges the kit's rules and patterns into the
target without overwriting the project's own conventions, on an approval gate, by a deterministic
method.

> Not needed on your own machine. If you own the target and it has no competing rules, just symlink
> or submodule the kit (see the repo README "Install" section). This skill is for **foreign or work
> repos** where the target has existing rules you must respect.

The skill has four phases. Do them in order. **Never apply anything before the human approves the
merge table (phase 3).**

---

## Phase 1 - INVENTORY the target

Find what the target already has. Do not assume; read.

- Locate existing agent config: `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, any `rules/` or `docs/`
  rule files, any skills dir.
- For each, note: what topics it covers (communication, coding, values, context, workspace map,
  tooling), and capture the exact rule lines so you can compare against the kit.
- Identify the project's package manager / stack and where its docs conventionally live (so kit
  patterns land in the right place).
- Record the target's VCS state: current commit, whether it's clean.

Output of this phase: a short list "target already covers: X, Y; target lacks: Z".

## Phase 2 - CLASSIFY each kit item vs the target

Go through every kit item (each `rules/*.md`, each `patterns/*.md`) and assign exactly one class:

| Class | When | Action |
|-------|------|--------|
| **ADOPT** | Target has no equivalent rule/pattern | Add the kit item (in a managed block) |
| **KEEP-THEIRS** | Target already covers it well; kit adds nothing | Do nothing; note it |
| **MERGE** | Both cover it, but each has something the other lacks | Union: keep the target's project-specific context, add the kit's missing structure - inside a managed block adjacent to theirs, never rewriting their lines |
| **CONFLICT** | The kit rule *contradicts* a target rule (e.g. kit says terse, target mandates verbose templated replies) | **Do not auto-resolve.** Flag it loud; a human decides. List the exact opposing lines side by side |
| **SKIP** | Item is irrelevant to this project (e.g. visual-proof rules in a headless library) | Omit; note why |
| **DEFER** | Plausibly useful but needs a decision/setup later (e.g. workspace map needs the generator wired into CI) | Stage it but don't apply; leave a TODO with the steps |
| **BLOAT** | A *target* rule looks redundant/superseded | **Report only.** In a work repo, NEVER auto-remove a target rule. Surface it as a suggestion for the human |

Rules for classifying:
- **Work skills default to MERGE,** not ADOPT-over-theirs. Assume the target's rules are
  intentional; add, don't replace.
- When unsure between MERGE and CONFLICT, choose CONFLICT - surfacing a false conflict costs a
  glance; a silent contradiction poisons the agent's behavior.
- BLOAT is advisory only in any repo you don't own.

## Phase 3 - present the approval-gated MERGE TABLE

Show the human one compact table, then stop and wait.

```
| Kit item                    | Class       | Action                                            |
|-----------------------------|-------------|---------------------------------------------------|
| rules/communication.md      | MERGE       | add decisions-as-table + ETA rule to their comms  |
| rules/coding.md             | ADOPT       | new: no project coding rules found                |
| rules/values.md             | CONFLICT    | kit "subscription-only" vs their "use API key X"  |
| rules/context.md            | ADOPT       | new                                               |
| patterns/workspace-map...   | DEFER       | needs gen-map wired to CI - TODO left             |
| patterns/agent-tooling...   | KEEP-THEIRS | they already document AXI-style API rules         |
```

State plainly: "Approve to apply ADOPT + MERGE rows. CONFLICT rows need your call. DEFER leaves a
TODO. Nothing is written until you say go." Do not proceed without an explicit approval.

## Phase 4 - APPLY (deterministic, on approval only)

Apply by a **mechanical method, not an LLM hand-merge.** The agent must not rewrite the human's
prose in its own words.

### Managed blocks
All kit-managed content goes inside delimited blocks. The human's own lines stay outside, untouched.

```
# >>> claude-kit managed (rules/coding.md @ <SHA>) - do not edit inside; re-run SETUP to update >>>
...kit content verbatim...
# <<< claude-kit managed <<<
```

- ADOPT: write a fresh managed block (a new file, or appended to the matching target file).
- MERGE: write the managed block *adjacent* to the target's own section - target lines above, kit
  block below. Never interleave or reword their lines.
- Re-running SETUP replaces only the content **between** the markers; everything outside is left
  byte-for-byte. This is what makes updates safe and repeatable.

### The lock file
Write `.claude-kit.lock` at the target root recording, for a future 3-way update:
- the kit commit **SHA** these blocks came from (pin by SHA, never "latest" / a branch);
- per applied file: the path, and the **pristine kit base** (the exact kit content written, or its
  hash) so a later update can do a real 3-way merge (old-kit vs new-kit vs current-target) and only
  touch what changed.

```json
{
  "kit_sha": "<commit-sha>",
  "applied": [
    { "file": "CLAUDE.md", "item": "rules/coding.md", "base_hash": "<sha256 of written block>" },
    { "file": "rules/context.md", "item": "rules/context.md", "base_hash": "<sha256>" }
  ],
  "deferred": ["patterns/workspace-map-playbook.md"],
  "conflicts": ["rules/values.md"]
}
```

### Updating later
On a new kit version: read `.claude-kit.lock`. The **merge base is the locked `kit_sha` re-fetched
from the kit repo** - not `base_hash` (that hash is only an integrity/tamper check on the block as
written). For each applied file, do a 3-way merge that operates **strictly on the managed-block
bytes** (locked-kit-block -> new-kit-block, against the current managed block) - never on the
human's surrounding lines. If the human edited *inside* a managed block (they shouldn't), the 3-way
surfaces it as a conflict to resolve, never silently clobbered. **If the locked `kit_sha` is
unreachable** (repo moved/forked/offline), don't guess - treat the file as a CONFLICT, show the
current block, and ask. Re-pin the lock to the new SHA after applying.

### After applying
- Report what changed: files written, blocks added, the SHA pinned.
- Restate any CONFLICT rows still awaiting a human decision and any DEFER TODOs left.
- Commit only if the human authorized it; in a work repo, prefer leaving the change staged for
  their review.

---

## Invariants (hold these regardless of phase)

- Never overwrite or reword a target's own lines. Kit content lives only inside managed blocks.
- Pin to a SHA, never a moving ref.
- Approval gate is mandatory - no writes before phase-3 sign-off.
- In a repo you don't own: MERGE by default, never auto-remove a target rule (BLOAT is report-only),
  and surface conflicts loudly rather than resolving them.
