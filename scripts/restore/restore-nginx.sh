#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="/srv/cloudaziz"
NGINX_DIR="$PROJECT_DIR/nginx"
BACKUP_DIR="$PROJECT_DIR/backups/nginx"

if [ $# -ne 1 ]; then
    echo "Usage:"
    echo "  ./scripts/restore/restore-nginx.sh <backup.tar.gz>"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found."
    echo "$BACKUP_FILE"
    exit 1
fi

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
EMERGENCY_BACKUP="$BACKUP_DIR/nginx-before-restore-$TIMESTAMP.tar.gz"

echo "======================================"
echo "Creating emergency backup..."
echo "======================================"

tar -czf "$EMERGENCY_BACKUP" -C "$PROJECT_DIR" nginx

echo
echo "Emergency backup:"
echo "$EMERGENCY_BACKUP"

echo
read -rp "Type YES to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Restore cancelled."
    exit 0
fi

echo
echo "Removing current nginx configuration..."

rm -rf "$NGINX_DIR"

echo
echo "Restoring backup..."

tar -xzf "$BACKUP_FILE" -C "$PROJECT_DIR"

echo
echo "Testing nginx configuration..."

if docker exec nginx nginx -t; then

    echo
    echo "Configuration OK."
    echo "Reloading nginx..."

    docker exec nginx nginx -s reload

    echo
    echo "Nginx restore completed successfully."

else

    echo
    echo "Configuration FAILED."
    echo "Rolling back..."

    rm -rf "$NGINX_DIR"

    tar -xzf "$EMERGENCY_BACKUP" -C "$PROJECT_DIR"

    docker exec nginx nginx -t

    docker exec nginx nginx -s reload

    echo
    echo "Rollback completed."

    exit 1

fi
