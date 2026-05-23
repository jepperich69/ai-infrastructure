$Task = @'
AGENT PROTOCOL: MANUSCRIPT FINAL PASS AUDITOR

[ROLE]
You are an Expert Journal Editor and Academic Auditor. Your task is
to make a final quality pass on a manuscript that is almost
completely finished.

[CRITICAL PRINCIPLE: EARNED EDITS]
Because the paper is nearly final, do NOT make unnecessary edits.
Any proposed change must heavily justify its inclusion. Focus on
correcting friction, errors, and inconsistencies.

PAPER CONTEXT:
- Title: Longitudinal study of activity space trajectories in Denmark using kernel density estimation on travel diary data (2007-2024).
- Measures how spatial action spaces have changed over time across age cohorts (10-17, 18-30, 31-55, 56-65, 66+).
- Key finding: older adults (66+) drive expansion in the full sample; urban-only restriction reverses the sign for 66+ and 56-65 (rural older adults are the dominant signal). Bandwidth choice (H_D = 3, 5, 7 km) does not alter drift signs or age-group ordering.
- Target journal: Nature Communications
- Phase: R1 revision complete -- 16 reviewer comments addressed
- Main manuscript: NatComm_R1.tex in Overleaf_source/
- Supplementary: NatComm_R1_supp.tex
- R1 response letter: NatComm_R1_response.tex (all 16 comments resolved)
- Age groups use label 56+ (not 55+) -- do not revert
- Language is age-group throughout (not generation)
- Bootstrap uncertainty fan: in main paper Figure 6a (not SI) -- bootstrap_arrow_fan.png
- SI figure numbering: S4=settlement robustness, S5=sex stratification, S6=bandwidth bars (bw_drift_bars.png)
- SI table numbering: Table S2=path complexity, Table S3=bandwidth sensitivity

Please read the manuscript files:
C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer\Pub_ActionSpace_NatComm\Overleaf_source\NatComm_R1.tex
C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer\Pub_ActionSpace_NatComm\Overleaf_source\NatComm_R1_supp.tex
C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer\Pub_ActionSpace_NatComm\Overleaf_source\NatComm_R1_response.tex

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
'@
$OutputDir   = 'C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\_pipelines\2026-05-22_21-53-46'
$Agents      = @('claude', 'gemini', 'codex', 'claude')
$ProjectPath = 'C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer\Pub_ActionSpace_NatComm'
$ProjectName = 'Pub_ActionSpace_NatComm'

$analysisDoc = ''
$startTime   = Get-Date

for ($i = 0; $i -lt $Agents.Count; $i++) {
    $agent    = $Agents[$i]
    $roundNum = $i + 1
    $N        = $Agents.Count
    $isFirst  = ($i -eq 0)
    $isLast   = ($i -eq ($Agents.Count - 1))

    if ($isFirst) {
        $roleInstr = "Produce a thorough, well-structured analysis. Your output will be reviewed and extended by subsequent agents. Be comprehensive -- this is the foundation. Read the manuscript files listed in the task context before producing your analysis."
        $prompt = "You are Agent $roundNum of $N in a multi-agent analysis pipeline.`n`nTASK:`n$Task`n`nINSTRUCTION:`n$roleInstr"
    } elseif ($isLast) {
        $roleInstr = "Synthesise the analysis document below into a single, coherent, high-quality final deliverable. Resolve any [DISAGREEMENT: ...] markers -- state the correct conclusion and why. Produce a clean, standalone document with no duplication. Structure it around the 7 checklist pillars."
        $prompt = "You are the FINAL agent ($roundNum of $N) in a multi-agent analysis pipeline.`n`nTASK:`n$Task`n`n=== ANALYSIS DOCUMENT ===`n$analysisDoc`n=== END ===`n`nINSTRUCTION:`n$roleInstr"
    } else {
        $roleInstr = "Review the current analysis document below. Your output must contain ONLY: (1) findings not yet documented -- add them under the relevant section heading; (2) explicit disagreements with existing findings, written as [DISAGREEMENT: <point>]. Do NOT restate or summarise anything already in the document. If you have nothing new to add on a section, omit it entirely. Shorter is better."
        $prompt = "You are Agent $roundNum of $N in a multi-agent analysis pipeline.`n`nTASK:`n$Task`n`n=== CURRENT ANALYSIS DOCUMENT ===`n$analysisDoc`n=== END ===`n`nINSTRUCTION:`n$roleInstr"
    }

    $promptFile = Join-Path $OutputDir "prompt_r${roundNum}.txt"
    [System.IO.File]::WriteAllText($promptFile, $prompt, [System.Text.Encoding]::UTF8)

    $roundFile = Join-Path $OutputDir "round${roundNum}_${agent}.md"
    try {
        $output = switch ($agent) {
            'claude' { & claude --add-dir $ProjectPath -p (Get-Content $promptFile -Raw) 2>&1 }
            'gemini' { & gemini -p (Get-Content $promptFile -Raw) --yolo --output-format text 2>&1 }
            'codex'  { Get-Content $promptFile -Raw | & codex exec --skip-git-repo-check 2>&1 }
        }
        if (-not $output) { $output = '(no output returned)' }
    } catch {
        $output = "EXCEPTION in round $roundNum (${agent}): $_"
    }

    $outputStr = if ($output -is [array]) { $output -join "`n" } else { "$output" }
    [System.IO.File]::WriteAllText($roundFile, $outputStr, [System.Text.Encoding]::UTF8)

    $cleanStr = ($outputStr -split "`n" | Where-Object {
        $_ -notmatch '^\s*(Warning:|YOLO mode|Ripgrep is not|API returned invalid|^\[Routing\]|Reading prompt from stdin|at retryWithBackoff|at async |Full report available at:|color support not detected|Not inside a trusted directory)'
    }) -join "`n"
    $cleanStr = $cleanStr.Trim()
    $cap = if ($isFirst) { 20000 } else { 10000 }
    if ($cleanStr.Length -gt $cap) { $cleanStr = $cleanStr.Substring(0, $cap) + "`n[truncated at $cap chars -- see round${roundNum}_${agent}.md for full output]" }

    if ($isFirst) {
        $analysisDoc = $cleanStr
    } else {
        $analysisDoc += "`n`n--- Additions from Agent $roundNum ($agent) ---`n$cleanStr"
    }
    Write-Host "Round $roundNum/$N ($agent) complete."
}

$lastFile = Join-Path $OutputDir "round$($Agents.Count)_$($Agents[-1]).md"
$finalFile = Join-Path $OutputDir "final.md"
Copy-Item $lastFile $finalFile

$endTime  = Get-Date
$duration = ($endTime - $startTime).ToString('hh\:mm\:ss')
$logLines = @("# Pipeline Log", "", "**Task:** $Task", "", "**Agents:** $($Agents -join ' -> ')", "**Started:** $startTime", "**Finished:** $endTime", "**Duration:** $duration", "", "## Round files")
for ($i = 0; $i -lt $Agents.Count; $i++) { $logLines += "- round$($i+1)_$($Agents[$i]).md" }
$logLines += @("", "**Final synthesis:** final.md")
[System.IO.File]::WriteAllText((Join-Path $OutputDir 'pipeline_log.md'), ($logLines -join "`n"), [System.Text.Encoding]::UTF8)

Invoke-Item $finalFile

try {
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType=WindowsRuntime] | Out-Null
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml('<toast><visual><binding template="ToastGeneric"><text>Pipeline complete (' + $duration + ')</text><text>' + ($ProjectName ? $ProjectName + ' -- ' : '') + $OutputDir + '</text></binding></visual></toast>')
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Pipeline').Show($toast)
} catch {}

if ($ProjectPath) {
    $finalExcerpt = Get-Content $finalFile -Raw -ErrorAction SilentlyContinue
    if ($finalExcerpt.Length -gt 3000) { $finalExcerpt = $finalExcerpt.Substring(0, 3000) + "`n[... truncated ...]" }
    $gitStatus = (& git -C $ProjectPath status --short 2>&1) -join "`n"

    $closePrompt = @"
You are performing an automated session close for a pipeline run on project $ProjectName.
Project directory: $ProjectPath

PIPELINE SESSION:
- Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
- Task: $Task
- Agent pipeline: $($Agents -join ' -> ')
- Duration: $duration
- Output: $finalFile

FINAL SYNTHESIS (excerpt):
$finalExcerpt

GIT STATUS:
$gitStatus

DO EXACTLY THIS -- nothing else:
1. Read ${ProjectPath}\_ai_log.md
2. Append a new session block at the end. Format it like existing blocks in the file.
   Include: date/time, goal (the task), method (pipeline run with these agents), 2-3 sentence outcome summary derived from the synthesis excerpt, any new or modified files from git status, path to final.md.
3. Run the shell command: helpi 7 $ProjectName
   This regenerates the handover document and opens the browser. Do not skip it.
"@

    $closePromptFile = Join-Path $OutputDir 'close_prompt.txt'
    [System.IO.File]::WriteAllText($closePromptFile, $closePrompt, [System.Text.Encoding]::UTF8)

    & claude --dangerously-skip-permissions --add-dir $ProjectPath -p (Get-Content $closePromptFile -Raw)
}
