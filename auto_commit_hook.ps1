# auto_commit_hook.ps1
# Claude Code Stop hook: auto-commits any file changes in the current git repo.
# Walks up from the working directory to find a .git root (max 4 levels).

$dir = (Get-Location).Path

for ($i = 0; $i -lt 5; $i++) {
    if (Test-Path (Join-Path $dir ".git")) {
        git -C $dir add -A 2>$null
        git -C $dir diff --cached --quiet 2>$null
        if ($LASTEXITCODE -ne 0) {
            $ts = Get-Date -Format "yyyy-MM-dd HH:mm"
            git -C $dir commit --quiet -m "claude: auto-commit $ts" 2>$null
        }
        break
    }
    $parent = Split-Path $dir -Parent
    if ($parent -eq $dir) { break }
    $dir = $parent
}
