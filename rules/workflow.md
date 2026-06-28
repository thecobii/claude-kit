# Workflow - autonomy boundaries & git hygiene

## When to act vs ask (Always / Ask-first / Never)
- **Always (safe unprompted):** read and search the codebase, run tests/builds/linters, make the
  scoped edits the task plainly implies, draft proposals. Bias to action on reversible, in-scope work.
- **Ask first (get a yes before doing):** anything destructive or hard to reverse (delete data,
  rewrite history, force-push); schema/data migrations; adding or upgrading a dependency; deploys
  and releases; anything that spends money or touches the outside world; mass or cross-cutting
  edits; changing shared/protected files or another team's conventions.
- **Never:** commit secrets; force-push a shared branch; bypass hooks (`--no-verify`); weaken,
  skip, or delete a test just to go green; touch code you weren't asked to. (See `security.md`.)

When unsure which tier an action is in, treat it as Ask-first.

## Git & commit hygiene
- Work on a branch off the default branch for anything non-trivial; don't develop straight on a
  shared/protected branch.
- Small, atomic commits - one logical change each. Don't mix unrelated changes in one commit.
- Clear messages: imperative subject, the *why* in the body when it isn't obvious.
- Run the project's verification (tests/lint/build) before you commit; never commit known-broken work.
- Don't commit generated artifacts, dependencies, local config, or secrets - keep them in `.gitignore`.
- Don't push to a shared branch without sign-off; follow the repo's review norms. (See `values.md`.)

## Verification discipline
- Run existing tests before claiming done; a change isn't done because it compiles.
- Fix the code to pass the test - never the test to pass the code. Add a test for a bug you fix.
- Report honestly: if tests fail or a step was skipped, say so with the output - a skip is not a pass.
