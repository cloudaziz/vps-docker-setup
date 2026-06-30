#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="/srv/cloudaziz"
DATE=$(date +%F_%H-%M-%S)

BACKUP_DIR="$BASE_DIR/backups"
LOG_DIR="$BACKUP_DIR/logs"

mkdir -p "$BACKUP_DIR/database"
mkdir -p "$BACKUP_DIR/wordpress"
mkdir -p "$BACKUP_DIR/nginx"
mkdir -p "$BACKUP_DIR/ssl"
mkdir -p "$BACKUP_DIR/checksum"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/backup-$DATE.log"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

log "========== Backup Started =========="

# Check .env exists
if [[ ! -f "$BASE_DIR/.env" ]]; then
    log "ERROR: $BASE_DIR/.env not found."
    exit 1
fi

# Load environment variables
set -a
source "$BASE_DIR/.env"
set +a

# Database Backup
DB_BACKUP="$BACKUP_DIR/database/database-$DATE.sql.gz"

log "Starting MariaDB backup..."

if docker exec \
    -e MYSQL_PWD="$MYSQL_PASSWORD" \
    mariadb \
    mariadb-dump \
        -u"$MYSQL_USER" \
        "$MYSQL_DATABASE" \
    | gzip > "$DB_BACKUP"; then

    log "Database backup completed."
else
    log "ERROR: Database backup failed."
    exit 1
fi

# WordPress Backup
WP_BACKUP="$BACKUP_DIR/wordpress/wordpress-$DATE.tar.gz"

log "Starting WordPress backup..."

if tar -czf "$WP_BACKUP" \
    -C /var/lib/docker/volumes/cloudaziz_wordpress_data/_data .; then

    log "WordPress backup completed."
else
    log "ERROR: WordPress backup failed."
    exit 1
fi

# Nginx Configuration Backup
NGINX_BACKUP="$BACKUP_DIR/nginx/nginx-$DATE.tar.gz"

log "Starting Nginx configuration backup..."

if tar -czf "$NGINX_BACKUP" \
    -C "$BASE_DIR" nginx; then

    log "Nginx configuration backup completed."
else
    log "ERROR: Nginx configuration backup failed."
    exit 1
fi

# SSL Certificate Backup
SSL_BACKUP="$BACKUP_DIR/ssl/ssl-$DATE.tar.gz"

log "Starting SSL certificate backup..."

if tar -czf "$SSL_BACKUP" \
    -C "$BASE_DIR" certbot/conf; then

    log "SSL certificate backup completed."
else
    log "ERROR: SSL certificate backup failed."
    exit 1
fi

# Docker Compose Backup
COMPOSE_BACKUP="$BACKUP_DIR/docker-compose-$DATE.tar.gz"

log "Starting Docker Compose backup..."

if tar -czf "$COMPOSE_BACKUP" \
    -C "$BASE_DIR" \
    docker-compose.yml \
    docker-compose.single.yml \
    docker/wordpress; then

    log "Docker Compose backup completed."
else
    log "ERROR: Docker Compose backup failed."
    exit 1
fi

# Generate checksums
CHECKSUM_FILE="$BACKUP_DIR/checksum/checksum-$DATE.sha256"

log "Generating SHA256 checksums..."

sha256sum \
    "$DB_BACKUP" \
    "$WP_BACKUP" \
    "$NGINX_BACKUP" \
    "$SSL_BACKUP" \
    "$COMPOSE_BACKUP" \
    > "$CHECKSUM_FILE"

log "Checksums generated."


# Remove backups older than 30 days
log "Removing backups older than 30 days..."

find "$BACKUP_DIR/database"   -type f -mtime +30 -delete
find "$BACKUP_DIR/wordpress"  -type f -mtime +30 -delete
find "$BACKUP_DIR/nginx"      -type f -mtime +30 -delete
find "$BACKUP_DIR/ssl"        -type f -mtime +30 -delete
find "$BACKUP_DIR/checksum"   -type f -mtime +30 -delete

log "Retention policy completed."

log "========== Backup Completed Successfully =========="
