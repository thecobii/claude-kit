# SessionStart hook - inject the workspace map(s) into the agent's context (Windows).
# Walks from the project root down to cwd, collecting every AGENTS.md (higher levels
# first, nearest last). Prints them to stdout; Claude Code injects a SessionStart
# hook's stdout as session context. No-op when no AGENTS.md exists. Deps: git only.
$ErrorActionPreference = 'SilentlyContinue'

$input_raw = [Console]::In.ReadToEnd()
$cwd = if ($input_raw -match '"cwd"\s*:\s*"([^"]*)"') { $matches[1] -replace '\\\\', '\' } else { (Get-Location).Path }
if (-not (Test-Path $cwd)) { exit 0 }
Set-Location $cwd

$norm = { param($p) (Resolve-Path $p).Path.TrimEnd('\','/') }
$root = (git -C $cwd rev-parse --show-toplevel 2>$null)
$root = if ($root) { (& $norm $root) } else { (& $norm $cwd) }

$chain = @()
$d = (& $norm $cwd)
while ($true) {
  $f = Join-Path $d 'AGENTS.md'
  if (Test-Path $f) { $chain = @($f) + $chain }
  if ($d -eq $root) { break }
  $p = Split-Path $d -Parent
  if (-not $p -or $p -eq $d) { break }
  $d = $p
}

if ($chain.Count -eq 0) { exit 0 }

foreach ($f in $chain) { Get-Content $f -Raw; "" }

@'
---
## Search protocol (use the workspace map above FIRST)
- Find files via this map; don't grep-storm to rediscover layout.
- Structural code queries (a function / definition / call site / usage) -> ast-grep (sg), not regex.
- Plain text / string hunts -> ripgrep (rg).
'@
