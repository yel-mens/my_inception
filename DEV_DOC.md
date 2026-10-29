# Developer Documentation

## 1. Purpose

This document describes the technical architecture of the Inception project and explains how to build, configure, inspect, and maintain its Docker infrastructure.

The infrastructure is defined using Docker Compose, with custom Dockerfiles for the individual services.

## 2. Project structure

The main project structure is organized as follows:

```text
inception/
├── Makefile
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        └── mariadb/
            ├── Dockerfile
            └── tools/
```

This is a representative overview. The exact configuration and script filenames depend on the current implementation.

- `Makefile`: provides convenient commands for managing the infrastructure.
- `srcs/docker-compose.yml`: declares the services, network, volumes, build contexts, and port mappings.
- `srcs/.env`: supplies environment variables to the Compose configuration and services.
- Each service directory contains the Dockerfile and configuration or initialization scripts required by that service.

## 3. System architecture

The mandatory infrastructure contains three services.

### 3.1 NGINX

NGINX is the entry point for incoming web traffic.

Its responsibilities include:

- Listening for HTTPS connections on port 443.
- Using a TLS certificate and private key.
- Forwarding PHP requests to WordPress through FastCGI.
- Serving as the public-facing web server.

The NGINX configuration should use the project's configured domain and permit only the required TLS versions.

### 3.2 WordPress

WordPress runs the website and uses PHP-FPM to process PHP requests.

Its responsibilities include:

- Initializing WordPress when required.
- Connecting to MariaDB using the internal Docker service name.
- Serving the WordPress application through PHP-FPM.
- Persisting the website files in the configured storage volume.

The WordPress initialization script should handle first-time installation and subsequent container restarts safely.

### 3.3 MariaDB

MariaDB provides persistent relational storage.

Its responsibilities include:

- Initializing the database when required.
- Creating the WordPress database and application user.
- Applying the necessary database privileges.
- Running the database server as the container's main process.

Database initialization must not erase existing data during an ordinary restart.

## 4. Network communication

The services communicate through a Docker network declared in Docker Compose.

The intended request flow is:

```text
Browser
   |
   | HTTPS :443
   v
 NGINX
   |
   | FastCGI :9000
   v
WordPress / PHP-FPM
   |
   | MariaDB protocol :3306
   v
 MariaDB
```

Docker's internal DNS resolves service names to their corresponding container addresses.

For example, WordPress can connect to the database using the MariaDB service name rather than a hard-coded container IP address.

Only the necessary public-facing ports should be published to the host. Internal services should communicate through the Docker network without unnecessary host port exposure.

## 5. Docker images and containers

Each mandatory service is built from its own Dockerfile.

A Docker image contains the filesystem and configuration needed to create a container. A container is a running instance of that image.

The Compose configuration should explicitly identify the images used for the services and define their respective build contexts.

Base images should use permitted, explicit version tags rather than relying on the `latest` tag, as required by the project subject.

Containers should run their intended service as the main process. Initialization scripts should use `exec` when handing over execution to the final service process.

## 6. Docker Compose

The Compose configuration is located at:

```text
srcs/docker-compose.yml
```

It defines the infrastructure as a set of related services.

The configuration is responsible for:

- Building service images.
- Creating and connecting the services to the Docker network.
- Configuring environment variables.
- Defining persistent volumes.
- Publishing the required host ports.
- Defining service startup dependencies.

A startup dependency alone does not guarantee that a database is ready to accept connections. The WordPress initialization process should therefore verify database availability before attempting installation.

## 7. Environment configuration

Environment variables are stored in:

```text
srcs/.env
```

They are used to configure the domain, database credentials, and WordPress installation.

The exact variable names must match those referenced by the Compose file, Dockerfiles, and initialization scripts.

Sensitive values must not be hard-coded into Dockerfiles or committed to the repository. The `.env` file should remain private and be protected with appropriate filesystem permissions.

The `.env` file is configuration input, not a replacement for application-level validation or secure password handling.

## 8. Persistent volumes

Persistent storage is configured under:

```text
/home/<login>/data/
├── mariadb/
└── wordpress/
```

Replace `yel-mens` with the actual configured login.

| Storage location | Purpose |
|---|---|
| `/home/yel-mens/data/mariadb` | Persistent MariaDB database files |
| `/home/yel-mens/data/wordpress` | Persistent WordPress application files |

These locations must correspond to the host paths configured in Docker Compose.

Containers can be recreated independently of their persistent data. This separation allows the services to be rebuilt without intentionally deleting the website or database.

Before destructive maintenance, create a backup and verify which resources the relevant Makefile target removes.

## 9. Build and lifecycle management

Run commands from the repository root.

### Start and build

```bash
make
```

### Stop the services

```bash
make down
```

### Rebuild and restart

```bash
make re
```

### Inspect the containers

```bash
docker compose \
  --env-file srcs/.env \
  -f srcs/docker-compose.yml ps
```

### Inspect the images

```bash
docker images
```

### Inspect the network

```bash
docker network ls
```

### Inspect volumes

```bash
docker volume ls
```

### Inspect service logs

```bash
docker compose \
  --env-file srcs/.env \
  -f srcs/docker-compose.yml logs nginx wordpress mariadb
```

The Makefile is the project's primary interface for routine lifecycle operations. Always check the implementation of destructive targets before using them.

## 10. Database administration

The project provides a database shell target:

```bash
make db-shell
```

Once connected, inspect the database:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

The database name must match the value configured in the environment.

A correctly initialized WordPress database should contain its application tables, including tables for posts, users, and options. The exact table prefix may vary according to the WordPress configuration.

## 11. First-start initialization

A fresh deployment requires the database and WordPress application to initialize in the correct order.

A robust startup sequence should:

1. Start MariaDB.
2. Initialize the database and application user if necessary.
3. Wait until MariaDB accepts connections.
4. Download WordPress files if they are missing.
5. Generate the WordPress configuration if it is missing.
6. Install WordPress only if it is not already installed.
7. Start PHP-FPM as the main container process.

Initialization scripts must be safe to execute again after a container restart. Existing databases, configuration files, and WordPress installations must not be overwritten unnecessarily.

## 12. Troubleshooting

### Database connection failures

Check the MariaDB logs and confirm that the database is ready. Verify the internal hostname and database credentials used by WordPress.

### NGINX returns a gateway error

Check that WordPress is running, PHP-FPM is listening on the expected internal port, and NGINX uses the correct upstream service name.

### Containers repeatedly restart

Inspect the logs of the affected service. Common causes include invalid configuration, missing environment variables, permission errors, and failed initialization.

### Data is missing after rebuilding

Verify the host paths and mount points in the Compose configuration. Confirm that the cleanup procedure did not remove the persistent directories.

### HTTPS does not work

Verify the port mapping, NGINX configuration, certificate paths, private-key permissions, and TLS settings.

## 13. Validation checklist

Before submitting the project, verify the following:

- [ ] All mandatory images build successfully from their Dockerfiles.
- [ ] All mandatory services start and remain running.
- [ ] Services communicate through the Docker network.
- [ ] Only the intended public-facing ports are exposed.
- [ ] HTTPS works with the required TLS configuration.
- [ ] HTTP is not served as an alternative website entry point.
- [ ] WordPress connects to MariaDB and is installed automatically.
- [ ] A clean first deployment succeeds without pre-existing data.
- [ ] WordPress and database data persist across container recreation.
- [ ] The website remains available after a virtual machine reboot.
- [ ] No credentials or private keys are committed to Git.

## 14. References

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress developer documentation](https://developer.wordpress.org/)
- [WP-CLI handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB documentation](https://mariadb.com/docs/)
- [PHP documentation](https://www.php.net/manual/en/)
