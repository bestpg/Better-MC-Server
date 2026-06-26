@echo off
REM Better MC x Youer - hybrid server launcher (Windows)
REM
REM Youer (MohistMC) is a self-contained NeoForge server that ALSO loads
REM Bukkit/Spigot/Paper plugins, so there is no separate NeoForge install step -
REM we just run youer.jar directly.
REM
REM JVM arguments (heap size, etc.) live in user_jvm_args.txt
java @user_jvm_args.txt -jar youer.jar nogui %*
pause
