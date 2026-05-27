---
name: close_procedure
description: Exact steps to close a session and regenerate the handover — do NOT re-discover these
type: feedback
originSessionId: 8e5eef93-a4b9-4065-95ea-f7b00aa7ecd5
---
At /close, execute exactly two steps in order — no exploration, no reading helpi:

**Step 1:** Append session block to `_ai_log.md` in the project root (Write tool, append at end of file).

**Step 2:** Run the handover generator directly:
```
powershell -NoProfile -File "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\generate_handover.ps1" -Project <ProjectName>
```
where `<ProjectName>` is the folder name (e.g. `Pub_SAA_PMIP_MC`), NOT a full path.

That's it. Do NOT call helpi, do NOT read helpi.ps1, do NOT read helpi.cmd, do NOT make exploratory attempts.

**Why:** The session context is largest at close time, so every extra tool call is maximally expensive. helpi requires interactive input and fails non-interactively anyway.

**User shortcut:** The user can run the handover themselves at any time with:
```
! powershell -NoProfile -File "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\generate_handover.ps1" -Project Pub_SAA_PMIP_MC
```
typed directly in the chat prompt (the `!` prefix runs it in-session).
