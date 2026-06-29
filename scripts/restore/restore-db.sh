#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="/srv/cloudaziz"
BACKUP_DIR="$PROJECT_DIR/backups/database"

set -a
source "$PROJECT_DIR/.env"
set +a

if [ $# -ne 1 ]; then
    echo "Usage:"
    echo "  ./scripts/restore/restore-db.sh <backup.sql.gz>"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found:"
    echo "$BACKUP_FILE"
    exit 1
fi

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
EMERGENCY_BACKUP="$BACKUP_DIR/${TIMESTAMP}-before-restore.sql.gz"

echo "========================================="
echo " Emergency Database Backup"
echo "========================================="

docker exec mariadb mariadb-dump \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}" \
| gzip > "$EMERGENCY_BACKUP"

echo
echo "Emergency backup saved:"
echo "$EMERGENCY_BACKUP"

echo
echo "========================================="
echo " Database Restore"
echo "========================================="

read -rp "Type YES to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Restore cancelled."
    exit 0
fi

gunzip -c "$BACKUP_FILE" | docker exec -i mariadb mariadb \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}"

echo
echo "Database restored successfully."

echo
echo "Running verification..."

docker exec mariadb mariadb \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    -e "USE ${MYSQL_DATABASE}; SHOW TABLES;" \
| head

echo
echo "Restore completed successfully."
