<#
.SYNOPSIS
    Orchestrates a multi-agent "Convergence Forum" discussion to reach consensus on research tasks.
    Uses a blackboard model with compact digests for token efficiency.

.PARAMETER Task
    The research task or agenda for the forum.

.PARAMETER ProjectName
    Short name of the project (e.g. Pub_MyPaper).

.PARAMETER Agents
    Comma-separated list of agents (default: claude,gemini,codex).

.PARAMETER MaxRounds
    Maximum number of discussion rounds (default: 5).

.PARAMETER Mode
    Execution mode: 'Forum' (default) or 'SAD' (Systematic Adversarial Design).

.PARAMETER OpenFinal
    Open the final forum markdown file when the run ends.

.PARAMETER AutoClose
    Ask Claude to append a session close entry after the forum run.
#>

param(
    [string]$Task = "",

    [string]$TaskFile = "",

    [string]$ProjectName = "",

    [string]$Agents = "claude,gemini,codex",

    [ValidateRange(1, 20)]
    [int]$MaxRounds = 5,

    [ValidateSet("Forum", "SAD")]
    [string]$Mode = "Forum",

    # Stage controls how conservative agents are:
    #   draft    - adversarial stress-testing, open to major changes (default)
    #   revision - surgical edits only, paper is in R1/R2 state
    #   final    - defect detection only, no suggestions
    [ValidateSet("draft", "revision", "final")]
    [string]$Stage = "draft",

    [switch]$OpenFinal,

    [switch]$AutoClose,

    [ValidateRange(1, 7200)]
    [int]$AgentTimeoutSeconds = 900
)

$ErrorActionPreference = "Continue"

$StageLabel = switch ($Stage) {
    "revision" { "REVISION (R1/R2)" }
    "final"    { "FINAL PRE-SUBMISSION" }
    default    { "DRAFT" }
}

$StageRoleHeader = switch ($Stage) {
    "revision" {
@"
You are a participant in a Research Convergence Forum on a paper in active revision ($StageLabel state).
The manuscript is substantially complete. Your role is SURGICAL EDITING, not improvement.
"@
    }
    "final" {
@"
You are a participant in a Research Convergence Forum on a paper in final pre-submission state.
The manuscript is complete. Your role is DEFECT DETECTION ONLY -- not improvement, not restructuring.
"@
    }
    default {
@"
You are a participant in a Research Convergence Forum.
Your job is to stress-test the current task and help move the forum toward a defensible consensus.
"@
    }
}

$StageConstraint = switch ($Stage) {
    "revision" {
@"
STAGE CONSTRAINT ($StageLabel): Changes must be minimal and directly tied to the task. Do NOT suggest restructuring, rewrites, new framings, or concerns not raised by the task. If you see something outside the task scope, park it -- do not expand on it.
"@
    }
    "final" {
@"
STAGE CONSTRAINT ($StageLabel): Only flag a change if it corrects a clear error (factual, logical, or grammatical). Do not reframe, restructure, or improve. Do not suggest anything that is not broken.
"@
    }
    default { "" }
}

$StageInstruction1 = switch ($Stage) {
    "revision" { "1. Provide a focused, conservative contribution strictly within the task scope. Avoid restating settled decisions." }
    "final"    { "1. Identify only clear defects within the task scope. Do not propose improvements." }
    default    { "1. Provide a focused adversarial contribution. Avoid restating settled decisions." }
}

$ForumReadOnlyConstraint = @"

FORUM CONSTRAINT -- READ ONLY: This is a Convergence Forum advisory session.
You produce TEXT SUGGESTIONS ONLY. You MUST NOT edit, create, write, or delete any file.
If you want to suggest a change to the manuscript or code, describe it in your response text.
The researcher reads the forum output and applies changes manually.
Any file edit made during this forum session is a policy violation.
"@

if (!$Task -and !$TaskFile) {
    Write-Error "Either -Task or -TaskFile is required."
    exit 1
}
if ($TaskFile) {
    if (!(Test-Path -LiteralPath $TaskFile)) {
        Write-Error "TaskFile not found: $TaskFile"
        exit 1
    }
    $Task = Get-Content -LiteralPath $TaskFile -Raw -Encoding UTF8
}

$AiRoot = $PSScriptRoot
$PubRoot = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"

# Resolve templates
if ($Task -and $Task -match '^[a-zA-Z0-9_-]+$' -and $Task.Length -lt 100 -and (Test-Path (Join-Path $AiRoot "prompts\$($Task).md"))) {
    $TemplateFile = Join-Path $AiRoot "prompts\$($Task).md"
    Write-Host "Resolved template: $Task" -ForegroundColor Gray
    $TaskName = $Task
    $Task = Get-Content $TemplateFile -Raw
} else {
    $TaskName = $Task
}

function Limit-Text {
    param(
        [AllowNull()]
        [string]$Text,
        [int]$MaxChars = 12000
    )
    if (!$Text) { return "" }
    if ($Text.Length -le $MaxChars) { return $Text }
    return $Text.Substring(0, $MaxChars) + "`n[truncated at $MaxChars chars; see transcript file for full output]"
}

function Get-Section {
    param(
        [string]$Text,
        [string]$SectionName
    )
    $pattern = "(?ms)^===\s*$([regex]::Escape($SectionName))\s*===\s*(.*?)(?=^===\s*[^`r`n]+?\s*===|\z)"        
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ""
}

function Get-CleanState {
    param([string]$Text)
    $match = [regex]::Match($Text, "(?ms)^# Convergence Forum:.*")
    if ($match.Success) { return $match.Value.Trim() }
    return $Text.Trim()
}

function Test-ForumState {
    param([string]$Text)
    if (!$Text) { return $false }
    $required = @(
        "# Convergence Forum:",
        "Status:",
        "## [CONVERGENCE LOG]",
        "## [ACTIVE ARENA]",
        "## [PARKING LOT]",
        "## [LATEST DIGESTS]"
    )
    foreach ($needle in $required) {
        if (-not $Text.Contains($needle)) { return $false }
    }
    return $true
}

function Get-StateSection {
    param(
        [string]$Text,
        [string]$SectionName
    )
    $pattern = "(?ms)^## \[$([regex]::Escape($SectionName))\]\s*(.*?)(?=^## \[|\z)"
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return ""
}

function Update-StateFallback {
    param(
        [string]$CurrentState,
        [string]$Round,
        [string]$Participant,
        [string]$Digest,
        [string]$StateUpdate
    )

    $title = if ($CurrentState -match "(?m)^# Convergence Forum:.*$") { $Matches[0] } else { "# Convergence Forum: $TaskName" }
    $convergence = Get-StateSection -Text $CurrentState -SectionName "CONVERGENCE LOG"
    $arena = Get-StateSection -Text $CurrentState -SectionName "ACTIVE ARENA"
    $parking = Get-StateSection -Text $CurrentState -SectionName "PARKING LOT"
    $latest = Get-StateSection -Text $CurrentState -SectionName "LATEST DIGESTS"

    if (!$convergence) { $convergence = "- No settled decisions yet." }
    if (!$arena) { $arena = "- Primary task: $TaskName" }
    if (!$parking) { $parking = "- No parked issues yet." }

    $compactUpdate = (Limit-Text -Text $StateUpdate -MaxChars 700) -replace "(`r`n|`n|`r)+", " | "
    if ($compactUpdate -and $compactUpdate -ne "(No explicit state update provided.)") {
        $convergence = ($convergence.TrimEnd() + "`n- Round ${Round} ${Participant} proposed update: $compactUpdate").Trim()
    }

    $compactDigest = (Limit-Text -Text $Digest -MaxChars 500) -replace "(`r`n|`n|`r)+", " "
    $digestLines = @("- Round ${Round} ${Participant}: $compactDigest")
    if ($latest -and $latest -ne "- No agent digests yet.") {
        $digestLines += ($latest -split "(`r`n|`n|`r)" | Where-Object { $_.Trim() } | Select-Object -First 7)
    }
    $latest = ($digestLines | Select-Object -First 8) -join "`n"

    return @"
$title

Status: active
Round: $Round

## [CONVERGENCE LOG]
$convergence

## [ACTIVE ARENA]
$arena

## [PARKING LOT]
$parking

## [LATEST DIGESTS]
$latest
"@.Trim()
}

function Invoke-CodexAgent {
    param(
        [string]$PromptText,
        [string]$ProjectPath,
        [int]$TimeoutSeconds = 900
    )

    $nodeExe = "C:\Program Files\nodejs\node.exe"
    $codexJs = "C:\Users\rich\AppData\Roaming\npm\node_modules\@openai\codex\bin\codex.js"
    if (-not (Test-Path -LiteralPath $nodeExe)) {
        $nodeExe = "node.exe"
    }
    if (-not (Test-Path -LiteralPath $codexJs)) {
        $script:LASTEXITCODE = 127
        return "ERR | Codex CLI entrypoint not found: $codexJs"
    }

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $nodeExe
    $processArgs = @(
        "`"$codexJs`"",
        "exec",
        "--skip-git-repo-check",
        "--color",
        "never"
    )
    if ($ProjectPath) {
        $processArgs += "--cd"
        $processArgs += "`"$ProjectPath`""
    }
    $processArgs += "-"
    $psi.Arguments = $processArgs -join " "
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8

    $proc = [System.Diagnostics.Process]::new()
    $proc.StartInfo = $psi
    [void]$proc.Start()

    $stdoutTask = $proc.StandardOutput.ReadToEndAsync()
    $stderrTask = $proc.StandardError.ReadToEndAsync()
    $proc.StandardInput.Write($PromptText)
    $proc.StandardInput.Close()

    if (-not $proc.WaitForExit($TimeoutSeconds * 1000)) {
        try { $proc.Kill($true) } catch {}
        $script:LASTEXITCODE = 124
        return "ERR | codex timed out after ${TimeoutSeconds}s before returning output."
    }

    $script:LASTEXITCODE = $proc.ExitCode
    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $stderrTask.GetAwaiter().GetResult()
    $combined = (($stdout, $stderr) | Where-Object { $_ }) -join "`n"
    $fatalPattern = "(?i)(401 Unauthorized|403 Forbidden|Not logged in|Please run /login|stream disconnected before completion|failed to connect to websocket)"
    if ($combined -match $fatalPattern) {
        return $combined
    }

    $clean = $stdout -replace "`r`n", "`n"
    $matches = [regex]::Matches($clean, "(?ms)^codex\s*$\n(.*)")
    if ($matches.Count -gt 0) {
        $clean = $matches[$matches.Count - 1].Groups[1].Value
    }
    $clean = [regex]::Replace($clean, "(?ms)\ntokens used\n.*\z", "")
    $clean = ($clean -split "`n" | Where-Object { $_.Trim() -ne "System.Management.Automation.RemoteException" }) -join "`n"
    $clean = $clean.Trim()
    if ($clean) {
        return $clean
    }
    return $combined
}

function Invoke-Agent {
    param(
        [string]$Agent,
        [string]$PromptFile,
        [string]$ProjectPath,
        [string]$RolePromptFile = ""
    )

    $promptText = Get-Content -LiteralPath $PromptFile -Raw -Encoding UTF8
    if ($RolePromptFile -and (Test-Path -LiteralPath $RolePromptFile)) {
        $roleText = Get-Content -LiteralPath $RolePromptFile -Raw -Encoding UTF8
        $promptText = $roleText + "`n`n" + $promptText
    }

    switch ($Agent) {
        "claude" {
            if ($ProjectPath) {
                return & claude --add-dir $ProjectPath --permission-mode plan -p $promptText 2>&1
            }
            return & claude --permission-mode plan -p $promptText 2>&1
        }
        "gemini" {
            return $promptText | & gemini --approval-mode plan --skip-trust --output-format text 2>&1
        }
        "codex" {
            return Invoke-CodexAgent -PromptText $promptText -ProjectPath $ProjectPath -TimeoutSeconds $AgentTimeoutSeconds
        }
        default {
            throw "Unknown forum agent '$Agent'. Use a comma-separated list from: claude, gemini, codex."       
        }
    }
}

$ProjectPath = ""
if ($ProjectName) {
    if ($ProjectName -eq "AI_auto") {
        $ProjectPath = $AiRoot
    } else {
        $ProjectPath = Join-Path $PubRoot $ProjectName
    }
    if (-not (Test-Path -LiteralPath $ProjectPath)) {
        Write-Error "Project path not found: $ProjectPath"
        exit 1
    }
}

$AgentsArray = @(
    $Agents -split "," |
        ForEach-Object { $_.Trim().ToLowerInvariant() } |
        Where-Object { $_ }
)
if ($AgentsArray.Count -eq 0) {
    Write-Error "No agents specified."
    exit 1
}

$AllowedAgents = @("claude", "gemini", "codex")
foreach ($agent in $AgentsArray) {
    if ($agent -notin $AllowedAgents) {
        Write-Error "Unknown forum agent '$agent'. Allowed agents: $($AllowedAgents -join ', ')."
        exit 1
    }
}

$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ForumRoot = if ($ProjectPath) { Join-Path $ProjectPath "_forums" } else { Join-Path $AiRoot "_forums" }        
$ForumDir = Join-Path $ForumRoot $Timestamp
New-Item -ItemType Directory -Path $ForumDir -Force | Out-Null

$StateFile = Join-Path $ForumDir "forum_state.md"
$ConvergenceLogFile = Join-Path $ForumDir "convergence_log.md"
$RunLogFile = Join-Path $ForumDir "forum_run_log.md"
$FinalFile = Join-Path $ForumDir "final.md"

$InitialState = @"
# Convergence Forum: $TaskName

Status: active
Round: 0
Stage: $StageLabel

## [CONVERGENCE LOG]
- No settled decisions yet.

## [ACTIVE ARENA]
- Primary task: $TaskName

## [PARKING LOT]
- No parked issues yet.

## [LATEST DIGESTS]
- No agent digests yet.
"@

[System.IO.File]::WriteAllText($StateFile, $InitialState, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($ConvergenceLogFile, "# Convergence Log`n`nStarted: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n- No settled decisions yet.`n", [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($RunLogFile, "# Forum Run Log`n`nTask: $TaskName`nAgents: $Agents`nMode: $Mode`nStage: $StageLabel`nStarted: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n", [System.Text.Encoding]::UTF8)

$StopForum = $false
$FailureCount = 0
$StartTime = Get-Date

Write-Host "Starting Convergence Forum in $ForumDir" -ForegroundColor Cyan

$ParticipantList = @()
if ($Mode -eq "SAD") {
    $PrimaryAgent = $AgentsArray[0]
    $ModeratorAgent = $PrimaryAgent
    $ParticipantList = @("critic", "advocate", "realist")
} else {
    $ModeratorAgent = "claude"
    $ParticipantList = $AgentsArray
}

for ($CurrentRound = 1; $CurrentRound -le $MaxRounds -and -not $StopForum; $CurrentRound++) {
    foreach ($participant in $ParticipantList) {
        $execAgent = if ($Mode -eq "SAD") { $PrimaryAgent } else { $participant }
        Write-Host "Round ${CurrentRound}: Role $participant ($execAgent) is thinking..." -ForegroundColor Yellow

        $BlackboardState = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8
        $Prompt = @"
$StageRoleHeader
$StageConstraint
$ForumReadOnlyConstraint
CURRENT BLACKBOARD STATE:
$BlackboardState

INSTRUCTIONS:
$StageInstruction1
2. End your response with exactly these two sections:

=== DIGEST ===
A max 200-word summary of your new contribution.

=== STATE UPDATE ===
Concrete proposed edits to [CONVERGENCE LOG], [ACTIVE ARENA], or [PARKING LOT].

AGENT ROLE: $participant
"@

        $RoundPromptFile = Join-Path $ForumDir "prompt_r${CurrentRound}_${participant}.txt"
        $RoundOutputFile = Join-Path $ForumDir "output_r${CurrentRound}_${participant}.md"
        [System.IO.File]::WriteAllText($RoundPromptFile, $Prompt, [System.Text.Encoding]::UTF8)

        $RolePromptFile = ""
        if ($Mode -eq "SAD") {
            $RolePromptFile = Join-Path $AiRoot "prompts\forum_roles\${participant}_sys.md"
        }

        try {
            $output = Invoke-Agent -Agent $execAgent -PromptFile $RoundPromptFile -ProjectPath $ProjectPath -RolePromptFile $RolePromptFile
            $exitCode = if ($LASTEXITCODE -is [int]) { $LASTEXITCODE } else { 0 }
            if (-not $output) { $output = "(no output returned)" }
        } catch {
            $output = "EXCEPTION in round ${CurrentRound} (${participant}): $($_.Exception.Message)"
            $exitCode = 1
        }

        $outputStr = if ($output -is [array]) { $output -join "`n" } else { "$output" }
        [System.IO.File]::WriteAllText($RoundOutputFile, $outputStr, [System.Text.Encoding]::UTF8)

        $digest = Get-Section -Text $outputStr -SectionName "DIGEST"
        $stateUpdate = Get-Section -Text $outputStr -SectionName "STATE UPDATE"
        if (!$digest) { $digest = Limit-Text -Text $outputStr -MaxChars 1200 }
        if (!$stateUpdate) { $stateUpdate = "(No explicit state update provided.)" }
        $digest = Limit-Text -Text $digest -MaxChars 1600
        $stateUpdate = Limit-Text -Text $stateUpdate -MaxChars 2400

        # Check for authentication errors, but anchor to line-start to avoid false positives in debug dumps
        if ($outputStr -split "`n" | Where-Object { $_.Trim() -match "^(Not logged in|Please run /login|please run /login)" }) {
            # Special case: if we actually got a valid response structure, ignore auth-like noise in stderr
            if ($digest -and $stateUpdate -and $stateUpdate -ne "(No explicit state update provided.)") {
                # Continue - it was likely just noise in a stack trace or debug dump
            } else {
                Write-Host "ERR | Agent '$execAgent' is not authenticated. Run: $execAgent login" -ForegroundColor Red
                Write-Host "     Then re-run the forum." -ForegroundColor Red
                exit 1
            }
        }

        $hasStructuredResponse = (
            $digest -and
            $stateUpdate -and
            $stateUpdate -ne "(No explicit state update provided.)"
        )
        $fatalAgentOutput = $outputStr -match "(?i)(401 Unauthorized|403 Forbidden|Not logged in|Please run /login|stream disconnected before completion|failed to connect to websocket|codex timed out)"
        $explicitAgentError = $outputStr -match "(?mi)^\s*(EXCEPTION|ERROR:|ERR\s*\||error:)"
        $agentFailed = (
            ($fatalAgentOutput -and -not $hasStructuredResponse) -or
            (($exitCode -ne 0 -or $explicitAgentError) -and -not $hasStructuredResponse)
        )

        if ($agentFailed) {
            $FailureCount++
            Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "- Round ${CurrentRound} ${participant}: FAILED. See $RoundOutputFile"
        } else {
            Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "- Round ${CurrentRound} ${participant}: complete. See $RoundOutputFile"
        }

        if ($FailureCount -ge 3) {
            $failedState = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8
            $failedState = $failedState -replace "(?m)^Status:.*$", "Status: failed"
            $failedState += "`n`n## [ADJOURNMENT]`nForum stopped after $FailureCount agent failures. Check forum_run_log.md and transcript files.`n"
            [System.IO.File]::WriteAllText($StateFile, $failedState, [System.Text.Encoding]::UTF8)
            $StopForum = $true
            break
        }

        Write-Host "Updating Blackboard State..." -ForegroundColor Gray
        $ModeratorPrompt = @"
You are the moderator of a Research Convergence Forum.
Update the blackboard using only the compact digest and proposed state update below.
Do not copy the full transcript. Do not remove already settled convergence-log decisions unless they are explicitly contradicted and you explain why.
$StageConstraint
$ForumReadOnlyConstraint

AGENT: $participant
ROUND: $CurrentRound

AGENT DIGEST:
$digest

AGENT PROPOSED STATE UPDATE:
$stateUpdate

CURRENT BLACKBOARD STATE:
$(Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8)

Return the complete new forum_state.md only.
Keep [LATEST DIGESTS] compact: at most the 8 most recent agent digests.
It must contain exactly these structural fields:
# Convergence Forum: ...
Status: active OR converged OR adjourned OR failed
Round: $CurrentRound
## [CONVERGENCE LOG]
## [ACTIVE ARENA]
## [PARKING LOT]
## [LATEST DIGESTS]
"@

        $ModeratorPromptFile = Join-Path $ForumDir "moderator_prompt_r${CurrentRound}_${participant}.txt"       
        $ModeratorOutputFile = Join-Path $ForumDir "moderator_output_r${CurrentRound}_${participant}.md"
        [System.IO.File]::WriteAllText($ModeratorPromptFile, $ModeratorPrompt, [System.Text.Encoding]::UTF8)    

        try {
            $ModOutput = Invoke-Agent -Agent $ModeratorAgent -PromptFile $ModeratorPromptFile -ProjectPath $ProjectPath
            $ModOutputStr = if ($ModOutput -is [array]) { $ModOutput -join "`n" } else { "$ModOutput" }
            [System.IO.File]::WriteAllText($ModeratorOutputFile, $ModOutputStr, [System.Text.Encoding]::UTF8)
            $cleanState = Get-CleanState -Text $ModOutputStr
            if (Test-ForumState -Text $cleanState) {
                [System.IO.File]::WriteAllText($StateFile, $cleanState, [System.Text.Encoding]::UTF8)
            } else {
                $fallbackState = Update-StateFallback -CurrentState (Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8) -Round $CurrentRound -Participant $participant -Digest $digest -StateUpdate $stateUpdate
                [System.IO.File]::WriteAllText($StateFile, $fallbackState, [System.Text.Encoding]::UTF8)
                Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "- Round ${CurrentRound} ${participant}: moderator state rejected; fallback state applied. See $ModeratorOutputFile"
            }
        } catch {
            $fallbackState = Update-StateFallback -CurrentState (Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8) -Round $CurrentRound -Participant $participant -Digest $digest -StateUpdate $stateUpdate
            [System.IO.File]::WriteAllText($StateFile, $fallbackState, [System.Text.Encoding]::UTF8)
            Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "- Round ${CurrentRound} ${participant}: moderator failed; fallback state applied: $($_.Exception.Message)"
        }

        $StateContent = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8
        $ConvergenceSection = if ($StateContent -match "(?ms)## \[CONVERGENCE LOG\]\s*(.*?)(?=^## \[|\z)") { $Matches[1].Trim() } else { "" }
        [System.IO.File]::WriteAllText($ConvergenceLogFile, "# Convergence Log`n`nUpdated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n$ConvergenceSection`n", [System.Text.Encoding]::UTF8)

        if ($StateContent -match "(?m)^Status:\s*(converged|adjourned|failed)\s*$") {
            $StopForum = $true
            Write-Host "Forum status: $($Matches[1]). Closing forum." -ForegroundColor Green
            break
        }
    }
}

$PostLoopState = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8
if ($PostLoopState -match "(?m)^Status:\s*active\s*$") {
    $PostLoopState = $PostLoopState -replace "(?m)^Status:.*$", "Status: adjourned"
    $PostLoopState += "`n`n## [ADJOURNMENT]`nForum stopped after $MaxRounds rounds without convergence.`n"      
    [System.IO.File]::WriteAllText($StateFile, $PostLoopState, [System.Text.Encoding]::UTF8)
}

$EndTime = Get-Date
$Duration = ($EndTime - $StartTime).ToString("hh\:mm\:ss")
$FinalState = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8
$Footer = @"

---
Forum directory: $ForumDir
Started: $($StartTime.ToString('yyyy-MM-dd HH:mm:ss'))
Finished: $($EndTime.ToString('yyyy-MM-dd HH:mm:ss'))
Duration: $Duration
"@
[System.IO.File]::WriteAllText($FinalFile, ($FinalState.Trim() + $Footer), [System.Text.Encoding]::UTF8)        

Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "`nFinished: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "Final state: $FinalFile"

$FinalStatus = if ($FinalState -match "(?m)^Status:\s*(\S+)\s*$") { $Matches[1] } else { "unknown" }
if ($FinalStatus -eq "failed") {
    Write-Host "Forum failed. Results in $ForumDir" -ForegroundColor Red
} else {
    Write-Host "Forum concluded ($FinalStatus). Results in $ForumDir" -ForegroundColor Cyan
}
Write-Host "Final state: $FinalFile" -ForegroundColor DarkGray
if ($OpenFinal) {
    try { Invoke-Item $FinalFile } catch { Write-Host "WARN | Could not open final forum file: $($_.Exception.Message)" -ForegroundColor Yellow }
}

if ($ProjectPath -and $AutoClose) {
    $finalExcerpt = Get-Content -LiteralPath $FinalFile -Raw -Encoding UTF8
    $finalExcerpt = Limit-Text -Text $finalExcerpt -MaxChars 3000
    $gitStatus = (& git -C $ProjectPath status --short 2>&1) -join "`n"

    $ClosePrompt = @"
You are performing an automated session close for a Convergence Forum run on project $ProjectName.
Project directory: $ProjectPath

FORUM SESSION:
- Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
- Task: $TaskName
- Agents: $($AgentsArray -join ' -> ')
- Duration: $Duration
- Output: $FinalFile

FINAL STATE EXCERPT:
$finalExcerpt

GIT STATUS:
$gitStatus

DO EXACTLY THIS:
1. Read ${ProjectPath}\_ai_log.md.
2. Append a new session block matching the existing format.
3. Include the forum task, agents, outcome summary, changed files from git status, and path to final.md.        
4. Run: helpi 7 $ProjectName
"@

    $ClosePromptFile = Join-Path $ForumDir "close_prompt.txt"
    [System.IO.File]::WriteAllText($ClosePromptFile, $ClosePrompt, [System.Text.Encoding]::UTF8)
    $closePromptText = Get-Content -LiteralPath $ClosePromptFile -Raw -Encoding UTF8
    $closed = $false
    try {
        Write-Host "Attempting automated session close via Claude..." -ForegroundColor Gray
        & claude --dangerously-skip-permissions --add-dir $ProjectPath -p $closePromptText 2>&1
        $closed = $true
    } catch {
        Write-Host "WARN | Claude close failed: $($_.Exception.Message). Trying Gemini..." -ForegroundColor Yellow
    }

    if (-not $closed) {
        try {
            Write-Host "Attempting automated session close via Gemini..." -ForegroundColor Gray
            $closePromptText | & gemini --approval-mode yolo --skip-trust  --output-format text 2>&1
            $closed = $true
        } catch {
            Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "Auto-close failed (all models): $($_.Exception.Message)" 
            Write-Host "WARN | Auto-close failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}
