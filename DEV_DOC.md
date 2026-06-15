# Developer Documentation - Inception

This document provides a comprehensive guide for developers to understand, set up, manage, and modify the Inception infrastructure.

---

## 1. Setting up the environment from scratch

### Prerequisites
- A Debian/Linux virtual machine (preferably Debian Bookworm or Bullseye).
- **Docker** and **Docker Compose** installed.
- **Make** installed.

### Host Configuration
The project requires the site to be accessible via the domain name `jfoeller.42.fr`. 
You must route this local domain to your localhost by modifying the `/etc/hosts` file:
```bash
sudo nano /etc/hosts
# Add the following line:
127.0.0.1   jfoeller.42.fr
```
If you are using a VirtualBox Virtual Machine with a NAT network interface, you must configure **Port Forwarding** rules in VirtualBox (Network -> Port Forwarding) to allow your host machine to communicate with the guest VM:

| Name | Protocol | Host IP | Host Port | Guest IP | Guest Port |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Navigateur | TCP | | `8443` | | `443` |
| SSH | TCP | `127.0.0.1` | `4242` | | `22` |

### Secrets and Environment Variables
All sensitive data and configuration parameters are managed via a `.env` file located in the `srcs/` directory. **This file is gitignored** and must be created manually from a `.env.example` (if provided) before launching.
It contains the following variables:
- `SQL_DATABASE`, `SQL_USER`, `SQL_PASSWORD`, `SQL_ROOT_PASSWORD`
- `WP_URL`, `WP_TITLE`
- `WP_ADMIN_USER` (must not contain "admin"), `WP_ADMIN_PASSWORD`, `WP_ADMIN_EMAIL`
- `WP_USER`, `WP_USER_PASSWORD`, `WP_USER_EMAIL`

---

## 2. Build and Launch the Activity

The entire infrastructure is orchestrated via the `Makefile` located at the root of the repository.

- **`make` or `make all`** : Creates the necessary local data folders (`mkdir -p`) and runs `docker compose up -d --build`. This builds the custom images and starts the containers in detached mode.
- **`make down` or `make clean`** : Stops and removes the containers and networks (`docker compose down --rmi all`), but **preserves the data volumes**.
- **`make fclean`** : **WARNING - DESTRUCTIVE COMMAND.** Executes `make clean` and forcibly removes the local data directories (`sudo rm -rf /home/jfoeller/data/*`).
- **`make re`** : Executes `fclean` followed by `all`.

---

## 3. Data Storage and Persistence

To ensure data survives container restarts or removals, this project uses **Named Volumes** mapped to local directories (**Bind Mounts**).

- **Database Volume (`mariadb`)** : Stored locally at `/home/jfoeller/data/mariadb`.
- **Website Volume (`wordpress`)** : Stored locally at `/home/jfoeller/data/wordpress`.

The mapping is defined in `docker-compose.yml` using `driver_opts` to explicitly link the Docker volume to the absolute local path. 
*Note: The `mkdir -p` command in the Makefile ensures these directories exist before Docker Compose attempts to mount them.*

---

## 4. Managing Containers and Volumes

Here are the essential commands for everyday management and debugging:

- Check running containers: `docker ps`
- Check all the services and containers status : `make status` (execute `docker compose ps`)
- Check internal container logs: `docker logs <container_name>` (e.g., `docker logs nginx`)
- Check all the internal containers logs: `make logs` (execute `docker compose logs`)
- Enter a running container: `docker exec -it <container_name> bash`
- List active Docker networks: `docker network ls`
- List active Docker volumes: `docker volume ls`
- Inspect volume persistence: `docker volume inspect srcs_mariadb` (Verify the "Mountpoint" and "device" path).

---

## 5. Live-Coding & Maintenance Guide

Below are procedures for standard evaluations or maintenance tasks. 
**Crucial Rule:** When modifying configuration to test persistence, use `make clean` and `make all`. **Never use `make fclean` or `make re`**, as they will destroy the persistent data.

### A. Verifying MariaDB Data Population
To prove that WordPress successfully populated the database:
1. Enter the MariaDB container:
   `docker exec -it mariadb mysql -u root -p`
2. Enter the root password defined in the `.env` file.
3. Run the following SQL commands:
   ```sql
   SHOW DATABASES;
   USE inception_db;
   SHOW TABLES;
   ```
4. *Optional:* `SELECT user_login FROM wp_users;`
5. Exit: `exit`

### B. Modifying the NGINX Port (e.g., 443 to 8443)
1. Stop the infrastructure: `make clean`
2. Edit `srcs/requirements/nginx/conf/nginx.conf`:
   Change `listen 443 ssl;` to `listen 8443 ssl;`
3. Edit `srcs/docker-compose.yml` in the `nginx` service:
   Change `ports: - "443:443"` to `ports: - "443:8443"`
4. Restart: `make all`

### C. Modifying the WordPress Port (PHP-FPM: 9000 to 9001)
1. Stop the infrastructure: `make clean`
2. Edit `srcs/requirements/wordpress/Dockerfile`:
   Change the `sed` command to listen on `9001` instead of `9000`.
3. Edit `srcs/requirements/nginx/conf/nginx.conf`:
   Update the PHP location block to: `fastcgi_pass wordpress:9001;`
4. Restart: `make all`

### D. Modifying the MariaDB Port (3306 to 3307)
*Note: Because WordPress data is persistent, modifying the MariaDB port requires updating the persistent WordPress configuration file directly.*
1. Stop the infrastructure: `make clean`
2. Edit `srcs/requirements/mariadb/mariadb.sh`:
   Add a line to force the new port:
   `sed -i '/\[mysqld\]/a port = 3307' /etc/mysql/mariadb.conf.d/50-server.cnf`
3. Edit the persistent `wp-config.php` file on the host machine:
   `sudo nano /home/jfoeller/data/wordpress/wp-config.php`
   Update the DB_HOST line to:
   `define( 'DB_HOST', 'mariadb:3307' );`
4. Restart: `make all`