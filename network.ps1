# network.ps1  --  Generate an interactive HTML network graph of all projects
#                  and their feeder links. Opens in default browser when done.
#
# Usage:  network.ps1

$aiRoot  = Split-Path -Parent $MyInvocation.MyCommand.Path
$pubRoot = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"
$outFile = Join-Path $aiRoot "network.html"

$projData = Get-Content "$aiRoot\projects.json" | ConvertFrom-Json

$nodes    = [System.Collections.Generic.List[string]]::new()
$edges    = [System.Collections.Generic.List[string]]::new()
$nameToId = @{}
$id       = 1

# ── Build nodes ───────────────────────────────────────────────────────────────
foreach ($proj in $projData) {
    $name = $proj.name
    $root = Join-Path $pubRoot $name

    # Last session date from _ai_log.md
    $lastSession = $null
    $logPath = Join-Path $root "_ai_log.md"
    if (Test-Path $logPath) {
        $m = Select-String -Path $logPath -Pattern '^## Session (\d{4}-\d{2}-\d{2})' |
             Select-Object -Last 1
        if ($m) { $lastSession = $m.Matches[0].Groups[1].Value }
    }

    # Color by recency
    if ($lastSession) {
        $days  = ([datetime]::Today - [datetime]$lastSession).Days
        $color = if ($days -le 14) { '#2a6b4a' } elseif ($days -le 60) { '#c8a000' } else { '#8a2c2c' }
        $tip   = "$name\nLast session: $lastSession ($days days ago)"
    } else {
        $color = '#999999'
        $tip   = "$name\nNo sessions yet"
    }

    # Has feeders?
    $hasFeeders = Test-Path (Join-Path $root "_feeders.json")
    $shape = if ($hasFeeders) { 'diamond' } else { 'box' }

    $label = $name -replace '^(Pub|Pro|PhD)_','' -replace '_TBA$','' -replace '_$',''

    $nameToId[$name] = $id
    $nodes.Add("{id:$id,label:$(($label|ConvertTo-Json -Compress)),title:$(($tip|ConvertTo-Json -Compress)),shape:'$shape',color:{background:$(($color|ConvertTo-Json -Compress)),border:'#222',highlight:{background:'#4a90c8',border:'#1a3a6a'}}}")
    $id++
}

# ── Build edges from _feeders.json files ─────────────────────────────────────
foreach ($proj in $projData) {
    $name        = $proj.name
    $feedersFile = Join-Path $pubRoot "$name\_feeders.json"
    if (-not (Test-Path $feedersFile)) { continue }

    $feeders = Get-Content $feedersFile | ConvertFrom-Json
    foreach ($feederName in $feeders.PSObject.Properties.Name) {
        if (-not $nameToId.ContainsKey($feederName)) { continue }
        if (-not $nameToId.ContainsKey($name))       { continue }

        $lastSync = if ($feeders.$feederName.last_synced_date) { $feeders.$feederName.last_synced_date } else { '?' }
        $tip = "Feeder: $feederName → $name\nDigest last synced: $lastSync"
        $edges.Add("{from:$($nameToId[$feederName]),to:$($nameToId[$name]),arrows:'to',title:$(($tip|ConvertTo-Json -Compress)),color:{color:'#5080a8',highlight:'#2c5f8a'},width:2}")
    }
}

$nodesJs = $nodes -join ","
$edgesJs = $edges -join ","
$genTime = Get-Date -Format "yyyy-MM-dd HH:mm"
$nProj   = $projData.Count
$nEdges  = $edges.Count

# ── Write HTML ────────────────────────────────────────────────────────────────
@"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Research Project Network</title>
<script src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: Georgia, serif; background: #f6f8fb; display: flex; flex-direction: column; height: 100vh; }
  #header { padding: 14px 24px; background: #2c5f8a; color: #fff;
            display: flex; align-items: baseline; gap: 20px; flex-shrink: 0; }
  #header h1 { font-size: 1.15em; }
  #header .sub { font-size: 0.8em; color: rgba(255,255,255,0.7); }
  #legend { padding: 8px 24px; background: #fff; border-bottom: 1px solid #dde4ee;
            display: flex; gap: 22px; align-items: center; font-size: 0.8em;
            color: #444; flex-shrink: 0; flex-wrap: wrap; }
  .leg { display: flex; align-items: center; gap: 6px; }
  .leg-dot { width: 13px; height: 13px; border-radius: 50%; border: 1px solid #333; flex-shrink: 0; }
  .leg-diamond { width: 13px; height: 13px; background: #ccc; border: 1px solid #333;
                 transform: rotate(45deg); flex-shrink: 0; }
  #network { flex: 1; }
</style>
</head>
<body>
<div id="header">
  <h1>Research Project Network</h1>
  <span class="sub">Generated $genTime &bull; $nProj projects &bull; $nEdges feeder links</span>
</div>
<div id="legend">
  <span style="font-weight:bold; color:#555;">Last session:</span>
  <div class="leg"><div class="leg-dot" style="background:#2a6b4a"></div>&le;14 days</div>
  <div class="leg"><div class="leg-dot" style="background:#c8a000"></div>15–60 days</div>
  <div class="leg"><div class="leg-dot" style="background:#8a2c2c"></div>&gt;60 days</div>
  <div class="leg"><div class="leg-dot" style="background:#999"></div>no sessions</div>
  <span style="margin-left:8px; border-left:1px solid #ddd; padding-left:16px; color:#555; font-weight:bold;">Shape:</span>
  <div class="leg"><div class="leg-diamond"></div>has feeders</div>
  <div class="leg"><div class="leg-dot" style="border-radius:3px; background:#dde8f8"></div>standalone</div>
  <span style="margin-left:8px; border-left:1px solid #ddd; padding-left:16px; color:#5080a8;">&#8594; feeder link (hover for sync date)</span>
</div>
<div id="network"></div>
<script>
var nodes = new vis.DataSet([$nodesJs]);
var edges = new vis.DataSet([$edgesJs]);
var net = new vis.Network(
  document.getElementById('network'),
  { nodes: nodes, edges: edges },
  {
    nodes: { font: { size: 12, face: 'Consolas, monospace', color: '#fff' },
             borderWidth: 1.5, widthConstraint: { maximum: 200 } },
    edges: { smooth: { type: 'curvedCW', roundness: 0.2 } },
    physics: { stabilization: { iterations: 300 },
               barnesHut: { gravitationalConstant: -9000, centralGravity: 0.25,
                            springLength: 180, springConstant: 0.04 } },
    interaction: { hover: true, tooltipDelay: 80, navigationButtons: true, keyboard: true }
  }
);
</script>
</body>
</html>
"@ | Out-File -FilePath $outFile -Encoding UTF8

Write-Host ""
Write-Host "  Network graph generated" -ForegroundColor Green
Write-Host "  Projects    : $nProj"
Write-Host "  Feeder links: $nEdges"
Write-Host "  Output      : $outFile"
Write-Host ""
Start-Process $outFile
