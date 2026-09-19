# DEV_DOC — Inception

Setup and maintenance notes. Subject rules and design choices: see [README.md](README.md).

## Requirements

Linux **VM**, Docker + Compose V2, Make, Git, internet during build.

## Structure

```
inception/
├── Makefile
├── secrets/                 # passwords (gitignored)
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/{nginx,wordpress,mariadb}/   # Dockerfile, conf/, tools/
```

Makefile → `docker compose -f srcs/docker-compose.yml`.

## First setup

1. Hosts: `<VM_IP>  ynieto-s.42.fr`
2. Secrets (no empty/weak passwords, no word `admin`):
   ```bash
   echo "your_db_password"   > secrets/db_password.txt
   echo "your_root_password" > secrets/db_root_password.txt
   echo "your_wp_password"   > secrets/credentials.txt
   chmod 600 secrets/*.txt
   ```
3. Check `srcs/.env`: `DOMAIN_NAME`, `MYSQL_*`, `WP_ADMIN_USER=ynieto-s` (no `admin`),
   `WP_USER2`, `DATA_PATH=/home/ynieto-s/data` (overridden by Makefile on `make`).
4. `make` (creates `/home/ynieto-s/data/...`, builds, starts).

## Volumes (subject)

| Volume | Container | Host |
|--------|-----------|------|
| `mariadb_data` | `/var/lib/mysql` | `/home/ynieto-s/data/mariadb` |
| `wordpress_data` | `/var/www/html` | `/home/ynieto-s/data/wordpress` |

NGINX mounts `wordpress_data` read-only.

```bash
make clean     # containers, images, compose volumes
make fclean    # + wipe /home/ynieto-s/data (sudo)
make re        # fclean + all
```

## Debug

```bash
make ps / logs
docker compose -f srcs/docker-compose.yml logs -f mariadb
docker exec -w /var/www/html wordpress wp user list --allow-root
```

- DB connection error → MariaDB Up? secrets same as at init? else `make fclean && make`
- 502 → wait for php-fpm / check wordpress logs
- Empty site after wipe → `make fclean && make`
- “Not secure” in browser → expected (self-signed TLS)

## Do not break (subject)

Debian/Alpine Dockerfiles only · no ready-made service images · no `host`/`links` ·
no passwords in Dockerfiles · only **443** · TLS 1.2/1.3 · data under `/home/ynieto-s/data`.
