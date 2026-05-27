---
name: shared-agents-skills-migration
description: "Plan to migrate skills to shared directory so Codex, Gemini CLI, and Mistral Vibe all share one set of research skills"
metadata: 
  node_type: memory
  type: project
  originSessionId: cdb7a2c1-8e64-49c0-b386-f16e8d183b00
---

All three CLI agents (Codex, Gemini CLI, Mistral Vibe) support the open Agent Skills standard and discover skills from `~/.agents/skills/`. Writing skills once in this shared directory means all agents pick them up automatically.

**Why:** Current Codex skills live in `~/.codex/skills/`. Moving them to `~/.agents/skills/` eliminates duplication when adding Gemini and Vibe.

**Skills to migrate (from ~/.codex/skills/):**
- `research-work` — open project session (/work equivalent)
- `research-close` — close session (/close equivalent)
- `research-snapshot` — snapshot manuscript (/snapshot equivalent)
- `research-family` — link feeder project (/family equivalent)

**Skill format differences:**
- Codex requires `agents/openai.yaml` metadata file alongside `SKILL.md`
- Gemini CLI: only `SKILL.md` required
- Mistral Vibe: only `SKILL.md` required (follows same open standard)
- Solution: keep `agents/openai.yaml` in each skill folder — Gemini and Vibe ignore it, Codex uses it

**Estimated effort:** ~2-3h total for all three agents (not 6-7h per agent as originally estimated).

**Status:** Not started. Gemini CLI is installed and ready. Do this as one piece of work.
