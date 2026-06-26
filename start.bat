@ECHO OFF
:: ###########################################################################
:: Better MC x Youer - server launcher (Windows)
::
:: Runs the Youer (MohistMC) hybrid server, which loads the Better MC NeoForge
:: mods AND the Bukkit/Spigot/Paper plugins in plugins\
::
::   - Edit RAM / JVM args in:  user_jvm_args.txt
:: ###########################################################################
PUSHD %~dp0

IF NOT EXIST youer.jar (
  ECHO ERROR: youer.jar not found. Download Youer 1.21.1 ^(build 657^) from:
  ECHO   https://api.mohistmc.com/project/youer/1.21.1/builds/657/download
  PAUSE
  EXIT /B 1
)

java @user_jvm_args.txt -jar youer.jar nogui %*

POPD
PAUSE
