---
name: feedback-close-autonomous
description: /close skill runs autonomously — all log/state/CLAUDE.md file writes are pre-approved in global settings.json
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9b78c1f0-9c60-4a2d-b258-0230cf1781cc
---

`/close` must execute all steps directly in the main Sonnet context — **never via a subagent**. The user always trusts these writes.

**Why:** Subagents spawned via the `Agent` tool have an independent permission model and do NOT inherit the parent's `settings.json` allowlist. Every write inside a subagent triggers a fresh permission prompt, regardless of what's pre-approved globally. This caused 3-4 manual approvals every session even with correct allowlist entries.

**How to apply:** The `/close` command (at `~/.claude/commands/close.md`) was rewritten 2026-05-29 to remove the Haiku subagent entirely. All steps A–H now run in the main context, which respects the allowlist. If you ever see close steps being delegated to a subagent, that is a regression — do not spawn one.

The `settings.json` allowlist covers all close operations for main-context execution:
- `_ai_log.md`, `_state/current.md`, `.claude/CLAUDE.md`, `known_issues.md` — Edit + Write (OneDrive wildcard + global)
- `~/.claude/projects/**/*.md` — Edit + Write (memory files)
- `PowerShell(git *)`, `PowerShell(helpi *)`, `PowerShell(helpi.ps1*)`, `PowerShell(pwsh*)` — shell ops
- `PowerShell(Remove-Item*)`, `PowerShell(New-Item*)`, etc. — utility ops
