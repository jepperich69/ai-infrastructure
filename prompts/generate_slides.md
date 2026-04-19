You are generating a Beamer LaTeX presentation from a research paper.

## Controls

- Duration:  $DURATION  (~$SLIDES slides total)
- Depth:     $DEPTH
- Audience:  $AUDIENCE
- Emphasis:  $EMPHASIS

## Your task

1. Read the paper at `Overleaf_source/$MAINFILE` (and its bibliography if present).
2. Generate a complete, compilable Beamer presentation.
3. Write it to `Overleaf_source/slides_main.tex`. Overwrite if it already exists.

## Depth guide

- **overview**:    Title + outline + 1 motivation slide + 1 methods slide + key result(s) + conclusion. No derivations. Pick the single most important figure.
- **standard**:    Full methods explained (assumptions, data, model). Main results with effect sizes and confidence. Brief robustness. Limitations in conclusion.
- **deep-dive**:   Everything in standard, plus derivations where relevant, all major figures, robustness checks as backup slides (after \appendix), open questions for discussion.

## Audience guide

- **conference**:      Assume field knowledge. Tight narrative. Minimal background. Lead with contribution.
- **research-group**:  Can be methodologically open. Discuss limitations and open questions. Encourage discussion.
- **non-specialist**:  Explain the problem from scratch. Avoid jargon or define it. Lead with real-world motivation. Focus on implications over methods.

## Emphasis guide

- **balanced**:        Follow the paper structure proportionally.
- **methods-heavy**:   Expand the methods section. Show data construction, model details, identification strategy.
- **results-heavy**:   Compress intro/methods. Dedicate most slides to results, subgroup analyses, figures.

## Beamer requirements

- Use `\documentclass[aspectratio=169]{beamer}` (16:9).
- Theme: `\usetheme{Madrid}` or a clean minimal theme -- do not use exotic themes that require special packages.
- Include `\usepackage{booktabs,graphicx,amsmath}`.
- Reference figures from the paper with `\includegraphics` using relative paths as they appear in the source (they will resolve correctly since slides_main.tex is in the same folder).
- Each slide: one clear point. Use `\pause` sparingly -- only when a reveal genuinely helps.
- For deep-dive: add backup slides after `\appendix` with a `\begin{frame}[noframenumbering]` wrapper.
- End with a "Thank you / Questions" slide that lists the paper title, authors, and contact.
- Do NOT use `\input` or `\include` -- the output must be a single self-contained file.

## Output

Write the complete .tex file to `Overleaf_source/slides_main.tex`. No other output needed -- do not summarize or explain what you did.
