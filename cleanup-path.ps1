Write-Host "Cleaning up duplicate PATH entries for the Current User..." -ForegroundColor Cyan

# Get the persistent User PATH from the Registry
$rawPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ([string]::IsNullOrWhiteSpace($rawPath)) {
    Write-Host "User PATH is empty. Nothing to clean." -ForegroundColor Yellow
} else {
    # Split, filter empty, and get unique entries (Case-insensitive by default on Windows)
    $pathParts = $rawPath -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

    # Reassemble
    $cleanedPath = $pathParts -join ';'

    # Check if changes are needed
    if ($cleanedPath -ne $rawPath) {
        # Update the Registry
        [Environment]::SetEnvironmentVariable("Path", $cleanedPath, "User")
        Write-Host "User PATH updated successfully (Registry)." -ForegroundColor Green
    } else {
        Write-Host "User PATH is already clean (Registry)." -ForegroundColor Green
    }
}

# Also clean the current session PATH
$sessionParts = $env:PATH -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
$cleanedSessionPath = $sessionParts -join ';'

if ($cleanedSessionPath -ne $env:PATH) {
    $env:PATH = $cleanedSessionPath
    Write-Host "Current session PATH cleaned." -ForegroundColor Green
} else {
    Write-Host "Current session PATH is already clean." -ForegroundColor Green
}

Write-Host ""
$showPaths = Read-Host "Do you want to see the current Registry and Session PATHs? (y/n)"
if ($showPaths -match "^[yY]") {
    Write-Host "`n--- Persistent User PATH (Registry) ---" -ForegroundColor Cyan
    [Environment]::GetEnvironmentVariable("Path", "User") -split ';' | ForEach-Object { Write-Host $_ }

    Write-Host "`n--- Current Session PATH ---" -ForegroundColor Cyan
    $env:PATH -split ';' | ForEach-Object { Write-Host $_ }
}