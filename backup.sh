#!/bin/bash
SERVER_DIR="/home/ubuntu/bettermc"
BACKUP_DIR="/home/ubuntu/backups"
BUCKET="minecraft-backups"
NAMESPACE="frkwoapqknlo"
RCON_HOST="127.0.0.1"
RCON_PORT="25575"
KEEP_LOCAL_DAYS=3
KEEP_REMOTE_DAYS=7

# Load RCON password from .env
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
sleep 10
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
