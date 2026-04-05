# status.ps1
# Dashboard: show all AI-active projects (those with _ai_log.md or code/.git).
# Displays last session date, uncommitted code changes, and Overleaf sync state.
#
# Usage:
#   .\status.ps1
#   .\status.ps1 -All    # include projects without _ai_log.md
#
param([switch]$All)

$pubRoot = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"

$projects = Get-ChildItem $pubRoot -Directory | Sort-Object Name

$rows = @()

foreach ($proj in $projects) {
    $logPath    = Join-Path $proj.FullName "_ai_log.md"
    $codeGit    = Join-Path $proj.FullName "code\.git"
    $overleafGit = Join-Path $proj.FullName "Overleaf_source\.git"

    $hasLog     = Test-Path $logPath
    $hasCodeGit = Test-Path $codeGit

    if (!$All -and !$hasLog -and !$hasCodeGit) { continue }

    # Last session date from _ai_log.md
    $lastSession = "-"
    if ($hasLog) {
        $sessionLine = Select-String -Path $logPath -Pattern "^## Session (\d{4}-\d{2}-\d{2})" |
                       Select-Object -Last 1
        if ($sessionLine) {
            $lastSession = $sessionLine.Matches[0].Groups[1].Value
        }
    }

    # Code git: uncommitted changes
    $codeStatus = "-"
    $lastCommit  = "-"
    if ($hasCodeGit) {
        $codeDir = Join-Path $proj.FullName "code"
        git -C $codeDir add -N . 2>$null   # mark new files so diff sees them
        $diff = git -C $codeDir status --porcelain 2>$null
        $codeStatus = if ($diff) { "DIRTY ($((($diff -split "`n") | Where-Object {$_}).Count) files)" } else { "clean" }
        $lastCommit = git -C $codeDir log -1 --format="%ar" 2>$null
        if (!$lastCommit) { $lastCommit = "-" }
    }

    # Overleaf: ahead/behind
    $overleafStatus = "-"
    if (Test-Path $overleafGit) {
        $overleafDir = Join-Path $proj.FullName "Overleaf_source"
        $behind = git -C $overleafDir rev-list "HEAD..origin/master" --count 2>$null
        $ahead  = git -C $overleafDir rev-list "origin/master..HEAD" --count 2>$null
        if ($null -ne $behind -and $null -ne $ahead) {
            if ($behind -eq "0" -and $ahead -eq "0") { $overleafStatus = "synced" }
            elseif ($behind -gt 0) { $overleafStatus = "BEHIND $behind" }
            elseif ($ahead -gt 0)  { $overleafStatus = "ahead $ahead"  }
        } else {
            $overleafStatus = "no remote"
        }
    }

    $rows += [PSCustomObject]@{
        Project        = $proj.Name
        "Last Session" = $lastSession
        "Code"         = $codeStatus
        "Last Commit"  = $lastCommit
        "Overleaf"     = $overleafStatus
    }
}

if ($rows.Count -eq 0) {
    Write-Host "No active projects found. Run with -All to see all projects."
    exit 0
}

Write-Host ""
Write-Host "  Active Projects" -ForegroundColor Cyan
Write-Host "  ═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

foreach ($r in $rows) {
    $codeColor = if ($r.Code -like "DIRTY*") { "Yellow" } else { "Green" }
    $olColor   = if ($r.Overleaf -like "BEHIND*") { "Red" } elseif ($r.Overleaf -eq "synced") { "Green" } else { "Gray" }

    Write-Host ("  {0}" -f $r.Project) -ForegroundColor White
    Write-Host ("    Session : {0}   Commit: {1}" -f $r."Last Session", $r."Last Commit") -ForegroundColor DarkGray
    Write-Host -NoNewline "    Code    : "
    Write-Host $r.Code -ForegroundColor $codeColor
    Write-Host -NoNewline "    Overleaf: "
    Write-Host $r.Overleaf -ForegroundColor $olColor
    Write-Host ""
}

Write-Host "  $($rows.Count) active project(s). Use -All to include projects without session logs." -ForegroundColor DarkCyan
Write-Host ""
