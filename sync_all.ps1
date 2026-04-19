. "$PSScriptRoot\config.ps1"
$jsonPath = "$aiRoot\projects.json"
$csvPath  = "$aiRoot\papers.csv"
$logDir   = "$aiRoot\logs"

if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
$logFile = "$logDir\sync_$(Get-Date -Format 'yyyy-MM-dd').log"

function Write-Log {
    param([string]$message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

# ---------------------------------------------------------------
# STEP 1: Check papers.csv for new projects not yet cloned
# ---------------------------------------------------------------
if (Test-Path $csvPath) {
    $raw       = Get-Content $csvPath -First 1
    $delimiter = if ($raw -match ";") { ";" } else { "," }
    $rows      = Import-Csv $csvPath -Delimiter $delimiter
    $projects  = Get-Content $jsonPath | ConvertFrom-Json

    foreach ($row in $rows) {
        if ($row.LocalFolder -eq "" -or $row.LocalFolder -like "*NO MATCH*") { continue }

        $clonePath = Join-Path $pubRoot $row.LocalFolder | Join-Path -ChildPath $row.SubFolder

        # Auto-number if another repo already occupies this path
        $baseClone = $clonePath
        $suffix    = 2
        while ((Test-Path (Join-Path $clonePath ".git")) -and
               (git -C $clonePath remote get-url origin 2>$null) -ne $row.GitUrl) {
            $clonePath = "${baseClone}_${suffix}"
            $suffix++
        }

        # Skip if already cloned
        if (Test-Path (Join-Path $clonePath ".git")) { continue }

        # New project â€” clone it
        Write-Log "NEW  | $($row.LocalFolder)"
        New-Item -ItemType Directory -Path $clonePath -Force | Out-Null
        git clone --quiet $row.GitUrl $clonePath 2>&1 | Out-Null

        if ($LASTEXITCODE -ne 0) {
            Write-Log "ERR  | $($row.LocalFolder) - clone failed"
            continue
        }

        # Detect branch
        $branch = "master"
        $head   = Join-Path $clonePath ".git\HEAD"
        if (Test-Path $head) {
            $headContent = Get-Content $head
            if ($headContent -match "refs/heads/(.+)") { $branch = $Matches[1] }
        }

        # Register in projects.json
        $projects += [PSCustomObject]@{ name = $row.LocalFolder; path = $clonePath; branch = $branch }
        $projects | ConvertTo-Json -Depth 5 | Set-Content $jsonPath
        Write-Log "OK   | $($row.LocalFolder) - cloned and registered (branch: $branch)"
    }
}

# ---------------------------------------------------------------
# STEP 2: Pull updates for all registered projects (parallel)
# ---------------------------------------------------------------
$projects = Get-Content $jsonPath | ConvertFrom-Json

$logBag = [System.Collections.Concurrent.ConcurrentBag[string]]::new()

$syncScript = {
    param($project, $logBag)

    $ts = { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" }

    if (!(Test-Path $project.path)) {
        $logBag.Add("$(& $ts) - SKIP | $($project.name) - path not found")
        return
    }

    try {
        # Pre-check: compare remote HEAD SHA to local â€” skip pull if identical
        $remoteRef = git -C $project.path ls-remote origin HEAD 2>$null
        if ($remoteRef) {
            $remoteSHA = ($remoteRef -split '\s+')[0].Trim()
            $localSHA  = (git -C $project.path rev-parse HEAD 2>$null).Trim()
            if ($remoteSHA -eq $localSHA) {
                # Check for uncommitted local changes before skipping entirely
                git -C $project.path add . 2>&1 | Out-Null
                git -C $project.path diff --cached --quiet 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    $logBag.Add("$(& $ts) - OK   | $($project.name) - up to date")
                    return
                }
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
                git -C $project.path commit --quiet -m "Auto-backup $timestamp" 2>&1 | Out-Null
                $logBag.Add("$(& $ts) - OK   | $($project.name) - backed up local changes")
                return
            }
        }

        # Remote has new commits â€” pull
        git -C $project.path pull --quiet origin $project.branch 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $logBag.Add("$(& $ts) - ERR  | $($project.name) - pull failed")
            return
        }

        git -C $project.path add . 2>&1 | Out-Null
        git -C $project.path diff --cached --quiet 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $logBag.Add("$(& $ts) - OK   | $($project.name) - pulled (no local changes)")
            return
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        git -C $project.path commit --quiet -m "Auto-backup $timestamp" 2>&1 | Out-Null
        $logBag.Add("$(& $ts) - OK   | $($project.name) - pulled and backed up")
    }
    catch {
        $logBag.Add("$(& $ts) - ERR  | $($project.name) - $_")
    }
}

# Run up to 20 repos concurrently using a runspace pool
$pool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, 20)
$pool.Open()

$jobs = foreach ($project in $projects) {
    $ps = [System.Management.Automation.PowerShell]::Create()
    $ps.RunspacePool = $pool
    $ps.AddScript($syncScript).AddParameters(@{ project = $project; logBag = $logBag }) | Out-Null
    [PSCustomObject]@{ PS = $ps; Handle = $ps.BeginInvoke() }
}

# Wait for all jobs to finish
foreach ($job in $jobs) {
    $job.PS.EndInvoke($job.Handle)
    $job.PS.Dispose()
}

$pool.Close()
$pool.Dispose()

# Write collected log entries (sorted by timestamp so the log stays readable)
foreach ($entry in ($logBag | Sort-Object)) {
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}
