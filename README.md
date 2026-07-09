# CloudAziz VPS Setup Guide

**Project:** CloudAziz Production Infrastructure
**Repository:** vps-docker-setup
**Version:** 1.0
**Platform:** Ubuntu 24.04 LTS (2GB VPS Optimized)

---

# 1. Overview

এই গাইড অনুসরণ করে একটি নতুন VPS-এ CloudAziz-এর সম্পূর্ণ Infrastructure প্রস্তুত করা হবে।

এই ধাপে কোনো Website Data Restore করা হবে না।

Infrastructure প্রস্তুত হওয়ার পর আলাদা Backup Repository ব্যবহার করে Site Restore করা হবে।

---

# 2. Server Requirements

Minimum Requirements

* 2 GB RAM
* 1 vCPU
* 40 GB SSD
* Ubuntu 24.04 LTS
* Public IPv4
* Domain Name
* Cloudflare (Recommended)

---

# 3. Login

SSH দিয়ে Server-এ Login করুন।

```bash
ssh root@SERVER_IP
```

---

# 4. Update System

```bash
apt update
apt upgrade -y
apt autoremove -y
```

---

# 5. Install Required Packages

```bash
apt install -y \
git \
curl \
wget \
nano \
tree \
ca-certificates \
gnupg \
lsb-release
```

---

# 6. Install Docker

Docker Official Repository ব্যবহার করে Docker Engine Install করুন।

যাচাই করুন:

```bash
docker --version
```

---

# 7. Install Docker Compose

যাচাই করুন:

```bash
docker compose version
```

---

# 8. Clone Repository

```bash
cd /srv

git clone git@github.com:cloudaziz/vps-docker-setup.git cloudaziz

cd cloudaziz
```

---

# 9. Repository Structure

```text
/srv/cloudaziz

docker/
nginx/
certbot/
scripts/
.env.example
docker-compose.yml
Dockerfile
php.ini
healthcheck.sh
README.md
```

---

# 10. Configure Environment

`.env.example` কপি করুন।

```bash
cp .env.example .env
```

`.env` ফাইল সম্পাদনা করুন।

উদাহরণ:

```env
DOMAIN=cloudaziz.com

MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=********
MYSQL_ROOT_PASSWORD=********

TZ=Asia/Dhaka
```

---

# 11. Verify Docker Compose

```bash
docker compose config
```

কোনো Error থাকা যাবে না।

---

# 12. Build Images

```bash
docker compose build
```

---

# 13. Start Infrastructure

```bash
docker compose up -d
```

---

# 14. Verify Containers

```bash
docker compose ps
```

Expected Services

* nginx
* mariadb
* redis
* wordpress
* wordpress-2
* phpmyadmin

সব Container Running এবং Healthy থাকতে হবে।

---

# 15. Verify Redis

```bash
docker exec redis redis-cli ping
```

Expected Output

```text
PONG
```

---

# 16. Verify MariaDB

```bash
docker exec mariadb mariadb -u root -p
```

---

# 17. Verify Nginx

```bash
docker exec nginx nginx -t
```

Expected Output

```text
syntax is ok
test is successful
```

---

# 18. Verify WordPress Containers

```bash
docker compose ps
```

WordPress এবং WordPress-2 Healthy থাকতে হবে।

---

# 19. Verify Logs

```bash
docker compose logs
```

কোনো Fatal Error থাকা যাবে না।

---

# 20. Infrastructure Status

এই পর্যায়ে—

✓ Docker Installed

✓ Docker Compose Installed

✓ Images Built

✓ Containers Running

✓ Redis Running

✓ MariaDB Running

✓ WordPress Running

✓ Nginx Running

Infrastructure Ready.

এখনও Website Restore করা হয়নি।

---

# 21. Next Step

Infrastructure প্রস্তুত হওয়ার পরে Backup Repository Clone করুন।

```bash
cd /srv

git clone git@github.com:cloudaziz/cloudaziz-docker-backup.git cloudaziz-backup
```

---

# 22. Restore Production Website

Infrastructure Repository থেকে নয়।

Backup Repository ব্যবহার করে Restore করুন।

```bash
cd /srv/cloudaziz/scripts

./restore.sh
```

Restore Process স্বয়ংক্রিয়ভাবে করবে:

* SHA256 Verification
* Docker Restore
* SSL Restore
* Nginx Restore
* WordPress Restore
* Database Restore
* Container Restart

---

# 23. Validation

Restore শেষ হলে পরীক্ষা করুন:

```bash
docker compose ps
```

```bash
docker exec redis redis-cli ping
```

```bash
docker exec nginx nginx -t
```

```bash
curl -I https://cloudaziz.com
```

Expected:

* HTTP/2 200
* SSL Working
* All Containers Healthy

---

# 24. Final Checklist

✓ Ubuntu Updated

✓ Docker Installed

✓ Docker Compose Installed

✓ Repository Cloned

✓ .env Configured

✓ Images Built

✓ Containers Running

✓ Restore Completed

✓ Website Online

✓ SSL Working

✓ Redis Connected

✓ Database Connected

✓ Load Balancer Working

✓ Health Checks Passed

---

# 25. Workflow Summary

```text
New VPS
    │
    ▼
Update Ubuntu
    │
    ▼
Install Docker
    │
    ▼
Install Docker Compose
    │
    ▼
Clone vps-docker-setup
    │
    ▼
Configure .env
    │
    ▼
docker compose build
    │
    ▼
docker compose up -d
    │
    ▼
Infrastructure Ready
    │
    ▼
Clone cloudaziz-docker-backup
    │
    ▼
Run restore.sh
    │
    ▼
Production Website Online
```

---

**Document Status:** Production Ready
**Repository:** vps-docker-setup
**Last Updated:** July 2026
