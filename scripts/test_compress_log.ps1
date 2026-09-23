$ErrorActionPreference = 'Stop'

$fixturePath = Join-Path $PSScriptRoot 'compress_log_metadata_fixture.md'
$scriptPath = Join-Path $PSScriptRoot 'compress_log.ps1'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("compress_log_test_" + [guid]::NewGuid().ToString('N'))

try {
    [void](New-Item -ItemType Directory -Path $testRoot)
    $testLog = Join-Path $testRoot '_ai_log.md'
    Copy-Item -LiteralPath $fixturePath -Destination $testLog

    Push-Location $testRoot
    try {
        & $scriptPath -ActiveCount 4
    } finally {
        Pop-Location
    }

    $result = Get-Content -LiteralPath $testLog -Raw -Encoding UTF8
    if ($result -notmatch '(?m)^\*\*Published status:\*\* Accepted$') {
        throw 'Published-status metadata was not preserved.'
    }
    if ($result -notmatch '(?m)^\*\*Journal:\*\* Test Journal$') {
        throw 'Journal metadata was not preserved.'
    }
    if ($result -notmatch '(?m)^\*\*Git ref:\*\* ---$') {
        throw 'Final Git ref placeholder was not preserved.'
    }

    Write-Host 'compress_log regression test passed.' -ForegroundColor Green
} finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}
