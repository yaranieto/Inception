# User Documentation — Inception

This guide explains how to use and manage the Inception web stack as an end user or administrator.

## Services overview

The Inception stack provides three containerized services:

| Service | Role | External access |
|---------|------|-----------------|
| **NGINX** | Reverse proxy with HTTPS (TLS 1.2/1.3) | Port **443** (only entry point) |
| **WordPress** | Content management system with PHP-FPM | Internal only (via NGINX) |
| **MariaDB** | Database server for WordPress | Internal only |

All services restart automatically if they crash (`restart: always`).

## Starting and stopping the project

From the project root directory:

```bash
# Start everything (build + launch)
make

# Start without rebuilding
make up

# Stop all containers
make down

# View running containers
make ps

# View live logs
make logs
```

## Accessing the website

1. Ensure your `/etc/hosts` file contains:
   ```
   <VM_IP_ADDRESS>  ynieto-s.42.fr
   ```
2. Open your browser and navigate to:
   ```
   https://ynieto-s.42.fr
   ```
3. Accept the self-signed certificate warning (expected in development).

## Accessing the WordPress admin panel

- **URL:** `https://ynieto-s.42.fr/wp-admin`
- **Username:** `yara` (defined in `srcs/.env` as `WP_ADMIN_USER`)
- **Password:** stored in `secrets/credentials.txt`

## Managing credentials

All sensitive credentials are stored locally and are **not** committed to Git:

| File | Contains |
|------|----------|
| `secrets/credentials.txt` | WordPress administrator password |
| `secrets/db_password.txt` | MariaDB user password (for WordPress) |
| `secrets/db_root_password.txt` | MariaDB root password |

To change a password:

1. Edit the corresponding file in `secrets/`.
2. Rebuild and restart the stack:
   ```bash
   make re
   ```

> **Note:** Changing the WordPress admin password file alone does not update an already-installed WordPress instance. Use the WordPress admin panel or WP-CLI to change it after installation.

Non-sensitive configuration (domain name, database name, admin username) is in `srcs/.env`.

## Checking that services are running

```bash
# Container status
make ps

# Expected output: mariadb, wordpress, nginx all "Up"

# Test HTTPS endpoint
curl -kI https://ynieto-s.42.fr

# Check TLS version (should be TLSv1.2 or TLSv1.3)
openssl s_client -connect ynieto-s.42.fr:443 -tls1_2 < /dev/null 2>/dev/null | head -5
```

If a container is not running, check its logs:

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs nginx
```

## Data persistence

Website files and database data persist across restarts in:

- `~/data/wordpress` — WordPress website files
- `~/data/mariadb` — MariaDB database files

These directories are managed by Docker named volumes and survive container restarts and rebuilds.
