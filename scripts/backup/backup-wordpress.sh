#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="/srv/cloudaziz"
BACKUP_DIR="$PROJECT_DIR/backups/wordpress"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "$BACKUP_DIR"

echo "======================================"
echo "Starting WordPress Backup..."
echo "Time: $TIMESTAMP"
echo "======================================"

docker run --rm \
  -v cloudaziz_wordpress_data:/data:ro \
  -v "$BACKUP_DIR":/backup \
  alpine \
  sh -c "tar -czf /backup/${TIMESTAMP}-wordpress.tar.gz -C /data ."

echo
echo "Backup completed."

ls -lh "$BACKUP_DIR/${TIMESTAMP}-wordpress.tar.gz"

echo
echo "Removing backups older than 7 days..."

find "$BACKUP_DIR" \
    -name "*.tar.gz" \
    -mtime +7 \
    -delete

echo
echo "Done."
