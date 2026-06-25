# INSTALL - Setting up AI_auto from scratch

This is the single source of truth for installing the infrastructure on a new
machine or for a new colleague. It is written for **two readers**:

- **A human owner**, who must create the accounts, pay for the paid plans, and
  complete the interactive logins. Read Parts A and B, then hand the machine to
  the agent.
- **A Claude (or other agent) doing the install**, who executes Part C top to
  bottom, stopping at every `HUMAN STEP` and asking the owner to act.

> The agent can automate everything **except** creating accounts, accepting paid
> plans, completing OAuth/browser logins, and generating API keys/tokens. Those
> are marked `HUMAN STEP`. Everything else the agent can do.

---

## Part A - Accounts and licenses you must bring

Create these **before** the install. The owner must do this; an agent cannot.

| Service | Needed for | Cost | What you end up with |
|---|---|---|---|
| **Anthropic / Claude** | Every AI session (`/work`, `/close`, `claude -p`). The core engine. | **Paid** - Claude Pro/Max subscription or API credits | An account you can `claude login` into |
| **Overleaf** | Manuscript sync (`helpi 2/3/4`) | **Paid** - git integration is a premium feature | An account + the `overleaf_session2` cookie |
| **GitHub** | Code repos (`helpi 23`), and the NoteTaker spool | Free | An account + `gh auth login` |
| **Google (Gemini)** | `helpi 25` forum; NoteTaker transcription | Free tier is enough | A Google account for `gemini` CLI login |
| **OpenAI (Codex)** | *Optional* - `helpi 24/25`, slides, one-pager when run with `-Agent codex` | **Paid** - ChatGPT Plus or API | An account you can `codex login` into |
| **Supabase** | *Only if installing NoteTaker* (voice notes) | Free tier is enough | A project + deployed edge function (see Part F) |

**Minimum to be useful:** Anthropic + Overleaf + GitHub. Gemini adds the forum.
Codex is optional. Supabase/NoteTaker is a separate, optional add-on.

---

## Part B - Software to install

| Software | Why | Install |
|---|---|---|
| **Git** | Everything | https://git-scm.com/download/win |
| **Claude Code CLI** | The agent | https://claude.ai/download |
| **Node.js** (LTS) | Provides `gemini`, `codex`, `supabase` CLIs via npm | https://nodejs.org |
| **GitHub CLI (`gh`)** | Code push / auth | https://cli.github.com |
| **MiKTeX** | LaTeX compile | https://miktex.org/download |
| **VS Code** | `helpi 5` opens projects here | https://code.visualstudio.com |
| **Strawberry Perl** | `latexdiff` in `submit.ps1` | https://strawberryperl.com |
| **Python / R** | Only if a project's `code/` needs them | as needed |

The three agent CLIs are npm packages:

```powershell
npm install -g @google/gemini-cli @openai/codex supabase
```

(Install only the ones you will use. `supabase` is needed only for NoteTaker.)

---

## Part C - Install runbook (agent-executable)

Run from PowerShell on Windows. Steps marked `HUMAN STEP` pause for the owner.

### 1. Clone the infrastructure
```powershell
cd "<your JR folder>"
git clone https://github.com/jepperich69/ai-infrastructure.git AI_auto
```

### 2. Run the setup wizard
```powershell
cd AI_auto
.\scripts\setup.ps1     # or, once helpi is on PATH: helpi 21
```
This writes `scripts\config.local.ps1` (publications root + git identity), adds
the `helpi` function to the PowerShell profile, registers the 4-hour auto-sync
task, and offers the Overleaf bulk-import. It does **not** touch any account.

### 3. `HUMAN STEP` - log in to the agent CLIs
The owner runs each of these once; they open a browser for OAuth:
```powershell
claude login        # Anthropic  (required)
gh auth login       # GitHub     (required)
gemini              # Google     (required for helpi 25; first run triggers login)
codex login         # OpenAI     (optional)
```
> Agent: you cannot complete these. Ask the owner to run them and confirm each
> succeeded before continuing.

### 4. `HUMAN STEP` - Overleaf cookie, then import projects
The owner logs into overleaf.com, opens `F12 -> Application -> Cookies`, and
copies the value of `overleaf_session2`. Then:
```powershell
.\scripts\fetch_overleaf_projects.ps1   # paste the cookie when prompted
.\scripts\link_projects.ps1             # clone + register everything
```

### 5. Copy the shared Claude config
The global `~/.claude/CLAUDE.md` and the skills/commands are not in this repo.
Copy them from the owner's existing machine or a colleague:
```powershell
# example: from a synced OneDrive or a shared location
Copy-Item "<source>\.claude\CLAUDE.md"  "$env:USERPROFILE\.claude\CLAUDE.md"
Copy-Item "<source>\.claude\skills"     "$env:USERPROFILE\.claude\" -Recurse
```

### 6. Verify (see Part E)

---

## Part D - Environment variables

**AI_auto core needs none.** The agent CLIs carry their own auth from the logins
in step 3.

Environment variables are required **only for NoteTaker** (Part F):

```powershell
setx GEMINI_API_KEY     "<google ai studio key>"
setx GITHUB_WRITE_PAT   "<fine-grained PAT, contents:write on notetaker-inbox>"
```
> Note: `setx` values appear in **new** shells only. Open a fresh terminal after
> setting them. Keep keys out of any committed file.

---

## Part E - Verification / smoke tests

```powershell
helpi 13                       # status dashboard - should list registered projects
helpi 3 <SomeProject>          # pull one Overleaf project - tests Overleaf auth
helpi 6 <SomeProject>          # compile LaTeX - tests MiKTeX
echo "hi" | gemini --model gemini-2.5-flash   # tests Gemini login (if used)
```
A clean `helpi 13` plus a successful `helpi 3` means the core is working.

---

## Part F - NoteTaker (optional voice-note pipeline)

NoteTaker is a **separate repo** with its own deep guide:
`NoteTaker/RECOVERY_GUIDE.md`. It roughly doubles the setup. Only do this if the
owner wants voice-note capture. Summary of what it additionally needs:

- A private GitHub repo `notetaker-inbox` with a release tagged `inbox-spool`.
- Two GitHub fine-grained PATs: a **read-only** one on the phone, a **write** one
  as a Supabase secret.
- A **Supabase** project with the `notetaker-proxy` edge function deployed and
  secrets set (`GITHUB_WRITE_PAT`, `GITHUB_OWNER`, `GITHUB_REPO`). The free tier
  auto-pauses after 7 days idle; the watcher pings it to stay alive (see
  `RECOVERY_GUIDE.md` section 2b).
- `GEMINI_API_KEY` and `GITHUB_WRITE_PAT` set as user env vars (Part D).
- The phone PWA deployed to GitHub Pages.
- The watcher running: `powershell -File NoteTaker\code\notetaker_watcher.ps1`
  (it auto-starts at logon via the Startup-folder launcher).

---

## What the agent can and cannot do - quick reference

**Agent can:** clone the repo, run `setup.ps1`, write `config.local.ps1`, install
CLIs via npm, set env vars, clone/register Overleaf projects (once given the
cookie), deploy the Supabase function via the `supabase` CLI, run all smoke tests.

**Agent cannot (HUMAN STEP):** create any account, accept/pay for a plan, complete
an OAuth/browser login, or generate an API key or PAT. Provide the agent with the
key *values* (or complete the logins yourself) and it handles the rest.
