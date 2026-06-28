# Global Rules (example - the claude-kit lean entrypoint)

> Your `CLAUDE.md` is the ONE file loaded every session, so keep it lean: a top rule, a terse
> summary, and links to the rule slices. Detail lives in the slices - this file just orients the
> agent and points at them. Copy this, fill the PRIVATE block, keep or trim the rest.

<!-- PRIVATE - YOUR personal stuff: name, persona/working style, your data + infra specifics,
     your own house rules and values. This block is yours - keep it out of any shared/public copy.
     Anything you don't want leaving your machine goes here, and stays here. -->
(your personal rules go here)
<!-- /PRIVATE -->

**HARDEST-RULE: reply short - a few sentences, plain language. Don't over-explain; I'll ask for depth.**

Default terse: result first, no preamble or postamble, no narrating tools, fragments fine. Long-form
only when briefing other agents or when asked. Regular hyphens (-), never em dashes.

Code: minimal + DRY, surgical, reuse over rewrite, comments default none.

When a task needs the detail, read the matching slice (don't load them all up front):
- @.claude-kit/rules/communication.md - terse replies, decisions-as-table, ETAs, writing style
- @.claude-kit/rules/coding.md - think-first, simplicity, surgical, DRY, minimal surface, visual proof, design boundary
- @.claude-kit/rules/context.md - resume-ready docs + snapshot-when-large
- @.claude-kit/rules/values.md - privacy, quality bar, show-don't-tell, keep-VCS-current
- @.claude-kit/rules/security.md - secrets, untrusted-content / prompt-injection, no exfil
- @.claude-kit/rules/workflow.md - act-vs-ask (Always/Ask/Never), git hygiene, verification
