# Step 1: Reviewer Response Scaffold

You are helping to build a structured reviewer response letter from a flat text file of reviewer comments.

## Your task

1. **Find the reviewer comments file**
   - Look for a `.txt` file in the project root whose name suggests reviewer comments (e.g. `reviews.txt`, `reviewer_comments.txt`, `R1_comments.txt`, or similar).
   - If more than one candidate exists, list them and ask the user which to use.
   - If none exists, ask the user to paste the comments directly.

2. **Parse the comments**
   - Identify each distinct reviewer/editor (Area Editor, Associate Editor, Technical Editor, Referee 1, Referee 2, etc.).
   - Within each reviewer, identify individual numbered or paragraph-separated comments.
   - Assign labels: R1.1, R1.2 ... for Referee 1; R2.1, R2.2 ... for Referee 2; AE.1 for Area Editor; TE.1 for Technical Editor, etc.
   - Preserve the full verbatim text of each comment — do not paraphrase.

3. **Read project context**
   - Read `.claude/CLAUDE.md` for: paper title, authors, journal/venue, manuscript ID if known.
   - Read the main manuscript `.tex` file (most recently modified in `Overleaf_source/`) to understand the paper's content — you will need this for drafting in Step 2.

4. **Generate the scaffold LaTeX file**
   - Output file: `Overleaf_source/Response_$ROUND.tex` where $ROUND is e.g. R1, R2.
   - Use exactly the LaTeX preamble and environment definitions below.
   - Reviewer comment goes inside `\begin{reviewerbox}...\end{reviewerbox}`.
   - Response slot uses `\response{\TODO{Simple - no author note needed}}` by default.
   - Structure: cover page → Preamble section → Summary of Major Changes (with \TODO{} items) → one `\section{}` per reviewer → point-by-point comments.

5. **Push to Overleaf**
   - Run: `helpi 2 <project>` to push the new file to Overleaf.
   - Confirm with: "Scaffold pushed to Overleaf. Authors can now fill in \TODO{} slots."

## LaTeX preamble to use verbatim

```latex
\documentclass[11pt,a4paper]{article}

\usepackage[margin=2.5cm]{geometry}
\usepackage{xcolor}
\usepackage{enumitem}
\usepackage{booktabs}
\usepackage{multirow}
\usepackage{hyperref}
\usepackage{microtype}
\usepackage{parskip}
\usepackage{titlesec}
\usepackage{mdframed}
\usepackage{amsmath,amssymb}

\definecolor{shadecolor}{RGB}{245,245,245}
\definecolor{responseshade}{RGB}{235,245,255}

\newmdenv[
  backgroundcolor=shadecolor, linecolor=black, linewidth=0.5pt,
  leftmargin=0pt, rightmargin=0pt,
  innerleftmargin=10pt, innerrightmargin=10pt,
  innertopmargin=8pt, innerbottommargin=8pt,
  skipabove=6pt, skipbelow=2pt
]{reviewerbox}

\newmdenv[
  backgroundcolor=responseshade, linecolor=black, linewidth=0.5pt,
  leftmargin=0pt, rightmargin=0pt,
  innerleftmargin=10pt, innerrightmargin=10pt,
  innertopmargin=8pt, innerbottommargin=8pt,
  skipabove=2pt, skipbelow=10pt
]{responsebox}

\newcommand{\response}[1]{\begin{responsebox}\itshape #1\end{responsebox}}
\newcommand{\TODO}[1]{\textcolor{red}{[TODO: #1]}}
\newcommand{\clabel}[1]{\textbf{[#1]}}

\titleformat{\section}{\large\bfseries}{}{0em}{}[\titlerule]
\titleformat{\subsection}{\normalsize\bfseries}{}{0em}{}
```

## Structure template

```latex
\begin{document}

\begin{center}
  {\LARGE\bfseries Response to Reviewers}\\[6pt]
  {\large <Manuscript ID if known>}\\[4pt]
  {\large\itshape <Paper title>}\\[4pt]
  {\normalsize <Authors>}\\[4pt]
  {\normalsize \today}
\end{center}

\vspace{1em}
\noindent\rule{\textwidth}{1.5pt}
\vspace{0.5em}

\section*{Preamble}

We thank the editors and all referees for their thorough and constructive reviews.
\TODO{Personalise preamble — mention number of referees, overall tone of reviews, key themes.}

\section*{Summary of Major Changes}

\begin{enumerate}[leftmargin=*, label=\textbf{C\arabic*.}]
  \item \TODO{List major change 1}
  \item \TODO{List major change 2}
\end{enumerate}

\noindent\rule{\textwidth}{0.4pt}

% --- One section per reviewer ---

\section{<Reviewer label, e.g. Referee 1>}

% Comment R1.1
\clabel{R1.1}
\begin{reviewerbox}
<Verbatim comment text>
\end{reviewerbox}

\response{\TODO{Simple - no author note needed}}

% Comment R1.2
...

\end{document}
```

## TODO slot conventions

Authors will edit the scaffold in Overleaf before Step 2. The slot format signals intent:

- `\TODO{Simple - no author note needed}` — Claude handles this solo in Step 2
- `\TODO{[NOTE] <author guidance>}` — Claude uses this note to draft the response
- `\TODO{[SKIP]}` — Do not draft; author will write manually
- Any text already written (not `\TODO`) — Treat as the final response; do not overwrite

Make this convention clear in a comment block at the top of the generated .tex file.
