# Coding rules

**Think first.** Don't assume or hide confusion. State your assumptions. Multiple
interpretations -> present them, don't silently pick one. A simpler approach exists -> say so,
and push back when warranted. Unclear -> stop, name it, ask.

**Decision rigor (prove it, don't assert it).** For non-trivial, foundational, or
hard-to-reverse decisions: pressure-test with a side agent *before* deciding; for the most
critical, dual-verify with two separate agents and resolve any disagreement against ground
truth before acting. Prefer real measured proof (A/B, before/after numbers) over assertion when
claiming an improvement - especially for process, performance, or architecture changes. The
human takes the final decision.

**Simplicity.** The minimum code that solves it. No speculative features, abstractions, or
flexibility; no error handling for impossible cases. 200 lines that could be 50 -> rewrite.

**Surgical.** Touch only what's asked; clean up only your own mess. Don't improve or refactor
adjacent code, comments, or formatting. Match existing style even if you'd do it differently.
Unrelated dead code -> mention it, don't delete it. Remove only the imports/vars your change
made unused.

**Goal-driven.** Turn tasks into verifiable goals; give a brief plan with a verification
checkpoint per step. Don't report done until it's verified working.

**DRY & tight (non-negotiable).** Verbose or duplicated code is a defect, not a style. Reuse
beats rewrite - check the shared design system, shared contracts, and existing utils before
writing new code; repeated logic -> one named helper. Fewest lines that read clearly; if it
sprawls it's probably wrong. One clear path per action - no duplicate entry points; merge
surfaces that do the same job (duplicated UX is a duplicated-code defect).

**No magic strings/numbers (non-negotiable).** No bare meaningful literals scattered through
the code. Hoist every key, route, config value, and repeated or significant string-or-number to
a named `const` in a clear place: top of the file, or a shared constants module if used
cross-file. A reader should find all the tunable/meaningful values in one obvious spot, not hunt
them inline. Exception: a truly single-use, self-evident value local to one function may stay
inline - don't over-abstract a genuine one-off. Named constant beats magic literal, always.

**Self-documenting code (comments default none).** Name functions and variables so clearly the
code reads without comments - consistent, intention-revealing names. A comment that restates
*what* the code does is a defect: delete it and fix the name instead. Keep only a one-line *why*
for genuinely non-obvious intent. The bar is near-zero comments.

**Minimal surface (non-negotiable).** UI and code both say the minimum. No explanatory, helper,
or instructional UI copy where the meaning is already obvious (no "pick one" hints, verbose
descriptions, over-worded empty states, narrated placeholders). Trim every label, placeholder,
and blurb to the fewest words - or none.

**Visual proof (non-negotiable).** A UI/CSS/layout change isn't done until a screenshot plus a
measurement of the key dimension confirm the outcome at the real width. Lint, type-check, and
build are non-visual - they pass on CSS that renders at 477px when it should be 1480. Frame UI
work as outcomes with acceptance criteria ("fills the width; measure >=1376px at a 1440 viewport"),
never "change this value". Measure the rendered dimension with the DOM - don't eyeball it - then
screenshot. Never relay an agent's "done, build green" as proof for a visual change. (See
`patterns/agent-tooling-standards.md` for the measure-vs-screenshot protocol.)

**Consistency is global (non-negotiable).** The same thing looks and works the same everywhere.
Generic UI - inputs, labels, buttons, section titles, overlays, cards - lives only in the shared
design system, never re-styled per project unless it's genuinely niche to one app.
- Section titles: one treatment, above the block (never inside the card), identical
  font/case/spacing everywhere.
- Buttons: restrained by default; reserve the solid/primary fill for the one main action per
  view.
- Overlays and modals never exceed the viewport - cap them to the window, scroll internally with
  a clean scrollbar.
- The same UI solved differently across apps is a defect -> globalize it into the design system.

**Polished by default.** Ship-to-paying-customer quality, never cheap or MVP-looking. Every
interactive feature gets loading / empty / error / success states plus keyboard access. Use the
design system, no native `prompt`/`confirm`/`alert`, prefer data-driven pickers over free text.
Reach for the polished option unasked.

**Dates & times (display).** Everywhere user-facing: date `dd.mm.yyyy`, time 24h `HH:mm`
(combined `dd.mm.yyyy HH:mm`); never ISO, US, or locale formats in displayed output. One
reusable formatter/component in the shared design system, never hand-rolled per app. Store
timestamps as ISO-8601 internally; format only at display.

**Capture every standing rule (don't let it live only in chat).** When the human states a
standing preference or correction ("always", "from now on", "make a rule", "I prefer",
"avoid X"), persist it to the right doc *that turn*, not just for the current chat. A rule that
exists only in conversation is lost next session - that's a defect. Say where it landed.

**Rule placement (keep configs lean) + confirm scope if unclear.** A new standing rule goes in
the narrowest-scope file that covers it (project/repo doc > a rules slice > global). Keep the
global agent config lean - only truly universal, high-value rules go there; never bloat it with
project- or one-off-specific notes. If it's unclear whether a rule is global (all projects) or
scoped (this project only), ask before placing it - don't silently guess the scope.
