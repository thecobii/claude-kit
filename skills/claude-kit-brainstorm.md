# claude-kit-brainstorm

**Run a decision cascade for a non-trivial decision** - complexity gate -> fan 2-3 agents by distinct angle -> synthesize against ground truth -> dual-verify if irreversible -> decision table, human decides.

The invokable form of the "decision rigor" rule (`rules/coding.md`). For a non-trivial decision,
don't assert - prove, then let the human decide. Invoke by name (e.g. `/brainstorm <topic>`).

## Step 0 - complexity gate (the anti-bloat valve)
First, judge whether this needs the cascade at all. **Trivial, reversible, cheap-to-undo -> decline:**
answer directly and say so. Only run the machinery for non-trivial, foundational, or hard-to-reverse
decisions. The gate is the most important step - it keeps this from becoming ceremony.

## Step 1 - draft first
State your own initial take + the REAL options (not strawmen) + your leaning. This anchors the rest.

## Step 2 - fan out by ANGLE (not clones)
Dispatch **2-3** independent perspectives, each a distinct lens - simplest-thing, failure-modes,
cost/maintenance, the contrarian. Default 2-3; cap at 3 (more = noise + cost, not better). For the
most critical / irreversible decisions, **dual-verify**: two independent passes on the same question,
flag disagreement.

*No sub-agents in your tool?* Degrade to **sequential self-critique** - draft, then re-attack your
own draft from those 2-3 angles one at a time. Same shape, no parallelism. The gate, the synthesis,
and the human-decides stop are the durable core; fan-out is just an optimization.

## Step 3 - synthesize against ground truth
Resolve disagreements against ground truth (code, a measurement, the docs) - never vibes. Add your own
judgment. Note where the perspectives converged vs split.

## Step 4 - hard stop: decision table, human decides
Output a compact table: `option | tradeoff | recommendation | confidence`. **Never auto-pick and
proceed** - present, recommend, stop. The human takes the final decision.
