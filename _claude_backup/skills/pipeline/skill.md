---
description: Multi-agent pipeline -- run any task through a configurable sequence of AI agents (Claude, Gemini, Codex) as a background job. Default order: claude -> gemini -> codex -> claude. Closes like a full session: updates _ai_log.md and regenerates handover.
argument-hint: '"Critique the methodology in this draft" --agents gemini,claude,codex,claude'
---

# /pipeline

Run a task through multiple AI agents sequentially in the background. Each agent receives the full task plus all prior agents' output. The final agent synthesises. When done: `final.md` opens, `_ai_log.md` is updated, and the handover is regenerated -- exactly as if you had run `/close`.

## Usage

```
/pipeline "task" --project Pub_MyPaper
/pipeline "Critique the methodology in this draft" --agents gemini,claude,codex,claude --project Pub_MyPaper
/pipeline "Refactor the estimation module" --project "C:\full\path\to\project"
/pipeline "task" --agents claude,gemini,claude
/pipeline --template final-pass --project Pub_MyPaper
/pipeline --template repro-audit --project Pub_MyPaper
/pipeline --template math-verify --project Pub_MyPaper
```

**Default agent order:** `claude,gemini,codex,claude`

Valid agent names: `claude`, `gemini`, `codex` (repeatable, any order, any length)

`--project` accepts a short name (e.g. `Pub_MyPaper`) resolved under `Publikationer\`, or a full path. Without it, the pipeline still runs but skips the log/handover closure.

`--template` loads a built-in task protocol by short name (see Templates section). Mutually exclusive with a quoted task string.

---

## Steps when invoked

### 0. If no arguments given, show help and stop

If the user typed `/pipeline` with no task description, respond with exactly this and do nothing else:

---
**`/pipeline`** -- multi-agent background job (Claude -> Gemini -> Codex -> Claude)

**Usage:** `/pipeline "task description"` `[--project Name]` `[--agents a,b,c,d]` `[--out path]`

**Example:**
```
/pipeline "Critique the methodology in this draft" --agents gemini,claude,codex,claude
```

**Agent options:** `claude`, `gemini`, `codex` -- any order, any length, repeatable
**Default order:** `claude -> gemini -> codex -> claude`
**Output:** timestamped folder in `AI_auto\_pipelines\` -- `final.md` opens when done
**With `--project`:** also updates `_ai_log.md` and regenerates the handover on finish

**Built-in templates** (use `--template <name>` instead of a quoted task):

| Name | Protocol |
|---|---|
| `final-pass` | Manuscript Final Pass Auditor -- 7-pillar quality check for near-final papers |
| `repro-audit` | Reproduction Suite Auditor -- 5-check code/artifact fidelity verifier |
| `math-verify` | Mathematical & Theorem Verifier -- 4-pillar formal proof and notation auditor |
| `lit-review` | Literature Review & Citation Builder -- 5-phase systematic search, gap detection, and comparison matrix |

---

### 1. Parse arguments

From the text after `/pipeline`:
- **task**: the quoted task description (required unless `--template` is used)
- **--template**: short name of a built-in protocol (`final-pass`, `repro-audit`, `math-verify`, `lit-review`). Mutually exclusive with a quoted task. Look up the full template body from the Templates section below and use it as the task string.
- **--project**: project short name or full path (optional but recommended)
- **--agents**: comma-separated agent names (optional, default: `claude,gemini,codex,claude`)
- **--out**: output directory path (optional)

**Resolve `--project` to a full path:**
- If it starts with a drive letter, use as-is
- Otherwise prepend: `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer\`
- Extract the project name (folder leaf) for use in helpi calls

If no `--project` given, set `$ProjectPath = ''` and `$ProjectName = ''`.

### 2. Create output directory

If `--out` not given:
- If `--project` was given: use `{ProjectPath}\_pipelines\YYYY-MM-DD_HH-MM-SS`
- Otherwise fall back to: `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\_pipelines\YYYY-MM-DD_HH-MM-SS`

Use the actual current timestamp (format: `2026-05-21_14-30-00`).

Create the directory now with PowerShell before writing the script.

### 3. Write run_pipeline.ps1 to the output directory

Write a fully self-contained PowerShell script -- all runtime values baked in as literals. Use the template below, substituting:
- `{TASK}` -> the actual task string (use a here-string `@'...'@` to avoid escaping issues)
- `{OUTPUT_DIR}` -> the actual output directory path
- `{AGENTS_ARRAY}` -> e.g. `@('claude', 'gemini', 'codex', 'claude')`
- `{PROJECT_PATH}` -> full resolved project path, or empty string `''`
- `{PROJECT_NAME}` -> folder leaf name, or empty string `''`

**CRITICAL PS1 rules:**
- Use only straight ASCII apostrophes and dashes -- no curly quotes, no em-dashes
- Use `[System.IO.File]::WriteAllText(path, content, encoding)` for file writes
- Check for and fix curly quotes after writing (step 4)

**Template:**

```powershell
$Task = @'
{TASK}
'@
$OutputDir   = '{OUTPUT_DIR}'
$Agents      = {AGENTS_ARRAY}
$ProjectPath = '{PROJECT_PATH}'
$ProjectName = '{PROJECT_NAME}'

$analysisDoc = ''
$startTime   = Get-Date

for ($i = 0; $i -lt $Agents.Count; $i++) {
    $agent    = $Agents[$i]
    $roundNum = $i + 1
    $N        = $Agents.Count
    $isFirst  = ($i -eq 0)
    $isLast   = ($i -eq ($Agents.Count - 1))

    if ($isFirst) {
        $roleInstr = "Produce a thorough, well-structured analysis. Be comprehensive -- this is the foundation. At the end of your response, append a section headed exactly `=== HANDOVER ===` followed by a tight bullet-point summary (max 300 words) of your key findings for the next agent."
        $prompt = "You are Agent $roundNum of $N in a multi-agent analysis pipeline.`n`nTASK:`n$Task`n`nINSTRUCTION:`n$roleInstr"
    } elseif ($isLast) {
        $roleInstr = "Synthesise the analysis document below into a single, coherent, high-quality final deliverable. Resolve any [DISAGREEMENT: ...] markers -- state the correct conclusion and why. Produce a clean, standalone document with no duplication."
        $prompt = "You are the FINAL agent ($roundNum of $N) in a multi-agent analysis pipeline.`n`nTASK:`n$Task`n`n=== ANALYSIS DOCUMENT ===`n$analysisDoc`n=== END ===`n`nINSTRUCTION:`n$roleInstr"
    } else {
        $roleInstr = "Review the current analysis document below. Your output must contain ONLY: (1) findings not yet documented -- add them under the relevant section heading; (2) explicit disagreements with existing findings, written as [DISAGREEMENT: <point>]. Do NOT restate or summarise anything already in the document. If you have nothing new to add on a section, omit it entirely. Shorter is better. At the end of your response, append a section headed exactly `=== HANDOVER ===` followed by a tight bullet-point summary (max 300 words) of your additions and any disagreements for the next agent."
        $prompt = "You are Agent $roundNum of $N in a multi-agent analysis pipeline.`n`nTASK:`n$Task`n`n=== CURRENT ANALYSIS DOCUMENT ===`n$analysisDoc`n=== END ===`n`nINSTRUCTION:`n$roleInstr"
    }

    $promptFile = Join-Path $OutputDir "prompt_r${roundNum}.txt"
    [System.IO.File]::WriteAllText($promptFile, $prompt, [System.Text.Encoding]::UTF8)

    $roundFile = Join-Path $OutputDir "round${roundNum}_${agent}.md"
    try {
        $output = switch ($agent) {
            'claude' { if ($ProjectPath) { Get-Content $promptFile -Raw | & claude --add-dir $ProjectPath --dangerously-skip-permissions --print --bare 2>&1 } else { Get-Content $promptFile -Raw | & claude --dangerously-skip-permissions --print --bare 2>&1 } }
            'gemini' { Get-Content $promptFile -Raw | & gemini --yolo --approval-mode yolo --skip-trust --output-format text 2>&1 }
            'codex'  {
                $cj = Start-Job -ScriptBlock {
                    param($pf)
                    Get-Content -LiteralPath $pf -Raw |
                        & "C:\Users\rich\AppData\Roaming\npm\codex.cmd" exec --skip-git-repo-check --dangerously-bypass-approvals-and-sandbox --color never - 2>&1
                } -ArgumentList $promptFile
                if (-not (Wait-Job $cj -Timeout 1800)) {
                    Stop-Job $cj; Remove-Job $cj
                    "(codex timed out after 1800s -- round skipped)"
                } else {
                    $r = Receive-Job $cj; Remove-Job $cj; $r
                }
            }
        }
        if (-not $output) { $output = '(no output returned)' }
    } catch {
        $output = "EXCEPTION in round $roundNum (${agent}): $_"
    }

    $outputStr = if ($output -is [array]) { $output -join "`n" } else { "$output" }
    [System.IO.File]::WriteAllText($roundFile, $outputStr, [System.Text.Encoding]::UTF8)

    # Strip CLI noise before accumulating into the analysis document
    $cleanStr = ($outputStr -split "`n" | Where-Object {
        $_ -notmatch '^\s*(Warning:|YOLO mode|Ripgrep is not|API returned invalid|^\[Routing\]|Reading prompt from stdin|at retryWithBackoff|at async |Full report available at:|color support not detected|Not inside a trusted directory)'
    }) -join "`n"
    $cleanStr = $cleanStr.Trim()

    # Extract handover section if present; fall back to first 4000 chars
    if ($cleanStr -match '(?s)=== HANDOVER ===(.+)$') {
        $handover = $matches[1].Trim()
    } else {
        $handover = $cleanStr.Substring(0, [Math]::Min($cleanStr.Length, 4000)) + $(if ($cleanStr.Length -gt 4000) { "`n[no HANDOVER section found -- truncated at 4000 chars; see round${roundNum}_${agent}.md]" })
    }

    if ($isFirst) {
        $analysisDoc = $handover
    } else {
        $analysisDoc += "`n`n--- Handover from Agent $roundNum ($agent) ---`n$handover"
    }
    Write-Host "Round $roundNum/$N ($agent) complete."
}

# Write final.md
$lastFile = Join-Path $OutputDir "round$($Agents.Count)_$($Agents[-1]).md"
$finalFile = Join-Path $OutputDir "final.md"
Copy-Item $lastFile $finalFile

# Write pipeline_log.md
$endTime  = Get-Date
$duration = ($endTime - $startTime).ToString('hh\:mm\:ss')
$logLines = @("# Pipeline Log", "", "**Task:** $Task", "", "**Agents:** $($Agents -join ' -> ')", "**Started:** $startTime", "**Finished:** $endTime", "**Duration:** $duration", "", "## Round files")
for ($i = 0; $i -lt $Agents.Count; $i++) { $logLines += "- round$($i+1)_$($Agents[$i]).md" }
$logLines += @("", "**Final synthesis:** final.md")
[System.IO.File]::WriteAllText((Join-Path $OutputDir 'pipeline_log.md'), ($logLines -join "`n"), [System.Text.Encoding]::UTF8)

# Open final.md
Invoke-Item $finalFile

# Toast (best-effort)
try {
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType=WindowsRuntime] | Out-Null
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml('<toast><visual><binding template="ToastGeneric"><text>Pipeline complete (' + $duration + ')</text><text>' + ($ProjectName ? $ProjectName + ' -- ' : '') + $OutputDir + '</text></binding></visual></toast>')
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Pipeline').Show($toast)
} catch {}

# --- SESSION CLOSE ---
if ($ProjectPath) {
    $finalExcerpt = Get-Content $finalFile -Raw -ErrorAction SilentlyContinue
    if ($finalExcerpt.Length -gt 3000) { $finalExcerpt = $finalExcerpt.Substring(0, 3000) + "`n[... truncated ...]" }
    $gitStatus = (& git -C $ProjectPath status --short 2>&1) -join "`n"

    $cp  = 'You are performing an automated session close for a pipeline run on project ' + $ProjectName + '.' + "`n"
    $cp += 'Project directory: ' + $ProjectPath + "`n`n"
    $cp += "PIPELINE SESSION:`n"
    $cp += '- Date: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm') + "`n"
    $cp += '- Task: ' + $Task + "`n"
    $cp += '- Agent pipeline: ' + ($Agents -join ' -> ') + "`n"
    $cp += '- Duration: ' + $duration + "`n"
    $cp += '- Output: ' + $finalFile + "`n`n"
    $cp += "FINAL SYNTHESIS (excerpt):`n" + $finalExcerpt + "`n`n"
    $cp += "GIT STATUS:`n" + $gitStatus + "`n`n"
    $cp += "DO EXACTLY THIS -- nothing else:`n"
    $cp += '1. Read ' + $ProjectPath + '\_ai_log.md' + "`n"
    $cp += "2. Append a new session block at the end. Format it like existing blocks in the file.`n"
    $cp += "   Include: date/time, goal (the task), method (pipeline run with these agents), 2-3 sentence outcome summary derived from the synthesis excerpt, any new or modified files from git status, path to final.md.`n"
    $cp += '3. Run the shell command: helpi 7 ' + $ProjectName + "`n"
    $cp += "   This regenerates the handover document and opens the browser. Do not skip it."

    $closePromptFile = Join-Path $OutputDir 'close_prompt.txt'
    [System.IO.File]::WriteAllText($closePromptFile, $cp, [System.Text.Encoding]::UTF8)

    $closePromptText = Get-Content -LiteralPath $closePromptFile -Raw -Encoding UTF8
    $closed = $false
    try {
        Write-Host "Attempting automated session close via Claude..." -ForegroundColor Gray
        $closePromptText | & claude --dangerously-skip-permissions --print --bare --add-dir $ProjectPath 2>&1
        $closed = $true
    } catch {
        Write-Host "WARN | Claude close failed: $($_.Exception.Message). Trying Gemini..." -ForegroundColor Yellow
    }

    if (-not $closed) {
        try {
            Write-Host "Attempting automated session close via Gemini..." -ForegroundColor Gray
            $closePromptText | & gemini --yolo --approval-mode yolo --skip-trust --output-format text 2>&1
            $closed = $true
        } catch {
            Write-Host "WARN | Session close failed (all models): $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}
```

### 4. Check for curly quotes in the PS1

After writing the file, run:
```powershell
$ps1 = Join-Path $outputDir 'run_pipeline.ps1'
$c = Get-Content $ps1 -Raw
$bad = [regex]::Matches($c, "[''""--]")
if ($bad.Count -gt 0) {
    $c = $c -replace "['']", "'" -replace "[""]", '"' -replace "[--]", '-'
    [System.IO.File]::WriteAllText($ps1, $c, [System.Text.Encoding]::UTF8)
}
```

### 5. Launch as detached background process

```powershell
$ps1Path = Join-Path $outputDir 'run_pipeline.ps1'
Start-Process pwsh -ArgumentList "-NonInteractive -File `"$ps1Path`"" -WindowStyle Hidden
```

### 6. Report to user

Tell the user:
- Pipeline started: N agents in order `agent1 -> agent2 -> ...`
- Project: name and path (if given), or note that log/handover will not update without `--project`
- Output directory: full path
- Estimated time: rough guess (typically 15-40 min for a 4-agent run; add ~5 min for the session close)
- "final.md will open automatically when done."
- "Intermediate round files appear as each agent finishes -- you can peek mid-run."
- If `--project` given: "_ai_log.md will be updated and the handover regenerated on finish."

---

## Templates

When `--template <name>` is given, substitute the full text below as the task string (in place of `{TASK}` in the PS1). Each template is a self-contained agent protocol.

---

### `final-pass` -- Manuscript Final Pass Auditor

```
AGENT PROTOCOL: MANUSCRIPT FINAL PASS AUDITOR

[ROLE]
You are an Expert Journal Editor and Academic Auditor. Your task is
to make a final quality pass on a manuscript that is almost
completely finished.

[CRITICAL PRINCIPLE: EARNED EDITS]
Because the paper is nearly final, do NOT make unnecessary edits.
Any proposed change must heavily justify its inclusion. Focus on
correcting friction, errors, and inconsistencies.

[TASK]
Scan the manuscript against these 7 core pillars. Output a brief
[PASS/FAIL] status for each section, noting explicit edits only
where strictly necessary.

THE CHECKLIST

1. REVIEWER ALIGNMENT
[ ] Response Match: Do explicit promises made in the Response to
    Reviewers letter perfectly match the final text in the manuscript?
    (e.g., If you promised a footnote on page 4, is it there?)

2. LITERATURE & CITATIONS
[ ] Placeholders: Are all bracketed placeholders, temporary tags,
    or "Author (202X)" notes completely removed?
[ ] Formatting: Do all in-text citations exist in the bibliography
    and match the journal's strict style guidelines?

3. LINGO, TONE, & SIMPLICITY
[ ] Seam Integration: Is the transition between old text and newly
    added text completely smooth and continuous?
[ ] Plain Language: Wherever complex or overly dense language can
    be simplified without losing technical accuracy, shorten it.

4. VISUALS & CALLOUTS
[ ] Cross-Referencing: Do all text callouts (e.g., "see Figure 2")
    correctly point to the actual numbers of the figures/tables?
[ ] Placement & Captions: Are placement markers clear, and do the
    captions match the exact titles of the actual figures/tables?

5. THE BOOKENDS (ABSTRACT & CONCLUSION)
[ ] High-Impact Clarity: Are the Abstract and Conclusion punchy,
    independent, clear, and absolutely free of typos?

6. MATH & NOTATION
[ ] Structural Consistency: Are all equations properly numbered?
    Do mathematical symbols mean the exact same thing across all sections?
[ ] Units: Are measurement units consistent and formatted correctly
    every time they appear?

7. COMPLIANCE & METADATA
[ ] Administrative Fields: Are funding numbers, acknowledgments,
    and Conflict of Interest (COI) statements complete and accurate?
[ ] Author Metadata: Are co-author names, affiliations, and email
    addresses completely up to date?

REQUIRED OUTPUT FORMAT
For any issues found, output exactly like this:

[FAIL] Section: [Manuscript Section, Page #, or Line #]
* Discrepancy: [Clear description of what is wrong and which step]
* Justification: [Why this change is critical enough to earn its place]
* Fix: [Exact text change or action needed to pass]
```

---

### `repro-audit` -- Reproduction Suite Auditor

```
AGENT PROTOCOL: REPRODUCTION SUITE AUDITOR

[ROLE]
You are an Academic Code Auditor. Your task is to verify a Python
reproduction suite against its corresponding paper for absolute
fidelity and reproducibility.

[TASK]
For every file, script, and artifact, execute these 5 binary checks
and output a brief [PASS/FAIL] status with explicit fixes.

THE CHECKLIST

1. ENVIRONMENT & PATHS
[ ] Master Switch: Is there a single script (e.g., main.py) that
    generates ALL figures and tables automatically?
[ ] Portability: Are all paths relative (no "C:/Users/...")?
[ ] Pins: Are all library versions strictly pinned in a
    requirements.txt or environment file?

2. THEORETICAL ALIGNMENT
[ ] Notation Match: Do variable names in the code match the math
    symbols in the paper (e.g., paper beta_1 -> code beta_1)?
[ ] Stochastic Lock: Is a global random seed set at the very
    beginning of the execution to freeze sampling/simulations?

3. ARTIFACT PARITY
[ ] Naming: Are exported files named exactly after the paper's
    structure (e.g., figure_1.pdf, table_2.csv)?
[ ] Precision: Do the decimal places and rounded values in the
    generated data match the printed paper text exactly?
[ ] Dynamic Labels: Are statistical values in plot titles/legends
    driven by data variables, not hardcoded text?

4. SAFE OPTIMIZATIONS
[ ] Zero-Variance Speeds: If loops were vectorized or I/O optimized,
    does the output pass a bit-wise identity check (0.00% variance)
    against the legacy code?

5. REPOSITORY HYGIENE
[ ] Leak Prevention: Does the .gitignore block local caches
    (__pycache__), system junk (.DS_Store), and proprietary data?

REQUIRED OUTPUT FORMAT
For any failures, output exactly like this:

[FAIL] Artifact: [Figure/Table # or Script Name]
* Discrepancy: [Clear description of what failed and which step]
* Fix: [Exact code or structural change needed to pass]
```

---

### `math-verify` -- Mathematical & Theorem Verifier

```
AGENT PROTOCOL: MATHEMATICAL & THEOREM VERIFIER

[ROLE]
You are a Rigorous Mathematical Auditor and Peer Reviewer. Your task
is to dissect every formal mathematical statement in the paper to
guarantee structural validity, absolute logical soundness, and
notational perfection.

[TASK]
Isolate every Theorem, Lemma, Proposition, and Corollary in the
manuscript. Audit them line-by-line against these 4 analytical pillars.
Output a [PASS/FAIL] status for each mathematical statement.

THE CHECKLIST

1. ASSUMPTION AUDITING
[ ] Necessity & Sufficiency: Are all stated assumptions strictly
    necessary for the statement to hold? Are there any hidden,
    unstated assumptions (e.g., assuming a matrix is invertible,
    a function is smooth, or a set is compact)?
[ ] Boundary Cases: Does the statement break down at extreme values,
    empty sets, zero, or infinity? Are these edge cases explicitly
    handled or ruled out by the assumptions?

2. PROOF VERIFICATION
[ ] Step-by-Step Logic: Is every mathematical transition justified?
    Check for logical leaps, invalid inequalities, circular reasoning,
    or signs (+/-) that flip accidentally between steps.
[ ] Theorem Misapplication: If the proof invokes an outside
    theorem or standard lemma, are all prerequisites for that outside
    theorem fully satisfied?
[ ] Definition Fidelity: Ensure that core mathematical objects
    exactly follow their defined properties throughout the entire derivation.

3. NOTATIONAL INTEGRITY
[ ] Variable Life Cycle: Is every single symbol, index, and
    subscript explicitly defined before or immediately upon its first
    appearance?
[ ] Overloading Check: Does the same symbol mean two different things
    in different equations (e.g., using 'k' as both a constant and a
    loop index)?
[ ] Text-to-Math Parity: Does the verbal description of the math in
    the prose perfectly mirror what the equation actually says?

4. COROLLARY & CASCADE FLOW
[ ] Inheritance: For every Corollary, does it actually follow
    trivially from the parent Theorem, or does it require additional,
    unstated machinery?
[ ] Internal Interplay: If Proposition B builds on Lemma A, do the
    outputs of Lemma A exactly match the required inputs for Proposition B?

REQUIRED OUTPUT FORMAT
For every mathematical statement checked, output exactly like this:

[PASS/FAIL] Statement: [e.g., Theorem 3.1, Page 8]
* Core Claim: [One-sentence mathematical summary of what is being proven]
* Discrepancy: [Detailed breakdown of the flaw, logical leap, or notation error]
* Mathematical Fix: [The exact correction, extra assumption, or step adjustment needed]
```

---

### `lit-review` -- Literature Review & Citation Builder

```
AGENT PROTOCOL: LITERATURE REVIEW & CITATION BUILDER

[ROLE]
You are an Expert Research Librarian and Academic Bibliographer. Your
task is to conduct a systematic, exhaustive search for literature,
verify paper relevance, identify critical gaps, and construct a
flawless, fully-cited reference section featuring a structural
positioning table.

[TASK]
Execute these 5 comprehensive phases to build and audit the paper's
literature foundations. Output a structured Literature Blueprint and
Curation Report using the required format below.

THE CHECKLIST

1. SYSTEMATIC SEARCH STRATEGY
[ ] Keyword Matrix: Generate a comprehensive matrix of primary keywords,
    synonyms, and boolean operators (AND/OR) across target databases
    (e.g., Google Scholar, Scopus, IEEE Xplore, PubMed).
[ ] Snowballing: Perform backward snowballing (reviewing references
    of key papers) and forward snowballing (reviewing recent papers
    that cited key papers) to capture historical and cutting-edge work.

2. RELEVANCE & SILO FILTERING
[ ] Core Alignment: Evaluate abstracts against the paper's specific
    research questions. Discard "tangential" papers that use similar
    buzzwords but solve fundamentally different problems.
[ ] Methodological Proximity: Categorize discoveries based on their
    closeness to your approach (e.g., Baseline Competitors, Theoretical
    Foundations, Contextual/Application-only work).

3. SEMINAL & CONTEMPORARY GAP CHECK
[ ] Unforgivable Omissions: Identify the top 3-5 standard, foundational
    papers that established this specific sub-field. Ensure they are present.
[ ] Recency Audit: Scan for highly relevant papers published within
    the last 12-24 months to prove the topic is currently active.
[ ] Competitor Scan: Ensure direct competitors or alternative state-of-the-art
    methods are explicitly cited and fairly positioned.

4. NARRATIVE SYNTHESIS & LINKING
[ ] Theme Clustering: Group papers by thematic narrative blocks rather
    than listing them chronologically or as an isolated "X did this, Y did that" list.
[ ] The Hook: Explicitly tie the cited literature back to your paper's
    motivation, clearly showing the exact gap or limitation your work addresses.

5. METADATA & DOI COMPLIANCE
[ ] Cross-Fidelity: Ensure every entry in the bibliography is actually
    cited in the text body, and every text citation exists in the bibliography.
[ ] Completeness: Verify all entries include complete metadata: authors,
    journal/conference title, volume, issue, year, and page numbers.
[ ] DOI Lock: Pull and append the verified Digital Object Identifier (DOI)
    URL (https://doi.org/...) for every single reference.

REQUIRED OUTPUT FORMAT
Generate your report using this exact structure:

### 1. FOUNDATIONAL PAPERS LOCATED
* [Author, Year]: [Core contribution & why it must be included]

### 2. DETECTED GAPS (POTENTIAL REVIEWER TRAPS)
* Missing Thread: [Description of an overlooked paper or adjacent school of thought]
* Consequence: [Why a reviewer might complain if this is omitted]
* Fix: [Suggested sentence to integrate this citation smoothly]

### 3. LITERATURE COMPARISON MATRIX
Generate a Markdown table comparing your target manuscript against the most
relevant referenced literature across key technical attributes:

| Paper / Reference | Methodology / Model | Dataset / Scope | Key Limitation | DOI Link |
| :--- | :--- | :--- | :--- | :--- |
| [Author et al., Year] | [Short description] | [Scope details] | [Their main gap] | [URL] |
| **This Work (Target)** | **[Your unique angle]** | **[Your dataset/scope]** | **[Remaining scope]** | **N/A** |

### 4. CURATED BIBLIOGRAPHY SNIPPET (EXAMPLE ENTRY)
* Citation: [Cleanly formatted style, e.g., APA/IEEE]
* DOI Link: [Verified URL]
* Context: [1 sentence explaining exactly where and why this is cited in your text]
```

---

## Notes

- **Incremental accumulation**: each non-final agent appends a compact `=== HANDOVER ===` section at the end of its output. Only that section is fed to the next agent's prompt, keeping `$analysisDoc` small regardless of how thorough the full analysis is. The complete output is always preserved in `roundN_agent.md`. If an agent omits the handover marker, the script falls back to the first 4 000 chars of its cleaned output.
- **Output cleaning**: before extracting the handover, CLI noise lines are stripped (warnings, YOLO notices, routing errors, stack traces, tool-call logs). The full raw output is always preserved in `roundN_agent.md` for inspection.
- **Codex**: wrapped in a 1800s (30 min) PowerShell job timeout. `--color never` suppresses ANSI codes from polluting the analysis doc; `Get-Content -LiteralPath` handles paths with spaces. If codex times out, the round file gets `(codex timed out after 1800s -- round skipped)` and the pipeline continues to the next agent. Typical codex rounds complete in 2-5 min; 30 min is a generous safety ceiling.
- **Context growth**: `$analysisDoc` passed to each agent contains the deduplicated running document, not a dump of all prior raw outputs. If a round still fails due to size, check `prompt_rN.txt` -- the task or baseline may be unusually large.
- **Agent failures**: exceptions are written to the round file and the pipeline continues.
- **Closure**: the session close runs `claude --dangerously-skip-permissions` -- it writes to `_ai_log.md` and calls `helpi 7`. It reads the existing log to match its formatting.
- **No project**: omitting `--project` runs the pipeline and produces files but skips the log and handover update entirely.
- **Re-running**: each invocation creates a new timestamped folder; previous runs are never overwritten.
