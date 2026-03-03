param(
    [switch]$SkipValidation,
    [ValidateSet("none", "old", "win11")]
    [string]$ContextMenu = "none",
    [switch]$RestartExplorer
)

$ErrorActionPreference = "Stop"

function Copy-ConfigFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    $destDir = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Host "[copied] $Destination"
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot

Write-Host "Starting windots bootstrap..."

if (-not $SkipValidation) {
    Write-Host "Running validation..."
    & (Join-Path $scriptRoot "validate.ps1")
}

$yasbTarget = Join-Path $HOME ".config\yasb"
$fastfetchTarget = Join-Path $HOME ".config\fastfetch"
$cutebordersTarget = Join-Path $HOME ".cuteborders"
$profileTarget = $PROFILE.CurrentUserAllHosts

Copy-ConfigFile -Source (Join-Path $repoRoot "configs\yasb\config.yaml") -Destination (Join-Path $yasbTarget "config.yaml")
Copy-ConfigFile -Source (Join-Path $repoRoot "configs\yasb\styles.css") -Destination (Join-Path $yasbTarget "styles.css")
Copy-ConfigFile -Source (Join-Path $repoRoot "configs\fastfetch\config.jsonc") -Destination (Join-Path $fastfetchTarget "config.jsonc")
Copy-ConfigFile -Source (Join-Path $repoRoot "configs\fastfetch\windows.txt") -Destination (Join-Path $fastfetchTarget "windows.txt")
Copy-ConfigFile -Source (Join-Path $repoRoot "configs\cuteborders\config.yaml") -Destination (Join-Path $cutebordersTarget "config.yaml")

if (Test-Path -LiteralPath $profileTarget) {
    $backup = "$profileTarget.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Copy-Item -LiteralPath $profileTarget -Destination $backup -Force
    Write-Host "[backup] $backup"
}

Copy-ConfigFile -Source (Join-Path $repoRoot "configs\powershell\profile.ps1") -Destination $profileTarget

if ($ContextMenu -ne "none") {
    & (Join-Path $scriptRoot "apply-context-menu.ps1") -Mode $ContextMenu -RestartExplorer:$RestartExplorer
}

Write-Host "Bootstrap complete."
Write-Host "Next: set your weather API key and location in $yasbTarget\config.yaml"
