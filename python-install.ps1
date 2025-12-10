Write-Host "Checking for Miniconda and Python..." -ForegroundColor Cyan

$condaCmd = Get-Command "conda" -ErrorAction SilentlyContinue
$pythonCmd = Get-Command "python" -ErrorAction SilentlyContinue

$pythonIsReal = $false
if ($pythonCmd) {
    $currentVersion = $(python --version 2>&1 | Out-String).Trim()
    if ($currentVersion -match "Python was not found") {
        Write-Host "Ignored Windows Store Python stub at $($pythonCmd.Source)" -ForegroundColor DarkGray
    } else {
        $pythonIsReal = $true
        Write-Host "Python found in PATH (First match):" -ForegroundColor Yellow
        Write-Host "  Location: $($pythonCmd.Source)"
        Write-Host "  Version:  $currentVersion"
    }
}

$condaInstalled = $false
if ($condaCmd) {
    $condaInstalled = $true
    Write-Host "Miniconda (conda) found in PATH:" -ForegroundColor Green
    Write-Host "  Location: $($condaCmd.Source)"
} else {
    # Check common install locations if not in PATH
    $commonPaths = @("$env:USERPROFILE\miniconda3", "$env:LOCALAPPDATA\miniconda3", "$env:ProgramData\miniconda3")
    foreach ($path in $commonPaths) {
        if (Test-Path "$path\Scripts\conda.exe") {
            $condaInstalled = $true
            Write-Host "Miniconda found at: $path" -ForegroundColor Green
            Write-Host "  (Not currently in PATH)" -ForegroundColor Yellow
            break
        }
    }
}

if ($condaInstalled) {
    Write-Host "Miniconda is already installed." -ForegroundColor Green
} else {
    $shouldInstall = $true

    if ($pythonIsReal) {
        Write-Host "Miniconda is NOT found in PATH." -ForegroundColor Yellow
        Write-Host "  Proposed Version:  Miniconda3 (Latest)"
        
        $response = Read-Host "Do you still want to install Miniconda? (y/n)"
        if ($response -notmatch "^[yY]") {
            $shouldInstall = $false
            Write-Host "Skipping Miniconda installation." -ForegroundColor Cyan
        }
    }

    if ($shouldInstall) {
        Write-Host "Installing Miniconda..." -ForegroundColor Yellow
        $url = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
        $output = "$env:TEMP\miniconda.exe"

        Write-Host "Downloading installer from $url..."
        Invoke-WebRequest -Uri $url -OutFile $output

        Write-Host "Running installer..."
        # /S = Silent, /InstallationType=JustMe = Current User, /AddToPath=1 = Add to PATH
        # As of Anaconda Distribution 2022.05 and Miniconda 4.12.0, the option to add Anaconda 
        # to the PATH environment variable during an All Users installation has been disabled. 
        # This was done to address a security exploit. You can still add Anaconda to the PATH 
        # environment variable during a Just Me installation.
        Start-Process -FilePath $output -ArgumentList "/S", "/InstallationType=JustMe", "/AddToPath=1" -Wait

        Remove-Item $output -Force
        
        # Refresh PATH for the current session so conda is available immediately
        $commonPaths = @("$env:USERPROFILE\miniconda3", "$env:LOCALAPPDATA\miniconda3", "$env:ProgramData\miniconda3")
        foreach ($path in $commonPaths) {
            if (Test-Path "$path\Scripts\conda.exe") {
                $env:PATH = "$path;$path\Scripts;$path\Library\bin;$env:PATH"
                Write-Host "Added Miniconda to current session PATH." -ForegroundColor Cyan
                break
            }
        }
        Write-Host "Miniconda installed successfully." -ForegroundColor Green
        Write-Host "Current Python Version:" -ForegroundColor Cyan
        python --version
    }
}