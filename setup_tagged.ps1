# setup_tagged.ps1
# Clones all Overleaf projects by tag into their target folders.
# Uses the cached debug_projects_page.html (re-fetches if needed via cookie).
#
# Tag -> Target folder mapping:
. "$PSScriptRoot\config.ps1"
# $tagTargets is defined in config.ps1
$jsonPath = "$aiRoot\projects.json"
$htmlPath = "$aiRoot\debug_projects_page.html"

Add-Type -AssemblyName System.Web

# --- Fetch fresh page if needed ---
if (!(Test-Path $htmlPath)) {
    Write-Host "No cached page found. Please provide your overleaf_session2 cookie." -ForegroundColor Yellow
    $sessionCookie = Read-Host "overleaf_session2"
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $cookie  = New-Object System.Net.Cookie("overleaf_session2", $sessionCookie, "/", "www.overleaf.com")
    $session.Cookies.Add($cookie)
    $page = Invoke-WebRequest -Uri "https://www.overleaf.com/project" -WebSession $session -UseBasicParsing
    $page.Content | Set-Content $htmlPath
}

$html = Get-Content $htmlPath -Raw

# --- Parse tags and projects ---
$html -match 'name="ol-tags"[^>]+content="([^"]+)"' | Out-Null
$tags = [System.Web.HttpUtility]::HtmlDecode($Matches[1]) | ConvertFrom-Json

$html -match 'name="ol-prefetchedProjectsBlob"[^>]+content="([^"]+)"' | Out-Null
$blob     = [System.Web.HttpUtility]::HtmlDecode($Matches[1]) | ConvertFrom-Json
$allProjs = $blob.projects

$projects = Get-Content $jsonPath | ConvertFrom-Json
$changed  = $false

foreach ($tagName in $tagTargets.Keys) {
    $targetRoot = $tagTargets[$tagName]
    $tagEntry   = $tags | Where-Object { $_.name -eq $tagName }

    if (-not $tagEntry) {
        Write-Host "Tag not found in Overleaf: '$tagName'" -ForegroundColor Yellow
        continue
    }

    Write-Host ""
    Write-Host "=== $tagName -> $targetRoot ===" -ForegroundColor Cyan

    $tagProjects = $allProjs | Where-Object { $tagEntry.project_ids -contains $_.id }
    Write-Host "  $($tagProjects.Count) projects found"

    foreach ($p in $tagProjects) {
        # Sanitise project name for use as folder name
        $folderName = $p.name -replace '[\\/:*?"<>|]', '_'
        $clonePath  = Join-Path $targetRoot $folderName

        # Skip if already cloned
        if (Test-Path (Join-Path $clonePath ".git")) {
            $alreadyIn = $projects | Where-Object { $_.path -eq $clonePath }
            if (-not $alreadyIn) {
                $projects += [PSCustomObject]@{ name = $p.name; path = $clonePath; branch = "master" }
                $changed = $true
            }
            Write-Host "  SKIP | $($p.name) (already cloned)"
            continue
        }

        # Clone
        Write-Host "  NEW  | $($p.name)"
        New-Item -ItemType Directory -Path $clonePath -Force | Out-Null
        git clone --quiet "https://git.overleaf.com/$($p.id)" $clonePath 2>&1 | Out-Null

        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ERR  | $($p.name) - clone failed" -ForegroundColor Red
            Remove-Item $clonePath -Recurse -Force -ErrorAction SilentlyContinue
            continue
        }

        # Detect branch
        $branch = "master"
        $head   = Join-Path $clonePath ".git\HEAD"
        if (Test-Path $head) {
            $h = Get-Content $head
            if ($h -match "refs/heads/(.+)") { $branch = $Matches[1] }
        }

        $projects += [PSCustomObject]@{ name = $p.name; path = $clonePath; branch = $branch }
        $changed = $true
        Write-Host "  OK   | $($p.name)" -ForegroundColor Green
    }
}

if ($changed) {
    $projects | ConvertTo-Json -Depth 5 | Set-Content $jsonPath
    Write-Host ""
    Write-Host "projects.json updated." -ForegroundColor Green
}

Write-Host ""
Write-Host "Done. All tagged projects are now registered and will sync every 4 hours." -ForegroundColor Green
