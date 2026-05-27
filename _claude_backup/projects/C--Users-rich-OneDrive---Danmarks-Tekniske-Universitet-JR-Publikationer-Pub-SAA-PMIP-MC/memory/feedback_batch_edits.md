---
name: feedback-batch-edits
description: "User prefers to batch agreed text edits and apply them all at once at session end, rather than writing to file after each discussion"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9f6f378e-296d-4d1f-89e2-909bae6a626b
---

Do not write edits to file immediately after each discussion. Keep a running log of agreed changes in the conversation and apply them all in one batch when the user says to.

**Why:** Avoids constant file writes and pushes mid-discussion; keeps the flow on the content, not the tooling.

**How to apply:** During editing sessions, maintain a numbered pending-edits list in the chat. Only write to file when the user signals they are done or ready to batch-apply.
