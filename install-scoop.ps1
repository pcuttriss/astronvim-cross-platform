if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'RemoteSigned') {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Scoop is already installed. Checking for updates..."
    scoop update
} else {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

$ScoopPath = "$env:USERPROFILE\scoop\shims"
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check and update Persistent User Path
if ($UserPath -notlike "*$ScoopPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$ScoopPath", "User")
    Write-Host "Success! Scoop added to persistent User Path." -ForegroundColor Green
} else {
    Write-Host "Scoop is already in your persistent User Path." -ForegroundColor Yellow
}

# Check and update Current Session Path
if ($env:PATH -notlike "*$ScoopPath*") {
    $env:PATH = "$env:PATH;$ScoopPath"
    Write-Host "Success! Scoop added to current session Path." -ForegroundColor Green
} else {
    Write-Host "Scoop is already in your current session Path." -ForegroundColor Yellow
}