#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz SSL Restore
########################################

PROJECT_DIR="/srv/cloudaziz"
BACKUP_REPO="/srv/cloudaziz-backup"

BACKUP_FILE="$BACKUP_REPO/ssl/ssl.tar.gz"

LOG_DIR="$BACKUP_REPO/logs"
LOG_FILE="$LOG_DIR/restore.log"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

log "======================================"
log "SSL Restore Started"
log "======================================"

if [ ! -f "$BACKUP_FILE" ]; then
    log "ERROR: Backup file not found."
    log "File : $BACKUP_FILE"
    exit 1
fi

tar -xzf "$BACKUP_FILE" -C "$PROJECT_DIR"

log "SSL restored successfully."

log "Destination : $PROJECT_DIR/certbot"

log "======================================"
log "SSL Restore Completed"
log "======================================"
