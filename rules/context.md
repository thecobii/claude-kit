# Context management

**Always resume-ready (standing rule).** Keep all docs current *as* you work - agent config
files, state/roadmap notes, specs, fact cards - not just at close-out. At any moment the project
must be ready for a fresh session to resume cold from the docs with nothing lost. Update docs in
the same breath as the change; never let them lag the code.

**Snapshot when a chat grows large.** Trigger on any of: a noticeably long tool output, 10+
back-and-forths on one task, the human says context feels slow or large, or you find yourself
re-reading earlier messages to recall decisions.
1. Write a snapshot file (e.g. `~/.claude/context/YYYY-MM-DD_HH-MM_<topic>.md`) capturing: goal -
   decisions and why - status (done / in-progress / pending) - key paths and snippets - open
   questions - an exact resume prompt.
2. Tell the human: context is large, saved to `<file>`; clear the session, then resume from that
   file.
3. On resume: read the snapshot first, then continue as if nothing was lost.
