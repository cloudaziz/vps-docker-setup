# CloudAziz VPS Docker Setup

## Overview

CloudAziz VPS Docker Setup is a production-ready Docker-based WordPress stack optimized for a **2 GB VPS**.

It provides a reproducible deployment with:

- Nginx (Reverse Proxy)
- WordPress PHP-FPM 8.3
- MariaDB 11.8
- Redis Object Cache
- phpMyAdmin
- Let's Encrypt SSL
- FastCGI Cache
- Load Balancing (2× WordPress Containers)
- Backup & Restore Scripts
- Health Monitoring

The repository is designed so that a fresh clone can be deployed on a new VPS with minimal configuration.

## Quick Start

```bash
git clone git@github.com:cloudaziz/vps-docker-setup.git

cd vps-docker-setup

cp .env.example .env

nano .env

docker compose build

docker compose up -d
```

After the stack is running, obtain an SSL certificate using Certbot and reload Nginx.

## Architecture

                Internet
                    │
              HTTPS :443
                    │
             +-------------+
             |    Nginx    |
             +-------------+
                    │
             least_conn Load Balancer
          ┌─────────┴─────────┐
          │                   │
 +----------------+   +----------------+
 | WordPress #1   |   | WordPress #2   |
 +----------------+   +----------------+
          │                   │
          └─────────┬─────────┘
                    │
            +----------------+
            |   MariaDB 11   |
            +----------------+
                    │
            +----------------+
            | Redis Object   |
            |     Cache      |
            +----------------+


Production-ready Docker-based WordPress stack optimized for a 2GB VPS.

---

## Features

* Docker Compose
* Nginx (Alpine)
* WordPress PHP-FPM 8.3
* MariaDB 11.8
* Redis Object Cache
* FastCGI Cache
* Load Balancing (2× WordPress PHP-FPM)
* Let's Encrypt SSL
* WP-CLI Integration
* Backup System
* Disaster Recovery
* Health Monitoring

---

# Server Specification

| Item       | Value            |
| ---------- | ---------------- |
| OS         | Ubuntu 24.04 LTS |
| RAM        | 2 GB             |
| CPU        | 1 vCPU           |
| Web Server | Nginx            |
| PHP        | 8.3              |
| Database   | MariaDB 11.8     |
| Cache      | Redis 8          |
| SSL        | Let's Encrypt    |
| Container  | Docker Compose   |

---

# Project Structure

```
.
├── backups/
│   ├── database/
│   ├── wordpress/
│   ├── nginx/
│   ├── ssl/
│   └── logs/
│
├── certbot/
│
├── docker/
│   └── wordpress/
│
├── nginx/
│   ├── conf.d/
│   ├── cache/
│   └── nginx.conf
│
├── scripts/
│   ├── backup/
│   ├── restore/
│   ├── monitor/
│   └── wp.sh
│
├── docker-compose.yml
├── .env
└── README.md
```

---

# Docker Services

| Service     | Purpose             |
| ----------- | ------------------- |
| nginx       | Reverse Proxy       |
| wordpress   | PHP-FPM Instance #1 |
| wordpress-2 | PHP-FPM Instance #2 |
| mariadb     | Database            |
| redis       | Object Cache        |

---

# Start Stack

```
docker compose up -d
```

---

# Stop Stack

```
docker compose down
```

---

# Restart

```
docker compose restart
```

---

# Service Status

```
docker compose ps
```

---

# Logs

```
docker compose logs -f
```

Specific service:

```
docker compose logs -f nginx
```

---

# WP-CLI

List plugins

```
./scripts/wp.sh plugin list
```

Core version

```
./scripts/wp.sh core version
```

Flush cache

```
./scripts/wp.sh cache flush
```

---

# Backup

Database

```
./scripts/backup/backup-db.sh
```

WordPress

```
./scripts/backup/backup-wordpress.sh
```

Nginx

```
./scripts/backup/backup-nginx.sh
```

SSL

```
./scripts/backup/backup-ssl.sh
```

---

# Restore

Database

```
./scripts/restore/restore-db.sh backups/database/file.sql.gz
```

WordPress

```
./scripts/restore/restore-wordpress.sh backups/wordpress/file.tar.gz
```

Nginx

```
./scripts/restore/restore-nginx.sh backups/nginx/file.tar.gz
```

SSL

```
./scripts/restore/restore-ssl.sh backups/ssl/file.tar.gz
```

Complete Disaster Recovery

```
./scripts/restore/restore-all.sh
```

---

# Monitoring

Run health check

```
./scripts/monitor/health-check.sh
```

---

# Health Checklist

* Nginx
* WordPress
* WordPress-2
* MariaDB
* Redis
* Website HTTP Status
* Disk Usage
* Memory Usage
* Docker Stats

---

# FastCGI Cache Test

```
curl -I https://cloudaziz.com
```

Expected

```
x-fastcgi-cache: HIT
```

---

# Redis Test

```
docker exec redis redis-cli ping
```

Expected

```
PONG
```

---

# Nginx Configuration Test

```
docker exec nginx nginx -t
```

Expected

```
syntax is ok
test is successful
```

---

# Git Workflow

Check status

```
git status
```

Commit

```
git add .
git commit -m "Description"
```

Push

```
git push
```

---

# Important

## Security Best Practices

- Never commit the `.env` file to Git.
- Never store production passwords, API keys, or secrets in the repository.
- Do not commit SSL certificates or Let's Encrypt account data (`certbot/conf/`).
- Generate SSL certificates separately on each production server.
- Verify backups before performing a production restore.
- Keep Docker images and base operating system packages up to date.
- Review configuration changes before deploying to production.
- Test all major changes on a staging or test environment before applying them to production.


Never commit:

* .env
* backups/
* SSL certificates
* cache
* logs

---

# Production Status

* Dockerized
* SSL Enabled
* Redis Enabled
* FastCGI Cache Enabled
* Load Balanced
* Backup Ready
* Disaster Recovery Ready
* Monitoring Ready

### Repository Verification

- ✅ Fresh clone tested
- ✅ Docker image builds successfully
- ✅ Stack starts successfully with Docker Compose
- ✅ Health checks pass
- ✅ Load balancing verified
- ✅ Repository contains no production secrets
---

Maintainer

**Md Abdul Aziz**

CloudAziz

