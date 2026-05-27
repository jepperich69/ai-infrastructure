---
name: grill-edit
description: Edit phase after a /grill-paper session. Walks through the master issue list in grill_log.md one by one, proposes concrete edits to main.tex, records author decisions (approve/adjust/dismiss with reason), and updates the submission verdict. Use after running /grill-paper, when the user wants to work through the logged issues and edit the manuscript.
---

# grill-edit -- Manuscript edit phase

Works through `Overleaf_source/grill_log.md` issue by issue. Proposes concrete edits to `main.tex`. Records every decision. Updates the verdict at the end.

Do not rush. Present one issue at a time and wait for the author's decision before moving to the next.

## Setup

### Step 1 -- Locate files

Walk up from CWD to the first folder starting with `Pub_`, `Pro_`, or `PhD_`. That is the project root.

Read:
- `Overleaf_source/grill_log.md` -- the master issue list
- `main.tex` (and any `\input{}`/`\include{}` files) -- the manuscript

If `grill_log.md` does not exist or has no open issues, report: "No open issues found in grill_log.md. Either run /grill-paper first, or all issues are already resolved."

### Step 2 -- Count and report

Before starting, report:
- Total open issues: B[x] blocking, S[x] significant, M[x] minor
- Current verdict: OPEN or READY
- Estimated session: roughly one issue per 3-5 minutes depending on complexity

Ask: "Ready to start? We will work through blocking issues first, then significant, then minor."

---

## Edit loop

Work through issues in this order: **Blocking -> Significant -> Minor**

For each open issue:

### Present the issue

```
--- Issue [B/S/M][n]: <label> ---
Finding: <from log>
Location: <from log>
Recommended fix: <from log>

Proposed edit:
<show the exact text change -- quote the current text and the proposed replacement,
or describe the addition if it is a new paragraph/section>

Options: [A] Apply as proposed  [E] Edit before applying  [D] Dismiss with reason  [S] Skip for now
```

### Handle the response

**Apply (A):** Make the edit to `main.tex`. Mark issue as Done in `grill_log.md`:
```markdown
**Status:** Done -- YYYY-MM-DD
**Resolution:** Applied as proposed
```

**Edit (E):** The author proposes a different fix. Discuss, agree on the final edit, apply it. Mark as Done:
```markdown
**Status:** Done -- YYYY-MM-DD
**Resolution:** Applied with modification -- <brief note on what changed>
```

**Dismiss (D):** Ask for the reason. Record it. Mark as Dismissed:
```markdown
**Status:** Dismissed -- YYYY-MM-DD
**Author decision:** <reason verbatim>
```
Note: a dismissed blocking or significant issue is a conscious editorial decision, not an oversight. Record it precisely.

**Skip (S):** Leave status as Open. Note it was seen but deferred:
```markdown
**Status:** Open (seen YYYY-MM-DD, deferred)
```

---

## Verdict assessment

After working through all issues (or when the author wants to stop):

### Blocking issues
- If any blocking issue is Open or Skipped: verdict stays OPEN. State clearly: "The paper is not ready for submission -- [n] blocking issue(s) unresolved."
- If all blocking issues are Done or Dismissed: proceed to significant assessment.

### Significant issues
- Count resolved (Done) vs. dismissed vs. open
- Give an explicit recommendation:
  - If all resolved or dismissed with reasons: "Significant issues addressed. Paper is defensible for submission."
  - If open significant issues remain: "Paper may be submittable but [n] significant issue(s) remain open -- reviewers are likely to raise them. Recommend resolving before submission."

### Final verdict

The author makes the final declaration. The griller recommends; it does not decide.

Present:
```
Verdict assessment:
- Blocking: [x] resolved, [x] dismissed, [x] open
- Significant: [x] resolved, [x] dismissed, [x] open
- Minor: [x] resolved, [x] dismissed, [x] open

Griller recommendation: READY / NOT READY
Reason: <one sentence>

Do you want to mark this paper READY for submission?
```

If yes, update `grill_log.md`:
```markdown
**Verdict:** READY -- YYYY-MM-DD
**Author declaration:** Ready for submission
**Griller recommendation:** [READY / NOT READY]
**Open at declaration:** B[x] S[x] M[x]
```

---

## Update grill_log.md

After the session, append to the session history:

```markdown
### Edit session -- YYYY-MM-DD
**Issues resolved:** B[x] S[x] M[x]
**Issues dismissed:** B[x] S[x] M[x]
**Issues remaining open:** B[x] S[x] M[x]
**Verdict:** OPEN / READY
```

---

## Reminders

- If blocking issues remain: recommend running `/grill-paper` again after fixing them -- a fresh session may find issues the first missed.
- If verdict is READY: remind the user to push to Overleaf (`helpi 2 <project>`) and run `/snapshot` before submission.