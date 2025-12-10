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

    Write-Host "Checking for $AppName (ID: $AppId)..." -ForegroundColor Yellow

    # Check if the app is already installed and capture output
    $listOutput = winget list --id $AppId --exact 2>&1

    if ($LASTEXITCODE -eq 0) {
        # App is installed, check for updates by parsing the output
        $line = $listOutput | Select-String -Pattern $AppId -SimpleMatch | Select-Object -First 1
        
        if ($line) {
            $lineStr = $line.ToString()
            # Find index of AppId to ignore the Name column
            $idIndex = $lineStr.IndexOf($AppId, [System.StringComparison]::OrdinalIgnoreCase)
            
            if ($idIndex -ge 0) {
                $rest = $lineStr.Substring($idIndex)
                $tokens = $rest -split '\s+'
                
                # If tokens count >= 4, it usually means: Id, Version, Available, Source
                if ($tokens.Count -ge 4) {
                    $newVer = $tokens[2]
                    Write-Host "$AppName is installed but a newer version ($newVer) is available." -ForegroundColor Cyan
                    $response = Read-Host "Do you want to update $AppName? (y/n)"
                    if ($response -match "^[yY]") {
                        Write-Host "Updating $AppName..." -ForegroundColor Yellow
                        winget upgrade --id $AppId -e -h
                    }
                } else {
                    Write-Host "$AppName is already installed and up to date." -ForegroundColor Green
                }
            }
        } else {
            Write-Host "$AppName is already installed." -ForegroundColor Green
        }
    } else {
        Write-Host "Installing $AppName..." -ForegroundColor Yellow
        # Use -h for silent installation if the app supports it.
        winget install --id $AppId -e -h 
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$AppName installed successfully." -ForegroundColor Green
        } elseif ($LASTEXITCODE -eq 17) {
            Write-Host "$AppName is already installed. Skipping." -ForegroundColor Cyan
        } else {
            Write-Host "Error installing $AppName. Exit code: $LASTEXITCODE" -ForegroundColor Red
        }
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

# 7. Install bottom (System Monitor)
Install-App -AppId Clement.bottom -AppName "bottom"

# 8. Install gdu (Go Disk Usage)
Install-App -AppId gdu.gdu -AppName "gdu"

Write-Host "✅ Setup script finished running." -ForegroundColor Green
