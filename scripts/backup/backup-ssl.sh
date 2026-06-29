#!/usr/bin/env bash

set -euo pipefail

mkdir -p backups/ssl

tar -czf backups/ssl/ssl-$(date +%F_%H-%M-%S).tar.gz certbot/conf
