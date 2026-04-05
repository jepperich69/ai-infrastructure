# link_projects.ps1
# Reads overleaf_projects.csv and clones + registers all matched projects.
# Run AFTER reviewing/fixing the CSV from fetch_overleaf_projects.ps1.
#
# Usage:
#   .\link_projects.ps1            # dry run (shows what would happen)
#   .\link_projects.ps1 -Execute   # actually clones and registers

param(
    [switch]$Execute
)

$pubRoot  = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"
$aiRoot   = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto"
$csvPath  = "$aiRoot\papers.csv"
$jsonPath = "$aiRoot\projects.json"

if (!(Test-Path $csvPath)) {
    Write-Host "ERROR: $csvPath not found." -ForegroundColor Red
    exit 1
}

# Handle both comma and semicolon delimiters (Excel Danish locale uses semicolons)
$raw       = Get-Content $csvPath -First 1
$delimiter = if ($raw -match ";") { ";" } else { "," }
$rows      = Import-Csv $csvPath -Delimiter $delimiter
$projects  = Get-Content $jsonPath | ConvertFrom-Json

if (-not $Execute) {
    Write-Host "=== DRY RUN (use -Execute to apply) ===" -ForegroundColor Yellow
    Write-Host ""
}

$cloned    = 0
$skipped   = 0
$errors    = 0
$noMatch   = 0

foreach ($row in $rows) {
    $overleafName = $row.OverleafName
    $gitUrl       = $row.GitUrl
    $localFolder  = $row.LocalFolder
    $alreadySynced = $row.AlreadySynced

    # Skip already synced
    if ($alreadySynced -eq "YES") {
        Write-Host "  SKIP (already synced): $overleafName" -ForegroundColor Gray
        $skipped++
        continue
    }

    # Skip unmatched
    if ($localFolder -eq "" -or $localFolder -like "*NO MATCH*") {
        Write-Host "  SKIP (no local folder): $overleafName" -ForegroundColor Yellow
        $noMatch++
        continue
    }

    # Build clone path, auto-numbering if another repo already occupies Overleaf_source
    $baseClone = Join-Path $pubRoot $localFolder | Join-Path -ChildPath "Overleaf_source"
    $clonePath = $baseClone
    $suffix    = 2
    while ((Test-Path (Join-Path $clonePath ".git")) -and
           (git -C $clonePath remote get-url origin 2>$null) -ne $gitUrl) {
        $clonePath = "${baseClone}_${suffix}"
        $suffix++
    }

    Write-Host "  $overleafName" -ForegroundColor Cyan
    Write-Host "    -> $clonePath"

    if ($Execute) {
        # Clone if not already present
        if (Test-Path (Join-Path $clonePath ".git")) {
            Write-Host "    Already cloned, skipping git clone." -ForegroundColor Gray
        } else {
            git clone $gitUrl $clonePath 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "    ERROR: clone failed." -ForegroundColor Red
                $errors++
                continue
            }
        }

        # Detect branch
        $branch = "master"
        $headFile = Join-Path $clonePath ".git\HEAD"
        if (Test-Path $headFile) {
            $headContent = Get-Content $headFile
            if ($headContent -match "refs/heads/(.+)") { $branch = $Matches[1] }
        }

        # Add to projects.json if not already there
        $alreadyIn = $projects | Where-Object { $_.path -eq $clonePath }
        if (-not $alreadyIn) {
            $newEntry = [PSCustomObject]@{
                name   = $localFolder
                path   = $clonePath
                branch = $branch
            }
            $projects += $newEntry
            Write-Host "    Added to projects.json (branch: $branch)" -ForegroundColor Green
        } else {
            Write-Host "    Already in projects.json." -ForegroundColor Gray
        }

        $cloned++
    } else {
        $cloned++
    }
}

if ($Execute) {
    $projects | ConvertTo-Json -Depth 5 | Set-Content $jsonPath
    Write-Host ""
    Write-Host "=== Done ===" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "=== Dry run summary ===" -ForegroundColor Yellow
}

Write-Host "  Would clone / cloned : $cloned"
Write-Host "  Already synced       : $skipped"
Write-Host "  No local folder match: $noMatch"
Write-Host "  Errors               : $errors"

if (-not $Execute -and $cloned -gt 0) {
    Write-Host ""
    Write-Host "Run with -Execute to apply changes." -ForegroundColor Cyan
}
