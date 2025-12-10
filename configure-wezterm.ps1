Write-Host "Configuring WezTerm..." -ForegroundColor Cyan

$configPath = "$env:USERPROFILE\.wezterm.lua"

# Attempt to find Git Bash
$gitBashPath = "C:\Program Files\Git\bin\bash.exe"

if (-not (Test-Path $gitBashPath)) {
    # Check x86 path
    $gitBashPath = "C:\Program Files (x86)\Git\bin\bash.exe"
}

if (-not (Test-Path $gitBashPath)) {
    # Try to find via git.exe in PATH
    $gitCmd = Get-Command git.exe -ErrorAction SilentlyContinue
    if ($gitCmd) {
        # Usually found in ...\Git\cmd\git.exe. We want ...\Git\bin\bash.exe
        $gitRoot = Split-Path (Split-Path $gitCmd.Source)
        $gitBashPath = Join-Path $gitRoot "bin\bash.exe"
    }
}

if (-not (Test-Path $gitBashPath)) {
    Write-Host "Could not find Git Bash. Please ensure Git is installed." -ForegroundColor Red
    exit
}

Write-Host "Found Git Bash at: $gitBashPath" -ForegroundColor Green

# Escape backslashes for Lua string (e.g., C:\Path becomes C:\\Path)
$luaPath = $gitBashPath.Replace('\', '\\')

$configContent = @"
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Spawn a bash shell in login mode
-- 1. Default Shell: Git Bash
-- (Standard "New Tab" + button will use this)
config.default_prog = { '$luaPath', '-i', '-l' }



-- 3. Launch Menu Entries
config.launch_menu = {
  -- Entry 1 (Required)
  {
    label = "PowerShell",
    args = { "powershell.exe", "-NoLogo" },
  },
  -- Entry 2 (Optional)
  {
    label = 'CMD',
    args = { 'cmd.exe' },
  },
}

-- 2. Keyboard Shortcuts
config.keys = {
  -- Option A: Split with PowerShell (CTRL + SHIFT + P)
  {
    key = 'P',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal {
      args = { 'powershell.exe', '-NoLogo' },
    },
  },

  -- Option B: Split with Git Bash (CTRL + SHIFT + B)
  {
    key = 'B',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal {
      args = { 'C:\\Program Files\\Git\\bin\\bash.exe', '-i', '-l' },
    },
  },
  
  -- (Optional) Vertical Splits
  -- CTRL + ALT + P (Vertical PowerShell)
  {
    key = 'P',
    mods = 'CTRL|ALT',
    action = wezterm.action.SplitVertical {
      args = { 'powershell.exe', '-NoLogo' },
    },
  },

  -- CTRL + ALT + B (Vertical Git Bash)
  {
    key = 'B',
    mods = 'CTRL|ALT',
    action = wezterm.action.SplitVertical {
      args = { '$luaPath', '-i', '-l' },
    },
  },
}

return config
"@

if (Test-Path $configPath) {
    Write-Host "Backing up existing WezTerm config to .wezterm.lua.bak" -ForegroundColor Yellow
    Copy-Item $configPath "$configPath.bak" -Force
}

Set-Content -Path $configPath -Value $configContent -Encoding UTF8
Write-Host "WezTerm configuration created at $configPath" -ForegroundColor Green