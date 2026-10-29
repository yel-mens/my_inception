# User Documentation

## 1. Overview

This document explains how to start, access, stop, and troubleshoot the Inception infrastructure.

The project runs a WordPress website using three services:

- NGINX provides secure HTTPS access.
- WordPress provides the website interface.
- MariaDB stores website data.

## 2. Requirements

Before starting, make sure the following tools are installed:

- Docker Engine
- Docker Compose
- Make

The project must be run from a Linux environment with the required permissions to use Docker.

## 3. Initial configuration

### 3.1 Configure environment variables

The environment configuration is stored in:

```text
srcs/.env
```

Set the required variables for the database, WordPress installation, domain name, and other settings expected by the Compose file and service scripts.

Use valid values for all required variables.

**Security:** Do not share the `.env` file or publish its passwords. Use strong passwords and keep private credentials outside version control.

### 3.2 Configure the domain

The website is intended to be accessed through:

```text
https://yel-mens.42.fr
```
For local testing, configure the domain to resolve to the virtual machine's IP address. Depending on the environment, this may require an entry in `/etc/hosts`.

## 4. Starting the project

Open a terminal in the repository root and run:

```bash
make
```

The Makefile builds the Docker images and starts the services.

Wait for the services to initialize before opening the website for the first time.

To inspect the running containers, use:

```bash
docker compose \
  --env-file srcs/.env \
  -f srcs/docker-compose.yml ps
```

The NGINX, WordPress, and MariaDB services should be running.

## 5. Accessing WordPress

Open the configured domain in a browser:

```text
https://yel-mens.42.fr
```

HTTPS is the intended access method.

A browser warning about the certificate can appear if the project uses a self-signed certificate. This is expected in a local development environment, but the certificate should not be treated as trusted for public production use.

### WordPress administration

To manage the website, open:

```text
https://yel-mens.42.fr/wp-admin
```

Sign in with the administrator credentials configured for the WordPress installation.

From the dashboard, an authorized administrator can manage posts, pages, users, themes, and other WordPress settings.

Never use the administrator account for ordinary user activities when a separate account is appropriate.

## 6. Stopping and restarting

Stop the services:

```bash
make down
```

Start them again:

```bash
make
```

Stopping containers does not normally delete the persistent data stored in the configured volumes.

Avoid destructive cleanup commands unless you understand their effect on the website and database.

## 7. Data persistence

The project stores persistent data under:

```text
/home/yel-mens/data/mariadb
/home/yel-mens/data/wordpress
```

These directories contain the database and WordPress files.

Do not manually delete or modify their contents while the services are running. Back up important data before performing maintenance.

Rebuilding a container should not be used as a substitute for a database backup.

## 8. Troubleshooting

### The website cannot be reached

Check the container status:

```bash
docker compose \
  --env-file srcs/.env \
  -f srcs/docker-compose.yml ps
```

Check the NGINX logs:

```bash
docker compose \
  --env-file srcs/.env \
  -f srcs/docker-compose.yml logs nginx
```

Verify that the configured domain resolves to the correct machine and that port 443 is reachable.

### WordPress displays a database connection error

Check the WordPress and MariaDB logs:

```bash
docker compose \
  --env-file srcs/.env \
  -f srcs/docker-compose.yml logs wordpress mariadb
```

Verify the database hostname, database name, username, and password in the configuration. The database hostname should match the MariaDB service name used in Docker Compose.

Allow time for MariaDB to initialize on a first startup.

### A container keeps restarting

Inspect its logs:

```bash
docker compose \
  --env-file srcs/.env \
  -f srcs/docker-compose.yml logs <service-name>
```

Replace `<service-name>` with `nginx`, `wordpress`, or `mariadb`.

Look for configuration errors, missing environment variables, file permission issues, or database initialization failures.

### The website loses data after maintenance

Check the Docker volume configuration and the host directories used for persistent storage.

Do not run destructive cleanup commands such as `make fclean` until you have verified exactly which resources and data the target removes.

## 9. Useful commands

| Action | Command |
|---|---|
| Start the project | `make` |
| Stop the project | `make down` |
| Rebuild and restart | `make re` |
| Inspect containers | `docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps` |
| View service logs | `docker compose --env-file srcs/.env -f srcs/docker-compose.yml logs` |
| Open a database shell | `make db-shell` |

The exact effects of each Makefile target should be checked in the project's Makefile before use.

## 10. Security recommendations

- Never publish credentials or private keys.
- Access the website through HTTPS.
- Use a strong WordPress administrator password.
- Keep persistent data and backups protected.
- Do not expose internal database or PHP-FPM ports unnecessarily.
- Do not delete persistent data unless a fresh installation is explicitly intended.
