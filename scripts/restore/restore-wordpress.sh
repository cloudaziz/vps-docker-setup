#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz WordPress Restore
########################################

PROJECT_DIR="/srv/cloudaziz"
BACKUP_REPO="/srv/cloudaziz-backup"

BACKUP_FILE="$BACKUP_REPO/wordpress/wordpress.tar.gz"

LOG_DIR="$BACKUP_REPO/logs"
LOG_FILE="$LOG_DIR/restore.log"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

log "======================================"
log "WordPress Restore Started"
log "======================================"

if [ ! -f "$BACKUP_FILE" ]; then
    log "ERROR: Backup file not found."
    log "File : $BACKUP_FILE"
    exit 1
fi

docker volume inspect cloudaziz_wordpress_data >/dev/null 2>&1 || {
    log "ERROR: Docker volume 'cloudaziz_wordpress_data' not found."
    exit 1
}

docker run --rm \
    -v cloudaziz_wordpress_data:/data \
    -v "$BACKUP_REPO/wordpress":/backup:ro \
    alpine \
    sh -c "rm -rf /data/* && tar -xzf /backup/wordpress.tar.gz -C /data"

log "WordPress restored successfully."

log "Volume : cloudaziz_wordpress_data"

log "======================================"
log "WordPress Restore Completed"
log "======================================"
