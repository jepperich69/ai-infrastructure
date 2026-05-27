---
name: feedback-paragraph-style
description: "User prefers italic paragraph headings, not bold — applies to all LaTeX papers"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 6f7d4a88-ede1-42da-bc9f-d374f9125e4d
---

Use italic (not bold) for `\paragraph{}` headings in all LaTeX manuscripts.

**Why:** User stated this as a general rule ("as a general rule, I thought I had informed you in the way I write").

**How to apply:** Add to preamble:
```latex
\usepackage{titlesec}
\titleformat{\paragraph}[runin]{\normalfont\itshape}{}{0pt}{}
\titlespacing*{\paragraph}{0pt}{1.5ex plus 0.2ex minus 0.2ex}{0.5em}
```
Apply this whenever creating or editing a LaTeX paper for this user. Do not use `\textbf{}` inline as a substitute for `\paragraph{}`.
