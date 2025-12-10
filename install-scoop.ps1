if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'RemoteSigned') {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Scoop is already installed. Checking for updates..."
    scoop update
} else {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}