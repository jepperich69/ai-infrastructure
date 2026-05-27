---
name: project_code_folder_restructure
description: Planned restructuring of AI_auto root — move .ps1 scripts into a code/ subfolder
metadata: 
  node_type: memory
  type: project
  originSessionId: 1ebbdedb-0992-4790-a0c1-47f8f23e7326
---

Move the ~26 .ps1 scripts from the AI_auto root into a `code/` subfolder to match the research project structure.

**Why:** Root folder is cluttered with scripts, docs, logs, and data all mixed together. Consistent with `code/` pattern used in Pub_/Pro_/PhD_ projects (and helpi 23 pushes that folder to GitHub).

**How to apply:** Defer until after the presentation. When ready, plan for ~1h: move .ps1 files, update `helpi.cmd` to point to `code\helpi.ps1`, fix `$aiRoot` in `config.ps1` (currently derived from `$PSScriptRoot`, needs `$PSScriptRoot\..` after the move), smoke-test helpi commands.
