# Developer Documentation — Inception

This guide covers setting up, building, and managing the Inception project from scratch.

## Prerequisites

- **OS:** Linux virtual machine (required by 42 subject)
- **Docker:** Engine 20.10+ with Compose V2 plugin
- **Make:** GNU Make
- **Git:** For cloning the repository
- **Network:** VM must have internet access during build (to download packages and WordPress)

Verify installations:

```bash
docker --version
docker compose version
make --version
```

## Project structure

```
inception/
├── Makefile                          # Build and lifecycle commands
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .gitignore
├── secrets/                          # Passwords (gitignored)
│   ├── credentials.txt               # WP admin password
│   ├── db_password.txt               # MariaDB user password
│   └── db_root_password.txt          # MariaDB root password
└── srcs/
    ├── docker-compose.yml            # Service orchestration
    ├── .env                          # Non-sensitive environment variables
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/50-server.cnf
        │   └── tools/entrypoint.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/nginx.conf
        │   ├── conf/default.conf.template
        │   └── tools/entrypoint.sh
        └── wordpress/
            ├── Dockerfile
            ├── conf/www.conf
            └── tools/entrypoint.sh
```

## Environment setup from scratch

### 1. Configure the domain

Add your VM's IP to `/etc/hosts` on the machine you browse from:

```
<VM_IP>  ynieto-s.42.fr
```

### 2. Create secrets

Each secret file must contain **only the password** (no trailing newline issues — one line, no extra spaces):

```bash
echo -n "StrongPassword123!" > secrets/db_password.txt
echo -n "StrongRootPass456!" > secrets/db_root_password.txt
echo -n "StrongAdminPass789!" > secrets/credentials.txt
chmod 600 secrets/*.txt
```

### 3. Review environment variables

Edit `srcs/.env` if needed:

```env
DOMAIN_NAME=ynieto-s.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_TITLE=Inception
WP_ADMIN_USER=yara
WP_ADMIN_EMAIL=yara@student.42.fr
DATA_PATH=/home/ynieto-s/data
```

> `WP_ADMIN_USER` must **not** contain `admin`, `Admin`, `administrator`, or `Administrator`.
>
> When using `make`, `DATA_PATH` is exported automatically as `$(HOME)/data`. The value in `.env` is only a fallback if you run `docker compose` directly.

### 4. Create data directories

The Makefile handles this automatically via `make setup`, but you can also run:

```bash
mkdir -p ~/data/mariadb ~/data/wordpress
```

## Build and launch

```bash
# Full setup: create dirs, build images, start containers
make

# Or step by step:
make setup
make build
make up
```

The Makefile calls Docker Compose with:

```bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
```

## Managing containers

```bash
# List containers
make ps
# or
docker compose -f srcs/docker-compose.yml ps

# Follow all logs
make logs

# Logs for a specific service
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb

# Restart a single service
docker compose -f srcs/docker-compose.yml restart nginx

# Execute a command inside a container
docker exec -it wordpress wp user list --allow-root
docker exec -it mariadb mariadb -u root -p
```

## Managing volumes

Named volumes are defined in `docker-compose.yml` and map to host paths:

| Volume name | Container path | Host path |
|-------------|---------------|-----------|
| `mariadb_data` | `/var/lib/mysql` | `~/data/mariadb` |
| `wordpress_data` | `/var/www/html` | `~/data/wordpress` |

NGINX also mounts `wordpress_data` read-only at `/var/www/html` to serve static assets over HTTPS.

```bash
# Inspect volumes
docker volume ls
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data

# Remove everything (containers, images, volumes)
make clean

# Full wipe including host data
make fclean
```

## Rebuilding after changes

```bash
# Rebuild a single service
docker compose -f srcs/docker-compose.yml build nginx
docker compose -f srcs/docker-compose.yml up -d nginx

# Full rebuild from scratch
make re
```

## Troubleshooting

### WordPress shows "Error establishing database connection"

- Check MariaDB is running: `docker compose -f srcs/docker-compose.yml ps`
- Verify secrets match: passwords in `secrets/` must be consistent across rebuilds
- Check MariaDB logs: `docker compose -f srcs/docker-compose.yml logs mariadb`

### NGINX returns 502 Bad Gateway

- WordPress/PHP-FPM may not be ready yet — wait a few seconds and retry
- Check WordPress logs: `docker compose -f srcs/docker-compose.yml logs wordpress`

### Empty WordPress site after first launch

- The entrypoint seeds files from `/var/www/wordpress-staging` into the volume on first run
- If the volume already exists but is empty, run `make fclean && make` to reset

### TLS certificate warnings

- Expected behavior — a self-signed certificate is generated on first NGINX start
- For evaluation, testers use `curl -k` or accept the browser warning

## Security notes

- Never commit `secrets/*.txt` to Git (covered by `.gitignore`)
- No passwords appear in Dockerfiles — all credentials come from secrets or `.env`
- Only port 443 is exposed externally
- TLS 1.2 and 1.3 only — older protocols are disabled in NGINX config
- `network: host`, `--link`, and `links:` are not used
