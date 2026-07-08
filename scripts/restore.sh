#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz Restore System
########################################

PROJECT_DIR="/srv/cloudaziz"
BACKUP_REPO="/srv/cloudaziz-backup"

########################################
# Load Libraries
########################################

source "$PROJECT_DIR/scripts/lib/checksum.sh"

LOG_DIR="$BACKUP_REPO/logs"
LOG_FILE="$LOG_DIR/restore.log"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

run_restore() {

    local script="$1"
    local name="$2"

    log "--------------------------------------"
    log "Running ${name} Restore"

    if bash "$script"; then
        log "${name} Restore Completed"
    else
        log "ERROR: ${name} Restore Failed"
        exit 1
    fi
}

########################################
# Confirmation
########################################

echo
echo "========================================"
echo "WARNING!"
echo "========================================"
echo
echo "This operation will overwrite existing data."
echo
echo "Type 'yes' to continue."
echo

read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo
    echo "Restore cancelled."
    exit 0
fi

########################################
# Start
########################################

: > "$LOG_FILE"

log "======================================"
log "CloudAziz Restore Started"
log "======================================"

########################################
# Verify Backup Integrity
########################################

log "======================================"
log "Verifying Backup Integrity"
log "======================================"

verify_checksum "$BACKUP_REPO/database/database.sql.gz"
verify_checksum "$BACKUP_REPO/wordpress/wordpress.tar.gz"
verify_checksum "$BACKUP_REPO/nginx/nginx.tar.gz"
verify_checksum "$BACKUP_REPO/ssl/ssl.tar.gz"
verify_checksum "$BACKUP_REPO/docker/docker.tar.gz"

log "All backup files verified successfully."

run_restore "$PROJECT_DIR/scripts/restore/restore-docker.sh" "Docker"

run_restore "$PROJECT_DIR/scripts/restore/restore-ssl.sh" "SSL"

run_restore "$PROJECT_DIR/scripts/restore/restore-nginx.sh" "Nginx"

run_restore "$PROJECT_DIR/scripts/restore/restore-wordpress.sh" "WordPress"

run_restore "$PROJECT_DIR/scripts/restore/restore-db.sh" "Database"

########################################
# Restart Containers
########################################

log "--------------------------------------"
log "Restarting Docker Containers"

cd "$PROJECT_DIR"

docker compose down
docker compose up -d

log "Docker Containers Restarted"

########################################
# Finish
########################################

log "======================================"
log "CloudAziz Restore Finished Successfully"
log "======================================"

echo
echo "========================================"
echo "Restore Completed Successfully."
echo "========================================"
