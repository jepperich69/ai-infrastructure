---
name: feedback-intuition-paragraphs
description: "After every proof (theorem, proposition, lemma), add a short Intuition paragraph — 2-4 sentences taking the reader by the hand"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 6f7d4a88-ede1-42da-bc9f-d374f9125e4d
---

Every theorem, proposition, and lemma proof must be followed by an \paragraph{Intuition.} block (2--4 sentences). This is a general writing rule applying to all papers.

**Why:** User wants to take the reader by the hand — what is the down-to-earth message and why does it make natural sense.

**How to apply:**
- Place it immediately after \end{proof}, before any \begin{remark}
- Structure: Statement → Proof → intuition paragraph → Remark(s)
- 2--4 sentences; plain language; no new formal content
- Do NOT use \paragraph{Intuition.} as a header — the paragraph should flow naturally from the proof text
- Vary the opening phrase depending on context: "The practical message is...", "What this buys us is...", "In plain terms,...", "The geometry behind this is...", "A practical reading of Theorem X is that..." etc.
- Apply when creating new results AND when reviewing existing manuscripts
