#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="/srv/cloudaziz"
SSL_DIR="$PROJECT_DIR/certbot/conf"
BACKUP_DIR="$PROJECT_DIR/backups/ssl"

if [ $# -ne 1 ]; then
    echo "Usage:"
    echo "  ./scripts/restore/restore-ssl.sh <backup.tar.gz>"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found."
    echo "$BACKUP_FILE"
    exit 1
fi

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
EMERGENCY="$BACKUP_DIR/ssl-before-restore-$TIMESTAMP.tar.gz"

echo "Creating emergency SSL backup..."

tar -czf "$EMERGENCY" -C "$PROJECT_DIR" certbot/conf

echo
echo "Emergency backup:"
echo "$EMERGENCY"

AUTO_CONFIRM=false

if [[ "${2:-}" == "--yes" ]] || [[ "${1:-}" == "--yes" ]]; then
    AUTO_CONFIRM=true
fi

if [ "$AUTO_CONFIRM" = false ]; then
    read -rp "Type YES to continue: " CONFIRM

    if [ "$CONFIRM" != "YES" ]; then
        echo "Restore cancelled."
        exit 0
    fi
else
    echo "Auto confirmation enabled."
fi

rm -rf "$SSL_DIR"

tar -xzf "$BACKUP_FILE" -C "$PROJECT_DIR"

echo
echo "Checking certificates..."

if [ ! -f "$SSL_DIR/live/cloudaziz.com/fullchain.pem" ]; then
    echo "Certificate missing."

    rm -rf "$SSL_DIR"

    tar -xzf "$EMERGENCY" -C "$PROJECT_DIR"

    exit 1
fi

echo
echo "Testing nginx..."

if docker exec nginx nginx -t; then

    docker exec nginx nginx -s reload

    echo
    echo "SSL restored successfully."

else

    echo
    echo "Rolling back..."

    rm -rf "$SSL_DIR"

    tar -xzf "$EMERGENCY" -C "$PROJECT_DIR"

    docker exec nginx nginx -t

    docker exec nginx nginx -s reload

    exit 1

fi
