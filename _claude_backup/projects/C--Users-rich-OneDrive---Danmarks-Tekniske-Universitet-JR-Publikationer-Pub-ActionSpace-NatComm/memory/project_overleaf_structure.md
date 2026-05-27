---
name: project-overleaf-structure
description: Active Overleaf file names and structure as of 2026-05-22 reorganization
metadata: 
  node_type: memory
  type: project
  originSessionId: 7a12e74f-d183-4fa0-b403-73cf6d198913
---

As of 2026-05-22, the Overleaf_source/ folder has this structure:

**Active .tex files (submit-ready):**
- `NatComm_original.tex` — original submission manuscript
- `NatComm_original_supp.tex` — original supplementary
- `NatComm_R1.tex` — R1 revision manuscript (main file to compile for submission)
- `NatComm_R1_supp.tex` — R1 supplementary
- `NatComm_R1_response.tex` — R1 response letter

**Subfolders:**
- `figures/` — all PNG files (22 images); all .tex files use `\graphicspath{{figures/}}`
- `archive/` — NatComm_early_draft.tex, NatComm_R1A_draft.tex, slides.tex, slides_grenoble.tex, main_methodology_draft.tex

**SI figure numbering (NatComm_R1_supp.tex):**
- S1: temporal window shifts
- S2: mean time shift
- S3: mean distance trend
- S4: settlement-type robustness (urban_drift_comparison.png)
- S5: bandwidth sensitivity bars (bw_drift_bars.png) — was S6; S5 (bootstrap fan) was dropped

**Bootstrap fan:** moved from SI Figure S5 to main paper Figure 6a (bootstrap_arrow_fan.png).
Response letter §2.2 and summary table updated accordingly.

**Why:** [[project_coverletter]] — cover letter still needed; table numbering discrepancy to flag.
