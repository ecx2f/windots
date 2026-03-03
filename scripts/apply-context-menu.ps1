param(
    [ValidateSet("old", "win11")]
    [string]$Mode = "old",
    [switch]$RestartExplorer
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$configDir = Join-Path $repoRoot "configs\windows-context-menu"

$regFile = if ($Mode -eq "old") {
    Join-Path $configDir "restore-old-context-menu.reg"
} else {
    Join-Path $configDir "restore-win11-context-menu.reg"
}

if (-not (Test-Path -LiteralPath $regFile)) {
    throw "Registry file not found: $regFile"
}

Write-Host "Applying context menu mode: $Mode"
reg.exe import "$regFile"

if ($RestartExplorer) {
    Write-Host "Restarting Explorer..."
    taskkill /f /im explorer.exe | Out-Null
    Start-Process explorer.exe
}

Write-Host "Done."
