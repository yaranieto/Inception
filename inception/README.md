# This project has been created as part of the 42 curriculum by ynieto-s.

## Description

Inception is a small infrastructure built with **Docker Compose** inside a **virtual machine**.
It runs three dedicated services:

- **NGINX** — only entry point, HTTPS on port **443**, **TLSv1.2 / TLSv1.3** only
- **WordPress + php-fpm** — no nginx inside this container
- **MariaDB** — WordPress database, no nginx

Images are built from **custom Dockerfiles** based on **Debian Bookworm**
(penultimate stable). Ready-made nginx/wordpress/mariadb images are not used.
Containers use `restart: always`. Domain: `ynieto-s.42.fr`.

```
[Client] --HTTPS:443--> [NGINX] --FastCGI:9000--> [WordPress + PHP-FPM]
                                                      |
                                                   TCP:3306
                                                      |
                                                   [MariaDB]
```

WordPress has two users: administrator (`yara`, name must not contain `admin`)
and a second user (`editor`).

## Project structure

```
inception/
├── Makefile
├── README.md / USER_DOC.md / DEV_DOC.md
├── secrets/          # passwords (gitignored)
└── srcs/
    ├── docker-compose.yml
    ├── .env          # non-sensitive config
    └── requirements/{nginx,wordpress,mariadb}/
```

## Design choices (asked in evaluation)

### Virtual machine vs Docker
The whole project must run **inside a VM** (42 rule). Docker does **not** replace the VM:
the VM is the host; Docker runs the three services as containers (shared kernel, lighter
and faster than one full VM per service).

### Environment variables vs secrets
- `srcs/.env` — domain, DB name, usernames (non-sensitive)
- `secrets/*.txt` — passwords only, mounted as Docker secrets in `/run/secrets/`
  (not hardcoded in Dockerfiles, not committed to Git)

### Docker network vs host network
A dedicated **bridge** network (`inception`) connects the containers by service name.
`network: host` and `links` are forbidden. Only port **443** is published to the host;
MariaDB (3306) and php-fpm (9000) stay internal.

### Volumes vs bind mounts
Two **named volumes** (`mariadb_data`, `wordpress_data`) with the `local` driver and
`bind` options map to fixed host paths required by the subject:

- `/home/<login>/data/mariadb` — database
- `/home/<login>/data/wordpress` — WordPress files

This keeps Docker named volumes while storing data under `/home/login/data` on the host.

## Setup

1. Add to `/etc/hosts`: `127.0.0.1 ynieto-s.42.fr` (or your VM IP)
2. Create secrets (passwords must not be empty/too weak, and should not contain `admin`):
   ```bash
   echo "your_db_password"   > secrets/db_password.txt
   echo "your_root_password" > secrets/db_root_password.txt
   echo "your_wp_password"   > secrets/credentials.txt
   ```
3. From the project root: `make`
4. Open `https://ynieto-s.42.fr` (accept the self-signed certificate warning).
   Admin panel: `https://ynieto-s.42.fr/wp-admin` (user `yara`, password in `credentials.txt`).

## Makefile

| Target | Description |
|--------|-------------|
| `make` / `all` | Create `~/data` dirs, build images, start the stack |
| `make build` | Build Docker images via Compose |
| `make up` / `down` | Start / stop containers |
| `make clean` | Remove containers, local images and Compose volumes |
| `make fclean` | `clean` + wipe host data under `~/data` (needs `sudo`) |
| `make re` | `fclean` then `all` |
| `make logs` / `ps` | Follow logs / show container status |

More detail: [USER_DOC.md](USER_DOC.md), [DEV_DOC.md](DEV_DOC.md).
