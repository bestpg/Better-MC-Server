<#
    Better MC x Youer - server launcher (Windows PowerShell)

    Runs the Youer (MohistMC) hybrid server, which loads the Better MC NeoForge
    mods AND the Bukkit/Spigot/Paper plugins in plugins\

      - Edit RAM / JVM args in:  user_jvm_args.txt
      - Auto-restart on crash:   pass -Restart  (e.g.  .\start.ps1 -Restart)
#>
param(
    [switch]$Restart
)

Set-Location -Path $PSScriptRoot

if (-not (Test-Path 'eula.txt') -or -not (Select-String -Path 'eula.txt' -Pattern '^eula=true' -Quiet)) {
    Write-Host "ERROR: You must accept the Minecraft EULA. Set 'eula=true' in eula.txt" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path 'youer.jar')) {
    Write-Host "ERROR: youer.jar not found. Download Youer 1.21.1 (build 657) from:" -ForegroundColor Red
    Write-Host "  https://api.mohistmc.com/project/youer/1.21.1/builds/657/download"
    exit 1
}

function Start-Youer {
    & java '@user_jvm_args.txt' -jar youer.jar nogui
}

if ($Restart) {
    while ($true) {
        Start-Youer
        Write-Host ">> Server stopped. Restarting in 5s (press Ctrl-C to abort)..."
        Start-Sleep -Seconds 5
    }
} else {
    Start-Youer
}
