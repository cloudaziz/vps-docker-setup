#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz WordPress Backup
########################################

PROJECT_DIR="/srv/cloudaziz"
BACKUP_REPO="/srv/cloudaziz-backup"

BACKUP_DIR="$BACKUP_REPO/wordpress"
LOG_DIR="$BACKUP_REPO/logs"

BACKUP_FILE="$BACKUP_DIR/wordpress.tar.gz"
CHECKSUM_FILE="$BACKUP_FILE.sha256"
LOG_FILE="$LOG_DIR/backup.log"

WORDPRESS_VOLUME="cloudaziz_wordpress_data"

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

log "======================================"
log "WordPress Backup Started"
log "======================================"

########################################
# Check Docker Volume
########################################

if ! docker volume inspect "$WORDPRESS_VOLUME" >/dev/null 2>&1; then
    log "ERROR: Docker volume '$WORDPRESS_VOLUME' not found."
    exit 1
fi

########################################
# Create Backup
########################################

docker run --rm \
    -v "${WORDPRESS_VOLUME}:/data:ro" \
    -v "${BACKUP_DIR}:/backup" \
    alpine:3.22 \
    sh -c "tar -czpf /backup/wordpress.tar.gz -C /data ."

########################################
# Verify Backup
########################################

if [ ! -s "$BACKUP_FILE" ]; then
    log "ERROR: Backup file is empty."
    exit 1
fi

tar -tzf "$BACKUP_FILE" >/dev/null

########################################
# Generate SHA256
########################################

sha256sum "$BACKUP_FILE" > "$CHECKSUM_FILE"

########################################
# Summary
########################################

SIZE=$(du -h "$BACKUP_FILE" | cut -f1)

log "WordPress backup completed successfully."
log "File : $BACKUP_FILE"
log "Size : $SIZE"

log "======================================"

