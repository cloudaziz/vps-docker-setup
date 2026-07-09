#!/usr/bin/env bash

set -euo pipefail

DOMAIN="cloudaziz.com"
EMAIL="cloudaziz@gmail.com"

docker compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    -d "$DOMAIN" \
    -d "www.$DOMAIN"

echo
echo "SSL certificate issued successfully."
echo
echo "Run:"
echo "./scripts/ssl/enable-ssl.sh"
