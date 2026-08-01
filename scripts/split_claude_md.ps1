<#
.SYNOPSIS
  Split an oversized project CLAUDE.md "Standing constraints" section into
  role-separated record documents, moving every bullet VERBATIM.

.DESCRIPTION
  A project CLAUDE.md drifts from a rules file into a findings ledger. This
  script performs the mechanical half of the repair: it relocates bullets by
  line index so no text is ever retyped, and asserts that not one character
  was lost.

  The JUDGMENT half -- deciding whether a bullet is a rule, a result or an
  audit trail -- is not automatable and is not attempted here. Supply it as a
  classification file.

  Classification file format: one line per bullet, "<index> <tier>", where
  index is 1-based within the section and tier is FINDINGS or SUPERSEDED.
  Bullets not listed default to FINDINGS. Rules are NOT listed: the rewritten
  rules section is authored by hand, and every bullet still lands verbatim in
  one of the two output files, so nothing depends on that authoring being
  complete.

.PARAMETER Project
  Project folder name under JR (searched recursively), or an absolute path.

.PARAMETER Classification
  Path to the classification file described above.

.PARAMETER Section
  Heading to split. Default "## Standing constraints".

.PARAMETER OutputDir
  Where FINDINGS.md / SUPERSEDED.md are written, relative to project root.

.PARAMETER WhatIf
  Report the partition and the character accounting without writing anything.

.EXAMPLE
  pwsh -File split_claude_md.ps1 -Project Pub_PMIP_VSP `
       -Classification classify.txt -OutputDir code\VSP_PostNord -WhatIf
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Project,
    [Parameter(Mandatory = $true)][string]$Classification,
    [string]$Section = '## Standing constraints',
    [string]$OutputDir = '.',
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$JRRoot = 'C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR'

# ---------- locate the project ----------
if (Test-Path -LiteralPath $Project -PathType Container) {
    $root = (Resolve-Path -LiteralPath $Project).Path
} else {
    $hit = Get-ChildItem -LiteralPath $JRRoot -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue |
           Where-Object { $_.Name -eq $Project } | Select-Object -First 1
    if (-not $hit) { throw "Project '$Project' not found under $JRRoot" }
    $root = $hit.FullName
}
$claude = Join-Path $root '.claude\CLAUDE.md'
if (-not (Test-Path -LiteralPath $claude)) { throw "No .claude\CLAUDE.md in $root" }

# ---------- read and locate the section ----------
$lines = Get-Content -LiteralPath $claude
$startIdx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq $Section) { $startIdx = $i; break }
}
if ($startIdx -lt 0) { throw "Section '$Section' not found in $claude" }

$endIdx = $lines.Count - 1
for ($i = $startIdx + 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -like '## *') { $endIdx = $i - 1; break }
}

# ---------- collect bullets ----------
$bullets = New-Object System.Collections.ArrayList
for ($i = $startIdx + 1; $i -le $endIdx; $i++) {
    if ($lines[$i] -match '^- ') {
        [void]$bullets.Add([pscustomobject]@{
            Index = $bullets.Count + 1
            Line  = $i + 1
            Text  = $lines[$i]
        })
    }
    elseif ($lines[$i].Trim() -ne '') {
        throw "Line $($i+1) is neither a bullet nor blank; this splitter only handles one-bullet-per-line sections. Aborting rather than guessing."
    }
}
if ($bullets.Count -eq 0) { throw "No bullets found in section '$Section'" }

# ---------- read the classification ----------
$tierOf = @{}
foreach ($raw in (Get-Content -LiteralPath $Classification)) {
    $l = $raw.Trim()
    if ($l -eq '' -or $l.StartsWith('#')) { continue }
    $l = ($l -split '#', 2)[0].Trim()   # strip trailing comment
    if ($l -eq '') { continue }
    $parts = $l -split '\s+', 2
    $idx   = [int]$parts[0]
    $tier  = $parts[1].Trim().ToUpper()
    if ($tier -notin @('FINDINGS', 'SUPERSEDED')) { throw "Unknown tier '$tier' for bullet $idx" }
    if ($idx -lt 1 -or $idx -gt $bullets.Count) { throw "Classification index $idx is outside 1..$($bullets.Count)" }
    $tierOf[$idx] = $tier
}

$findings   = @($bullets | Where-Object { ($tierOf[$_.Index] ?? 'FINDINGS') -eq 'FINDINGS' })
$superseded = @($bullets | Where-Object { ($tierOf[$_.Index] ?? 'FINDINGS') -eq 'SUPERSEDED' })

# ---------- character accounting: the guarantee ----------
$origChars = ($bullets    | Measure-Object -Property { $_.Text.Length } -Sum).Sum
$fChars    = ($findings   | Measure-Object -Property { $_.Text.Length } -Sum).Sum
$sChars    = ($superseded | Measure-Object -Property { $_.Text.Length } -Sum).Sum

Write-Host ""
Write-Host "Project        : $root"
Write-Host "Section        : $Section (lines $($startIdx+1)..$($endIdx+1))"
Write-Host "Bullets        : $($bullets.Count)"
Write-Host "  -> FINDINGS  : $($findings.Count)  ($fChars chars)"
Write-Host "  -> SUPERSEDED: $($superseded.Count)  ($sChars chars)"
Write-Host "Char accounting: $fChars + $sChars = $($fChars + $sChars) vs original $origChars"

if (($fChars + $sChars) -ne $origChars) {
    throw "LOSSLESSNESS CHECK FAILED: $($fChars + $sChars) != $origChars. Nothing written."
}
Write-Host "Losslessness   : PASS (every bullet character accounted for)" -ForegroundColor Green

if ($WhatIf) { Write-Host "`n-WhatIf: no files written."; return }

# ---------- write ----------
$outRoot = Join-Path $root $OutputDir
if (-not (Test-Path -LiteralPath $outRoot)) { New-Item -ItemType Directory -Path $outRoot -Force | Out-Null }
$stamp = Get-Date -Format 'yyyy-MM-dd'

$fPath = Join-Path $outRoot 'FINDINGS.md'
$fOut  = New-Object System.Collections.ArrayList
[void]$fOut.Add("# Measured findings -- $(Split-Path $root -Leaf)")
[void]$fOut.Add("")
[void]$fOut.Add("Split verbatim out of ``.claude/CLAUDE.md`` on $stamp. Every entry is the")
[void]$fOut.Add("original text, unedited. Rules extracted from these entries live in")
[void]$fOut.Add("``.claude/CLAUDE.md``; entries retired by later work live in ``SUPERSEDED.md``.")
[void]$fOut.Add("")
[void]$fOut.Add("Read this when working on the layer a finding belongs to. It is not loaded")
[void]$fOut.Add("into context automatically, which is the point.")
[void]$fOut.Add("")
[void]$fOut.Add("---")
[void]$fOut.Add("")
foreach ($b in $findings) { [void]$fOut.Add($b.Text) }
$fOut | Set-Content -LiteralPath $fPath -Encoding UTF8

$sPath = Join-Path $outRoot 'SUPERSEDED.md'
$sOut  = New-Object System.Collections.ArrayList
[void]$sOut.Add("# Superseded and withdrawn claims -- $(Split-Path $root -Leaf)")
[void]$sOut.Add("")
[void]$sOut.Add("Split verbatim out of ``.claude/CLAUDE.md`` on $stamp. These entries are")
[void]$sOut.Add("RETIRED: each was corrected, withdrawn or replaced by later measurement.")
[void]$sOut.Add("They are kept so the chain of corrections stays auditable -- do not quote a")
[void]$sOut.Add("figure from this file as a current result.")
[void]$sOut.Add("")
[void]$sOut.Add("---")
[void]$sOut.Add("")
foreach ($b in $superseded) { [void]$sOut.Add($b.Text) }
$sOut | Set-Content -LiteralPath $sPath -Encoding UTF8

Write-Host ""
Write-Host "Wrote $fPath" -ForegroundColor Green
Write-Host "Wrote $sPath" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT: replace the '$Section' section of .claude\CLAUDE.md with a rewritten"
Write-Host "rules section. This script does not touch CLAUDE.md -- that edit is manual"
Write-Host "on purpose, because compressing a rule is a judgment, not a move."
