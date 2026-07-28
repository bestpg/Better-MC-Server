# Better MC × Youer Server

A self-hosted **Better MC [NEOFORGE] BMC5** Minecraft server running on
**[Youer](https://mohistmc.com/software/youer)** — MohistMC's NeoForge **hybrid** server core.
Youer runs the full Better MC NeoForge mod set **and** Bukkit/Spigot/Paper **plugins** at the
same time, so this server keeps all 288 mods *and* adds an admin/plugin layer (EssentialsX,
LuckPerms, WorldEdit, Multiverse, …).

This repository tracks the whole server.

---

## Overview

| | |
|---|---|
| **Modpack** | Better MC [NEOFORGE] BMC5 (Server Pack v50) |
| **Minecraft** | 1.21.1 |
| **Server core** | **Youer 1.21.1** (build 657 · bundles NeoForge 21.1.232) |
| **Plugin API** | Bukkit / Spigot / Paper (1.21.1) |
| **Java** | 21+ |
| **Host** | Oracle Cloud — Ampere A1.Flex (ARM / aarch64), Ubuntu |
| **Resources** | 2 OCPU, ~12 GB RAM |
| **Heap** | `-Xmx8G -Xms8G` |
| **Port** | 25565 (default) |

> **What changed from the upstream NeoForge pack?** The vanilla NeoForge launch
> (the `neoforge-*-installer.jar` + `run.sh`/ServerStarterJar machinery) was swapped for a
> single self-contained **`youer.jar`**. The mods, config and world are untouched — Youer *is*
> NeoForge 21.1.232 under the hood, with the Bukkit/Spigot/Paper plugin layer added on top.

---

## Current status

✅ **Full deployment active** — Server running with 288 Better MC BMC5 mods + hybrid Bukkit layer

✅ **Automated backups functional** — World snapshots run every hour to Oracle Object Storage (frkwoapqknlo namespace, minecraft-backups bucket)

✅ **Dynamic DNS active** — DuckDNS updates every 5 minutes to track IP changes

✅ **Network configured** — Oracle Cloud security rules + iptables accepting TCP 25565

✅ **Full boot smoke-tested** — 288-mod + plugins world-load verified end-to-end

✅ **systemd service active** — Auto-start on reboot and crash recovery configured

✅ **Static IP reserved** — Address survives stop/start

⚠ **Ready for LuckPerms setup** — LuckPerms 5.5.53 installed; groups/tracks pending

⚠ **Friends whitelist** — Standard Minecraft whitelist not yet implemented

⚠ **Vault for EssentialsX** — Optional economy/permission bridging not yet installed

---

## Running the server

Youer is a single self-contained jar — no installer step.

```bash
./start.sh          # recommended (EULA check + optional auto-restart)
# or, minimal:
./run.sh            # java @user_jvm_args.txt -jar youer.jar nogui
```

Launch inside a named `screen` session so it survives SSH disconnects:

```bash
screen -S bettermc
cd ~/bettermc
./start.sh
# detach with: Ctrl+A then D
# reattach with: screen -r bettermc
```

On Windows: `start.bat` (or `start.ps1`, which supports `-Restart`).

### First boot

* **Back up `world/` first.** Moving a Forge/NeoForge world onto a hybrid core is normally
  seamless (same chunk format), but a one-time backup before the first Youer boot is cheap insurance.
* On first start Youer generates its own `bukkit.yml`, `spigot.yml`, `paper-*.yml`,
  `commands.yml`, `permissions.yml` and a `youer`/`mohist` config folder — those are **fresh
  defaults** (not carried over from skytekx) and are safe to tweak afterwards.

## How players connect

Connect in the Minecraft client (with the matching **Better MC BMC5** pack installed) to:

```
YOUR_SUBDOMAIN.duckdns.org
```

No port needed — the server runs on the default 25565. Everyone must be on the **same pack
version** to join. (Youer is server-side only; clients still run plain Better MC BMC5 / NeoForge.)

## Configuration

RAM and JVM flags live in **`user_jvm_args.txt`** (read by every launch script):

```
-Xmx8G -Xms8G -Dlog4j2.formatMsgNoLookups=true
```

On this 12 GB instance, 8 GB is allocated to the server, leaving headroom for the OS. Don't set
this higher than the box can spare or the JVM will fail to start or get killed. The
`-Dlog4j2.formatMsgNoLookups=true` flag mitigates the Log4Shell (CVE-2021-44228) exploit class —
leave it on.

> `variables.txt` is now only read by `install_java.sh` (optional Java 21 install). Its old
> ServerStarterJar / NeoForge-auto-install fields are no longer used by the launch scripts.

## Hosting notes

### Networking
Two firewalls both need port 25565 open:
- **Oracle Cloud** — an ingress rule for TCP 25565 in the subnet's security list (alongside the
  default SSH/ICMP rules).
- **The instance itself** — an `iptables` rule, saved with `netfilter-persistent`:
  ```bash
  sudo iptables -I INPUT -p tcp --dport 25565 -j ACCEPT
  sudo netfilter-persistent save
  ```

### Dynamic DNS
The public IP can change if the instance is stopped/started, so DuckDNS keeps the domain pointed at
the current IP. A cron job re-asserts it every 5 minutes:
```
*/5 * * * * ~/duckdns/duck.sh >/dev/null 2>&1
```
The update script leaves `ip=` blank so DuckDNS auto-detects the instance's current public IP.

## Mod notes

### Removed
- **packanalytics** — disabled (`.jar.disabled`). It crashed the server on boot via a
  compatibility break with the bundled Better Compatibility Checker
  (`NoClassDefFoundError: BetterStatusServerHolder`). It's pack telemetry only, so removing it has
  no gameplay impact.

### Auto-quarantined by Youer on first boot
Youer ships `youer-config/youer.yml` with **`auto_delete_mods: true`**, so on its first start it
**moves mods it considers hybrid-incompatible into `delete/mods/`** (moved, not deleted — fully
recoverable). On this pack that catches **8 mods**:

| Mod | Why Youer rejects it |
|---|---|
| `lithium`, `c2me`, `modernfix`, `ScalableLux`, `alltheleaks`, `luna_minecraft` | Deep server-engine / chunk / lighting optimizers that patch the same internals Youer's hybrid core rewrites — they conflict with the Bukkit/Spigot layer. |
| `continuity`, `skinlayers3d` | Client-only cosmetic mods (connected textures, 3D skin layers); they do nothing server-side. |

This is expected and lets the server boot. To override, set `auto_delete_mods: false` in
`youer-config/youer.yml` (and expect boot conflicts from the engine mods), or just move any you
want to keep back into `mods/`.

### Added
- **Chunky 1.4.23** (NeoForge) — chunk pre-generator. Note: use the **1.4.x** line for MC 1.21.1;
  the 1.5.x builds require Minecraft 26.1+ and will not load here.

### Pre-generating the world
Run before inviting players (it's CPU-heavy on 2 ARM cores, so do it overnight):
```
chunky radius 3000
chunky start
```
Resume an interrupted run with `chunky continue`. Set a matching world border afterward with the
**built-in vanilla command** (the WorldBorder plugin is no longer needed, see above):
```
worldborder set 6000
```

## Backup operations

Backups run hourly via automated script:

```bash
#!/bin/bash
SERVER_DIR="/home/ubuntu/bettermc"
BACKUP_DIR="/home/ubuntu/backups"
BUCKET="minecraft-backups"
NAMESPACE="frkwoapqknlo"
RCON_HOST="127.0.0.1"
RCON_PORT="25575"
KEEP_LOCAL_DAYS=3
KEEP_REMOTE_DAYS=7

source /home/ubuntu/.env

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
FILENAME="bettermc_backup_${TIMESTAMP}.tar.gz"
LOGFILE="/home/ubuntu/backups/backup.log"

mkdir -p "$BACKUP_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"; }

log "=== Backup gestartet: $FILENAME ==="
log "Sende save-all und save-off..."
mcrcon -H "$RCON_HOST" -P "$RCON_PORT" -p "$RCON_PASS" "save-all"
sleep 3
mcrcon -H "$RCON_HOST" -P "$RCON_PORT" -p "$RCON_PASS" "save-off"
sleep 2
log "Erstelle Archiv..."
tar -czf "$BACKUP_DIR/$FILENAME" -C "$SERVER_DIR" world
TAR_EXIT=$?
log "Aktiviere save-on..."
mcrcon -H "$RCON_HOST" -P "$RCON_PORT" -p "$RCON_PASS" "save-on"
if [ $TAR_EXIT -ne 0 ]; then
    log "FEHLER: tar fehlgeschlagen (Exit-Code $TAR_EXIT)"
    exit 1
fi
FILESIZE=$(du -sh "$BACKUP_DIR/$FILENAME" | cut -f1)
log "Archiv erstellt: $FILENAME ($FILESIZE)"
log "Lade hoch nach Object Storage..."
/home/ubuntu/bin/oci os object put --namespace "$NAMESPACE" --bucket-name "$BUCKET" --file "$BACKUP_DIR/$FILENAME" --name "$FILENAME" --force
if [ $? -eq 0 ]; then
    log "Upload erfolgreich: $FILENAME"
else
    log "WARNUNG: Upload fehlgeschlagen"
fi
find "$BACKUP_DIR" -name "bettermc_backup_*.tar.gz" -mtime +$KEEP_LOCAL_DAYS -delete
log "=== Backup abgeschlossen ==="
```

**Backup retention:**
- Local storage: 3 days (`KEEP_LOCAL_DAYS=3`)
- Object Storage: 7 days (`KEEP_REMOTE_DAYS=7`)

---

## Pending / TODO

- [ ] Set up **LuckPerms** groups/tracks and decide whether to add **Vault** for EssentialsX economy
- [ ] Whitelist for the friends group