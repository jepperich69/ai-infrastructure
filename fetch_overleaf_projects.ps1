# fetch_overleaf_projects.ps1
# Uses your browser session cookie to fetch all Overleaf projects.
# Bypasses reCAPTCHA by reusing an existing browser login.
#
# HOW TO GET YOUR SESSION COOKIE:
#   1. Log into overleaf.com in your browser
#   2. Press F12 -> Application -> Cookies -> https://www.overleaf.com
#   3. Copy the value of the cookie named: overleaf_session2
#   4. Paste it when prompted below
#
# Usage:
#   .\fetch_overleaf_projects.ps1

. "$PSScriptRoot\config.ps1"

# --- Session cookie (never stored to disk) ---
Write-Host "Paste your 'overleaf_session2' cookie value (F12 -> Application -> Cookies):" -ForegroundColor Cyan
$sessionCookie = Read-Host "overleaf_session2"

if (-not $sessionCookie) {
    Write-Host "ERROR: No cookie provided." -ForegroundColor Red
    exit 1
}

# Build a web session with the cookie injected
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie  = New-Object System.Net.Cookie("overleaf_session2", $sessionCookie, "/", "www.overleaf.com")
$session.Cookies.Add($cookie)

# --- Fetch projects page ---
Write-Host "Fetching project list from Overleaf..." -ForegroundColor Cyan

try {
    $projectsPage = Invoke-WebRequest -Uri "https://www.overleaf.com/project" `
                                      -WebSession $session `
                                      -UseBasicParsing
} catch {
    Write-Host "ERROR: Could not fetch projects page: $_" -ForegroundColor Red
    exit 1
}

# Check we're not redirected to login page
if ($projectsPage.BaseResponse.RequestMessage.RequestUri.AbsolutePath -eq "/login") {
    Write-Host "ERROR: Cookie invalid or expired. Please get a fresh cookie from your browser." -ForegroundColor Red
    exit 1
}

Write-Host "  Connected successfully." -ForegroundColor Green

# --- Step 4: Extract project JSON ---
# Overleaf embeds projects in a meta tag: <meta name="ol-projects" ... content="[...]">
# or in a window.projectList = ... script block
$projectsJson = $null

# Try meta tag format (newer Overleaf)
if ($projectsPage.Content -match '<meta\s+name="ol-projects"[^>]+content="([^"]+)"') {
    $projectsJson = [System.Web.HttpUtility]::HtmlDecode($Matches[1])
}

# Try script-embedded JSON (older format)
if (-not $projectsJson -and $projectsPage.Content -match '"projects"\s*:\s*(\[[\s\S]*?\])\s*,\s*"totalSize"') {
    $projectsJson = $Matches[1]
}

# Try window.project_list
if (-not $projectsJson -and $projectsPage.Content -match 'window\.project_list\s*=\s*(\[[\s\S]*?\]);') {
    $projectsJson = $Matches[1]
}

if (-not $projectsJson) {
    Write-Host "ERROR: Could not extract project list from page." -ForegroundColor Red
    Write-Host "Saving page source for inspection to: $aiRoot\debug_projects_page.html" -ForegroundColor Yellow
    $projectsPage.Content | Set-Content "$aiRoot\debug_projects_page.html"
    exit 1
}

$projects = $projectsJson | ConvertFrom-Json

Write-Host "  Found $($projects.Count) Overleaf projects.`n" -ForegroundColor Green

# --- Step 5: Get local folders ---
$localFolders = Get-ChildItem $pubRoot -Directory | Select-Object -ExpandProperty Name

# --- Step 6: Build match table ---
# Check which are already in projects.json
$syncedPaths = (Get-Content "$aiRoot\projects.json" | ConvertFrom-Json).path

$results = @()
foreach ($p in $projects) {
    $id      = $p.id
    $name    = $p.name
    $gitUrl  = "https://git.overleaf.com/$id"

    # Try to find a matching local folder (fuzzy: ignore case, punctuation, spaces)
    $normalName = ($name -replace '[^a-zA-Z0-9]', '').ToLower()
    $matchedFolder = $localFolders | Where-Object {
        $normalFolder = ($_ -replace '[^a-zA-Z0-9]', '').ToLower()
        $normalFolder -like "*$normalName*" -or $normalName -like "*$normalFolder*"
    } | Select-Object -First 1

    $synced = if ($syncedPaths | Where-Object { $_ -like "*$id*" }) { "YES" } else { "no" }

    $results += [PSCustomObject]@{
        OverleafName  = $name
        GitUrl        = $gitUrl
        LocalFolder   = if ($matchedFolder) { $matchedFolder } else { "??? NO MATCH" }
        AlreadySynced = $synced
    }
}

# --- Step 7: Display table ---
Write-Host "=== Overleaf Projects ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize

# --- Step 8: Export CSV ---
$csvPath = "$aiRoot\overleaf_projects.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "Full list saved to: $csvPath" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: review the CSV, fix any '??? NO MATCH' entries," -ForegroundColor Yellow
Write-Host "then run link_projects.ps1 to clone and register everything." -ForegroundColor Yellow
