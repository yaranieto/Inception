# This project has been created as part of the 42 curriculum by ynieto-s.

## Description

Inception is a Docker-based infrastructure project that deploys a small, production-like web stack inside a virtual machine. The goal is to containerize and orchestrate three services — NGINX, WordPress (with PHP-FPM), and MariaDB — using Docker Compose, custom Dockerfiles, named volumes, secrets, and a dedicated Docker network.

The stack exposes a WordPress website over HTTPS (TLS 1.2/1.3 only) through NGINX, which acts as the single entry point on port 443.

## Project description

This project uses **Docker** to package each service into its own container, ensuring isolation, reproducibility, and easy deployment. All images are built from custom Dockerfiles based on **Debian Bookworm** (the penultimate stable release at the time of development). No pre-built application images are pulled from Docker Hub — only the base OS image is used.

### Architecture

```
[Client] --HTTPS:443--> [NGINX] --FastCGI:9000--> [WordPress + PHP-FPM]
                                                          |
                                                     TCP:3306
                                                          |
                                                      [MariaDB]
```

### Main design choices

- **One container per service** — NGINX, WordPress/PHP-FPM, and MariaDB each run in dedicated containers.
- **Custom Dockerfiles** — Every service is built from scratch on Debian Bookworm.
- **Docker Compose** — Orchestrates build, networking, volumes, and secrets.
- **Named volumes with local driver** — Persistent data stored under `~/data/` on the host (`/home/<login>/data`).
- **Docker secrets** — Database and WordPress admin passwords are never hardcoded in Dockerfiles or committed to Git.
- **Dedicated bridge network** — Containers communicate internally without exposing unnecessary ports.

### Virtual Machines vs Docker

| Aspect | Virtual Machine | Docker |
|--------|----------------|--------|
| Isolation | Full OS per VM | Shared kernel, isolated processes |
| Size | GBs per VM | MBs per container |
| Boot time | Minutes | Seconds |
| Overhead | High (hypervisor + full OS) | Low (container runtime) |
| Use case | Different OS kernels, full isolation | Microservices, reproducible dev/prod environments |

Docker containers share the host kernel, making them lightweight and fast to start. VMs provide stronger isolation at the cost of resources and complexity. For this project, Docker is ideal because each service runs Linux and benefits from fast, reproducible deployments.

### Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets |
|--------|----------------------|----------------|
| Visibility | Visible in `docker inspect`, process lists | Mounted as files in `/run/secrets/`, not in env |
| Git safety | Risk of committing `.env` with passwords | Stored in separate files, gitignored |
| Use case | Non-sensitive config (domain, usernames) | Passwords, API keys, credentials |

This project uses `.env` for non-sensitive configuration (domain name, database name, admin username) and **Docker secrets** for all passwords.

### Docker Network vs Host Network

| Aspect | Docker Network (bridge) | Host Network |
|--------|------------------------|--------------|
| Isolation | Containers get private IPs | Container shares host network stack |
| Port mapping | Explicit `ports:` mapping | Container binds directly to host ports |
| DNS | Built-in service name resolution | No automatic service discovery |
| Security | Better isolation between services | Less isolation |

A dedicated bridge network (`inception`) allows containers to communicate by service name (e.g., `wordpress:9000`, `mariadb:3306`) while only NGINX exposes port 443 to the outside.

### Docker Volumes vs Bind Mounts

| Aspect | Named Volumes | Bind Mounts |
|--------|--------------|-------------|
| Management | Managed by Docker | Direct host path mapping |
| Portability | Docker handles location | Tied to specific host path |
| Performance | Optimized by Docker | Depends on filesystem |
| Use case | Persistent app data | Dev hot-reload, config files |

This project uses **named volumes** with the `local` driver and `bind` options to store data in `/home/<login>/data/`, satisfying both the named volume requirement and the host path constraint. NGINX mounts the WordPress volume read-only so static assets (CSS, JS, images) are served correctly.

## Instructions

### Prerequisites

- A Linux virtual machine (mandatory for 42 evaluation)
- Docker and Docker Compose installed
- Domain `ynieto-s.42.fr` pointing to your VM's local IP in `/etc/hosts`

### Quick start

```bash
# 1. Clone the repository
git clone <repo-url> inception && cd inception

# 2. Create secrets (see DEV_DOC.md for details)
echo "your_db_password"       > secrets/db_password.txt
echo "your_root_password"     > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/credentials.txt

# 3. Build and launch
make

# 4. Visit the site
https://ynieto-s.42.fr
```

### Makefile targets

| Target | Description |
|--------|-------------|
| `make` / `make all` | Setup data dirs, build images, and start containers |
| `make build` | Build Docker images |
| `make up` | Start containers in detached mode |
| `make down` | Stop and remove containers |
| `make clean` | Stop containers, remove images and volumes |
| `make fclean` | Full clean including host data directories |
| `make re` | Rebuild from scratch |
| `make logs` | Follow container logs |
| `make ps` | Show running containers |

See [USER_DOC.md](USER_DOC.md) for end-user documentation and [DEV_DOC.md](DEV_DOC.md) for developer setup details.

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [WP-CLI Handbook](https://developer.wordpress.org/cli/commands/)
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### AI usage

AI (Cursor/Claude) was used during this project for:

- Generating the initial project structure and boilerplate Dockerfiles
- Drafting configuration files (NGINX, PHP-FPM, MariaDB)
- Writing documentation (README, USER_DOC, DEV_DOC)
- Reviewing compliance with 42 subject requirements

All generated code was reviewed, tested, and adapted manually. Architecture decisions and security choices (secrets management, TLS configuration, volume strategy) were validated against the official subject and Docker best practices.
