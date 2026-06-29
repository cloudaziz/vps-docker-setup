#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="/srv/cloudaziz"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

STEP=0

log() {
    echo -e "${BLUE}$1${NC}"
}

success() {
    echo -e "${GREEN}$1${NC}"
}

error() {
    echo -e "${RED}$1${NC}"
}

run_step() {

    local TITLE="$1"
    shift

    STEP=$((STEP+1))

    echo
    log "[$STEP] $TITLE"

    if "$@"; then
        success "✔ $TITLE completed"
    else
        error "✖ $TITLE failed"
        exit 1
    fi
}

echo
echo "========================================"
echo " CloudAziz Disaster Recovery"
echo "========================================"

DB_BACKUP=$(ls -t "$PROJECT_DIR"/backups/database/*.sql.gz 2>/dev/null | head -n1)
WP_BACKUP=$(ls -t "$PROJECT_DIR"/backups/wordpress/*.tar.gz 2>/dev/null | head -n1)
NGINX_BACKUP=$(ls -t "$PROJECT_DIR"/backups/nginx/*.tar.gz 2>/dev/null | head -n1)
SSL_BACKUP=$(ls -t "$PROJECT_DIR"/backups/ssl/*.tar.gz 2>/dev/null | head -n1)

for file in \
"$DB_BACKUP" \
"$WP_BACKUP" \
"$NGINX_BACKUP" \
"$SSL_BACKUP"
do
    if [ ! -f "$file" ]; then
        error "Backup not found:"
        echo "$file"
        exit 1
    fi
done

success "All backup files found."

run_step \
"Restore Database" \
./scripts/restore/restore-db.sh "$DB_BACKUP" --yes

run_step \
"Restore WordPress" \
./scripts/restore/restore-wordpress.sh "$WP_BACKUP" --yes

run_step \
"Restore Nginx" \
./scripts/restore/restore-nginx.sh "$NGINX_BACKUP" --yes

run_step \
"Restore SSL" \
./scripts/restore/restore-ssl.sh "$SSL_BACKUP" --yes

run_step \
"Restart Docker" \
docker compose restart

echo
log "Waiting for containers..."
sleep 10

run_step \
"Nginx Configuration Test" \
docker exec nginx nginx -t

run_step \
"Website Health Check" \
curl -fsS https://cloudaziz.com >/dev/null

echo
echo "========================================"
success " Disaster Recovery Completed Successfully "
echo "========================================"
