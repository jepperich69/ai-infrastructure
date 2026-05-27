---
name: grill-paper
description: Pre-submission quality pass for a research paper. AI reads the manuscript, then grills the author relentlessly across contribution, rigor, and weaknesses. Logs all issues to grill_log.md. No edits during session -- use /grill-edit afterwards. Use when the user wants a pre-submission stress-test, says "grill the paper", or wants to pressure-test a manuscript before sending it out.
---

# grill-paper -- Pre-submission manuscript stress-test

Runs autonomously through three blocks, then grills the author. Do not pause for approval between blocks. Flag blocking issues immediately when found.

## Setup

### Step 1 -- Locate the manuscript

Walk up from CWD to the first folder starting with `Pub_`, `Pro_`, or `PhD_`. That is the project root.

Find the primary `.tex` file in `Overleaf_source/`:
1. Use `main.tex` if it exists.
2. Otherwise list all `.tex` files and ask the user which is the primary manuscript.

Read the full manuscript including any `\input{}` or `\include{}` files.

### Step 2 -- Load existing log

Check for `Overleaf_source/grill_log.md`. If it exists:
- Read the master issue list
- Note which issues are already open -- carry these into your grilling frame
- Note which issues were raised in previous sessions -- if you find the same issue independently, flag it as a **strong signal** when logging

If no log exists, create `Overleaf_source/grill_log.md` with this header:

```markdown
# Grill log -- <paper title>
**Project:** <project folder name>
**Verdict:** OPEN

---

## Master issue list

*(No issues yet)*

---

## Session history

```

---

## Grilling protocol

Ask one question at a time. For each question, provide your recommended answer before the author responds -- this forces them to react to a position rather than answer in a vacuum.

If a question can be answered by re-reading the manuscript, do that instead of asking.

When you find a **blocking issue** (see definitions below), stop and flag it clearly before continuing:

> **BLOCKING ISSUE FOUND -- B[n]: <label>**
> <finding>
> Logging this now. We should address it before continuing, or note it and proceed -- your call.

---

## Grading

After the author responds to each question, give two grades (0-10) with a brief comment each, before moving to the next question.

```
Paper:  [0-10] -- <one sentence: what the manuscript does well or where it falls short>
Author: [0-10] -- <one sentence: how clearly the author understands and articulates this>
```

### Scale anchors

| Score | Meaning |
|---|---|
| 0-2 | Absent or fundamentally wrong -- not addressed at all, or the answer directly contradicts the evidence |
| 3-4 | Seriously insufficient -- present but so thin or flawed that reviewers will raise it as a major issue |
| 5-6 | Adequate -- handled, but with clear room for improvement; a careful reviewer will note it |
| 7-8 | Good -- well-handled with only minor gaps; unlikely to cause revision requests |
| 9-10 | Excellent -- crisp, accurate, and complete; nothing a reviewer could reasonably add |

### What the two grades measure

**Paper grade (0-10):** What a reader finds in the manuscript. If the author gives a strong verbal answer that is not in the paper, the paper grade is still low -- the reader will not hear the conversation.

**Author grade (0-10):** Whether the author genuinely understands the dimension being probed. Verbal fluency does not matter -- a hesitant answer that reaches the right place scores higher than a confident wrong one.

### Diagnostic combinations

| Pattern | Signal | Action |
|---|---|---|
| Both >= 7 | Good -- move on | No issue logged |
| Paper < 5, Author >= 7 | Writing gap -- insight exists, not on the page | Log issue; fix is clear |
| Paper >= 7, Author < 5 | Understanding gap -- answer is in the paper, author cannot explain it | Note verbally, probe with follow-up; do not log as paper issue |
| Both < 5 | Fundamental problem | Log issue with elevated severity |
| Author score > Paper score by 3+ | Writing gap | Log issue |
| Paper score > Author score by 3+ | Understanding gap | Note and probe |

### Issue logging threshold

- Paper score 0-4 -> always log (severity set by which block and question)
- Paper score 5-6 -> log as Minor
- Paper score 7+ -> no issue logged, even if author score is low

### Grade summary in session history

Grades are recorded as a block-level summary in the session history, not as individual entries per question. At the end of each block, note the range and average for paper and author grades, and flag any large gaps.

---

## Block 1 -- Positioning (always run first, in this order)

**Q1. The problem**
"What problem does this paper address, and why does it matter?"
Check: Is the problem clearly and specifically stated? Is the motivation genuine or generic? Would a reader outside the subfield immediately understand why this matters?

**Q2. The gap**
"Why hasn't this problem been solved before -- what makes it genuinely non-trivial?"
Check: Does the paper establish that the gap is real and that prior work genuinely falls short? Or does it just assert novelty?

**Q3. The contribution**
"What exactly does this paper do that others do not?"
Check: Is the contribution claim crisp and accurate? Is it overstated (promises more than the paper delivers) or understated (sells the work short)? Is there a mismatch between the abstract's claim and what the paper actually shows?

**Q4. The impact**
"What changes -- for the field, for practitioners -- if this paper is right?"
Check: Is the impact claim proportionate to the results? Vague impact claims ("this will be useful for...") are a red flag.

---

## Block 2 -- Rigor (always run second, in this order)

**Q5. Internal validity**
"Do the results actually demonstrate what you claim within the study?"
Check: Are the right things measured? Are confounds controlled or acknowledged? Is the analysis appropriate for the data and research design?

**Q6. External validity**
"Does the scope of your conclusions match what the data can support?"
Check: Is the paper generalizing beyond its sample, setting, or method? Are population-level claims made from convenience samples? Are causal claims made from correlational data?

**Q7a. Unacknowledged limitations**
Read the paper for limitations the authors do not mention. For each one found:
- Flag it as a risk: reviewers will likely raise it
- Ask: "Why isn't [limitation X] discussed?"

**Q7b. Acknowledged-but-thin limitations**
Read the limitations section. For each stated limitation:
- Is it genuinely engaged with, or just mentioned to tick a box?
- A one-line "future work may address X" is not an acknowledgment -- it is avoidance

**Q8. Natural extensions** (light weight)
"Does this work open up credible next steps and generalizations?"
Check: Are obvious extensions missing entirely? This is not a blocking issue -- flag only if the paper feels like a dead end with no forward path.

---

## Block 3 -- Freestyle (griller-driven)

After completing Blocks 1 and 2, identify the 2-3 weakest spots in the paper. Choose from this pool:

- **Related work**: Is anything important missing? Is prior work misrepresented or strawmanned?
- **Narrative coherence**: Does the story hold from introduction to conclusion? Does the abstract promise what the paper delivers?
- **Methodology defensibility**: Are design choices justified or just made? Would a skeptical reviewer accept them?
- **Likely reviewer objections**: What specific pushback will this paper get, given the venue and topic?
- **Writing and framing**: Is the contribution undersold or oversold? Are key terms used consistently throughout?
- **Citation scrutiny** *(use only if the argument rests heavily on prior work)*: Pick 3-5 load-bearing citations. Challenge: what claim does this citation support, and does it actually do that?
- **Theorem/proposition intuition** *(use only if the paper has formal mathematical results)*: For each major theorem or proposition -- "What is the intuition here, and does the paper communicate it?" Check both whether the author can articulate it and whether a reader gets enough to grasp it.

Go deep on the 2-3 chosen areas. Do not skim all seven shallowly.

---

## Logging

After each question-answer exchange, append the finding to `Overleaf_source/grill_log.md`.

### Issue severity definitions

- **Blocking (B)**: Paper should not be submitted until resolved. Examples: contribution claim not supported by results, major missing baseline, fundamental methodological flaw.
- **Significant (S)**: Likely to cause a major revision request. Reviewer will flag it. Examples: overstated generalization, unacknowledged limitation that weakens the argument, missing important citation.
- **Minor (M)**: Reviewer may note it but it will not sink the paper. Examples: thin limitation acknowledgment, unclear sentence, inconsistent notation.

### Log entry format

Append to the master issue list:

```markdown
### [B/S/M][n] -- <short label> [Session YYYY-MM-DD]
**Finding:** <what was found>
**Location:** <section, paragraph, theorem number, or "abstract">
**Recommended fix:** <concrete action>
**Status:** Open
```

If the same issue was already in the log from a previous session, do not create a duplicate. Instead append to the existing entry:

```markdown
**Also raised:** Session YYYY-MM-DD -- <brief note>
**Signal:** STRONG -- raised in multiple sessions
```

### Session history entry

At the end of the session, append to the session history section:

```markdown
### Grill session -- YYYY-MM-DD
**Blocks completed:** [list]
**Issues logged:** B[x] S[x] M[x]
**Blocking issues found:** [list labels, or "none"]
**Strong signals:** [list labels, or "none"]
**Notes:** <anything unusual about this session>
```

---

## Ending the session

When all three blocks are complete:

1. Print a session summary:
   - Blocks completed
   - Issue counts by severity
   - Blocking issues (listed explicitly)
   - Strong signals (issues raised in multiple sessions)
   - Overall assessment: is the paper close to ready, or does it need substantial work before another grill session?

2. Remind the user:
   - Run `/grill-edit` to work through the master issue list and edit the manuscript
   - A second `/grill-paper` session after fixes is recommended if blocking issues were found
   - The paper reaches READY verdict in `/grill-edit` when all blocking issues are resolved and the griller recommends submission