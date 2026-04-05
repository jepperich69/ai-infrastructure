$repo = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer\Public transport granularity\Napsti paper 1\Overleaf_source"
$branch = "main"   # change to master if needed

Set-Location $repo

git pull origin $branch

git add .

git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    exit
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
git commit -m "Auto-backup $timestamp"

git push github $branch