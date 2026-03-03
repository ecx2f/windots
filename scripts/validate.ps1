param(
    [switch]$FailOnPlaceholders
)

$ErrorActionPreference = "Stop"
$failed = $false

function Test-JsonFile {
    param([string]$Path)

    try {
        $null = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
        Write-Host "[ok] json $Path"
    }
    catch {
        Write-Host "[fail] json $Path"
        Write-Host "  $($_.Exception.Message)"
        $script:failed = $true
    }
}

function Test-RegFile {
    param([string]$Path)

    $firstLine = (Get-Content -LiteralPath $Path -TotalCount 1).Trim()
    if ($firstLine -eq "Windows Registry Editor Version 5.00") {
        Write-Host "[ok] reg  $Path"
    }
    else {
        Write-Host "[fail] reg  $Path"
        Write-Host "  Missing valid .reg header"
        $script:failed = $true
    }
}

function Test-RequiredText {
    param(
        [string]$Path,
        [string[]]$Required
    )

    $content = Get-Content -Raw -LiteralPath $Path
    foreach ($token in $Required) {
        if ($content -notmatch [regex]::Escape($token)) {
            Write-Host "[fail] text $Path"
            Write-Host "  Missing required token: $token"
            $script:failed = $true
            return
        }
    }
    Write-Host "[ok] text $Path"
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot

$jsonFiles = @(
    (Join-Path $repoRoot "configs\stylus\stylus.json"),
    (Join-Path $repoRoot "configs\windhawk\notification.json"),
    (Join-Path $repoRoot "configs\windhawk\startmenu.json"),
    (Join-Path $repoRoot "configs\windhawk\startmenu-straker.json"),
    (Join-Path $repoRoot "configs\windhawk\taskbar.json"),
    (Join-Path $repoRoot "configs\windhawk\taskbar-tray-icon-spacing.json")
)

foreach ($file in $jsonFiles) {
    Test-JsonFile -Path $file
}

$regFiles = @(
    (Join-Path $repoRoot "configs\windows-context-menu\restore-old-context-menu.reg"),
    (Join-Path $repoRoot "configs\windows-context-menu\restore-win11-context-menu.reg")
)

foreach ($file in $regFiles) {
    Test-RegFile -Path $file
}

Test-RequiredText -Path (Join-Path $repoRoot "configs\yasb\config.yaml") -Required @("api_key:", "location:")

if ($FailOnPlaceholders) {
    $yasbContent = Get-Content -Raw -LiteralPath (Join-Path $repoRoot "configs\yasb\config.yaml")
    if ($yasbContent -match "YOUR_WEATHERAPI_KEY|YOUR_CITY") {
        Write-Host "[fail] placeholders configs\\yasb\\config.yaml"
        Write-Host "  Placeholder values are still present"
        $failed = $true
    }
}

if ($failed) {
    exit 1
}

Write-Host "Validation passed."
