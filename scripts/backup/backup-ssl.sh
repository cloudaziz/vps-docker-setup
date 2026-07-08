#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz SSL Backup
########################################

PROJECT_DIR="/srv/cloudaziz"
BACKUP_REPO="/srv/cloudaziz-backup"

SSL_DIR="$PROJECT_DIR/certbot/conf"

BACKUP_DIR="$BACKUP_REPO/ssl"
LOG_DIR="$BACKUP_REPO/logs"

BACKUP_FILE="$BACKUP_DIR/ssl.tar.gz"
CHECKSUM_FILE="$BACKUP_FILE.sha256"
LOG_FILE="$LOG_DIR/backup.log"

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

log "======================================"
log "SSL Backup Started"
log "======================================"

########################################
# Check Source Directory
########################################

if [ ! -d "$SSL_DIR" ]; then
    log "ERROR: SSL directory not found."
    exit 1
fi

########################################
# Create Backup
########################################

tar -czpf "$BACKUP_FILE" \
    -C "$PROJECT_DIR" \
    certbot

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

log "SSL backup completed successfully."
log "File : $BACKUP_FILE"
log "Size : $SIZE"

log "======================================"

