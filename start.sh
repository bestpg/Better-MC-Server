#!/usr/bin/env bash
###############################################################################
# Better MC x Youer - server launcher (Linux/macOS)
#
# Recommended entry point. This runs the Youer (MohistMC) hybrid server, which
# loads the Better MC NeoForge mods AND the Bukkit/Spigot/Paper plugins in
# plugins/.
#
#   - Edit RAM / JVM args in:  user_jvm_args.txt
#   - Need Java 21? run:       ./install_java.sh   (then re-run this script)
#   - Auto-restart on crash:   set RESTART=true below
###############################################################################
set -euo pipefail
cd "$(dirname "$0")"

JAR="youer.jar"
RESTART="${RESTART:-false}"

# Minecraft requires you to accept the EULA.
if [ ! -f eula.txt ] || ! grep -q '^eula=true' eula.txt; then
  echo "ERROR: You must accept the Minecraft EULA. Set 'eula=true' in eula.txt"
  exit 1
fi

# Make sure the Youer server jar is present.
if [ ! -f "$JAR" ]; then
  echo "ERROR: $JAR not found. Download Youer 1.21.1 (build 657) with:"
  echo "  curl -fL -o youer.jar 'https://api.mohistmc.com/project/youer/1.21.1/builds/657/download'"
  exit 1
fi

run() {
  # JVM args come from user_jvm_args.txt; 'nogui' keeps the console in the terminal.
  java @user_jvm_args.txt -jar "$JAR" nogui
}

if [ "$RESTART" = "true" ]; then
  while true; do
    run || true
    echo ">> Server stopped. Restarting in 5s (press Ctrl-C to abort)..."
    sleep 5
  done
else
  run
fi
