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
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Task,

    [string]$ProjectName = "",

    [string]$Agents = "claude,gemini,codex",

    [ValidateRange(1, 20)]
    [int]$MaxRounds = 5,

    [ValidateSet("Forum", "SAD")]
    [string]$Mode = "Forum"
)

$ErrorActionPreference = "Stop"

$AiRoot = $PSScriptRoot
$PubRoot = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"

# ... (Limit-Text, Get-Section, Get-CleanState, Test-ForumState functions unchanged)

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
                return & claude --add-dir $ProjectPath -p $promptText 2>&1
            }
            return & claude -p $promptText 2>&1
        }
        "gemini" {
            # Use a slightly more capable model for SAD if available, otherwise default
            return & gemini -p $promptText --yolo --output-format text 2>&1
        }
        "codex" {
            return $promptText | & codex exec --skip-git-repo-check --color never 2>&1
        }
        default {
            throw "Unknown forum agent '$Agent'. Use a comma-separated list from: claude, gemini, codex."
        }
    }
}

function Invoke-Moderator {
    param(
        [string]$PromptFile,
        [string]$ProjectPath,
        [string]$RolePromptFile = ""
    )

    $promptText = Get-Content -LiteralPath $PromptFile -Raw -Encoding UTF8
    if ($RolePromptFile -and (Test-Path -LiteralPath $RolePromptFile)) {
        $roleText = Get-Content -LiteralPath $RolePromptFile -Raw -Encoding UTF8
        $promptText = $roleText + "`n`n" + $promptText
    }

    if ($ProjectPath) {
        return & claude --add-dir $ProjectPath -p $promptText 2>&1
    }
    return & claude -p $promptText 2>&1
}

# ... (ProjectPath resolution, Timestamp, ForumDir setup unchanged)

$AgentsArray = @(
    $Agents -split "," |
        ForEach-Object { $_.Trim().ToLowerInvariant() } |
        Where-Object { $_ }
)

if ($Mode -eq "SAD") {
    if ($AgentsArray.Count -gt 1) {
        Write-Host "SAD Mode: Using only the first agent ($($AgentsArray[0])) for all roles." -ForegroundColor Yellow
        $AgentsArray = @($AgentsArray[0])
    }
}

# ... (AllowedAgents check, InitialState, StateFile setup unchanged)

$StopForum = $false
$FailureCount = 0
$StartTime = Get-Date

Write-Host "Starting Convergence Forum ($Mode mode) in $ForumDir" -ForegroundColor Cyan

$CurrentRound = 1
while ($CurrentRound -le $MaxRounds -and -not $StopForum) {
    
    $Participants = if ($Mode -eq "SAD") { 
        @("critic", "advocate", "realist") 
    } else { 
        $AgentsArray 
    }

    foreach ($role in $Participants) {
        $agent = if ($Mode -eq "SAD") { $AgentsArray[0] } else { $role }
        
        Write-Host "Round ${CurrentRound}: Role [$role] (Agent $agent) is thinking..." -ForegroundColor Yellow

        $BlackboardState = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8
        $Prompt = @"
You are a participant in a Research Convergence Forum.
Your job is to stress-test the current task and help move the forum toward a defensible consensus.

CURRENT BLACKBOARD STATE:
$BlackboardState

INSTRUCTIONS:
1. Provide a focused adversarial contribution. Avoid restating settled decisions.
2. End your response with exactly these two sections:

=== DIGEST ===
A max 200-word summary of your new contribution.

=== STATE UPDATE ===
Concrete proposed edits to [CONVERGENCE LOG], [ACTIVE ARENA], or [PARKING LOT].

AGENT ROLE: $role
"@

        $RoundPromptFile = Join-Path $ForumDir "prompt_r${CurrentRound}_${role}.txt"
        $RoundOutputFile = Join-Path $ForumDir "output_r${CurrentRound}_${role}.md"
        $RolePromptFile = if ($Mode -eq "SAD") { Join-Path $AiRoot "prompts\forum_roles\${role}_sys.md" } else { "" }
        
        [System.IO.File]::WriteAllText($RoundPromptFile, $Prompt, [System.Text.Encoding]::UTF8)

        try {
            if ($role -eq "realist" -and $Mode -eq "SAD") {
                # Realist pass in SAD mode uses the Moderator invocation for higher weight
                $output = Invoke-Moderator -PromptFile $RoundPromptFile -ProjectPath $ProjectPath -RolePromptFile $RolePromptFile
            } else {
                $output = Invoke-Agent -Agent $agent -PromptFile $RoundPromptFile -ProjectPath $ProjectPath -RolePromptFile $RolePromptFile
            }
            $exitCode = if ($LASTEXITCODE -is [int]) { $LASTEXITCODE } else { 0 }
            if (-not $output) { $output = "(no output returned)" }
        } catch {
            $output = "EXCEPTION in round ${CurrentRound} (${role}): $($_.Exception.Message)"
            $exitCode = 1
        }

        # ... (OutputStr processing, Digest extraction, stateUpdate extraction unchanged)

        if ($exitCode -ne 0 -or $outputStr -match "^(EXCEPTION|error:|ERR\s*\|)") {
            $FailureCount++
            Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "- Round ${CurrentRound} ${role}: FAILED. See $RoundOutputFile"
        } else {
            Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "- Round ${CurrentRound} ${role}: complete. See $RoundOutputFile"
        }

        if ($FailureCount -ge 2) {
            # ... (FailedState logic unchanged)
            $StopForum = $true
            break
        }

        # Moderator Pass
        Write-Host "Updating Blackboard State..." -ForegroundColor Gray
        $ModeratorPrompt = @"
You are the moderator of a Research Convergence Forum.
Update the blackboard using only the compact digest and proposed state update below.
Do not copy the full transcript. Do not remove already settled convergence-log decisions unless they are explicitly contradicted and you explain why.

ROLE: $role
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

        $ModeratorPromptFile = Join-Path $ForumDir "moderator_prompt_r${CurrentRound}_${role}.txt"
        [System.IO.File]::WriteAllText($ModeratorPromptFile, $ModeratorPrompt, [System.Text.Encoding]::UTF8)

        try {
            $ModOutput = Invoke-Moderator -PromptFile $ModeratorPromptFile -ProjectPath $ProjectPath
            $ModOutputStr = if ($ModOutput -is [array]) { $ModOutput -join "`n" } else { "$ModOutput" }
            $cleanState = Get-CleanState -Text $ModOutputStr
            if (Test-ForumState -Text $cleanState) {
                [System.IO.File]::WriteAllText($StateFile, $cleanState, [System.Text.Encoding]::UTF8)
            } else {
                Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "- Round ${CurrentRound} ${role}: moderator state rejected; previous state preserved."
            }
        } catch {
            Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "- Round ${CurrentRound} ${role}: moderator failed: $($_.Exception.Message)"
        }

        $StateContent = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8
        # ... (ConvergenceSection extraction unchanged)

        if ($StateContent -match "(?m)^Status:\s*(converged|adjourned|failed)\s*$") {
            $StopForum = $true
            Write-Host "Forum status: $($Matches[1]). Closing forum." -ForegroundColor Green
            break
        }
    }
    $CurrentRound++
}

# ... (FinalFile, Duration, Auto-Close logic unchanged)


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

Write-Host "Forum concluded. Results in $ForumDir" -ForegroundColor Cyan
try { Invoke-Item $FinalFile } catch { Write-Host "WARN | Could not open final forum file: $($_.Exception.Message)" -ForegroundColor Yellow }

if ($ProjectPath) {
    $finalExcerpt = Get-Content -LiteralPath $FinalFile -Raw -Encoding UTF8
    $finalExcerpt = Limit-Text -Text $finalExcerpt -MaxChars 3000
    $gitStatus = (& git -C $ProjectPath status --short 2>&1) -join "`n"

    $ClosePrompt = @"
You are performing an automated session close for a Convergence Forum run on project $ProjectName.
Project directory: $ProjectPath

FORUM SESSION:
- Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
- Task: $Task
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
    try {
        & claude --dangerously-skip-permissions --add-dir $ProjectPath -p (Get-Content -LiteralPath $ClosePromptFile -Raw -Encoding UTF8)
    } catch {
        Add-Content -LiteralPath $RunLogFile -Encoding UTF8 -Value "Auto-close failed: $($_.Exception.Message)"
        Write-Host "WARN | Auto-close failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
