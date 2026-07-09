#!/usr/bin/env bash

set -euo pipefail

########################################
# CloudAziz SSL Enable Script
########################################

PROJECT_DIR="/srv/cloudaziz"

SSL_DIR="$PROJECT_DIR/certbot/conf/live/cloudaziz.com"

PRODUCTION_DIR="$PROJECT_DIR/nginx/production"
NGINX_CONF_DIR="$PROJECT_DIR/nginx/conf.d"

FULLCHAIN="$SSL_DIR/fullchain.pem"
PRIVKEY="$SSL_DIR/privkey.pem"

########################################
# Log
########################################

log() {
    echo "[$(date '+%F %T')] $1"
}

log "======================================"
log "CloudAziz SSL Enable Started"
log "======================================"

########################################
# Check SSL Certificate
########################################

if [ ! -f "$FULLCHAIN" ]; then
    log "ERROR: SSL certificate not found."
    log "Missing: $FULLCHAIN"
    exit 1
fi

if [ ! -f "$PRIVKEY" ]; then
    log "ERROR: SSL private key not found."
    log "Missing: $PRIVKEY"
    exit 1
fi

log "SSL certificate found."

########################################
# Check Production Config
########################################

if [ ! -f "$PRODUCTION_DIR/default.conf" ]; then
    log "ERROR: production/default.conf not found."
    exit 1
fi

if [ ! -f "$PRODUCTION_DIR/ssl.conf" ]; then
    log "ERROR: production/ssl.conf not found."
    exit 1
fi

########################################
# Enable Production Config
########################################

cp "$PRODUCTION_DIR/default.conf" "$NGINX_CONF_DIR/default.conf"

cp "$PRODUCTION_DIR/ssl.conf" "$NGINX_CONF_DIR/ssl.conf"

log "Production configuration activated."

########################################
# Test nginx
########################################

docker compose exec nginx nginx -t

log "Nginx configuration test passed."

########################################
# Reload nginx
########################################

docker compose exec nginx nginx -s reload

log "Nginx reloaded."

########################################
# Finished
########################################

log "======================================"
log "HTTPS is now enabled."
log "======================================"
