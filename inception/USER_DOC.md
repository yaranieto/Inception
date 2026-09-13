# USER_DOC — Inception

How to use the stack.

## Services

| Service | Role | Outside |
|---------|------|---------|
| NGINX | HTTPS (TLS 1.2/1.3) | **443** only |
| WordPress + php-fpm | CMS | via NGINX |
| MariaDB | DB | internal |

`restart: always` on all containers.

## Commands

```bash
make          # build + start
make up / down / ps / logs
```

## Access

1. `/etc/hosts`: `<VM_IP>  ynieto-s.42.fr`
2. Site: `https://ynieto-s.42.fr` (accept self-signed cert warning)
3. Admin: `https://ynieto-s.42.fr/wp-admin`
   - user `yara` (`.env` → `WP_ADMIN_USER`, must not contain `admin`)
   - password in `secrets/credentials.txt`
   - second user: `editor`

## Secrets & data

| File | Use |
|------|-----|
| `secrets/credentials.txt` | WP admin password |
| `secrets/db_password.txt` | MariaDB user (WordPress) |
| `secrets/db_root_password.txt` | MariaDB root |

`.env` = domain, DB name, usernames (not passwords). Secrets are gitignored.

Persistence: `~/data/wordpress` and `~/data/mariadb` (survive `down`/`up`).
`make fclean` wipes them (needs `sudo`).

Check: `make ps` and `curl -kI https://ynieto-s.42.fr`.
Logs: `docker compose -f srcs/docker-compose.yml logs <service>`.
