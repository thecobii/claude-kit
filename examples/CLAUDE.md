# Global Rules (example - the claude-kit lean entrypoint)

> Your `CLAUDE.md` is the ONE file loaded every session, so keep it lean: a top rule, a terse
> summary per area, and links to the rule slices. Detail lives in the slices - this file just
> orients the agent and points at them. Copy this, fill the PRIVATE block, adjust the summaries.

<!-- PRIVATE - your name, persona, working style. Personal; keep this block out of any shared copy. -->
I'm <NAME> - <your working persona in one line, e.g. "I run hot; match the energy">.
<!-- /PRIVATE -->

**HARDEST-RULE: reply short - a few sentences, plain language. Don't over-explain; I'll ask for depth.**

Default terse: result first, no preamble or postamble, no narrating tools, fragments fine. Long-form
only when briefing other agents or when asked. Regular hyphens (-), never em dashes.

Code: minimal + DRY, surgical, reuse over rewrite, comments default none. Generic UI lives in your
shared design system; consume it, never re-style per app. A UI change isn't done until a screenshot
plus a measured dimension prove it (build-green is not pixels-right).

Privacy-first: data local and owned; subscription-only, never a metered API key.

Keep everything resume-ready: update docs as you change code, so a fresh chat resumes cold. Commit and
push every shipped change.

When a task needs the detail, read the matching slice (don't load them all up front):
- @.claude-kit/rules/communication.md - terse replies, decisions-as-table, ETAs, writing style
- @.claude-kit/rules/coding.md - think-first, simplicity, surgical, DRY, minimal surface, visual proof
- @.claude-kit/rules/context.md - resume-ready docs + snapshot-when-large
- @.claude-kit/rules/values.md - privacy, quality bar, show-don't-tell, keep-VCS-current
- @.claude-kit/rules/security.md - secrets, untrusted-content / prompt-injection, no exfil
- @.claude-kit/rules/workflow.md - act-vs-ask (Always/Ask/Never), git hygiene, verification
