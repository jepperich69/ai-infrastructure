# Step 2: Reviewer Response Draft Loop

You are drafting point-by-point responses to reviewer comments, using a scaffold file that authors have partially filled in.

## Your task

### Setup
1. **Auto-pull from Overleaf** — run `sync_one.ps1 -Project <project>` to get the latest version with author notes.
2. **Find the scaffold file** — look for `Overleaf_source/Response_$ROUND.tex`. If multiple exist, ask which round.
3. **Read the manuscript** — read the most recently modified `.tex` file in `Overleaf_source/` for context (sections, equations, tables, results).
4. **Read `.claude/CLAUDE.md`** for paper context.

### Drafting rules

Work through every `\TODO{...}` slot in order. For each:

- **`\TODO{Simple - no author note needed}`** — draft a complete, polished academic response yourself. Use the manuscript to cite specific equations, sections, tables, or changes made.
- **`\TODO{[NOTE] <author guidance>}`** — use the author's note as your direction. Draft a response that follows it, citing the manuscript as appropriate.
- **`\TODO{[SKIP]}`** — leave untouched. Print `SKIP: <label>` to the console.
- **Any text already written (not `\TODO`)** — leave untouched. Print `DONE: <label>` to the console.

### Response style

- Write in first-person plural ("We thank...", "We have revised...", "We agree...").
- Be specific: cite equation numbers, section numbers, page numbers, line numbers where relevant.
- For changes made: describe exactly what was changed and where ("We have added a sentence at the end of Section 3.2...").
- For disagreements: acknowledge the concern, explain the position clearly, offer a compromise if appropriate.
- Typical length: 3-10 sentences per comment. Match the complexity of the comment.
- Do not use `\TODO` in any output you write.

### Output

- Edit `Overleaf_source/Response_$ROUND.tex` in place — replace each `\TODO{...}` with the drafted response text inside the existing `\response{...}` command.
- After every 5 comments, print a progress update: `Drafted R1.1-R1.5 — continuing...`
- When finished: print a summary table listing each label, status (Drafted / Skipped / Already done), and word count of the response.
- Then push to Overleaf: run `helpi 2 <project>`.
- Finally: remind the user to review the draft in Overleaf before compiling.

### Quality check before pushing

Before pushing, verify:
- No `\TODO` strings remain except those marked `[SKIP]`.
- The LaTeX compiles without obvious errors (balanced braces, no undefined commands).
- Each response references at least one specific location in the revised manuscript (section, equation, figure, or table number).
