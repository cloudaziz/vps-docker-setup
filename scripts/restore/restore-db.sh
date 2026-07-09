#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz Database Restore
########################################

PROJECT_DIR="/srv/cloudaziz"
BACKUP_REPO="/srv/cloudaziz-backup"

set -a
source "$PROJECT_DIR/.env"
set +a

BACKUP_FILE="$BACKUP_REPO/database/database.sql.gz"

LOG_DIR="$BACKUP_REPO/logs"
LOG_FILE="$LOG_DIR/restore.log"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

log "======================================"
log "Database Restore Started"
log "======================================"

if [ ! -f "$BACKUP_FILE" ]; then
    log "ERROR: Backup file not found."
    log "File : $BACKUP_FILE"
    exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q '^mariadb$'; then
    log "ERROR: MariaDB container is not running."
    exit 1
fi

log "Restoring database..."

gunzip -c "$BACKUP_FILE" | docker exec -i mariadb mariadb \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}"

log "Database restored successfully."

log "Database : ${MYSQL_DATABASE}"

log "======================================"
log "Database Restore Completed"
log "======================================"
