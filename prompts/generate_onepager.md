You are generating a compact technical one-pager and a companion supplement from a research paper.

## Your task

1. Read the paper at `Overleaf_source/$MAINFILE`.
2. Identify the single primary technical contribution -- one idea, one key result.
3. Write a self-contained, compilable LaTeX one-pager that distils it.
4. Write the output to `Overleaf_source/technical_onepager.tex`. Overwrite if it exists.
5. Write a companion supplement to `Overleaf_source/supplement_onepager.tex`. Overwrite if it exists.

## What to distil

Focus on the technical core:
- What is the key object or transformation being introduced?
- What is the central formula or analytical result?
- What is the insight that makes it exact, tractable, or useful?
- How does it connect to existing computational machinery?
- One concrete illustrative instance (in prose, no table or figure).
- One boxed separation that captures the contribution structure.

Skip: literature review, related work, numerical experiments beyond one illustrative check,
proofs, and citations.

## Document style (follow exactly)

Use this exact preamble for `technical_onepager.tex`:

```
\documentclass[10pt]{article}
\usepackage[a4paper,margin=1.7cm]{geometry}
\usepackage{amsmath,amssymb}
\usepackage{hyperref}
\setlength{\parindent}{0pt}
\setlength{\parskip}{4pt}
\newcommand{\fn}[1]{\textsuperscript{\normalfont\small #1}}

\title{\vspace{-1.4cm}<concise technical statement of what the paper does>}
\author{<authors as they appear in the paper>}
\date{\vspace{-0.5cm}\today}
```

Use this document structure (5-7 paragraphs total):

```
\begin{document}
\maketitle
\vspace{-0.6cm}

\textit{Idea.}
<2-3 sentences: the problem and the core construction. State the key object formally.
One display equation for the primary construction.>

\textit{Key result.}
<The central analytical result. One display equation.
One sentence on why it holds (the key insight, e.g. x_j^2 = x_j for binary x).
One sentence on what it implies operationally.>

\textit{<Optional interpretation or connection.>}  % omit section if not essential
<One paragraph. Include only if it materially aids understanding.>

\textit{Solver / application layer.}
<How the result connects to existing computational machinery.
One display equation if needed. One or two sentences.>

\textit{Small check.}
<One concrete illustrative instance in prose -- no table, no figure. 2-3 sentences.>

\textit{Core claim.}
<One sentence framing the contribution. Then the boxed separation:>
\begin{equation}
  \boxed{\text{first component}} \quad+\quad \boxed{\text{second component}}
\end{equation}
<One sentence on exactness conditions and open questions.>

\noindent\rule{\linewidth}{0.4pt}
{\footnotesize\textit{Supplement notes} 1--N contain <brief description of what the notes cover>.}

\end{document}
```

## Footnote markers in the main one-pager

Use `\fn{N}` (defined in the preamble) to place superscript footnote numbers at key points
in the compiled text. These markers have NO text on the main page -- all content appears in
the supplement. Place one marker per note, immediately after the sentence or equation it
annotates. Aim for 3--6 markers total.

Good places for markers:
- After the sentence defining a dense notation-heavy quantity
- After a key result sentence that has non-obvious intuition
- After a condition or threshold that deserves derivation
- After a structural claim (plateau, boundary solution, complementarity)

Do NOT place markers in the middle of an equation or on a display equation line.

## Language standard

- Use down-to-earth technical language. Prefer concrete phrases over dense structural labels.
- If a precise term from the manuscript is necessary but may be unclear, briefly explain it
  in the compiled text when space allows. As a minimum, explain it in a `% Notation:` comment.
- Prefer plain policy language for practical relevance.

## Hard constraints (main one-pager)

- Do NOT use `\cite`, `\ref`, `\input`, `\include`, or `\begin{figure}`.
- Do NOT use `\textbf` for paragraph headers -- use `\textit` run-ins only.
- Do NOT add a bibliography or `\bibliographystyle`.
- Keep total LaTeX source under 130 lines. The compiled PDF must fit on one A4 page.
- Every display equation must earn its place. If a formula adds nothing beyond prose, write prose.
- Use numbered display equations with `\begin{equation}` ... `\end{equation}` for every major
  equation. Do not use unnumbered `\[...\]` displays for major equations.
- The title must be a concise technical statement, not a catchy headline.
- Notation must be consistent with the source manuscript.

## Source comments (main one-pager)

Add brief `% Notation:` comments for dense symbols. Keep them short (1--2 lines max) since
detailed derivations and intuitions go in the supplement, not in source comments.
Add one `% Policy reflection:` comment near the core claim.

## Supplement document (`supplement_onepager.tex`)

The supplement compiles the notes referenced by `\fn{N}` markers in the main one-pager.
It must fit on one A4 page and use the same preamble style (10pt, same margins, no `\fn`
command needed).

Use this preamble:

```
\documentclass[10pt]{article}
\usepackage[a4paper,margin=1.7cm]{geometry}
\usepackage{amsmath,amssymb}
\usepackage{hyperref}
\setlength{\parindent}{0pt}
\setlength{\parskip}{5pt}

\title{\vspace{-1.4cm}Supplement Notes to One-Pager}
\author{<same authors>}
\date{\vspace{-0.5cm}\today}
```

For each note N, use this structure (bold bracketed number, dotted separator between notes):

```
\noindent\textbf{[N]:}~\textit{<short title>.}

<Content: derivation, parameter derivation, or intuition. Use \begin{equation}...\end{equation}
for any math. 4--10 lines of compiled text per note. Plain, down-to-earth language.
Show numeric checks where helpful.>

\vspace{2pt}\noindent\dotfill\vspace{2pt}   % between notes; omit after the last note
```

What each note should contain:
- **Notation notes**: derive the parameter from first principles (e.g. alpha = VoT/v_walk)
  and give a numeric example at the paper's calibration.
- **Derivation notes**: show the algebra step by step, arrive at a clean condition or formula,
  give a numeric check.
- **Intuition notes**: explain in 3--5 sentences why the result holds, what it means in
  plain terms, and what it implies for the design problem.

Hard constraints (supplement):
- Do NOT use `\cite`, `\ref`, `\input`, `\include`, or `\begin{figure}`.
- Do NOT use `\textbf` for headers -- use `\textit` run-ins only.
- Do NOT add a bibliography.
- The compiled PDF must fit on one A4 page.
- Every display equation must earn its place.
- Numbered display equations with `\begin{equation}` ... `\end{equation}`.

## Output hygiene

Do not leave or push LaTeX build artifacts from one-pager compilation. The intended deliverables are only the source files `Overleaf_source/technical_onepager.tex` and `Overleaf_source/supplement_onepager.tex`. If you compile for verification, remove generated `.aux`, `.log`, `.fls`, `.fdb_latexmk`, `.out`, `.synctex.gz`, and `.pdf` files before pushing to Overleaf unless the user explicitly asks for PDFs.
## Output
Write both complete .tex files:
- `Overleaf_source/technical_onepager.tex`
- `Overleaf_source/supplement_onepager.tex`

No other output -- do not summarize or explain what you did.
