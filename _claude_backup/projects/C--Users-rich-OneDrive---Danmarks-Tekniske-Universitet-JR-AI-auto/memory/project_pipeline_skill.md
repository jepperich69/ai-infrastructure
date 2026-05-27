---
name: project-pipeline-skill
description: "/pipeline skill — multi-agent background job (Claude -> Gemini -> Codex -> Claude), configurable agent order, async with toast + file open on completion"
metadata: 
  node_type: memory
  type: project
  originSessionId: 33d5eeb4-55da-45e2-b7cf-603cc0240fbe
---

/pipeline skill built 2026-05-21. Lives at `~/.claude/skills/pipeline/SKILL.md`.

**What it does:** Runs any task through a configurable sequence of AI agents as a detached background process. Each agent receives the full task plus all prior agents' output. Final agent synthesises.

**Default order:** `claude -> gemini -> codex -> claude`

**Usage:**
```
/pipeline "task description"
/pipeline "task" --agents gemini,claude,codex,claude
/pipeline "task" --out "C:\path\to\output"
```

**Output:** Timestamped folder in `AI_auto\_pipelines\YYYY-MM-DD_HH-MM-SS\` containing:
- `prompt_rN.txt` (what each agent was sent)
- `roundN_agentname.md` (each agent's output)
- `final.md` (last agent's synthesis, opens automatically when done)
- `pipeline_log.md` (task, agents, duration)

**On completion:** `final.md` opens in default app + Windows toast notification (best-effort).

**Why:** User wants to leave a well-defined task running across multiple AI families (Claude/Gemini/Codex) for diverse, independent perspectives, then return to a finished synthesis.

**Known limitation:** accumulated context for later rounds can be large for very long tasks; no automatic truncation.
