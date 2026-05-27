# /submit — Submission package generator

Runs autonomously. Produces a complete submission package in a versioned subfolder.
Do not pause for approval — report any failures at the end.

## Argument parsing

`$ARGUMENTS` is one of:
- Empty — first submission → subfolder `Original`
- `R1`, `R2`, `R3` → subfolder `Revision_R1`, `Revision_R2`, `Revision_R3`

Resolve the **project root** by walking up from CWD to the first folder starting with `Pub_`, `Pro_`, or `PhD_`.

All working files are in `<project_root>\Overleaf_source\`.
All outputs go into `<project_root>\Overleaf_source\<subfolder>\`.

Create the subfolder if it does not exist:
```powershell
New-Item -ItemType Directory -Path "<project_root>\Overleaf_source\<subfolder>" -Force
```

---

## Phase 1 — Full compilation

Compile `main.tex` with full BibTeX passes to produce `main.bbl`:

```bash
cd "<project_root>/Overleaf_source"
latexmk -pdf -bibtex -interaction=nonstopmode main.tex
```

If compilation fails, stop and report the LaTeX errors. Do not proceed with broken source.

Verify `main.bbl` exists after compilation. If it does not (no bibliography), note this and skip Phase 2 — the zip will include `refs.bib` instead.

---

## Phase 2 — BibTeX integration

Create `submission_main.tex` — a copy of `main.tex` with the bibliography inlined:

1. Read `main.tex`
2. Read `main.bbl`
3. Find the `\bibliography{...}` line (may reference one or multiple .bib files)
4. Replace it with the full contents of `main.bbl`
5. Add a comment above: `% Bibliography integrated from main.bbl for submission — source: refs.bib`
6. Write to `Overleaf_source/submission_main.tex`

Handle edge cases:
- If `\bibliography` spans multiple lines or has extra whitespace, match flexibly
- If no `\bibliography` command exists, skip integration and use `main.tex` directly

---

## Phase 3 — Anonymous version

Create `anonymous_main.tex` from `submission_main.tex`. Strip all author-identifying information by **commenting out** (not deleting) each block:

Strip the following patterns — add `% [ANONYMOUS] ` before each commented line:
- `\author{...}` — may span multiple lines; match to closing brace
- `\affiliation{...}`, `\address{...}`, `\institute{...}` — same
- `\thanks{...}` — often nested inside `\author`
- `\ead{...}`, `\corref{...}`, `\fnref{...}` — elsarticle author markers
- `\cortext{...}`, `\fntext{...}` — elsarticle footnotes
- Any line matching `\email{`, `\phone{`, `\fax{`
- Acknowledgements section: everything between `\section*{Acknowledgement` (or `Acknowledgment`) and the next `\section` or `\end{document}`. Comment out the section heading and all content.
- `\begin{acks}...\end{acks}` block if present

After stripping, compile:
```bash
latexmk -pdf -interaction=nonstopmode anonymous_main.tex
```

Output: `anonymous_main.pdf`

If compilation fails after stripping, report which commands were removed and what the error is — this likely means the class file requires author info to be present.

---

## Phase 4 — Front page

Generate `frontpage.tex` — a standalone one-page document with full author information:

Extract from `main.tex`:
- Paper title (from `\title{...}`)
- Authors (from `\author{...}` blocks)
- Affiliations
- Corresponding author email if present
- Date or `\today`

Write `frontpage.tex`:

```latex
\documentclass[12pt]{article}
\usepackage[margin=3cm]{geometry}
\usepackage{parskip}
\usepackage{hyperref}
\pagestyle{empty}

\begin{document}

\begin{center}
  {\LARGE \textbf{<title>}} \\[16pt]
  {\large <authors>} \\[8pt]
  {\normalsize <affiliations>} \\[6pt]
  {\small <email if available>} \\[6pt]
  {\small \today}
\end{center}

\end{document}
```

Compile → `frontpage.pdf`

---

## Phase 5 — Create submission zip

Collect files for the zip. Include:
- `submission_main.tex` → rename to `main.tex` inside the zip
- All figure files: contents of `figures/`, `pictures/`, `figs/` if they exist
- Any `*.sty`, `*.cls`, `*.bst` files in `Overleaf_source/` root
- Any explicitly `\input{}`-ed or `\include{}`-ed `.tex` files found in `main.tex`

Exclude explicitly:
- `*.bib` (bibliography is integrated)
- `*.aux`, `*.log`, `*.bbl`, `*.blg`, `*.out`, `*.synctex*`, `*.fls`, `*.fdb_latexmk`
- `response_R*.tex`, `reviewers_R*.txt`, `manus_R*_diff.tex`
- `submission_main.tex`, `anonymous_main.tex`, `frontpage.tex`
- `coverletter.tex`, `highlights.tex`, `author_statements.tex`
- The `Original/`, `Revision_R*/` subfolders themselves

Create the zip:
```powershell
$files = @(... collected file list ...)
Compress-Archive -Path $files -DestinationPath "Overleaf_source\<subfolder>\manuscript.zip" -Force
```

---

## Phase 6 — Cover letter

Read the paper's `\title{}`, abstract (content of `abstract` environment), and introduction (first ~300 words after `\section{Introduction}` or equivalent).

Draft `coverletter.tex` — maximum one page when compiled. Structure:

```latex
\documentclass[12pt]{article}
\usepackage[margin=2.5cm]{geometry}
\usepackage{parskip}
\pagestyle{empty}

\begin{document}

\begin{flushright}
Prof.\ Jeppe Rich \\
Technical University of Denmark \\
\today
\end{flushright}

\bigskip
Dear Editor,

\bigskip
[Opening: "We are pleased to submit our manuscript \textit{<title>} for consideration in \textit{[Journal Name]}."]

[Paragraph 1 — what the paper does: the research question, the method, and the main finding. 3--4 sentences. Based on the abstract.]

[Paragraph 2 — why it matters and why this journal: contribution to the field, relevance to the journal's scope. 2--3 sentences. Infer from the introduction.]

[Closing: "We confirm that this manuscript has not been published elsewhere and is not currently under review at another journal. All authors have approved the submission." 2 sentences.]

\bigskip
Yours sincerely,

\bigskip\bigskip
Prof.\ Jeppe Rich \\
Technical University of Denmark

\end{document}
```

Leave `[Journal Name]` as a placeholder — the user fills this in.
Keep total length to one page strictly — trim if needed.

Compile → `coverletter.pdf`

---

## Phase 7 — Highlights

Read the abstract and conclusions section of `main.tex`.

Generate exactly **5 bullet points**. Each must be:
- A complete, standalone statement of a finding or contribution
- **Strictly ≤ 85 characters including spaces** — count every character, do not approximate
- Written as a result or insight, not a description of what the paper does

Check each point character by character. If any exceeds 85 characters, shorten it before proceeding.

Write `highlights.tex`:

```latex
\documentclass[12pt]{article}
\usepackage[margin=2.5cm]{geometry}
\usepackage{parskip}
\pagestyle{empty}

\begin{document}

\begin{center}
  {\large \textbf{Highlights}}
\end{center}

\begin{itemize}
  \item <highlight 1>
  \item <highlight 2>
  \item <highlight 3>
  \item <highlight 4>
  \item <highlight 5>
\end{itemize}

\bigskip
\noindent Prof.\ Jeppe Rich, Technical University of Denmark

\end{document}
```

Also write `highlights.txt` — plain text version:
```
Highlights

• <highlight 1>
• <highlight 2>
• <highlight 3>
• <highlight 4>
• <highlight 5>

Prof. Jeppe Rich, Technical University of Denmark
```

Compile `highlights.tex` → `highlights.pdf`

---

## Phase 8 — Author statements

Generate `author_statements.tex` using CRediT taxonomy.

Read the paper to infer contributions. For sole-author papers, attribute all roles to J.R. For multi-author papers, attribute what can be inferred and mark unclear roles as `[to be confirmed]`.

```latex
\documentclass[12pt]{article}
\usepackage[margin=2.5cm]{geometry}
\usepackage{parskip}
\pagestyle{empty}

\begin{document}

\textbf{Author Contributions} (CRediT taxonomy)

\textbf{J.R.}: Conceptualization; Methodology; Software; Formal analysis;
Writing -- original draft; Writing -- review \& editing; Visualization.

% If co-authors exist, add lines:
% \textbf{[Co-author initials]}: [roles -- to be confirmed]

\bigskip
\textbf{Declaration of competing interests}

The author(s) declare no competing interests.

\bigskip
\textbf{Data availability}

[Data available upon reasonable request. / Data available at: / No data used.]

\end{document}
```

Leave `Data availability` as a placeholder with options — user selects the right one.

---

## Phase 9 — Assemble outputs

Copy all generated files into `Overleaf_source/<subfolder>/`:

| File | Description |
|---|---|
| `manuscript.zip` | Submission package — bbl integrated, no .bib |
| `anonymous_main.pdf` | PDF for double-blind review |
| `frontpage.pdf` | Title page with full author info |
| `coverletter.tex` + `coverletter.pdf` | Cover letter — fill in journal name |
| `highlights.tex` + `highlights.txt` + `highlights.pdf` | 5-point highlights |
| `author_statements.tex` | CRediT + declarations — fill in data availability |

Clean up working files from `Overleaf_source/` root:
- Delete `submission_main.tex`, `anonymous_main.tex`, `frontpage.tex`
- Keep `main.tex`, `refs.bib` untouched

---

## Session logging

Append to `_ai_log.md`:

```
## Session YYYY-MM-DD — Submission package [subfolder]
**Agent:** Claude Sonnet 4.6
**Goal:** Generate submission package for [subfolder]
**BibTeX integration:** [done / skipped — no bibliography]
**Files generated:** manuscript.zip, anonymous_main.pdf, frontpage.pdf,
  coverletter.tex/.pdf, highlights.tex/.txt/.pdf, author_statements.tex
**Subfolder:** Overleaf_source/<subfolder>/
**Items requiring user attention:**
- Cover letter: fill in [Journal Name]
- Author statements: confirm co-author contributions and data availability statement
- Review highlights for accuracy
**Next steps:** Review outputs, edit placeholders, push to Overleaf with helpi 2
```

## Final report to user

Print:
- Subfolder created and list of files
- Any compilation errors or warnings
- Explicitly list the placeholders the user must fill in before submitting
- Character counts for each highlight (confirm all ≤ 85)
