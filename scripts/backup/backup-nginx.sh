#!/usr/bin/env bash

set -euo pipefail

mkdir -p backups/nginx

tar -czf backups/nginx/nginx-$(date +%F_%H-%M-%S).tar.gz nginx

