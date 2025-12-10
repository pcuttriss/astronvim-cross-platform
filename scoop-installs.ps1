## Scoop Package Installs

function Install-ScoopApp {
    param (
        [Parameter(Mandatory=$true)]
        [string]$AppName,
        [string]$Description
    )

    if ($Description) {
        Write-Host $Description -ForegroundColor Cyan
    }

    # Check if installed by looking for the exact package name in the list output
    $isInstalled = (scoop list $AppName 2>$null) | Select-String -Pattern "^$AppName\s" -Quiet

    if ($isInstalled) {
        Write-Host "$AppName is already installed. Checking for updates..." -ForegroundColor Yellow
        scoop update $AppName
    } else {
        Write-Host "Installing $AppName..." -ForegroundColor Yellow
        scoop install $AppName
    }
}

Write-Host "Installing/Updating Scoop packages..." -ForegroundColor Cyan

# Zig - Required for nvim-treesitter on Windows
Install-ScoopApp -AppName "zig" -Description "Zig - Required for nvim-treesitter on Windows"

# rga - ripgrep-all (includes ripgrep)
Install-ScoopApp -AppName "rga" -Description "rga - ripgrep-all (includes ripgrep)"

# fzf - Fuzzy finder
Install-ScoopApp -AppName "fzf" -Description "fzf - Fuzzy finder"

# Fira Code Font
Write-Host "Ensuring nerd-fonts bucket is available..." -ForegroundColor Cyan
if (-not (scoop bucket list | Select-String "nerd-fonts" -Quiet)) {
    scoop bucket add nerd-fonts
}

Install-ScoopApp -AppName "FiraCode" -Description "Fira Code Font"

Write-Host "Scoop packages processing complete." -ForegroundColor Green