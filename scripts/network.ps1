# network.ps1  --  Generate a project network graph with cluster shading.
#                  No external dependencies. Opens in default browser.
# Usage:  network.ps1

. "$PSScriptRoot\config.ps1"
$outFile = Join-Path $aiRoot "network.html"

$projData = Get-Content "$aiRoot\projects.json" | ConvertFrom-Json

# â”€â”€ Helper: skip entries with path-illegal characters â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function Test-ValidName([string]$n) {
    return $n -and $n -notmatch '[<>:"|?*\x00-\x1f]'
}

# â”€â”€ Last-session dates â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$lastSessions = @{}
foreach ($proj in $projData) {
    if (-not (Test-ValidName $proj.name)) { continue }
    $logPath = Join-Path $pubRoot "$($proj.name)\_ai_log.md"
    try {
        if (Test-Path -LiteralPath $logPath) {
            $m = Select-String -LiteralPath $logPath -Pattern '^## Session (\d{4}-\d{2}-\d{2})' |
                 Select-Object -Last 1
            if ($m) { $lastSessions[$proj.name] = $m.Matches[0].Groups[1].Value }
        }
    } catch { }
}

# â”€â”€ Edges â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$edges    = [System.Collections.Generic.List[object]]::new()
$involved = [System.Collections.Generic.HashSet[string]]::new()

foreach ($proj in $projData) {
    if (-not (Test-ValidName $proj.name)) { continue }
    $feedersFile = Join-Path $pubRoot "$($proj.name)\_feeders.json"
    try { $exists = Test-Path -LiteralPath $feedersFile } catch { continue }
    if (-not $exists) { continue }

    $raw = Get-Content -LiteralPath $feedersFile -Raw | ConvertFrom-Json
    $feederNames = @()
    if ($raw.PSObject.Properties.Name -contains 'feeders' -and $raw.feeders -is [array]) {
        $feederNames = $raw.feeders | ForEach-Object { $_.name }
    } else {
        $feederNames = $raw.PSObject.Properties.Name
    }

    foreach ($feederName in $feederNames) {
        $lastSync = '?'
        if (-not ($raw.PSObject.Properties.Name -contains 'feeders')) {
            $entry = $raw.$feederName
            if ($entry -and $entry.last_synced_date) { $lastSync = $entry.last_synced_date }
        }
        $edges.Add([PSCustomObject]@{ from=$feederName; to=$proj.name; sync=$lastSync })
        [void]$involved.Add($feederName)
        [void]$involved.Add($proj.name)
    }
}

# â”€â”€ Connected-component clustering (union-find) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$parent = @{}
function Find-Root([string]$x) {
    if (-not $parent.ContainsKey($x)) { $parent[$x] = $x }
    if ($parent[$x] -ne $x) { $parent[$x] = Find-Root $parent[$x] }
    return $parent[$x]
}
function Union-Nodes([string]$x, [string]$y) {
    $px = Find-Root $x; $py = Find-Root $y
    if ($px -ne $py) { $parent[$px] = $py }
}
foreach ($e in $edges) { Union-Nodes $e.from $e.to }

$clusterIdMap  = @{}
$rootToCluster = @{}
$nextCluster   = 0
foreach ($name in ($involved | Sort-Object)) {
    $root = Find-Root $name
    if (-not $rootToCluster.ContainsKey($root)) {
        $rootToCluster[$root] = $nextCluster++
    }
    $clusterIdMap[$name] = $rootToCluster[$root]
}

# â”€â”€ Node list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$nodeList = [System.Collections.Generic.List[object]]::new()
foreach ($name in ($involved | Sort-Object)) {
    $session = if ($lastSessions.ContainsKey($name)) { $lastSessions[$name] } else { $null }
    $days    = if ($session) { ([datetime]::Today - [datetime]$session).Days } else { 9999 }
    $color   = if ($days -le 14) { '#2a7a52' } elseif ($days -le 60) { '#c8a000' } elseif ($days -le 9998) { '#9a3030' } else { '#aaaaaa' }
    $label   = $name -replace '^(Pub|Pro|PhD)_','' -replace '_TBA$','' -replace '_$',''
    $tip     = if ($session) { "Last session: $session" } else { "No sessions yet" }
    $cluster = $clusterIdMap[$name]
    $nodeList.Add([PSCustomObject]@{ name=$name; label=$label; color=$color; tip=$tip; cluster=$cluster })
}

# â”€â”€ Standalone list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$standaloneHtml = ($projData |
    Where-Object { -not $involved.Contains($_.name) } |
    Sort-Object name |
    ForEach-Object {
        $lbl = $_.name -replace '^(Pub|Pro|PhD)_','' -replace '_TBA$','' -replace '_$',''
        "<li>$lbl</li>"
    }) -join "`n"

# â”€â”€ Serialise to JSON â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$nodesJson = ($nodeList | ForEach-Object {
    $n = $_.name    | ConvertTo-Json -Compress
    $l = $_.label   | ConvertTo-Json -Compress
    $c = $_.color   | ConvertTo-Json -Compress
    $t = $_.tip     | ConvertTo-Json -Compress
    $k = $_.cluster
    "{name:$n,label:$l,color:$c,tip:$t,cluster:$k}"
}) -join ","

$edgesJson = ($edges | ForEach-Object {
    $f = $_.from | ConvertTo-Json -Compress
    $t = $_.to   | ConvertTo-Json -Compress
    $s = $_.sync | ConvertTo-Json -Compress
    "{from:$f,to:$t,sync:$s}"
}) -join ","

$genTime     = Get-Date -Format "yyyy-MM-dd HH:mm"
$nTotal      = $projData.Count
$nConnected  = $involved.Count
$nEdges      = $edges.Count
$nClusters   = $nextCluster
$nStandalone = $nTotal - $nConnected

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Research Project Network</title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: Georgia, serif; background: #f4f7fb; }
#header { padding: 12px 24px; background: #2c5f8a; color: #fff; display: flex; align-items: baseline; gap: 20px; }
#header h1 { font-size: 1.1em; font-weight: bold; }
#header .sub { font-size: 0.78em; opacity: 0.75; }
#legend { padding: 8px 24px; background: #fff; border-bottom: 1px solid #dde4ee; display: flex; gap: 18px; align-items: center; font-size: 0.75em; color: #444; flex-wrap: wrap; }
.leg { display: flex; align-items: center; gap: 5px; }
.dot { width: 12px; height: 12px; border-radius: 50%; border: 1px solid #555; flex-shrink: 0; }
#toolbar { padding: 6px 24px; background: #eef2f8; border-bottom: 1px solid #dde4ee; display: flex; gap: 12px; align-items: center; font-size: 0.78em; }
button { padding: 4px 12px; background: #2c5f8a; color: #fff; border: none; border-radius: 3px; cursor: pointer; font-size: 0.9em; }
button:hover { background: #1a3f6a; }
#canvas-wrap { padding: 20px; display: flex; justify-content: center; }
canvas { background: #fff; border: 1px solid #dde4ee; border-radius: 4px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
#tooltip { position: fixed; background: rgba(30,40,60,0.92); color: #fff; padding: 6px 10px; border-radius: 4px; font-size: 0.75em; pointer-events: none; display: none; max-width: 260px; line-height: 1.5; white-space: pre-line; }
#standalone { padding: 12px 24px 20px; font-size: 0.75em; color: #666; }
#standalone summary { cursor: pointer; color: #2c5f8a; font-weight: bold; }
#standalone ul { margin-top: 8px; columns: 4; column-gap: 20px; list-style: none; }
#standalone li { padding: 2px 0; }
</style>
</head>
<body>
<div id="header">
  <h1>Research Project Network</h1>
  <span class="sub">Generated $genTime &bull; $nConnected connected / $nTotal total &bull; $nEdges feeder links &bull; $nClusters clusters</span>
</div>
<div id="legend">
  <strong style="color:#555">Last session:</strong>
  <div class="leg"><div class="dot" style="background:#2a7a52"></div>&le;14 days</div>
  <div class="leg"><div class="dot" style="background:#c8a000"></div>15-60 days</div>
  <div class="leg"><div class="dot" style="background:#9a3030"></div>&gt;60 days</div>
  <div class="leg"><div class="dot" style="background:#aaaaaa"></div>no sessions</div>
  <span style="margin-left:6px;border-left:1px solid #ddd;padding-left:14px;color:#5080a8">shaded area = cluster &bull; arrow = feeder link</span>
</div>
<div id="toolbar">
  <button onclick="resetLayout()">Reset layout</button>
  <button onclick="window.print()">Print / Save PDF</button>
  <span style="color:#888">Drag nodes &bull; Scroll to zoom &bull; Click-drag background to pan</span>
</div>
<div id="canvas-wrap"><canvas id="c"></canvas></div>
<div id="tooltip"></div>
<details id="standalone">
  <summary>Standalone projects ($nStandalone - no feeder links)</summary>
  <ul>
$standaloneHtml
  </ul>
</details>
<script>
var RAW_NODES = [$nodesJson];
var RAW_EDGES = [$edgesJson];

var CLUSTER_FILL   = ['rgba(44,95,138,0.10)','rgba(42,107,74,0.10)','rgba(122,92,0,0.10)',
                      'rgba(138,44,44,0.10)','rgba(74,74,154,0.10)','rgba(44,122,122,0.10)',
                      'rgba(138,42,106,0.10)','rgba(80,60,20,0.10)','rgba(20,80,80,0.10)'];
var CLUSTER_STROKE = ['rgba(44,95,138,0.40)','rgba(42,107,74,0.40)','rgba(122,92,0,0.40)',
                      'rgba(138,44,44,0.40)','rgba(74,74,154,0.40)','rgba(44,122,122,0.40)',
                      'rgba(138,42,106,0.40)','rgba(80,60,20,0.40)','rgba(20,80,80,0.40)'];

var canvas = document.getElementById('c');
var ctx = canvas.getContext('2d');
var W = 960, H = 600;
var dpr = window.devicePixelRatio || 1;
canvas.width  = W * dpr; canvas.height = H * dpr;
canvas.style.width = W+'px'; canvas.style.height = H+'px';
ctx.scale(dpr, dpr);

// Initial positions on a circle
var N = RAW_NODES.length;
var pos = {}, vel = {};
RAW_NODES.forEach(function(n, i) {
  var angle = 2 * Math.PI * i / N;
  var r = Math.min(W, H) * 0.35;
  pos[n.name] = { x: W/2 + r*Math.cos(angle), y: H/2 + r*Math.sin(angle) };
  vel[n.name] = { x: 0, y: 0 };
});

// Force simulation
for (var iter = 0; iter < 800; iter++) {
  var f = {};
  RAW_NODES.forEach(function(n) { f[n.name] = { x:0, y:0 }; });

  for (var i = 0; i < N; i++) {
    for (var j = i+1; j < N; j++) {
      var a = RAW_NODES[i], b = RAW_NODES[j];
      var dx = pos[b.name].x - pos[a.name].x, dy = pos[b.name].y - pos[a.name].y;
      var d = Math.max(Math.sqrt(dx*dx+dy*dy), 1);
      // Stronger repulsion between different clusters
      var rep = (a.cluster === b.cluster ? 18000 : 28000) / (d*d);
      f[a.name].x -= rep*dx/d; f[a.name].y -= rep*dy/d;
      f[b.name].x += rep*dx/d; f[b.name].y += rep*dy/d;
    }
  }

  RAW_EDGES.forEach(function(e) {
    if (!pos[e.from] || !pos[e.to]) return;
    var dx = pos[e.to].x - pos[e.from].x, dy = pos[e.to].y - pos[e.from].y;
    var d = Math.max(Math.sqrt(dx*dx+dy*dy), 1);
    var att = (d - 140) * 0.05;
    f[e.from].x += att*dx/d; f[e.from].y += att*dy/d;
    f[e.to].x   -= att*dx/d; f[e.to].y   -= att*dy/d;
  });

  RAW_NODES.forEach(function(n) {
    f[n.name].x += (W/2 - pos[n.name].x) * 0.015;
    f[n.name].y += (H/2 - pos[n.name].y) * 0.015;
  });

  var cool = 1 - iter/800;
  RAW_NODES.forEach(function(n) {
    vel[n.name].x = (vel[n.name].x + f[n.name].x) * 0.4;
    vel[n.name].y = (vel[n.name].y + f[n.name].y) * 0.4;
    pos[n.name].x = Math.max(70, Math.min(W-70, pos[n.name].x + vel[n.name].x * cool));
    pos[n.name].y = Math.max(40, Math.min(H-40, pos[n.name].y + vel[n.name].y * cool));
  });
}

// Convex hull (Jarvis march)
function convexHull(pts) {
  if (pts.length < 2) return pts;
  var start = pts.reduce(function(a,b){ return a.x < b.x ? a : b; });
  var hull = [], cur = start, iters = 0;
  do {
    hull.push(cur);
    var nxt = pts[0];
    for (var i = 1; i < pts.length; i++) {
      if (nxt === cur) { nxt = pts[i]; continue; }
      var cross = (nxt.x-cur.x)*(pts[i].y-cur.y) - (nxt.y-cur.y)*(pts[i].x-cur.x);
      var d1 = Math.hypot(nxt.x-cur.x, nxt.y-cur.y);
      var d2 = Math.hypot(pts[i].x-cur.x, pts[i].y-cur.y);
      if (cross < 0 || (cross === 0 && d2 > d1)) nxt = pts[i];
    }
    cur = nxt;
  } while (cur !== start && ++iters <= pts.length + 2);
  return hull;
}

// Expand hull outward by padding px
function expandHull(hull, pad) {
  var cx = hull.reduce(function(s,p){return s+p.x;},0)/hull.length;
  var cy = hull.reduce(function(s,p){return s+p.y;},0)/hull.length;
  return hull.map(function(p){
    var dx=p.x-cx, dy=p.y-cy, d=Math.hypot(dx,dy)||1;
    return {x: p.x+dx/d*pad, y: p.y+dy/d*pad};
  });
}

var R = 28;
var tr = { x:0, y:0, s:1 };
var dragging = null, dragOX = 0, dragOY = 0;
var panning = false, panSX = 0, panSY = 0, panOX = 0, panOY = 0;

function toWorld(sx,sy) { return { x:(sx-tr.x)/tr.s, y:(sy-tr.y)/tr.s }; }

function draw() {
  ctx.clearRect(0, 0, W, H);
  ctx.save();
  ctx.translate(tr.x, tr.y);
  ctx.scale(tr.s, tr.s);

  // â”€â”€ Cluster convex hulls â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  var clusterPts = {};
  RAW_NODES.forEach(function(n) {
    var c = n.cluster;
    if (!clusterPts[c]) clusterPts[c] = [];
    var p = pos[n.name];
    // Add points around the node circle for better hull shape
    for (var a = 0; a < 8; a++) {
      clusterPts[c].push({ x: p.x + R*Math.cos(a*Math.PI/4), y: p.y + R*Math.sin(a*Math.PI/4) });
    }
  });
  Object.keys(clusterPts).forEach(function(c) {
    var hull = convexHull(clusterPts[c]);
    if (hull.length < 2) return;
    var exp = expandHull(hull, 14);
    var ci = parseInt(c) % CLUSTER_FILL.length;
    ctx.beginPath();
    ctx.moveTo(exp[0].x, exp[0].y);
    for (var i = 1; i < exp.length; i++) ctx.lineTo(exp[i].x, exp[i].y);
    ctx.closePath();
    ctx.fillStyle = CLUSTER_FILL[ci];
    ctx.fill();
    ctx.strokeStyle = CLUSTER_STROKE[ci];
    ctx.lineWidth = 1.5;
    ctx.setLineDash([5,4]);
    ctx.stroke();
    ctx.setLineDash([]);
  });

  // â”€â”€ Edges â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  RAW_EDGES.forEach(function(e) {
    if (!pos[e.from] || !pos[e.to]) return;
    var fx=pos[e.from].x, fy=pos[e.from].y, tx=pos[e.to].x, ty=pos[e.to].y;
    var dx=tx-fx, dy=ty-fy, d=Math.sqrt(dx*dx+dy*dy)||1;
    var sx2=fx+dx/d*R, sy2=fy+dy/d*R, ex=tx-dx/d*(R+9), ey=ty-dy/d*(R+9);
    ctx.beginPath(); ctx.moveTo(sx2,sy2); ctx.lineTo(ex,ey);
    ctx.strokeStyle='#5080a8'; ctx.lineWidth=1.5; ctx.stroke();
    var ang=Math.atan2(dy,dx);
    ctx.beginPath(); ctx.moveTo(ex,ey);
    ctx.lineTo(ex-10*Math.cos(ang-0.4), ey-10*Math.sin(ang-0.4));
    ctx.lineTo(ex-10*Math.cos(ang+0.4), ey-10*Math.sin(ang+0.4));
    ctx.closePath(); ctx.fillStyle='#5080a8'; ctx.fill();
  });

  // â”€â”€ Nodes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  RAW_NODES.forEach(function(n) {
    var x=pos[n.name].x, y=pos[n.name].y;
    ctx.beginPath(); ctx.arc(x,y,R,0,2*Math.PI);
    ctx.fillStyle=n.color; ctx.fill();
    ctx.strokeStyle='#222'; ctx.lineWidth=1.5; ctx.stroke();
    ctx.fillStyle='#fff'; ctx.font='bold 8.5px Consolas,monospace';
    ctx.textAlign='center'; ctx.textBaseline='middle';
    var words=n.label.split('_'), lines=[], cur='';
    words.forEach(function(w){
      if ((cur+(cur?'_':'')+w).length>13){if(cur)lines.push(cur);cur=w;}
      else{cur=cur?cur+'_'+w:w;}
    });
    if(cur)lines.push(cur);
    var lh=11, top=y-(lines.length-1)*lh/2;
    lines.forEach(function(l,i){ctx.fillText(l,x,top+i*lh);});
  });

  ctx.restore();
}

function resetLayout() { tr={x:0,y:0,s:1}; draw(); }

var tip = document.getElementById('tooltip');
function nodeAt(sx,sy) {
  var w=toWorld(sx,sy);
  return RAW_NODES.filter(function(n){
    var dx=pos[n.name].x-w.x, dy=pos[n.name].y-w.y;
    return Math.sqrt(dx*dx+dy*dy)<=R/tr.s;
  })[0]||null;
}
function edgeAt(sx,sy) {
  var w=toWorld(sx,sy);
  return RAW_EDGES.filter(function(e){
    if(!pos[e.from]||!pos[e.to])return false;
    var x1=pos[e.from].x,y1=pos[e.from].y,x2=pos[e.to].x,y2=pos[e.to].y;
    var dx=x2-x1,dy=y2-y1,len=Math.sqrt(dx*dx+dy*dy)||1;
    var t=Math.max(0,Math.min(1,((w.x-x1)*dx+(w.y-y1)*dy)/(len*len)));
    var px=x1+t*dx-w.x,py=y1+t*dy-w.y;
    return Math.sqrt(px*px+py*py)<=9/tr.s;
  })[0]||null;
}

canvas.addEventListener('mousemove',function(ev){
  var r=canvas.getBoundingClientRect(),sx=ev.clientX-r.left,sy=ev.clientY-r.top;
  if(dragging){var w=toWorld(sx+dragOX,sy+dragOY);pos[dragging].x=w.x;pos[dragging].y=w.y;draw();return;}
  if(panning){tr.x=panOX+(sx-panSX);tr.y=panOY+(sy-panSY);draw();return;}
  var n=nodeAt(sx,sy),e=(!n)&&edgeAt(sx,sy);
  if(n){tip.style.display='block';tip.style.left=(ev.clientX+14)+'px';tip.style.top=(ev.clientY-10)+'px';tip.textContent=n.tip;canvas.style.cursor='grab';}
  else if(e){tip.style.display='block';tip.style.left=(ev.clientX+14)+'px';tip.style.top=(ev.clientY-10)+'px';tip.textContent=e.from+' -> '+e.to+'\nDigest synced: '+e.sync;canvas.style.cursor='default';}
  else{tip.style.display='none';canvas.style.cursor='move';}
});
canvas.addEventListener('mousedown',function(ev){
  var r=canvas.getBoundingClientRect(),sx=ev.clientX-r.left,sy=ev.clientY-r.top;
  var n=nodeAt(sx,sy);
  if(n){dragging=n.name;dragOX=pos[n.name].x*tr.s+tr.x-sx;dragOY=pos[n.name].y*tr.s+tr.y-sy;}
  else{panning=true;panSX=sx;panSY=sy;panOX=tr.x;panOY=tr.y;}
});
canvas.addEventListener('mouseup',function(){dragging=null;panning=false;});
canvas.addEventListener('mouseleave',function(){dragging=null;panning=false;tip.style.display='none';});
canvas.addEventListener('wheel',function(ev){
  ev.preventDefault();
  var r=canvas.getBoundingClientRect(),sx=ev.clientX-r.left,sy=ev.clientY-r.top;
  var f=ev.deltaY<0?1.12:0.89;
  tr.x=sx+(tr.x-sx)*f;tr.y=sy+(tr.y-sy)*f;tr.s*=f;draw();
},{passive:false});

draw();
</script>
</body>
</html>
"@

[System.IO.File]::WriteAllText($outFile, $html, [System.Text.Encoding]::UTF8)

Write-Host ""
Write-Host "  Network graph generated" -ForegroundColor Green
Write-Host "  Projects    : $nTotal ($nConnected connected, $nStandalone standalone)"
Write-Host "  Feeder links: $nEdges"
Write-Host "  Clusters    : $nClusters"
Write-Host "  Output      : $outFile"
Write-Host ""
Start-Process $outFile
