---
name: mistral-vibe-cli-integration-plan
description: "Deferred plan to add Mistral Vibe as a third peer agent alongside Claude and Codex, using shared ~/.agents/skills/"
metadata: 
  node_type: memory
  type: project
  originSessionId: cdb7a2c1-8e64-49c0-b386-f16e8d183b00
---

Plan to integrate Mistral Vibe CLI as a third coding agent in the AI_auto infrastructure.

**Why:** Model diversity; Codestral is coding-specialized; user has Le Chat Pro subscription (no API key billing).

**Updated understanding (2026-05-15):** Mistral Vibe natively reads `AGENTS.md` and discovers skills from `~/.agents/skills/` (shared Agent Skills standard). The PS1 injection helper from the old plan is NOT needed. Effort estimate revised from 6-7h down to ~1-2h once shared skills exist.

**How to apply (revised):**
1. Install: `pip install mistral-vibe` via `C:\Users\rich\AppData\Local\miniconda3\python.exe`
2. Skills go in `~/.agents/skills/` — shared with Codex and Gemini CLI, no duplication
3. Configure `~/.vibe/config.toml` with global instructions (equivalent to GEMINI.md / CLAUDE.md)
4. Trusted folders config may be needed for `.agents/skills/` discovery
5. Update `infrastructure.html`

**Key constraint:** No headless/non-interactive mode — session-launch agent only.

**Status:** Deferred. Do AFTER shared skills migration is complete. See [[project_shared_agents_skills]].
