#!/usr/bin/env sh
# Better MC x Youer - hybrid server launcher (Linux/macOS)
#
# Youer (MohistMC) is a self-contained NeoForge server that ALSO loads
# Bukkit/Spigot/Paper plugins, so there is no separate NeoForge install step -
# we just run youer.jar directly.
#
# JVM arguments (heap size, etc.) live in user_jvm_args.txt
# Extra program args can be passed straight to this script.
java @user_jvm_args.txt -jar youer.jar nogui "$@"
