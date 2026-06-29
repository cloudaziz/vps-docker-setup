#!/usr/bin/env bash

set -Eeuo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

info() {
    echo -e "${BLUE}$1${NC}"
}

echo
info "========== CloudAziz Health Check =========="
echo

check_container() {
    local NAME="$1"

    STATUS=$(docker inspect \
        --format='{{.State.Health.Status}}' \
        "$NAME" 2>/dev/null || echo "running")

    if [[ "$STATUS" == "healthy" || "$STATUS" == "running" ]]; then
        ok "$NAME"
    else
        fail "$NAME ($STATUS)"
    fi
}

check_container nginx
check_container wordpress
check_container wordpress-2
check_container mariadb
check_container redis

echo

HTTP=$(curl -k -o /dev/null -s -w "%{http_code}" https://cloudaziz.com)

if [[ "$HTTP" == "200" ]]; then
    ok "Website (HTTP 200)"
else
    fail "Website (HTTP $HTTP)"
fi

echo

FREE=$(df -h / | awk 'NR==2 {print $4}')
USED=$(free -h | awk '/Mem:/ {print $3 "/" $2}')

echo "Disk Free : $FREE"
echo "Memory    : $USED"

echo

docker stats --no-stream

echo
info "============================================"
