# AI_auto

AI_auto is a local, file-based infrastructure for running long-lived projects with AI agents. It keeps project context, decisions, source material, code, logs, and handovers in ordinary files so work survives across sessions, agents, and machines.

The basic idea is simple:

- Every project gets a durable brief, session log, handover, and agent instructions.
- Claude Code, Codex, and Gemini read the same context and continue one another's work.
- PowerShell scripts automate project creation, status, backups, documentation, and tool setup.
- Research projects add a mature paper workflow: Overleaf synchronization, LaTeX compilation, literature tracking, mathematical verification, reviewer responses, and submission packaging.

The full reference guide is [`infrastructure.html`](infrastructure.html). The short generated guide is [`infrastructure_summary.html`](infrastructure_summary.html), and the printable full guide is [`infrastructure_full.pdf`](infrastructure_full.pdf).

## What This Solves

Serious projects are split across files, repositories, notes, chat windows, specialist tools, and collaborators' machines. AI agents add another failure mode: each session can start without the decisions and constraints established earlier.

AI_auto adds a common project backbone:

- AI session logs in `_ai_log.md`.
- Permanent project briefs in `.claude/CLAUDE.md` and generated `AGENTS.md` files.
- Generated handovers for switching agents or resuming after a long break.
- Cross-project feeder links so one project can inherit compact context from another.
- A shared skill layer for referee review, mathematical verification, pre-submission grilling, diagnosis, TDD, prototyping, and multi-agent pipelines.
- Project-scoped integrations for specialized tools such as QGIS, plus a generated software inventory in [`TOOLS.md`](TOOLS.md).
- A NoteTaker bridge that moves dictated notes from a phone through a serverless spool into the local workflow.
- For research: git-backed manuscripts and code, Overleaf sync, snapshots, reviewer workflows, and submission packages.

Research is the most developed application, but it is not a boundary: `helpi 27` creates the same continuity layer for software, infrastructure, teaching, administration, and other non-paper projects. The system is intentionally local-first and coordinates existing tools rather than replacing them.

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

Start any general project:

```powershell
helpi 27 MyProject              # add brief, log, handover, source register, and agent sandbox
cd <project-folder>
claude                          # or codex / gemini
/work                           # load context and agree the session goal
/close                          # record outcome and regenerate the handover
```

Research-project commands:

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

## Standard Project Folders

A general project needs only the continuity layer:

```text
MyProject/
  Literature/               # retrieved sources and source register
  _ai_log.md                # durable cross-agent session log
  _handover.html            # generated current-state handover
  .claude/CLAUDE.md         # permanent project brief
  AGENTS.md                  # generated instructions for Codex and Gemini
```

A research project extends it with manuscript and analysis infrastructure:

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

Research folders use `Pub_`, `Pro_`, or `PhD_` prefixes. `Pub_Topic_Driver` names the person responsible for keeping a paper moving, not necessarily the PI. General projects have no required prefix.

## Operating Principles

- Keep project artifacts and decisions in normal files, not only in AI chat history.
- Close AI sessions with `/close` so `_ai_log.md` and `_handover.html` stay current.
- Use the same brief, log, and handover across agents.
- Make deliberate, scoped commits; do not use indiscriminate per-response auto-commit hooks.
- For research projects, sync before manuscript edits, snapshot before major revisions, and keep retrieved sources registered under `Literature/`.

## Requirements

This repository is built for Windows and PowerShell. It assumes:

- PowerShell
- Git
- GitHub CLI (`gh`) for GitHub publication
- Node.js for the `gemini` / `codex` / `supabase` CLIs
- Claude Code (required) and optionally Gemini / Codex for AI-assisted sessions

Research workflows additionally use MiKTeX/LaTeX and, when required, paid Overleaf git access.

Accounts, paid plans, and API keys are listed in full in [`INSTALL.md`](INSTALL.md).
See [`known_issues.md`](known_issues.md) for the current machine-specific environment map.
