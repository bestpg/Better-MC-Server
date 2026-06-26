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

## Mods + Plugins, side by side

Youer is a **hybrid** server: it loads **two** ecosystems from two folders.

| Folder | Loaded as | Contents |
|---|---|---|
| `mods/`    | NeoForge mods    | The 288 Better MC BMC5 mods (unchanged) |
| `plugins/` | Bukkit plugins   | The admin/utility plugins below |

### Plugins (`plugins/`)

Mirrored from the [`skytekx2-1122` server](https://github.com/skytekx/skytekx2-1122-server-xmas-backup).
That server was **Mohist 1.12.2**, so every plugin there was a 1.12.2 jar — useless on 1.21.1.
Each was therefore **upgraded to the current 1.21.1-compatible build of the same project**:

| Plugin | skytekx (1.12.2) | Here (1.21.1) | Source |
|---|---|---|---|
| **EssentialsX** (+ Spawn, AntiBuild, Protect, Chat) | 2.19.7 | **2.22.0** | [GitHub](https://github.com/EssentialsX/Essentials/releases) |
| **LuckPerms** (Bukkit) | 5.4.151 | **5.5.53** | [Modrinth](https://modrinth.com/plugin/luckperms) |
| **WorldEdit** (Bukkit) | 6.1.9 | **7.3.9** | [Modrinth](https://modrinth.com/plugin/worldedit) |
| **Multiverse-Core** | 2.5.0 | **5.7.1** | [Modrinth](https://modrinth.com/plugin/multiverse-core) |
| **Multiverse-Portals** | 2.5.0 | **5.2.3** | [Modrinth](https://modrinth.com/plugin/multiverse-portals) |

Dependency notes: Multiverse-Portals requires Multiverse-Core (present). EssentialsX
*soft*-depends on **Vault** for economy / permission-group bridging — install
[Vault](https://www.spigotmc.org/resources/vault.34315/) if you want that, otherwise EssentialsX
runs standalone. LuckPerms config auto-migrates on first start; Multiverse 5 is a ground-up
rewrite, so its config format is **not** compatible with the old 2.5.0 — fresh configs are used.

### Two plugins have **no 1.21.1 build** (and were not blindly copied)

| Plugin | Why it's gone | What to use instead on 1.21.1 |
|---|---|---|
| **WorldBorder** (Brettflan) | Abandoned in 2020; no release/fork targets 1.21. | Minecraft's **built-in `/worldborder`** command already covers this (see below). For a *visible* per-world border + land pre-generation, use **[ChunkyBorder](https://modrinth.com/plugin/chunkyborder)** + **[Chunky](https://modrinth.com/plugin/chunky)**. |
| **SB-Skylands** | Abandoned 2017 (1.12 world-generator API); no 1.21 build exists. Also a *skylands/skyblock* world generator, which doesn't fit this pack's existing full modded overworld. | If you ever want an empty/floating-island world, attach **[VoidGen](https://modrinth.com/plugin/voidgen)** to a Multiverse world: `mv create skyworld normal -g VoidGen`. |

> To add either suggested plugin, drop its jar in `plugins/` and restart. They are intentionally
> **not** pre-installed.

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

---

## How players connect

Connect in the Minecraft client (with the matching **Better MC BMC5** pack installed) to:

```
YOUR_SUBDOMAIN.duckdns.org
```

No port needed — the server runs on the default 25565. Everyone must be on the **same pack
version** to join. (Youer is server-side only; clients still run plain Better MC BMC5 / NeoForge.)

---

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

---

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

---

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

---

## Rebuilding from scratch

1. Provision an Oracle A1.Flex (ARM) instance with Ubuntu.
2. Open port 25565 in both the Oracle security list and `iptables`.
3. Download the **BMC5 Server Pack v50** (Linux) into `~/bettermc` and unzip it.
4. Restore the tracked config files **and the `plugins/` folder** from this repo over the defaults.
5. Download the Youer core jar:
   ```bash
   curl -fL -o youer.jar 'https://api.mohistmc.com/project/youer/1.21.1/builds/657/download'
   ```
   (sha256 `8cde13c6493ed8e6d4b4a94525c2f66dd3cf345e8ac19689fa6fd2a881a559ab`; newer builds at
   <https://mohistmc.com/software/youer>.)
6. Set the EULA: `echo "eula=true" > eula.txt`
7. Confirm `user_jvm_args.txt` heap matches the instance's RAM.
8. (Optional) Re-add Chunky 1.4.23 (NeoForge) to `mods/` if pre-generating.
9. (Optional) Install Java 21: `./install_java.sh`
10. Start in `screen` with `./start.sh`.

---

## Pending / TODO

- [ ] **Smoke-test the full boot** — the conversion is assembled and statically verified (Youer jar
      boots to its banner; all plugin jars validated), but a full 288-mod + plugins world-load has
      not been run end-to-end yet. Watch the first boot for any mod/plugin that misbehaves under the
      hybrid core.
- [ ] **Automated backups to Oracle Object Storage** (highest priority — the world is not yet
      backed up off-instance)
- [ ] **`systemd` service** for auto-start on reboot and crash recovery
- [ ] **Reserved (static) public IP** so the address survives stop/start
- [ ] Whitelist for the friends group
- [ ] Set up **LuckPerms** groups/tracks and decide whether to add **Vault** for EssentialsX economy
