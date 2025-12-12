Write-Host "Starting Neovim Configuration Backup..." -ForegroundColor Cyan

# 1. Target Directory
$nvimPath = "$env:LOCALAPPDATA\nvim"
if (-not (Test-Path $nvimPath)) {
    Write-Host "Error: Neovim directory not found at $nvimPath" -ForegroundColor Red
    exit
}

Push-Location $nvimPath

# 2. Initialize Git
if (-not (Test-Path ".git")) {
    Write-Host "Initializing new Git repository..." -ForegroundColor Yellow
    git init
}

# 3. Add Files
Write-Host "Adding files to staging..." -ForegroundColor Yellow
git add .

# 4. Commit with Date/Time
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMsg = "Configuration backup: $timestamp"

$status = git status --porcelain
if ($status) {
    Write-Host "Committing changes..." -ForegroundColor Green
    git commit -m $commitMsg
} else {
    Write-Host "No changes detected to commit." -ForegroundColor Yellow
}

# 5. Prompt for GitHub Details
Write-Host "`n--- GitHub Remote Setup ---" -ForegroundColor Cyan
$userId = Read-Host "Enter your GitHub User ID"
$repoName = Read-Host "Enter the Repository Name"

if ([string]::IsNullOrWhiteSpace($userId) -or [string]::IsNullOrWhiteSpace($repoName)) {
    Write-Host "Missing User ID or Repository Name. Skipping push." -ForegroundColor Red
} else {
    $remoteUrl = "https://github.com/$userId/$repoName.git"
    
    # Configure Remote
    $currentRemote = git remote get-url origin 2>$null
    # We now check the exit code to determine if the remote exists
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Updating existing remote 'origin' to $remoteUrl" -ForegroundColor Yellow
        git remote set-url origin $remoteUrl
    } else {
        Write-Host "Adding remote 'origin' ($remoteUrl)..." -ForegroundColor Yellow
        git remote add origin $remoteUrl
    }

    # Push
    Write-Host "Pushing to GitHub (main branch)..." -ForegroundColor Cyan
    git branch -M main
    git push -u origin main
}

Pop-Location
Write-Host "Backup process completed." -ForegroundColor Green
