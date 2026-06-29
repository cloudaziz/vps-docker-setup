# CloudAziz VPS Docker Setup

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

---

Maintainer

**Md Abdul Aziz**

CloudAziz

