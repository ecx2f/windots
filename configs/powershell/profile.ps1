# Clear the terminal and then run fastfetch
Clear-Host
fastfetch

function dev() {
    $devRoot = if ($env:DEV_HOME) { $env:DEV_HOME } else { Join-Path $HOME "dev" }
    Set-Location -Path $devRoot
}


