---
name: feedback-close-autonomous
description: /close skill runs autonomously — all log/state/CLAUDE.md file writes are pre-approved in global settings.json
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9b78c1f0-9c60-4a2d-b258-0230cf1781cc
---

`/close` should execute all its steps without asking for permission on each file edit. The user always trusts these writes.

**Why:** User was repeatedly approving the same low-risk edits (log entries, state card, CLAUDE.md updates) every session — unnecessary friction for a trusted, mechanical operation.

**How to apply:** Do not pause or ask for confirmation during /close. All relevant patterns are pre-allowed in `~/.claude/settings.json`. Root cause of previous failures: allowlist had Bash variants (`Bash(git *)`, `Bash(helpi*)`) but /close uses the PowerShell tool — PowerShell equivalents were missing. Also missing: memory file writes.

Current coverage (as of 2026-05-27):
- `_ai_log.md`, `_state/current.md`, `.claude/CLAUDE.md`, `known_issues.md` — Edit + Write (OneDrive wildcard + global)
- `~/.claude/projects/**/*.md` — Edit + Write (memory files)
- `PowerShell(git *)`, `PowerShell(helpi *)`, `PowerShell(helpi.ps1*)` — for close-skill PowerShell tool calls
- `PowerShell(Remove-Item*)`, `PowerShell(Get-ChildItem*)`, `PowerShell(Test-Path*)`, `PowerShell(New-Item*)` — utility ops
- `Bash(pwsh*)`, `Bash(helpi*)`, `Bash(git *)` — Bash tool variants
