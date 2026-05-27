---
name: overleaf-github-setup-rule
description: "Correct pattern for new projects with both Overleaf and GitHub — use setup_project.ps1, never a dual-remote single repo"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 532d7d66-8c2d-4cf8-bc8d-400b6b1c9551
---

Always use `setup_project.ps1` to link a project to Overleaf. Never create a manual dual-remote git setup.

**Why:** In Pub_QP_SAA_MC, a single parent repo was created with `origin`=GitHub and `overleaf` as a secondary remote. This caused `helpi 4` to push only to GitHub (it always runs `git push origin`), leaving Overleaf stale. When the Overleaf remote WAS pushed manually, the full repo arrived with `main.tex` buried in `Overleaf_source/` subfolder — Overleaf couldn't compile it. Recovery required git plumbing tricks because Overleaf blocks force pushes.

**How to apply:** When setting up any new project with Overleaf:
1. Run `.\setup_project.ps1 -FolderName Pub_X -OverleafUrl https://git.overleaf.com/<id>` — this clones Overleaf into `Overleaf_source/` as a standalone repo with `origin`=Overleaf, and registers it in `projects.json`.
2. If the project also needs GitHub: create a separate repo in `code/` (use `init_project_git.ps1`), OR at the project root with `Overleaf_source/` in `.gitignore`. Never add Overleaf as a secondary remote to a GitHub-origin repo.

Full details in `AI_auto/known_issues.md` §9.
