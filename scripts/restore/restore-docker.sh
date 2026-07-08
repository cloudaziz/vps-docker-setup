#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz Docker Configuration Restore
########################################

PROJECT_DIR="/srv/cloudaziz"
BACKUP_REPO="/srv/cloudaziz-backup"

BACKUP_FILE="$BACKUP_REPO/docker/docker.tar.gz"

LOG_FILE="$BACKUP_REPO/logs/restore.log"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

log "======================================"
log "Docker Configuration Restore Started"
log "======================================"

if [ ! -f "$BACKUP_FILE" ]; then
    log "ERROR: Backup file not found."
    log "File: $BACKUP_FILE"
    exit 1
fi

tar -xzf "$BACKUP_FILE" -C "$PROJECT_DIR"

log "Docker configuration restored successfully."

log "Destination : $PROJECT_DIR"

log "======================================"
log "Docker Configuration Restore Completed"
log "======================================"
