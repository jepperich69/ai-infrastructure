# The Down-to-Earth AI Researcher

## A practical book about research life, AI, and the file infrastructure that makes the gains real

Draft date: 2026-04-19  
Working title: The Down-to-Earth AI Researcher  
Source base: `AI_auto/infrastructure_full.html`, current infrastructure v0.7, and selected literature listed in the references.

---

## Book Premise

This book is not about replacing the researcher. It is about the researcher who already lives inside a fragmented digital workplace: Overleaf, Git, Python, local folders, institutional cloud drives, confidential data areas, old submitted versions, reviewer letters, co-author edits, PDFs, BibTeX files, and notes spread across systems.

The central claim is simple:

> AI improves research work only when the researcher can give it controlled access to the right project state, at the right moment, with enough structure to act safely.

The uncomfortable truth is that most successful AI implementation is not prompt cleverness. It is control, structure, overview, and versioning of the file infrastructure across platforms. A reasonable working rule for the book is:

> Around 80 percent of successful AI adoption in research is infrastructure: knowing where the work is, what version is current, what must not be touched, what data is sensitive, what the last session achieved, and how to recover if something goes wrong.

The book should remain down-to-earth. The reader should recognize their own research life in it: deadlines, co-author emails, lost notes, local code that only runs on one machine, reviewer comments, half-finished revisions, and the moment where an AI assistant is powerful but dangerous because it sees too little, too much, or the wrong thing.

---

## Chapter 1 - The AI Productivity Law

### Thesis

AI will raise the level of research work because it increases the effective cognitive, editorial, and operational capacity available to a researcher. The best analogy is not magic intelligence. It is the arrival of a much larger calculator, spreadsheet, search engine, and research assistant at once. Researchers who learn to use it under disciplined conditions will eventually produce faster, cleaner, more ambitious work.

### Opening Argument

Academic research is a competitive environment. If a tool reliably improves speed, quality, search, drafting, coding, checking, or coordination, it does not remain optional for long. It becomes part of the baseline. The calculator changed quantitative work. Statistical software changed empirical work. Reference managers changed literature management. Git changed software collaboration. AI is entering the same category, but with a broader surface: text, code, literature, project memory, review response, figures, slides, and administrative packaging.

The key question is not whether AI can be useful. The evidence already says it can. The serious question is: under what conditions do the gains appear, and when do they disappear or become unsafe?

### Evidence

The strongest early evidence comes from controlled and field settings:

- Noy and Zhang (2023) ran a preregistered experiment on professional writing tasks. Access to ChatGPT reduced completion time by about 40 percent and increased output quality by about 18 percent in their setting.
- Brynjolfsson, Li, and Raymond (2023) studied a generative AI assistant in customer support using data from 5,179 agents. Productivity rose by about 14 percent on average, with larger effects for novice and lower-skilled workers.
- Peng et al. (2023) studied GitHub Copilot in a controlled programming task. Developers with Copilot completed the task 55.8 percent faster.
- Dell'Acqua et al. (2023) showed that AI can improve performance for tasks inside the model's competence frontier, but can hurt performance outside that frontier. This is the "jagged frontier" problem: AI is strong in some parts of knowledge work and unreliable in others.

The implication for researchers is practical. AI can save time and improve quality in tasks resembling writing, summarizing, coding, structuring, and procedural execution. But research also contains tasks where wrong confidence is costly: theoretical claims, causal identification, data interpretation, confidential data handling, legal/ethical compliance, and final submission checks.

### The AI Productivity Law

The book can state a modest theorem rather than a hype claim:

**The AI Productivity Law for Research Work**

For a research task `T`, AI assistance increases expected research productivity when five conditions hold:

1. The task has a clear success criterion.
2. The AI has access to the relevant non-sensitive context.
3. The researcher can verify the output at lower cost than producing it from scratch.
4. The file infrastructure supports rollback, comparison, and version control.
5. The task is inside the model's practical competence frontier.

Under these conditions, the expected gain is:

`productivity gain = saved search/drafting/execution time + quality improvement - verification cost - error recovery cost - coordination cost`

This law is deliberately conditional. It does not say AI always helps. It says AI helps when the cost of giving context, checking output, and recovering from mistakes is lower than the work saved.

### Why Research Is Especially Exposed

Research work has high leverage and high pressure. A better abstract, cleaner proof, faster revision, stronger response letter, or more complete submission package can matter. Competition means the field will absorb tools that work. The frontier will move from "using AI" to "using AI with controlled project memory, versioning, and reproducible infrastructure."

### Chapter Ending

The first lesson is not "learn prompts." It is: reduce the cost of context, verification, and rollback. That is where the durable productivity gain comes from.

---

## Chapter 2 - The Modern Researcher's Mess

### Thesis

The modern researcher does not lack tools. The modern researcher has too many disconnected tools. AI exposes this problem because an assistant cannot act reliably when the project state is scattered, implicit, stale, or unsafe to access.

### The Real Research Workplace

A typical paper project may involve:

- A manuscript in Overleaf.
- Code in Python, R, Julia, MATLAB, Stata, or a local notebook.
- Data in institutional storage, OneDrive, Dropbox, SharePoint, a local encrypted drive, or a lab server.
- Sensitive data in a separate restricted folder.
- Bibliography in BibTeX, Zotero, Mendeley, or copied from old papers.
- Figures generated locally and uploaded manually.
- Reviewer comments in PDF, Word, email, or a journal portal.
- A submitted version that must remain frozen.
- A revised version that evolves daily.
- A response letter that must stay aligned with the manuscript.
- Notes in email, chat, NotebookLM, Word, text files, or memory.

This is normal research life. It is also exactly the environment in which AI assistants fail if they are given vague instructions and no stable file infrastructure.

### The Backup Problem

Many researchers have less backup than they think. A manuscript may be "safe" in Overleaf, but that does not mean the complete research object is safe. The code may live locally. The figures may be generated by scripts that depend on local paths. The data may not be reproducible from the files shared with co-authors. The comments explaining why a section changed may exist only in chat history.

Wilson et al. (2017) argue that researchers need basic computing practices as a kind of laboratory hygiene: organized data, documented steps, version control, and reproducible workflows. Wilkinson et al. (2016) make a related point from the data side through the FAIR principles: research objects should be findable, accessible, interoperable, and reusable.

AI raises the bar. If a human struggles to reconstruct a project, an AI assistant will hallucinate the missing structure or act on the wrong version.

### Local Detailed Project Information

Most research projects need local project memory:

- What is the paper about?
- Who are the co-authors?
- What stage is the paper in?
- Which sections are frozen?
- Which version was submitted?
- Which theorem notation is fragile?
- Which files are generated and should not be hand-edited?
- Where does the code run?
- What data must never be exposed to an API?
- What did the last AI session do?
- What are the next steps?

The infrastructure described in `infrastructure_full.html` solves this by keeping a per-project brief (`.claude/CLAUDE.md`), a session log (`_ai_log.md`), a generated handover (`_handover.html` and `_handover.json`), Git history, and project-specific source folders.

### Chapter Ending

Before discussing agents, prompts, or automation, the book must make the reader feel the central pain: research work is already fragmented. AI does not remove that fragmentation. It amplifies the cost of not controlling it.

---

## Chapter 3 - File Infrastructure Before AI Infrastructure

### Thesis

There are two broad ways to implement AI research workflows: API-based systems and local/license-based agent systems. API systems can be powerful, but for academic research they create practical problems around sandboxing, cost, data protection, and integration with real files. Local agent systems are not automatically safe, but they make it easier to build a controlled research workspace.

### Two Approaches

**API-based solution**

An API workflow sends selected content to a model provider and receives output. It can be embedded in scripts, web apps, notebooks, and custom tools.

Advantages:

- Highly programmable.
- Easy to integrate into automated pipelines.
- Good for batch tasks.
- Model choice can be explicit.
- Useful for production systems.

Disadvantages for the individual researcher:

- Sandboxing is difficult because every script decides what to send.
- Costs can be hard to predict when context grows.
- Sensitive data handling requires strict discipline and institutional approval.
- The model often sees extracted snippets rather than the actual project state.
- Logging, provenance, and reproducibility must be built separately.
- Authentication keys become another security object.
- Co-author workflows are harder because each person may run a different local script state.

**Local/license-based agent solution**

A local agent operates in a project folder, reads files under configured permissions, edits local files, and uses Git or other versioning to track changes.

Advantages:

- The file boundary is concrete.
- The agent can inspect real project files.
- Rollback and diffs are natural through Git.
- The workflow can be agent-agnostic if the shared project files are the source of truth.
- Sensitive data can be excluded structurally by deny rules and folder conventions.
- The researcher can work with the same project in Overleaf, VS Code, Git, and the agent.

Disadvantages:

- Initial setup is heavier.
- Local machine configuration matters.
- Different agents have different capabilities and permission models.
- A careless local agent can still damage files if versioning and sandboxing are weak.
- The system depends on disciplined folder conventions.

### The 80 Percent Claim

The uncomfortable truth is that most successful AI implementation in research is file infrastructure:

- Control: the agent sees what it should see and cannot see what it should not see.
- Structure: every project has predictable folders and metadata.
- Overview: the researcher and agent can reconstruct project state quickly.
- Versioning: every meaningful change can be compared, restored, or tagged.
- Synchronization: cloud collaboration layers and local work do not drift silently.
- Handover: the next human or agent can continue without rediscovering everything.

Prompting matters, but prompting cannot compensate for stale files, missing context, untracked edits, or confidential data leakage.

### The Running Example

The book's running example is a Windows-first research infrastructure:

- `Overleaf_source/` contains the manuscript cloned from Overleaf.
- `code/` contains research code under local Git.
- `_ai_log.md` records session history.
- `.claude/CLAUDE.md` contains permanent project context.
- `_handover.html` and `_handover.json` compile the current project state.
- `_feeders/` stores compact digests from related projects.
- `helpi` commands perform sync, push, compile, snapshot, submit, restore, and setup operations.

This is not the only possible implementation. It is the book's concrete example because a book about research life needs a real workflow, not a diagram that never meets a deadline.

---

## Chapter 4 - Pull, Push, and the Research Safety Net

### Thesis

AI becomes useful in paper writing when it can operate on the same manuscript the researcher and co-authors use. For many researchers, that means Overleaf plus Git. Pull and push are not technical decorations. They are the bridge between collaborative writing and local AI work.

### Overleaf as Collaboration Layer

Overleaf is a natural collaboration surface for LaTeX papers. Co-authors can edit in the browser, see compiled PDFs, and comment without installing a local toolchain. But Overleaf is not the full research project. It is primarily the manuscript layer.

The Overleaf Git integration allows an Overleaf project to be treated as a Git remote. According to Overleaf's documentation, the researcher can clone the project locally, pull updates from Overleaf, and push local changes back.

### Git as the Local Truth Layer

Git gives the researcher:

- A local copy.
- A change history.
- Diffs before and after AI edits.
- Tags for named milestones.
- Branch or snapshot patterns for risky rewrites.
- Recovery when an edit goes wrong.

The infrastructure example uses:

- automatic or manual pull from Overleaf,
- manual push to Overleaf after local changes,
- pre-push safety pulls to catch co-author updates,
- conflict resolution when local and Overleaf edits touch the same lines,
- snapshots as Git tags over the full `Overleaf_source/` state.

### Pull Before Work

A safe AI session starts by pulling current work from Overleaf. Otherwise, the agent may edit stale text and overwrite a co-author's changes. The local agent should work on the newest available manuscript state.

### Push After Verification

The agent should not blindly push. The researcher should inspect the diff, compile, and decide whether the changes belong in the shared Overleaf project. Push is a publication of local edits back into the co-author workspace.

### Why This Matters for AI

AI often makes broad edits. It may rename a term, restructure a paragraph, or touch a response letter and manuscript together. Without Git, these changes are hard to review. With Git, AI work becomes inspectable:

- What changed?
- Which file changed?
- Did the agent touch generated files?
- Did it alter bibliography or figures?
- Can we restore one file?
- Can we compare the current manuscript with a tagged snapshot?

### Chapter Ending

The practical rule is: do not invite AI into a manuscript that has no local version history. The first AI safety feature is not a model setting. It is a clean Git diff.

---

## Chapter 5 - Handover, Logging, and Agent-Agnostic Memory

### Thesis

AI research work fails when every session starts cold. A project needs durable memory that is not trapped inside one chat, one model, or one vendor. The handover and logging infrastructure solves this by making project memory file-based and agent-agnostic.

### The Session Log

The session log is the research notebook for AI-assisted work. In the running infrastructure it is `_ai_log.md`. Each session records:

- date,
- agent,
- goal,
- files touched,
- outcome,
- next steps,
- Git reference when available.

This creates a chronological memory of what happened. It is useful for the researcher, for future agents, and for co-authors who need to understand why a file changed.

### The Permanent Project Brief

The per-project brief (`.claude/CLAUDE.md`) is not a diary. It is stable context:

- paper description,
- co-authors,
- venue,
- current phase,
- key files,
- standing constraints,
- what not to touch.

This prevents the agent from rediscovering basic facts every session.

### The Handover Document

The handover document compiles the current project state from the log and project metadata. In the running example, `generate_handover.ps1` emits:

- `_handover.html` for human reading,
- `_handover.json` for machine reading,
- `AGENTS.md` for Codex and other agents.

The important design choice is that `_ai_log.md` remains the source of truth. The handover is compiled from it. This reduces drift between "what happened" and "what the agent thinks happened."

### Agent-Agnostic Design

Agent-agnostic memory means:

- Claude Code and Codex read the same project files.
- Both can write to the same session log format.
- Both can reconstruct the last session from the same handover.
- Switching agents does not require manual retelling.
- The project state belongs to the researcher, not to a chat interface.

This is a core principle of the book. The right abstraction is not "my conversation with model X." It is "my project has a documented state that any approved tool can read."

### Chapter Ending

Handover is not bureaucracy. It is how a researcher avoids paying the cold-start cost every morning.

---

## Chapter 6 - Families, Feeders, and Why This Is Not Just RAG

### Thesis

Related research projects should be connected, but not by dumping every file into one vector database. A family/feeder infrastructure gives the current project compact, curated, version-aware knowledge from related projects while preserving project boundaries.

### What a Feeder Is

A feeder project is a related project that contributes knowledge to the current project. It may contain:

- a prior theorem,
- a modeling convention,
- a dataset history,
- a reviewer response strategy,
- a proof structure,
- a notation choice,
- a related paper's abstract and contribution,
- session history that explains why a decision was made.

In the running infrastructure, `/family` registers feeder projects. It reads their session log, handover document, and manuscript abstract, then writes compact digests to `_feeders/` and registers them in `_feeders.json`.

### How It Differs from Pure RAG

Retrieval-augmented generation, introduced by Lewis et al. (2020), combines a language model with retrieved external knowledge. RAG is powerful when the problem is finding relevant chunks in a large corpus. But a researcher's project network has different needs.

A pure RAG system often focuses on:

- chunking documents,
- embedding chunks,
- retrieving semantically similar text,
- injecting retrieved chunks into a prompt.

A feeder system focuses on:

- project identity,
- provenance,
- current phase,
- session history,
- deltas since last ingestion,
- compact structured summaries,
- boundaries between active projects.

### Why Feeder Infrastructure Can Be Better for Research Projects

For a research family, the goal is not only semantic retrieval. It is continuity.

A feeder digest can answer:

- What was the paper actually about?
- What did the last session change?
- Which version is frozen?
- Which notation should not be imported blindly?
- Which result is relevant and under what assumptions?
- Has the feeder changed since the current project last read it?

This is more structured than "retrieve the nearest paragraph." It gives the agent a small, stable memory object with provenance and update logic.

### Many-to-Many Research

The infrastructure guide describes each feeder as a full two-layer project:

- file layer: sync, push, compile, handover,
- AI layer: work, close, snapshot, family.

This matters because a feeder may itself have feeders. Research knowledge is a network, not a folder dump.

### Chapter Ending

RAG retrieves text. Feeder infrastructure transfers project memory. The distinction matters because research projects are living objects with history, constraints, and status.

---

## Chapter 7 - Prompting: What To Do and What Not To Do

### Thesis

Prompting is important, but it is not a substitute for context, verification, and file discipline. Good prompting turns a controlled infrastructure into productive work. Bad prompting asks the model to guess the project.

### Good Prompting

A good research prompt does five things:

1. States the task.
2. Names the relevant files or project area.
3. Defines the output format.
4. States constraints and what not to change.
5. Requires verification.

Examples:

```text
Review section 3 of main.tex for logical flow only. Do not rewrite notation,
do not edit the theorem statements, and do not touch the bibliography. Return
findings first with file/line references, then propose minimal edits.
```

```text
Draft responses to reviewer comments in Response_R1.tex by filling only the
\TODO{} slots. Use the current manuscript for context. Do not invent new
experiments. Mark any response that needs human factual confirmation.
```

```text
Compare snapshot-v2 with HEAD and identify changes that could affect the
submitted claims. Focus on theorem assumptions, result interpretation, and
figure captions.
```

### Bad Prompting

Bad prompts are vague, overbroad, or unsafe:

- "Improve the paper."
- "Make it more Nature-like."
- "Fix all reviewer comments."
- "Rewrite everything."
- "Use the data and find something interesting."
- "Push when done."
- "Make the argument stronger" without specifying which claims are allowed to change.

These prompts invite the model to optimize style over truth, change too much, or invent missing context.

### The Prompting Ladder

The book can introduce a practical ladder:

1. Ask for diagnosis before edits.
2. Ask for minimal edits before rewrites.
3. Ask for section-level rewrites before paper-wide rewrites.
4. Ask for diff-aware edits before accepting changes.
5. Ask for final checks only after compilation and human review.

### Prompting for Research Integrity

Research prompts should include integrity constraints:

- Do not invent citations.
- Do not claim new results.
- Do not modify numerical results without checking source code.
- Do not access sensitive data.
- Do not change submitted versions.
- Flag uncertainty.
- Separate editorial suggestions from scientific claims.

### Chapter Ending

Prompting is steering. Infrastructure is the road. Without the road, steering is mostly theater.

---

## Chapter 8 - The Natural Stages of Paper Writing

### Thesis

AI assistance should follow the paper lifecycle. The useful workflow is not "AI writes paper." It is: AI helps the researcher move through structured stages with better memory, review, versioning, and packaging.

### Stage 1 - Project Creation

Create the project folder, connect Overleaf if relevant, initialize Git, create the session log, and write the project brief.

In the running example:

- `helpi 1` scaffolds the project.
- `Overleaf_source/` holds the manuscript.
- `code/` holds analysis code.
- `_ai_log.md` starts the session record.
- `.claude/CLAUDE.md` stores stable project context.

### Stage 2 - Internal Review

Internal review is where AI is already useful:

- argument map,
- contribution clarity,
- section diagnosis,
- notation consistency,
- missing assumptions,
- abstract and title variants,
- figure-caption alignment,
- theorem/proof dependency checks,
- "what would a skeptical reviewer ask?"

The agent should first produce findings, not edits. Findings can then be converted into scoped edits.

### Stage 3 - Literature and Positioning

AI can help identify how the paper positions itself, but citations must be verified. The right workflow is:

1. Use literature tools and databases to identify candidates.
2. Use AI to summarize and compare.
3. Verify claims against source papers.
4. Add citations deliberately.
5. Keep a note of why each citation is used.

### Stage 4 - Drafting and Revision

AI can improve local text:

- paragraph structure,
- transitions,
- definitions,
- abstract compression,
- introduction logic,
- response to co-author comments,
- related-work flow.

But AI should not silently change:

- mathematical assumptions,
- empirical results,
- table values,
- figure interpretations,
- claims about novelty,
- legal or ethical statements.

### Stage 5 - External Review

Before submission, run structured external-style reviews:

- contribution review,
- methods review,
- robustness review,
- notation review,
- reviewer-2 stress test,
- journal-fit review,
- reproducibility review,
- abstract-only review.

Each review should end in a prioritized action list.

### Stage 6 - Submission Package

The submission package is an ideal automation target because it is procedural and error-prone:

- compile final PDF,
- inline bibliography if required,
- prepare blind manuscript if required,
- prepare cover letter,
- prepare highlights,
- prepare author statement,
- generate diff from previous version,
- assemble zip,
- name files consistently.

In the running infrastructure, `submit.ps1` and `/submit` assemble a journal-ready package in `_submissions/YYYY-MM-DD_journal/`.

### Stage 7 - Reviewer Response

Reviewer response needs alignment:

- every comment gets a response,
- every promised change appears in the manuscript,
- response tone is professional,
- line numbers and section references are correct,
- repeated criticisms are addressed at the root,
- impossible requests are answered clearly.

The running example uses a two-step reviewer loop:

- scaffold the response letter with numbered TODO slots,
- draft the TODO slots using the manuscript context,
- push back to Overleaf after review.

### Stage 8 - Slides, CV, and Afterlife

After the paper, the same infrastructure supports:

- conference slides,
- seminar slides,
- public-facing slides,
- CV updates,
- publication lists,
- grant text,
- project summaries,
- handover to students or collaborators.

The book should treat these as part of research life, not side tasks. A paper creates reusable intellectual assets. AI can help reuse them if the project is structured.

---

## Chapter 9 - Setup and Installation

### Thesis

The setup chapter must be honest: infrastructure takes work. But the work pays back because it lowers the cost of every later AI session, every paper revision, every co-author handoff, and every recovery from mistakes.

### Requirements

The running example assumes:

- Windows machine,
- PowerShell,
- Git,
- Overleaf Git integration,
- MiKTeX for local LaTeX compilation,
- VS Code with LaTeX Workshop,
- local AI agent tooling,
- project root under a known publications folder,
- configuration in `config.ps1`.

### Two Installation Scenarios

**Restore on a replacement machine**

Use the restore flow when the researcher already has projects and needs to rebuild the local environment. The infrastructure guide describes `helpi 20` / `restore.ps1` as checking Claude CLI, Git, MiKTeX, VS Code, PowerShell profile, scheduled tasks, and project registry.

**New colleague or new user**

Use the setup wizard for a new user. The infrastructure guide describes `helpi 21` / `setup.ps1` as guiding through root paths, Git identity, tool detection, configuration, PowerShell profile setup, scheduled sync, and optional Overleaf import.

### Sensitive Data

The setup chapter should be explicit:

- Sensitive data should live outside ordinary AI-readable project folders.
- Global and per-project deny rules should block agent access.
- Synthetic data can be generated for testing.
- The workflow should make the safe path easy and the unsafe path difficult.

### Backups and Recovery

The book should recommend:

- local Git for each project,
- Overleaf remote for manuscript collaboration,
- cloud backup for non-sensitive project files,
- restricted storage for sensitive data,
- named snapshots before major rewrites,
- handover regeneration after sessions,
- periodic status dashboard checks.

### Chapter Ending

Setup is not a one-time technical chore. It is the foundation for a research practice where AI can act without turning the project into an untraceable mess.

---

## Chapter 10 - CVs, Profiles, and the Researcher's Public Record

### Thesis

AI infrastructure should eventually connect to the researcher's public record: CV, publication list, project summaries, talks, grant bios, and impact statements. These documents are repetitive, high-stakes, and often out of date.

### Why CV Creation Belongs in the Same Book

The CV is not separate from the project infrastructure. It is downstream of it. If each project knows:

- title,
- authors,
- venue,
- status,
- abstract,
- key contribution,
- publication date,
- DOI,
- code/data availability,
- related talks,

then CV generation becomes a structured transformation rather than a manual memory exercise.

### Practical Uses

AI can help produce:

- academic CV entries,
- short bios,
- grant biosketches,
- publication summaries,
- selected-publication narratives,
- teaching and supervision summaries,
- annual-report text,
- website updates,
- ORCID/Google Scholar cross-check lists.

### Guardrails

The public record must be accurate. AI should not invent acceptance status, metrics, DOI links, impact claims, or co-author order. CV generation should use project metadata and require human confirmation for all status-sensitive claims.

### Chapter Ending

The same infrastructure that helps write a paper can help preserve the researcher's career memory. But the rule is the same: structured source of truth first, AI generation second.

---

## Proposed Book Architecture

### Part I - Why AI Changes Research Work

1. The AI Productivity Law
2. The Modern Researcher's Mess

### Part II - The Infrastructure Layer

3. File Infrastructure Before AI Infrastructure
4. Pull, Push, and the Research Safety Net
5. Handover, Logging, and Agent-Agnostic Memory
6. Families, Feeders, and Why This Is Not Just RAG

### Part III - The Working Researcher

7. Prompting: What To Do and What Not To Do
8. The Natural Stages of Paper Writing
9. Setup and Installation
10. CVs, Profiles, and the Researcher's Public Record

### Possible Appendices

- Appendix A: Command reference for the running infrastructure.
- Appendix B: Example project folder.
- Appendix C: Example session log.
- Appendix D: Example handover.
- Appendix E: Example reviewer response workflow.
- Appendix F: Sensitive data checklist.
- Appendix G: Prompt library.
- Appendix H: Troubleshooting Git/Overleaf conflicts.

---

## Key Concepts to Develop Throughout the Book

### The Research Object

A paper is not only `main.tex`. It is a research object:

- manuscript,
- bibliography,
- figures,
- code,
- data references,
- submission documents,
- review history,
- session memory,
- project constraints.

AI needs the research object, not just a prompt.

### The Context Cost

Every AI session has a context cost. The researcher pays this cost by explaining the project, locating files, describing constraints, and checking what changed. Good infrastructure lowers the context cost.

### The Verification Cost

AI output is useful only when verification is cheaper than doing the work manually. This is why AI is excellent for drafting a response scaffold and dangerous for unverified empirical claims.

### The Recovery Cost

If an AI edit is wrong, how expensive is recovery? With Git tags and diffs, recovery can be minutes. Without versioning, recovery can be an afternoon of anxiety.

### The Competence Frontier

The jagged frontier from Dell'Acqua et al. should become a recurring warning. AI may be excellent at rewriting a paragraph and poor at judging whether a new theorem assumption is valid. The researcher must know which tasks are inside and outside the tool's frontier.

---

## Working Reference List

Brynjolfsson, E., Li, D., and Raymond, L. R. (2023). "Generative AI at Work." NBER Working Paper 31161. https://www.nber.org/papers/w31161

Dell'Acqua, F., McFowland III, E., Mollick, E. R., Lifshitz-Assaf, H., Kellogg, K., Rajendran, S., Krayer, L., Candelon, F., and Lakhani, K. R. (2023). "Navigating the Jagged Technological Frontier: Field Experimental Evidence of the Effects of AI on Knowledge Worker Productivity and Quality." SSRN. https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4573321

Lewis, P., Perez, E., Piktus, A., Petroni, F., Karpukhin, V., Goyal, N., Kuttler, H., Lewis, M., Yih, W., Rocktaschel, T., Riedel, S., and Kiela, D. (2020). "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks." NeurIPS. https://nlp.cs.ucl.ac.uk/publications/2020-05-retrieval-augmented-generation-for-knowledge-intensive-nlp-tasks/

Noy, S., and Zhang, W. (2023). "Experimental evidence on the productivity effects of generative artificial intelligence." Science, 381(6654), 187-192. https://doi.org/10.1126/science.adh2586

Overleaf. "Git integration." Overleaf Documentation. https://docs.overleaf.com/integrations-and-add-ons/git-integration-and-github-synchronization/git-integration

Peng, S., Kalliamvakou, E., Cihon, P., and Demirer, M. (2023). "The Impact of AI on Developer Productivity: Evidence from GitHub Copilot." arXiv:2302.06590. https://www.microsoft.com/en-us/research/publication/the-impact-of-ai-on-developer-productivity-evidence-from-github-copilot/

Wilkinson, M. D., Dumontier, M., Aalbersberg, I. J., et al. (2016). "The FAIR Guiding Principles for scientific data management and stewardship." Scientific Data, 3, 160018. https://doi.org/10.1038/sdata.2016.18

Wilson, G., Bryan, J., Cranston, K., Kitzes, J., Nederbragt, L., and Teal, T. K. (2017). "Good enough practices in scientific computing." PLOS Computational Biology, 13(6), e1005510. https://doi.org/10.1371/journal.pcbi.1005510

---

## Notes for the Next Draft

The next pass should do three things:

1. Turn Chapter 1 into a polished opening essay with the productivity theorem as the intellectual hook.
2. Convert Chapters 3-6 into a concrete narrative around one fictional paper project, showing the researcher pulling from Overleaf, working locally, logging, closing, and linking feeders.
3. Add boxed checklists at the end of each chapter: "What to implement this week", "What to avoid", and "What to automate later."

