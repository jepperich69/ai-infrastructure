# Submission Staging — AI Content Only

Generates the AI-authored submission documents (cover letter, highlights,
author statement) and stages them in `_submit_staging/`.
Does NOT call submit.ps1 — that is handled by the caller.

---

## Setup

1. Identify the project root from the current working directory.
2. Read `.claude/CLAUDE.md` for: paper title, journal, author name, email,
   manuscript number, abstract, contributions.
3. Read the active manuscript (`Overleaf_source/` — check CLAUDE.md for the
   filename) to extract the abstract and contributions list if not fully
   captured in CLAUDE.md.

---

## Generate three files into `_submit_staging/`

Create `_submit_staging/` under the project root if it does not exist.

---

### 1. `_submit_staging/cover_letter.tex`

One page maximum. Use this LaTeX template:

```latex
\documentclass[12pt]{article}
\usepackage[top=2.5cm,bottom=2.5cm,left=3cm,right=3cm]{geometry}
\usepackage{parskip}
\usepackage{microtype}
\begin{document}
\raggedright

\today

\bigskip
The Editor-in-Chief \\
\textit{<Journal full name>}

\bigskip
Dear Editor,

<Body: 3--4 short paragraphs>

\bigskip
Sincerely,

\bigskip
<Author name> \\
<Title, Department, Institution> \\
<Email>

\end{document}
```

Body structure:
- **Para 1:** We submit [paper title] for consideration in [journal]. If
  resubmission, reference the manuscript number: "We are pleased to submit
  our revised manuscript (no. XX) in response to the reviewers' comments."
- **Para 2:** What the paper does — two sentences drawn from the abstract.
  Why it fits the journal — one sentence (scope match).
- **Para 3:** Key contributions — two to three bullet points or a short list,
  drawn from the contributions section of the manuscript.
- **Para 4 (standard closing):** "The manuscript has not been previously
  published and is not under consideration for publication elsewhere. All
  authors have read and approved the final manuscript."

Compile to `_submit_staging/cover_letter.pdf` using pdflatex. If compilation
fails, leave the .tex and note the error — do not abort.

---

### 2. `_submit_staging/highlights.txt`

Exactly 5 bullet points. Each must be **<= 85 characters** — count carefully
including spaces and punctuation. Draw from the abstract, introduction, and
contributions. Each should be a standalone factual claim, not a sentence
fragment.

Format exactly as:
```
* <highlight 1>
* <highlight 2>
* <highlight 3>
* <highlight 4>
* <highlight 5>
```

Check each line length before writing. If a line exceeds 85 characters,
shorten it — do not leave it long.

---

### 3. `_submit_staging/author_statement.tex`

Standard CRediT taxonomy author contribution statement. For a single-author
paper, attribute all applicable roles to that author. Use this template:

```latex
\documentclass[12pt]{article}
\usepackage[margin=2.5cm]{geometry}
\usepackage{parskip}
\begin{document}

\section*{Author Contributions}

\textbf{<Author name>:} Conceptualization, Methodology, Software, Validation,
Formal analysis, Investigation, Data Curation, Writing -- Original Draft,
Writing -- Review \& Editing, Visualization.

\end{document}
```

Adjust the role list if the paper has multiple authors — assign roles
appropriately based on what is described in the manuscript.

Compile to `_submit_staging/author_statement.pdf`. If compilation fails,
leave the .tex.

---

## Report

Print a short summary:
- Which files were created and whether PDFs compiled
- Character counts for each highlight (confirm all <= 85)
- Note that submit.ps1 will be called next to assemble the full package
