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

$themeDir = "$env:USERPROFILE\Documents\github\dracula-theme"
$luaThemeDir = $themeDir.Replace('\', '\\')

$configContent = @"
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.front_end = 'WebGpu'

-- Set Window Size and Appearance
config.initial_rows = 48
config.initial_cols = 150
config.color_scheme_dirs = { '$luaThemeDir' }
config.color_scheme = "Dracula (Official)"
-- Use a bright background and a contrasting foreground for selected text
config.colors = {
  selection_bg = '#464645ff',
  selection_fg = '#000000',
}
-- config.tab_bar_at_bottom = true
-- config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.window_frame = {
  border_left_width = '0.5cell',
  border_right_width = '0.5cell',
  border_bottom_height = '0.25cell',
  border_top_height = '0.25cell',
  border_left_color = 'purple',
  border_right_color = 'purple',
  border_bottom_color = 'purple',
  border_top_color = 'purple',
}

-- Set Font
config.font = wezterm.font 'Fira Code'
config.font_size = 11.0

-- 1. Default Shell: Git Bash
-- (Standard "New Tab" + button will use this)
config.default_prog = { '$luaPath', '-i', '-l' }



-- 3. Launch Menu Entries
config.launch_menu = {
  -- Entry 1 (Required)
  {
    label = "PowerShell",
    args = { "pwsh.exe", "-NoLogo" },
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

-- Copy on mouse selection
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CopyTo 'Clipboard',
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