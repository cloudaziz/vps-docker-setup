#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="/srv/cloudaziz"

set -a
source "$PROJECT_DIR/.env"
set +a

if [ $# -ne 1 ]; then
    echo "Usage:"
    echo "./restore-db.sh backup.sql.gz"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file not found."
    exit 1
fi

echo
echo "WARNING!"
echo
echo "This will overwrite the current database."
echo

read -p "Continue? (yes/no): " answer

if [ "$answer" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo
echo "Restoring database..."

gunzip -c "$BACKUP_FILE" | docker exec -i mariadb mariadb \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    "${MYSQL_DATABASE}"

echo
echo "Restore completed successfully."
