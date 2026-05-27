---
name: project_forum_readonly
description: Convergence Forum (helpi 25) is read-only — agents must not edit manuscript or code files
metadata: 
  node_type: memory
  type: project
  originSessionId: 1ebbdedb-0992-4790-a0c1-47f8f23e7326
---

Forum agents run in read-only mode and produce text suggestions only. The researcher applies changes manually.

**Why:** Gemini with `--approval-mode yolo` edited the manuscript directly during a forum session. This is unacceptable — forum output must be advisory, not applied.

**How to apply:** When discussing or extending helpi 25 / run_forum.ps1, always preserve the read-only protections:
1. Claude invoked with `--permission-mode plan` (not `--dangerously-skip-permissions`)
2. Gemini invoked with `--approval-mode plan` (not `yolo`)
3. Every agent prompt and moderator prompt includes `$ForumReadOnlyConstraint` block
4. Exception: the `AutoClose` section at the end legitimately writes `_ai_log.md` — keep its permissions as-is.

Fixed in commit after 2026-05-27 session.
