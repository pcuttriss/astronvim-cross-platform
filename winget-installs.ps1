## 💻 Windows Development Environment Setup Script

# Requires winget, which is included in modern versions of Windows 10/11.

# --- Function for Installation ---
function Install-App {
    param(
        [Parameter(Mandatory=$true)]
        [string]$AppId,
        [Parameter(Mandatory=$true)]
        [string]$AppName
    )

    Write-Host "Installing $AppName (ID: $AppId)..." -ForegroundColor Yellow
    
    # Use -h for silent installation if the app supports it.
    winget install --id $AppId -e -h 
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$AppName installed successfully." -ForegroundColor Green
    } elseif ($LASTEXITCODE -eq 17) {
        Write-Host "$AppName is already installed. Skipping." -ForegroundColor Cyan
    } else {
        Write-Host "Error installing $AppName. Exit code: $LASTEXITCODE" -ForegroundColor Red
    }
    Write-Host "---"
}

# --- Application Installations ---

# 1. Install PowerShell (PowerShell 7/Core)
# Note: PowerShell 7 is an optional install, separate from Windows PowerShell.
# The user's request specifically included this.
Install-App -AppId Microsoft.PowerShell -AppName "PowerShell (Core)"

# 2. Install Git
Install-App -AppId Git.Git -AppName "Git"

# 3. Install Neovim
Install-App -AppId Neovim.Neovim -AppName "Neovim"

# 4. Install Wezterm (Terminal Emulator)
# The second winget command you listed in your request for Wezterm (wez.wezterm) is used here.
Install-App -AppId wez.wezterm -AppName "Wezterm Terminal"

# 5. Install Lazygit (Terminal UI for Git)
Install-App -AppId JesseDuffield.lazygit -AppName "Lazygit"

# 6. Install Visual Studio Code
Install-App -AppId Microsoft.VisualStudioCode -AppName "Visual Studio Code"

Write-Host "✅ Setup script finished running." -ForegroundColor Green
