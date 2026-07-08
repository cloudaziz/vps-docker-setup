#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz Docker Configuration Backup
########################################

PROJECT_DIR="/srv/cloudaziz"
BACKUP_REPO="/srv/cloudaziz-backup"

BACKUP_DIR="$BACKUP_REPO/docker"
LOG_DIR="$BACKUP_REPO/logs"

BACKUP_FILE="$BACKUP_DIR/docker.tar.gz"
CHECKSUM_FILE="$BACKUP_FILE.sha256"
LOG_FILE="$LOG_DIR/backup.log"

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

log "======================================"
log "Docker Configuration Backup Started"
log "======================================"

########################################
# Build Backup File List
########################################

FILES=()

[ -d "$PROJECT_DIR/docker" ] && FILES+=("docker")
[ -f "$PROJECT_DIR/docker-compose.yml" ] && FILES+=("docker-compose.yml")
[ -f "$PROJECT_DIR/docker-compose.single.yml" ] && FILES+=("docker-compose.single.yml")
[ -f "$PROJECT_DIR/docker-compose.override.yml" ] && FILES+=("docker-compose.override.yml")
[ -f "$PROJECT_DIR/.env" ] && FILES+=(".env")

if [ ${#FILES[@]} -eq 0 ]; then
    log "ERROR: No Docker configuration files found."
    exit 1
fi

########################################
# Create Backup
########################################

tar -czpf "$BACKUP_FILE" \
    -C "$PROJECT_DIR" \
    "${FILES[@]}"

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

log "Docker configuration backup completed successfully."
log "File : $BACKUP_FILE"
log "Size : $SIZE"

log "======================================"

