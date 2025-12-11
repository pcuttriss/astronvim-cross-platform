$bashrcPath = "$env:USERPROFILE\.bashrc"
$bashProfilePath = "$env:USERPROFILE\.bash_profile"

# Set prompt to user@host:path$
$bashrcContent = @'
# Custom Git-aware prompt
parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/\* \(.*\)/ (\1)/'
}

 
if echo "$USERNAME" | grep -iq "paulcuttriss"; then
  DISPLAY_USER="pcc"
else
  DISPLAY_USER="$USERNAME"
fi

PS1='\[\033[01;32m\]$DISPLAY_USER@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[0;33m\]$(parse_git_branch)\[\033[00m\] $ '
'@

if (Test-Path $bashrcPath) {
    Write-Host ".bashrc already exists at $bashrcPath" -ForegroundColor Yellow
    $response = Read-Host "Do you want to (R)ecreate it or edit it (M)anually? (r/m)"
    if ($response -match "^[rR]") {
        Write-Host "Recreating .bashrc..." -ForegroundColor Cyan
        Set-Content -Path $bashrcPath -Value $bashrcContent -Encoding UTF8
    } else {
        Write-Host "Skipping automatic creation." -ForegroundColor Cyan
        Write-Host "Please add the following to your .bashrc manually:" -ForegroundColor Green
        Write-Host $bashrcContent
    }
} else {
    Write-Host "Configuring .bashrc at $bashrcPath" -ForegroundColor Cyan
    Set-Content -Path $bashrcPath -Value $bashrcContent -Encoding UTF8
}

# Git Bash as a login shell (default in WezTerm config) needs .bash_profile to source .bashrc
if (-not (Test-Path $bashProfilePath)) {
    Write-Host "Creating .bash_profile to source .bashrc" -ForegroundColor Yellow
    $profileContent = @"
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
"@
    Set-Content -Path $bashProfilePath -Value $profileContent -Encoding UTF8
}