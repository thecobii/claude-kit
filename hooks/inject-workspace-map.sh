#!/usr/bin/env bash
# SessionStart hook - inject the workspace map(s) into the agent's context.
# Walks from the project root down to cwd, collecting every AGENTS.md (higher
# levels first, nearest last - the "nearest wins" cascade). Prints them to stdout;
# Claude Code injects a SessionStart hook's stdout as session context.
# No-op (prints nothing) when no AGENTS.md exists. Zero dependencies: bash + git.
set -uo pipefail

input="$(cat 2>/dev/null || true)"
cwd="$(printf '%s' "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
[ -z "${cwd:-}" ] && cwd="$PWD"
# Normalize Windows paths: JSON-escaped "C:\\foo" -> "C:\foo" -> "C:/foo".
cwd="${cwd//\\\\/\\}"
cwd="${cwd//\\//}"
cd "$cwd" 2>/dev/null || exit 0

root="$(git rev-parse --show-toplevel 2>/dev/null || echo "$cwd")"

chain=()
d="$cwd"
while :; do
  [ -f "$d/AGENTS.md" ] && chain=("$d/AGENTS.md" "${chain[@]}")
  [ "$d" = "$root" ] && break
  p="$(dirname "$d")"
  [ "$p" = "$d" ] && break
  d="$p"
done

[ ${#chain[@]} -eq 0 ] && exit 0

for f in "${chain[@]}"; do
  cat "$f"
  echo
done

cat <<'PROTOCOL'
---
## Search protocol (use the workspace map above FIRST)
- Find files via this map; don't grep-storm to rediscover layout.
- Structural code queries (a function / definition / call site / usage) -> ast-grep (`sg`), not regex.
- Plain text / string hunts -> ripgrep (`rg`).
PROTOCOL
