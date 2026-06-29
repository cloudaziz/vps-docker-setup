#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="/srv/cloudaziz"

BACKUP_DIR="$PROJECT_DIR/backups/wordpress"

VOLUME_NAME="cloudaziz_wordpress_data"

if [ $# -ne 1 ]; then

echo "Usage:"

echo " ./scripts/restore/restore-wordpress.sh <backup.tar.gz>"

exit 1

fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then

echo "ERROR: Backup file not found:"

echo "$BACKUP_FILE"

exit 1

fi

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

EMERGENCY_BACKUP="$BACKUP_DIR/${TIMESTAMP}-before-restore.tar.gz"

echo "========================================="

echo " Emergency WordPress Backup"

echo "========================================="

docker run --rm \

-v ${VOLUME_NAME}:/data:ro \

-v "$BACKUP_DIR":/backup \

alpine \

sh -c "tar -czf /backup/$(basename "$EMERGENCY_BACKUP") -C /data ."

echo

echo "Emergency backup saved:"

echo "$EMERGENCY_BACKUP"

echo

echo "========================================="

echo " WordPress Restore"

echo "========================================="

read -rp "Type YES to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then

echo "Restore cancelled."

exit 0

fi

echo

echo "Stopping WordPress containers..."

docker stop wordpress wordpress-2

echo

echo "Clearing existing WordPress data..."

docker run --rm \

-v ${VOLUME_NAME}:/data \

alpine \

sh -c "rm -rf /data/* /data/.[!.]* /data/..?* 2>/dev/null || true"

echo

echo "Restoring backup..."

docker run --rm \

-v ${VOLUME_NAME}:/data \

-v "$(dirname "$BACKUP_FILE")":/restore \

alpine \

sh -c "tar -xzf /restore/$(basename "$BACKUP_FILE") -C /data"

echo

echo "Starting WordPress containers..."

docker start wordpress wordpress-2

echo

echo "Verifying restore..."

docker run --rm \

-v ${VOLUME_NAME}:/data:ro \

alpine \

sh -c "ls -lah /data | head"

echo

echo "WordPress restore completed successfully."
