#!/usr/bin/env bash

set -euo pipefail

echo "======================================"
echo "CloudAziz Full Backup"
echo "Started: $(date)"
echo "======================================"

./scripts/backup/backup-db.sh
echo

./scripts/backup/backup-wordpress.sh
echo

./scripts/backup/backup-nginx.sh
echo

./scripts/backup/backup-ssl.sh
echo

echo "======================================"
echo "All backups completed successfully!"
echo "Finished: $(date)"
echo "======================================"
