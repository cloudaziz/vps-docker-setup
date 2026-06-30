#!/usr/bin/env bash
set -Eeuo pipefail

LOCK_FILE="/tmp/cloudaziz-restore.lock"

exec 9>"$LOCK_FILE"

if ! flock -n 9; then
    echo "Another restore process is already running."
    exit 1
fi

trap 'rm -f "$LOCK_FILE"' EXIT
touch "$LOCK_FILE"

BASE_DIR="/srv/cloudaziz"
BACKUP_DIR="$BASE_DIR/backups"
LOG_DIR="$BACKUP_DIR/logs"

DATE=$(date +%F_%H-%M-%S)
LOG_FILE="$LOG_DIR/restore-$DATE.log"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

trap 'log "ERROR: Restore failed on line $LINENO"; exit 1' ERR

log "========== Restore Started =========="

# -------------------------
# Load environment
# -------------------------
if [[ ! -f "$BASE_DIR/.env" ]]; then
    log "ERROR: .env file not found"
    exit 1
fi

set -a
source "$BASE_DIR/.env"
set +a

# -------------------------
# Locate latest backups
# -------------------------
DB_BACKUP=$(ls -t "$BACKUP_DIR"/database/database-*.sql.gz | head -1)
WP_BACKUP=$(ls -t "$BACKUP_DIR"/wordpress/wordpress-*.tar.gz | head -1)
NGINX_BACKUP=$(ls -t "$BACKUP_DIR"/nginx/nginx-*.tar.gz | head -1)
SSL_BACKUP=$(ls -t "$BACKUP_DIR"/ssl/ssl-*.tar.gz | head -1)
COMPOSE_BACKUP=$(ls -t "$BACKUP_DIR"/docker-compose-*.tar.gz | head -1)

log "Latest backup files detected."
log "Database : $DB_BACKUP"
log "WordPress: $WP_BACKUP"
log "Nginx    : $NGINX_BACKUP"
log "SSL      : $SSL_BACKUP"
log "Compose  : $COMPOSE_BACKUP"

# -------------------------
# Safety confirmation
# -------------------------
echo
echo "=========================================="
echo " WARNING: Production Restore"
echo "=========================================="
echo
echo "This operation will overwrite:"
echo " - Database"
echo " - WordPress files"
echo " - Nginx configuration"
echo " - SSL certificates"
echo
read -rp "Type YES to continue: " CONFIRM

if [[ "${CONFIRM^^}" != "YES" ]]; then
    log "Restore cancelled by user."
    exit 0
fi

log "User confirmed restore."

# -------------------------
# Database Restore
# -------------------------
log "Starting database restore..."

PRE_RESTORE_BACKUP="$BACKUP_DIR/database/pre-restore-$DATE.sql.gz"

log "Creating emergency backup before restore..."

docker exec mariadb mariadb-dump \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    "$MYSQL_DATABASE" | gzip > "$PRE_RESTORE_BACKUP"

log "Emergency backup created: $PRE_RESTORE_BACKUP"

log "Restoring database..."

gunzip -c "$DB_BACKUP" | docker exec -i mariadb mariadb \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    "$MYSQL_DATABASE"

log "Database restore completed."

# ------------------------
#
# ------------------------

log "Stopping WordPress containers..."

docker stop wordpress wordpress-2 || true

log "Restoring WordPress files..."

WP_VOLUME="/var/lib/docker/volumes/cloudaziz_wordpress_data/_data"

rm -rf "$WP_VOLUME"/*

tar -xzf "$WP_BACKUP" -C "$WP_VOLUME"

log "WordPress restore completed."

log "Starting WordPress containers..."

docker start wordpress wordpress-2 || true

log "Waiting for WordPress to initialize..."
sleep 8

log "Reloading Nginx..."

docker exec nginx nginx -s reload || true
# -------------------------
# Final Health Check
# -------------------------
log "Running health check..."

sleep 3

if curl -fsS https://cloudaziz.com > /dev/null; then
    log "Website is UP"
else
    log "WARNING: Website health check failed"
fi

log "========== RESTORE COMPLETED SUCCESSFULLY =========="
