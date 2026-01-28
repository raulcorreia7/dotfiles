#!/usr/bin/env pwsh
# Windows package installer using Chocolatey, Scoop, or Winget.
#
# Usage:
#   .\install-windows.ps1 [options]
#
# Options:
#   -DryRun      Preview what would be installed without installing
#   -Help        Show this help message

# ------------------------------------------------------------------------------
# SECTION 1: Configuration
# ------------------------------------------------------------------------------

param(
    [switch]$DryRun,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Windows Package Installer

Usage: .\install-windows.ps1 [options]

Options:
  -DryRun    Preview what would be installed
  -Help      Show this help message
"@
    exit 0
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackagesDir = Join-Path $ScriptDir "packages\windows"

$script:InstalledCount = 0
$script:SkippedCount = 0
$script:FailedCount = 0

# ------------------------------------------------------------------------------
# SECTION 2: Helper Functions
# ------------------------------------------------------------------------------

function Test-Command($Command) {
    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

function Install-Package($Package) {
    $Installed = $false

    if ($DryRun) {
        Write-Host "  [dry-run] Would install: $Package" -ForegroundColor Gray
        return $true
    }

    # Try Chocolatey
    if (Test-Command 'choco') {
        Write-Host "  [choco] $Package" -ForegroundColor Cyan
        choco install $Package -y 2>$null
        if ($LASTEXITCODE -eq 0) { $Installed = $true }
    }

    # Try Scoop
    if (-not $Installed -and (Test-Command 'scoop')) {
        Write-Host "  [scoop] $Package" -ForegroundColor Cyan
        scoop install $Package 2>$null
        if ($LASTEXITCODE -eq 0) { $Installed = $true }
    }

    # Try Winget
    if (-not $Installed -and (Test-Command 'winget')) {
        Write-Host "  [winget] $Package" -ForegroundColor Cyan
        winget install --id $Package --accept-package-agreements --silent 2>$null
        if ($LASTEXITCODE -eq 0) { $Installed = $true }
    }

    return $Installed
}

function Install-FromFile($FilePath) {
    if (-not (Test-Path $FilePath)) {
        Write-Host "Package file not found: $FilePath" -ForegroundColor Red
        return
    }

    $Packages = Get-Content $FilePath | Where-Object { $_ -match '^\S+$' -and $_ -notmatch '^#' }
    $Total = ($Packages | Measure-Object).Count

    Write-Host "Found $Total packages" -ForegroundColor White
    Write-Host ""

    foreach ($Pkg in $Packages) {
        # Check if already installed (simplified check)
        $AlreadyInstalled = $false
        if (Test-Command $Pkg) { $AlreadyInstalled = $true }

        if ($AlreadyInstalled) {
            Write-Host "  [skip] $Pkg (already installed)" -ForegroundColor DarkGray
            $script:SkippedCount++
        } else {
            if (Install-Package $Pkg) {
                Write-Host "  [ok] $Pkg" -ForegroundColor Green
                $script:InstalledCount++
            } else {
                Write-Host "  [fail] $Pkg" -ForegroundColor Red
                $script:FailedCount++
            }
        }
    }
}

# ------------------------------------------------------------------------------
# SECTION 3: Main
# ------------------------------------------------------------------------------

Write-Host "=== Windows Package Installer ===" -ForegroundColor White
if ($DryRun) { Write-Host "Mode: DRY RUN" -ForegroundColor Yellow }
Write-Host ""

# Install from packages file
$PackageFile = Join-Path $PackagesDir "packages"
Install-FromFile $PackageFile

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor White
if ($DryRun) { Write-Host "Mode: DRY RUN" }
Write-Host "Installed: $script:InstalledCount"
Write-Host "Skipped: $script:SkippedCount"
if ($script:FailedCount -gt 0) { Write-Host "Failed: $script:FailedCount" }
