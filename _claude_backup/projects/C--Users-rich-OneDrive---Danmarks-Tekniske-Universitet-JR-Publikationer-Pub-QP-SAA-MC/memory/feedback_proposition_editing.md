---
name: feedback_proposition_editing
description: How to handle proposition restructuring requests in this paper — avoid the failure modes from the 2026-05-16 session
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b95bd97b-fb8e-4757-939e-f3f671cae1d2
---

When the user says "the Boltzmann stuff is still in Proposition 1 — remove it," they mean: **rewrite the proposition statement itself**, not just simplify the proof. The distinction is: proposition body vs. proof body. These are separate things. Changing one does not change the other.

**Why:** In the 2026-05-16 session (continued into the next session), the assistant repeatedly simplified the proof while leaving the Boltzmann definitions in the proposition statement itself. The user had to repeat the instruction multiple times, each time getting more frustrated. Tokens and turns were wasted because the assistant never stopped to confirm whether it understood the structural intent.

**How to apply:**
- When asked to "remove X from Proposition N," read the proposition statement (not just the proof) and confirm which of the two needs changing before editing.
- If the request is "move this to the appendix," the correct sequence is: (1) rewrite main-text proposition to be lean, (2) add the full version to the appendix, (3) add a remark in the main text pointing to the appendix. Do all three in one pass.
- For file versioning: QP_SP_v1.tex = frozen anchor, QP_SP_v2.tex = working copy. Never edit v1 after the snapshot is declared. Edits from Overleaf go in the working file.
- Always read the exact section you are about to edit before calling Edit. "File has not been read" errors waste turns.
- When a user says "don't change anything, do you get my point?" — they are asking for confirmation of understanding, not action. Reply with a clear restatement of the intent, then wait.
