---
name: gemini-cli-integration
description: Gemini CLI installed and configured as a peer agent; skills migration to ~/.agents/skills/ is the next step
metadata: 
  node_type: memory
  type: project
  originSessionId: cdb7a2c1-8e64-49c0-b386-f16e8d183b00
---

Gemini CLI installed and configured as of 2026-05-15.

**Installation:** `npm install -g @google/gemini-cli` — v0.42.0, Node.js v24 in PATH.

**Auth:** `oauth-personal` (Google AI Pro account — data not used for training).

**Config files:**
- `~/.gemini/settings.json` — auth + `context.fileName: "AGENTS.md"` (Gemini reads AGENTS.md from every project automatically)
- `~/.gemini/AGENTS.md` — global research instructions (who user is, platform facts, session rules, helpi commands)

**Key design decision:** `context.fileName: "AGENTS.md"` means every project's auto-generated `AGENTS.md` (from `helpi 7`) is read by Gemini automatically at session start. No per-project setup needed.

**Next step:** Migrate Codex skills to `~/.agents/skills/` (shared directory), verify Gemini picks them up, then add research-work/close/snapshot/family skills. See [[project_shared_agents_skills]].

**Remaining warnings (cosmetic):**
- Ripgrep: installed via winget 2026-05-15, needs terminal restart to register in PATH
- 256-color: terminal limitation, non-critical
