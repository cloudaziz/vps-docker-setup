#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="/srv/cloudaziz"
set -a
source "$PROJECT_DIR/.env"
set +a
BACKUP_DIR="$PROJECT_DIR/backups/database"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "$BACKUP_DIR"

echo "======================================"
echo "Starting MariaDB Backup..."
echo "Time: $TIMESTAMP"
echo "======================================"

docker exec mariadb mariadb-dump \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}" \
| gzip > "$BACKUP_DIR/${TIMESTAMP}.sql.gz"

echo
echo "Backup completed."

ls -lh "$BACKUP_DIR/${TIMESTAMP}.sql.gz"

echo
echo "Removing backups older than 7 days..."

find "$BACKUP_DIR" \
    -name "*.sql.gz" \
    -mtime +7 \
    -delete

echo
echo "Done."
