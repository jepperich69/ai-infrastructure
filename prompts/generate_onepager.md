You are generating a compact technical one-pager from a research paper.

## Your task

1. Read the paper at `Overleaf_source/$MAINFILE`.
2. Identify the single primary technical contribution -- one idea, one key result.
3. Write a self-contained, compilable LaTeX one-pager that distils it.
4. Write the output to `Overleaf_source/technical_onepager.tex`. Overwrite if it exists.

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

Use this exact preamble:

```
\documentclass[10pt]{article}
\usepackage[a4paper,margin=1.7cm]{geometry}
\usepackage{amsmath,amssymb}
\usepackage{hyperref}
\setlength{\parindent}{0pt}
\setlength{\parskip}{4pt}

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
\[
    \boxed{\text{first component}} \quad+\quad \boxed{\text{second component}}
\]
<One sentence on exactness conditions and open questions.>

\end{document}
```

## Hard constraints

- Do NOT use `\cite`, `\ref`, `\input`, `\include`, or `\begin{figure}`.
- Do NOT use `\textbf` for paragraph headers -- use `\textit` run-ins only.
- Do NOT add a bibliography or `\bibliographystyle`.
- Keep total LaTeX source under 130 lines. The compiled PDF must fit on one A4 page.
- Every display equation must earn its place. If a formula adds nothing beyond prose, write prose.
- The title must be a concise technical statement, not a catchy headline.
- Notation must be consistent with the source manuscript.

## Output

Write the complete .tex file to `Overleaf_source/technical_onepager.tex`.
No other output -- do not summarize or explain what you did.
