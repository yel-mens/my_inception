*This project has been created as part of the 42 curriculum by yel-mens.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. Its goal is to build a small infrastructure using Docker and Docker Compose, with each service running in its own dedicated container.

The mandatory infrastructure consists of three services:

- **NGINX:** acts as the web server and provides secure HTTPS access.
- **WordPress:** runs the website and processes PHP requests.
- **MariaDB:** stores the WordPress database.

The services communicate through a Docker network. Persistent volumes keep database and website data available even when containers are stopped, removed, or recreated.

The infrastructure is built from custom Dockerfiles rather than relying on preconfigured application images.

## Architecture

```text
                 Web browser
                      |
                   HTTPS :443
                      |
                 +---------+
                 |  NGINX  |
                 +---------+
                      |
                 FastCGI :9000
                      |
                +-----------+
                | WordPress |
                +-----------+
                      |
                  MariaDB
                 TCP :3306
                      |
                +-----------+
                |  MariaDB  |
                +-----------+

        Docker network: inception

        Persistent storage:
        - WordPress files
        - MariaDB database
```

Only the HTTPS entry point is intended to be exposed to the host. WordPress and MariaDB communicate internally through the Docker network.

## Services

| Service | Responsibility |
|---|---|
| NGINX | HTTPS connections, TLS termination and PHP request forwarding |
| WordPress | Website management and dynamic PHP processing |
| MariaDB | Persistent relational database for WordPress |

Each service has its own Dockerfile and configuration.

## Technologies

- Docker
- Docker Compose
- Linux
- NGINX
- WordPress
- PHP-FPM
- MariaDB
- TLS/SSL certificates
- Make

## Instructions

### Prerequisites

- A Linux virtual machine or compatible Linux environment.
- Docker Engine.
- Docker Compose, preferably through the Docker Compose plugin.
- `make`.
- A valid local domain configured for the project.

### Configuration

Configure the required environment variables in `srcs/.env` according to the project's configuration.

Do not commit passwords, private keys, or other sensitive information to Git.

Make sure the domain used by NGINX resolves to the virtual machine. For a local evaluation environment, an entry in `/etc/hosts` may be required.

### Build and start

From the repository root:

```bash
make
```

This command builds the required images and starts the services according to the Makefile and Docker Compose configuration.

### Stop the infrastructure

```bash
make down
```

### Rebuild the infrastructure

```bash
make re
```

Check the Makefile before using cleanup targets, as some of them may remove containers, images, or persistent data.

### Access the website

Open the configured domain in a browser:

```text
https://yel-mens.42.fr
```

The certificate may be self-signed, so a browser security warning can be expected in a local development environment.

## Persistent data

The persistent data directories are configured under:

```text
/home/yel-mens/data/
├── mariadb/
└── wordpress/
```

The MariaDB directory stores database files. The WordPress directory stores website files.

These directories must be preserved when restarting or rebuilding the infrastructure.

## Documentation

- [`USER_DOC.md`](USER_DOC.md): instructions for starting and using the infrastructure.
- [`DEV_DOC.md`](DEV_DOC.md): technical architecture, configuration, maintenance and troubleshooting.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [WP-CLI documentation](https://make.wordpress.org/cli/handbook/)
- [MariaDB documentation](https://mariadb.com/docs/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)

### Use of AI

AI tools were used as assistance during project development and documentation, including reviewing configuration, identifying potential startup and persistence issues, explaining Docker concepts, and helping prepare troubleshooting procedures. All generated suggestions must be checked against the actual implementation and the project requirements.
