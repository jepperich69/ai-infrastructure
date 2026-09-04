# AI_auto

AI_auto is a local research infrastructure for writing papers with AI agents while keeping the actual scholarly work in ordinary files: Overleaf git clones, code repositories, logs, handovers, and reproducible submission packages.

The basic idea is simple:

- Overleaf remains the collaboration surface for manuscripts.
- Each paper also has a local project folder with `Overleaf_source/`, `code/`, logs, and metadata.
- PowerShell scripts handle mechanical work such as sync, compile, snapshots, handovers, and submission packaging.
- AI agents such as Claude Code and Codex read the same project context and write to the same session log, so work can continue across sessions and across tools.

The full reference guide is [`infrastructure.html`](infrastructure.html). The short generated guide is [`infrastructure_summary.html`](infrastructure_summary.html), and the printable full guide is [`infrastructure_full.pdf`](infrastructure_full.pdf).

## What This Solves

Modern research workflows are split across Overleaf, local code, shared notes, AI chat windows, submission portals, and collaborators' machines. That makes it easy to lose context, overwrite work, or leave an AI session with no durable record of what happened.

AI_auto adds a file-based backbone:

- Local git-backed copies of manuscripts and code.
- Standard paper project folders named like `Pub_Topic_Driver`.
- AI session logs in `_ai_log.md`.
- Generated handover documents for agent switching.
- Version snapshots before major manuscript changes.
- Submission package generation for journal workflows.
- Cross-project "feeder" links so one paper can inherit compact context from another.
- A shared skill layer for referee review, mathematical verification, pre-submission grilling, diagnosis, TDD, prototyping, and multi-agent pipelines.
- Project-scoped integrations for specialized tools such as QGIS, plus a generated software inventory in [`TOOLS.md`](TOOLS.md).
- A NoteTaker bridge that moves dictated notes from a phone through a serverless spool into the local workflow.

It is intentionally local-first. The system does not replace Overleaf, GitHub, or the AI agent. It coordinates them.

## Installing

New machine or new colleague? See [`INSTALL.md`](INSTALL.md) for the full setup:
the accounts and licenses you must bring (which are paid), the software to
install, and a step-by-step runbook an AI agent can execute, pausing only at the
human-only steps (account creation, payment, OAuth logins, key generation).

## Quick Start

Run commands from PowerShell. The wrapper is:

```powershell
helpi
```

Common commands:

```powershell
helpi 1 Pub_MyPaper_JR          # create a new paper project
helpi 2                         # pull all registered Overleaf projects
helpi 3 Pub_MyPaper_JR          # pull one Overleaf project
helpi 4 Pub_MyPaper_JR          # push local manuscript edits to Overleaf
helpi 5 Pub_MyPaper_JR          # open/compile a project for work
helpi 6 Pub_MyPaper_JR          # compile LaTeX only
helpi 8 Pub_MyPaper_JR          # create a manuscript snapshot tag
helpi 10 Pub_MyPaper_JR         # build a submission package
helpi 13                        # project status dashboard
helpi 14                        # project network graph
helpi 15                        # open the infrastructure guide
helpi 16                        # regenerate HTML/PDF documentation
helpi 22 Pub_MyPaper_JR         # compress old AI log entries
helpi 23 Pub_MyPaper_JR         # push code/ to GitHub
helpi 25 Pub_MyPaper_JR "Task"  # run a structured multi-agent forum
helpi 26                        # update AI_auto from GitHub
helpi 27 MyProject              # create a generic non-paper project
helpi 28 Pub_MyPaper_JR         # add project-scoped PyQGIS support
helpi 29                        # regenerate the installed-tool inventory
```

Inside AI agents, the main workflow commands are:

```text
/work Pub_MyPaper_JR
/snapshot V2
/family Pub_RelatedPaper_AB
/review-paper
/grill-paper
/pipeline "Task" --project Pub_MyPaper_JR
/close
```

## Repository Layout

Core entry points:

- [`helpi.cmd`](helpi.cmd) and [`scripts/helpi.ps1`](scripts/helpi.ps1): command wrapper and menu for all infrastructure tasks.
- [`scripts/config.ps1`](scripts/config.ps1): shared configuration loader; machine-specific values stay in gitignored `config.local.ps1`.
- [`infrastructure.html`](infrastructure.html): authoritative human-readable guide.
- [`README.md`](README.md): GitHub-facing introduction.
- [`CHANGELOG.md`](CHANGELOG.md), [`RELEASING.md`](RELEASING.md), [`VERSION`](VERSION): release notes and version metadata.

Project lifecycle:

- [`scripts/new_project.ps1`](scripts/new_project.ps1): create a new paper project folder.
- [`scripts/new_generic_project.ps1`](scripts/new_generic_project.ps1): create the AI continuity layer for a non-paper project.
- [`scripts/setup_project.ps1`](scripts/setup_project.ps1): initialize project-local infrastructure.
- [`scripts/setup.ps1`](scripts/setup.ps1): first-time setup for a new user or machine.
- [`scripts/restore.ps1`](scripts/restore.ps1): restore infrastructure on a replacement machine.

Overleaf sync and manuscript work:

- [`scripts/sync_all.ps1`](scripts/sync_all.ps1): pull all registered Overleaf projects.
- [`scripts/sync_one.ps1`](scripts/sync_one.ps1): pull one project.
- [`scripts/push_to_overleaf.ps1`](scripts/push_to_overleaf.ps1): push local manuscript edits back to Overleaf.
- [`scripts/compile_latex.ps1`](scripts/compile_latex.ps1): compile a LaTeX manuscript.

AI continuity:

- [`scripts/generate_handover.ps1`](scripts/generate_handover.ps1): build `_handover.html`, `_handover.json`, `AGENTS.md`, and collaborator handovers.
- [`scripts/ai_log_tools.ps1`](scripts/ai_log_tools.ps1): helpers for AI session logs.
- [`scripts/compress_log.ps1`](scripts/compress_log.ps1): compress old `_ai_log.md` sessions into compact summaries.
- [`_ai_log.md`](_ai_log.md): session history for this infrastructure project.
- [`_handover.html`](_handover.html): generated handover for agent switching.
- [`AGENTS.md`](AGENTS.md): generated instructions for AI agents entering this repo.

Versioning, rollback, and submission:

- [`scripts/snapshot.ps1`](scripts/snapshot.ps1): create manuscript snapshot tags.
- [`scripts/rollback.ps1`](scripts/rollback.ps1): rollback recent code commits.
- [`scripts/submit.ps1`](scripts/submit.ps1): build journal submission packages.
- [`scripts/push_to_github.ps1`](scripts/push_to_github.ps1): push a project's `code/` repository to GitHub.

Adversarial Debate:

- [`scripts/run_forum.ps1`](scripts/run_forum.ps1): orchestrate a **Convergence Forum** using multi-agent rounds or one agent in three roles.

Monitoring and documentation:

- [`scripts/status.ps1`](scripts/status.ps1): project status dashboard.
- [`scripts/network.ps1`](scripts/network.ps1): generate the project network graph.
- [`network.html`](network.html): generated network visualization.
- [`scripts/generate_docs.ps1`](scripts/generate_docs.ps1): regenerate summary/full HTML and PDF documentation from `infrastructure.html`.
- [`scripts/add_qgis.ps1`](scripts/add_qgis.ps1): add project-scoped PyQGIS configuration.
- [`TOOLS.md`](TOOLS.md): generated inventory of installed research software; refresh with `helpi 29`.
- [`known_issues.md`](known_issues.md): local environment map and platform notes.
- [`onboarding_paper_projects.md`](onboarding_paper_projects.md): onboarding guide for paper project naming and group rollout.
- [`book_draft_researcher_ai_infrastructure.md`](book_draft_researcher_ai_infrastructure.md): working draft about the research workflow.

Registries and generated state:

- [`projects.json`](projects.json): registered projects and sync metadata.
- [`papers.csv`](papers.csv): paper/project table.
- [`overleaf_projects.csv`](overleaf_projects.csv): Overleaf project export.
- [`_feeders/`](_feeders): compact cross-project feeder digests.
- [`_state/`](_state): local runtime state, such as the last active project.
- [`logs/`](logs): local logs.
- [`Overleaf_source/`](Overleaf_source): Overleaf clone for the AI_auto presentation/documentation project.

Prompts:

- [`prompts/`](prompts): reusable AI prompts for slides, submission staging, reviewer response scaffolds, and reviewer draft loops.

## Standard Project Folder

A paper project typically looks like this:

```text
Pub_Topic_Driver/
  Overleaf_source/      # Overleaf git clone
  code/                 # analysis code, with its own git history
  Literature/           # literature material
  _ai_log.md            # durable AI session log
  _handover.html        # generated agent handover
  _feeders/             # imported context from related projects
  .claude/CLAUDE.md     # project brief shared by agents
```

The naming convention is `Pub_Topic_Driver`, where the driver is the person responsible for keeping the paper moving, not necessarily the PI.

## Operating Principles

- Keep research artifacts in normal files, not only in AI chat history.
- Sync before major edits and push back to Overleaf after manuscript changes.
- Snapshot before large rewrites, submissions, and revision rounds.
- Close AI sessions with `/close` so `_ai_log.md` and `_handover.html` stay current.
- Treat GitHub as the home for code repositories, while Overleaf remains the manuscript collaboration layer.
- Save web sources used in research outputs under `Literature/` and register them in `Literature/_retrieved_sources.md`.
- Make deliberate, scoped commits; do not use indiscriminate per-response auto-commit hooks.

## Requirements

This repository is built for Windows and PowerShell. It assumes:

- PowerShell
- Git
- GitHub CLI (`gh`) for GitHub publication
- Node.js for the `gemini` / `codex` / `supabase` CLIs
- MiKTeX/LaTeX for manuscript compilation
- Overleaf git access (a paid Overleaf feature) for manuscript sync
- Claude Code (required) and optionally Gemini / Codex for AI-assisted sessions

Accounts, paid plans, and API keys are listed in full in [`INSTALL.md`](INSTALL.md).
See [`known_issues.md`](known_issues.md) for the current machine-specific environment map.
