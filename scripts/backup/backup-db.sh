#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz Database Backup
########################################

PROJECT_DIR="/srv/cloudaziz"
BACKUP_REPO="/srv/cloudaziz-backup"

set -a
source "$PROJECT_DIR/.env"
set +a

BACKUP_DIR="$BACKUP_REPO/database"
LOG_DIR="$BACKUP_REPO/logs"

BACKUP_FILE="$BACKUP_DIR/database.sql.gz"
CHECKSUM_FILE="$BACKUP_FILE.sha256"
LOG_FILE="$LOG_DIR/backup.log"

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

log "======================================"
log "Database Backup Started"
log "======================================"

########################################
# Check MariaDB Container
########################################

if ! docker ps --format '{{.Names}}' | grep -qx "mariadb"; then
    log "ERROR: MariaDB container is not running."
    exit 1
fi

########################################
# Create Database Backup
########################################

docker exec mariadb mariadb-dump \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}" \
| gzip > "$BACKUP_FILE"

########################################
# Verify Backup
########################################

if [ ! -s "$BACKUP_FILE" ]; then
    log "ERROR: Backup file is empty."
    exit 1
fi

gzip -t "$BACKUP_FILE"

########################################
# SHA256
########################################

sha256sum "$BACKUP_FILE" > "$CHECKSUM_FILE"

########################################
# Summary
########################################

SIZE=$(du -h "$BACKUP_FILE" | cut -f1)

log "Database backup completed successfully."
log "File : $BACKUP_FILE"
log "Size : $SIZE"

log "======================================"

