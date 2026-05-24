<#
.SYNOPSIS
    Orchestrates a multi-agent "Convergence Forum" discussion to reach consensus on research tasks.
    Uses a blackboard model with a Convergence Log for token efficiency.

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
    [string]$Task,

    [string]$ProjectName = "",

    [string]$Agents = "claude,gemini,codex",

    [int]$MaxRounds = 5
)

# 1. Resolve Project Path
$ProjectPath = ""
if ($ProjectName) {
    $ProjectPath = Join-Path "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer" $ProjectName
    if (-not (Test-Path $ProjectPath)) {
        Write-Error "Project path not found: $ProjectPath"
        exit 1
    }
}

# 2. Setup Forum Directory
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ForumDir = Join-Path (Get-Location) "_forums\$Timestamp"
New-Item -ItemType Directory -Path $ForumDir -Force | Out-Null

$StateFile = Join-Path $ForumDir "forum_state.md"
$LogFile   = Join-Path $ForumDir "convergence_log.md"

# 3. Initialize Blackboard State
$InitialState = @"
# Convergence Forum: $Task

## [CONVERGENCE LOG]
*Settled facts and decisions will appear here.*

## [ACTIVE ARENA]
- Primary Task: $Task

## [PARKING LOT]
*Issues for later discussion.*

## [LATEST DIGESTS]
*Summaries of recent arguments.*
"@

[System.IO.File]::WriteAllText($StateFile, $InitialState, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($LogFile, "# Convergence Log`n`nStarted: $(Get-Date)", [System.Text.Encoding]::UTF8)

$AgentsArray = $Agents -split ","
$CurrentRound = 1
$StopForum = $false

Write-Host "Starting Convergence Forum in $ForumDir" -ForegroundColor Cyan

while ($CurrentRound -le $MaxRounds -and -not $StopForum) {
    foreach ($agent in $AgentsArray) {
        Write-Host "Round $CurrentRound: Agent $agent is thinking..." -ForegroundColor Yellow
        
        $Prompt = @"
You are a participant in a Research Convergence Forum.
Your goal is to debate the current task and reach consensus.

CURRENT BLACKBOARD STATE:
$(Get-Content $StateFile -Raw)

INSTRUCTIONS:
1. Provide a thorough, adversarial argument or contribution.
2. At the end of your response, you MUST provide two sections:
   - === DIGEST === : A max 200-word summary of your point for the blackboard.
   - === STATE UPDATE === : Proposed changes to the [CONVERGENCE LOG], [ACTIVE ARENA], or [PARKING LOT].

AGENT ROLE: $agent
"@

        $RoundPromptFile = Join-Path $ForumDir "prompt_r${CurrentRound}_${agent}.txt"
        [System.IO.File]::WriteAllText($RoundPromptFile, $Prompt, [System.Text.Encoding]::UTF8)
        
        $RoundOutputFile = Join-Path $ForumDir "output_r${CurrentRound}_${agent}.md"
        
        # Execute Agent (YOLO/Dangerously skip permissions for speed as per user preference)
        try {
            $output = switch ($agent) {
                'claude' { & claude -p (Get-Content $RoundPromptFile -Raw) 2>&1 }
                'gemini' { & gemini -p (Get-Content $RoundPromptFile -Raw) --yolo --output-format text 2>&1 }
                'codex'  { & codex exec --skip-git-repo-check --dangerously-bypass-approvals-and-sandbox --color never (Get-Content $RoundPromptFile -Raw) 2>&1 }
            }
        } catch {
            $output = "EXCEPTION: $_"
        }
        
        $outputStr = if ($output -is [array]) { $output -join "`n" } else { "$output" }
        [System.IO.File]::WriteAllText($RoundOutputFile, $outputStr, [System.Text.Encoding]::UTF8)

        # 4. Moderator Logic (Claude acts as Moderator every 2 turns or at end of loop)
        # For simplicity in this first version, we'll ask Claude to update the state after each Gemini/Codex turn.
        if ($agent -ne 'claude' -or $true) {
             Write-Host "Updating Blackboard State..." -ForegroundColor Gray
             $ModPrompt = @"
Review the recent agent output and update the Blackboard State.
Identify if any consensus was reached and move it to the [CONVERGENCE LOG].
Update the [LATEST DIGESTS] with the new summary.

RECENT OUTPUT:
$outputStr

CURRENT STATE:
$(Get-Content $StateFile -Raw)

Output the NEW complete content for forum_state.md.
"@
             $ModOutput = & claude -p $ModPrompt
             $cleanState = ($ModOutput -join "`n") -replace ".*# Convergence Forum", "# Convergence Forum"
             [System.IO.File]::WriteAllText($StateFile, $cleanState, [System.Text.Encoding]::UTF8)
        }
    }
    
    # 5. Check for Termination
    $StateContent = Get-Content $StateFile -Raw
    if ($StateContent -match "\[ACTIVE ARENA\]\s*\n*(EMPTY|None|Resolved)") {
        $StopForum = $true
        Write-Host "Consensus reached. Closing forum." -ForegroundColor Green
    }

    $CurrentRound++
}

# 6. Finalization
Write-Host "Forum concluded. Results in $ForumDir" -ForegroundColor Cyan
Invoke-Item $StateFile

if ($ProjectPath) {
    # Update AI Log (simplified for now)
    $LogMsg = "Convergence Forum: $Task. Consensus reached in $CurrentRound rounds. See $StateFile"
    # helpi 7 call would go here
}
