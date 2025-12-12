# Dracula Theme Installation Script for WezTerm
# https://draculatheme.com/wezterm

$repoUrl = "https://github.com/dracula/wezterm.git"
$targetDir = "$env:USERPROFILE\Documents\github\dracula-theme"

Write-Host "Ensuring directory exists: $targetDir" -ForegroundColor Cyan
if (-not (Test-Path $targetDir)) {
    New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
}

if (Test-Path "$targetDir\.git") {
    Write-Host "Repository already cloned in $targetDir" -ForegroundColor Yellow
} else {
    Write-Host "Cloning $repoUrl into $targetDir" -ForegroundColor Cyan
    git clone $repoUrl $targetDir
}