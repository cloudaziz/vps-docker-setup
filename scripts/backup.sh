#!/bin/bash
set -Eeuo pipefail

BASE_DIR="/srv/cloudaziz"
BACKUP_DIR="$BASE_DIR/backups/daily/$(date +%F)"
LOG_DIR="$BASE_DIR/backups/logs"

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

# Load environment variables
if [ -f "$BASE_DIR/.env" ]; then
    set -a
    source "$BASE_DIR/.env"
    set +a
fi

LOG_FILE="$LOG_DIR/backup-$(date +%F).log"

echo "=== Backup Started $(date) ===" | tee -a "$LOG_FILE"

# Database Backup
docker exec mariadb \
    mysqldump \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    "$MYSQL_DATABASE" \
    | gzip > "$BACKUP_DIR/database.sql.gz"

# WordPress Volume Backup
docker run --rm \
    -v cloudaziz_wordpress_data:/source:ro \
    -v "$BACKUP_DIR":/backup \
    alpine \
    tar czf /backup/wordpress.tar.gz -C /source .

# Docker Compose
cp "$BASE_DIR/docker-compose.yml" "$BACKUP_DIR/"

# SHA256 checksums
cd "$BACKUP_DIR"
sha256sum * > SHA256SUMS

echo "Backup completed successfully." | tee -a "$LOG_FILE"
