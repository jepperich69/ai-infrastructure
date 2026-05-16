function Get-AiLogSessions {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (!(Test-Path $Path)) { return @() }

    $raw = Get-Content $Path -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) { return @() }

    $lines = $raw -split "`r?`n"
    $sessions = @()
    $current = $null
    $currentField = $null

    foreach ($line in $lines) {
        if ($line -match '^##\s+Session\s+(.+)$') {
            if ($null -ne $current) {
                $sessions += [PSCustomObject]$current
            }

            $current = @{
                title = $Matches[1].Trim()
                order = $sessions.Count
                fields = [ordered]@{}
                raw_lines = @($line)
            }
            $currentField = $null
            continue
        }

        if ($null -eq $current) { continue }

        $current.raw_lines += $line

        if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim() -eq '---') {
            $currentField = $null
            continue
        }

        if ($line -match '^\*\*(.+?):\*\*\s*(.*)$') {
            $fieldName = $Matches[1].Trim()
            $fieldValue = $Matches[2].Trim()
            $values = [System.Collections.ArrayList]::new()
            if ($fieldValue) { [void]$values.Add($fieldValue) }
            $current.fields[$fieldName] = $values
            $currentField = $fieldName
            continue
        }

        if ($line -match '^[-*]\s+(.+)$' -and $null -ne $currentField) {
            [void]$current.fields[$currentField].Add($Matches[1].Trim())
            continue
        }

        if (![string]::IsNullOrWhiteSpace($line) -and $null -ne $currentField) {
            [void]$current.fields[$currentField].Add($line.Trim())
        }
    }

    if ($null -ne $current) {
        $sessions += [PSCustomObject]$current
    }

    return $sessions
}

function Get-AiLogLatestSession {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $sessions = Get-AiLogSessions -Path $Path
    if ($sessions.Count -eq 0) { return $null }
    return $sessions |
        Sort-Object `
            @{ Expression = {
                    if ($_.title -match '^(\d{4}-\d{2}-\d{2})') { [datetime]::ParseExact($Matches[1], 'yyyy-MM-dd', $null) }
                    else { [datetime]::MinValue }
                }; Descending = $true }, `
            @{ Expression = {
                    if ($_.title -match '^\d{4}-\d{2}-\d{2}(.*)$') { $Matches[1] } else { '' }
                }; Descending = $true }, `
            @{ Expression = { $_.order }; Descending = $true } |
        Select-Object -First 1
}

function Test-AiLogSessionComplete {
    param(
        [Parameter(Mandatory = $true)]
        $Session
    )

    $required = @('Agent', 'Goal', 'Outcome', 'Next steps')
    $missing = @()

    foreach ($name in $required) {
        if (!$Session.fields.Contains($name) -or $Session.fields[$name].Count -eq 0 -or [string]::IsNullOrWhiteSpace(($Session.fields[$name] -join ' ').Trim())) {
            $missing += $name
        }
    }

    [PSCustomObject]@{
        is_complete = ($missing.Count -eq 0)
        missing = $missing
    }
}

function Convert-AiLogSessionToSummary {
    param(
        [Parameter(Mandatory = $true)]
        $Session
    )

    $filesTouched = if ($Session.fields.Contains('Files touched')) { $Session.fields['Files touched'] } else { @() }

    [PSCustomObject]@{
        title = $Session.title
        agent = if ($Session.fields.Contains('Agent')) { ($Session.fields['Agent'] -join ' ') } else { '' }
        goal = if ($Session.fields.Contains('Goal')) { ($Session.fields['Goal'] -join ' ') } else { '' }
        outcome = if ($Session.fields.Contains('Outcome')) { ($Session.fields['Outcome'] -join ' ') } else { '' }
        next_steps = if ($Session.fields.Contains('Next steps')) { ($Session.fields['Next steps'] -join ' ') } else { '' }
        git_ref = if ($Session.fields.Contains('Git ref')) { ($Session.fields['Git ref'] -join ' ') } else { '' }
        files_touched = $filesTouched
    }
}
