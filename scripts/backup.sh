#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz Backup System
########################################

PROJECT_DIR="/srv/cloudaziz"
BACKUP_REPO="/srv/cloudaziz-backup"

LOG_DIR="$BACKUP_REPO/logs"
MANIFEST_DIR="$BACKUP_REPO/manifest"

LOG_FILE="$LOG_DIR/backup.log"
MANIFEST_FILE="$MANIFEST_DIR/manifest.txt"

mkdir -p "$LOG_DIR"
mkdir -p "$MANIFEST_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOG_FILE"
}

run_backup() {

    local script="$1"
    local name="$2"

    log "--------------------------------------"
    log "Running ${name} Backup"

    if bash "$script"; then
        log "${name} Backup Completed"
    else
        log "ERROR: ${name} Backup Failed"
        exit 1
    fi
}

########################################
# Start
########################################

: > "$LOG_FILE"

log "======================================"
log "CloudAziz Full Backup Started"
log "======================================"

run_backup "$PROJECT_DIR/scripts/backup/backup-db.sh" "Database"

run_backup "$PROJECT_DIR/scripts/backup/backup-wordpress.sh" "WordPress"

run_backup "$PROJECT_DIR/scripts/backup/backup-nginx.sh" "Nginx"

run_backup "$PROJECT_DIR/scripts/backup/backup-ssl.sh" "SSL"

run_backup "$PROJECT_DIR/scripts/backup/backup-docker.sh" "Docker"

########################################
# Collect System Information
########################################

set -a
source "$PROJECT_DIR/.env"
set +a

DOMAIN="${DOMAIN:-Unknown}"

PHP_VERSION=$(docker exec wordpress php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null || echo "Unknown")

MARIADB_VERSION=$(docker exec mariadb mariadb --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "Unknown")

WORDPRESS_VERSION=$(docker exec wordpress php -r 'include "/var/www/html/wp-includes/version.php"; echo $wp_version;' 2>/dev/null || echo "Unknown")

if docker exec redis redis-cli ping >/dev/null 2>&1; then
    REDIS_STATUS="Enabled"
else
    REDIS_STATUS="Disabled"
fi

DOCKER_COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "Unknown")

WORDPRESS_NODES=$(docker ps --format '{{.Names}}' | grep -E '^wordpress(-[0-9]+)?$' | wc -l)

NGINX_VERSION=$(docker exec nginx nginx -v 2>&1 | cut -d/ -f2 || echo "Unknown")

########################################
# Generate Manifest
########################################

cat > "$MANIFEST_FILE" <<EOF
========================================
CloudAziz Backup Manifest
========================================

Backup Time     : $(date '+%F %T')
Domain          : ${DOMAIN}

PHP             : ${PHP_VERSION}
MariaDB         : ${MARIADB_VERSION}
WordPress       : ${WORDPRESS_VERSION}
Redis           : ${REDIS_STATUS}
Nginx           : ${NGINX_VERSION}
Compose         : ${DOCKER_COMPOSE_VERSION}

WordPress Nodes : ${WORDPRESS_NODES}

Infrastructure  : Docker
Backup Type     : Full

----------------------------------------

Database        : database/database.sql.gz
WordPress       : wordpress/wordpress.tar.gz
Nginx           : nginx/nginx.tar.gz
SSL             : ssl/ssl.tar.gz
Docker          : docker/docker.tar.gz

----------------------------------------

Status      : VERIFIED

========================================
EOF

log "Manifest generated."

########################################
# Finish
########################################

log "======================================"
log "CloudAziz Backup Finished Successfully"
log "======================================"

