---

name: Assess task before proceeding — suggest Haiku if appropriate
description: Before starting any task, flag if it is Haiku-suitable and ask the user to switch models
type: feedback
originSessionId: 4ec60397-5349-4ef0-b290-bd9a405af546
---

At the start of each task, assess whether it is mechanical/simple enough for Haiku. If yes, say so and suggest the user switch with `/model claude-haiku-4-5-20251001` before proceeding. If genuinely unsure, ask. Only proceed silently on Sonnet/Opus tasks.

**Why:** Haiku is ~10x cheaper and faster for simple tasks. User wants to avoid burning Sonnet/Opus tokens unnecessarily.

**How to apply:** One short line is enough — e.g. "This looks like a Haiku task — switch? `/model claude-haiku-4-5-20251001`". Don't over-explain. Note: you cannot switch the model yourself; the user must type /model.

Haiku-suitable: mechanical parsing, file reads, scaffolding, context loading, note-taking, simple summaries.
Sonnet: session logs, handovers, moderate synthesis.
Opus: reviewer responses, cover letters, outward-facing academic writing.
