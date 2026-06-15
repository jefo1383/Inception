# User & Administrator Documentation - Inception

This documentation provides clear, simple instructions for end-users and administrators to understand, operate, and verify the Inception application stack.

---

## 1. Services Provided by the Stack

The infrastructure runs as a multi-container application stack composed of three core services working together seamlessly:

1. **NGINX (Web Server)**: The sole entry point of the infrastructure. It securely handles incoming user traffic over HTTPS (port 443 internally), decrypts the SSL/TLS layer, and acts as a reverse proxy routing traffic to WordPress.
2. **WordPress (Content Management System)**: Powered by PHP-FPM, this service serves the dynamic website, process publications, manages comments, and handles administrative dashboards.
3. **MariaDB (Database)**: The relational database management system that securely stores all persistent application data, including posts, pages, configuration adjustments, and user profiles.

---

## 2. Starting and Stopping the Activity

Administrators can control the entire stack directly from the project root using standard terminal commands wrapped inside the `Makefile`.

### How to Start the Stack
To build images, initialize networks, mount volumes, and launch all services in the background, run the following command in your terminal:

    make all

*Note: If it is the first launch, this command automatically creates the persistent data directories on the host system.*

### How to Stop the Stack
To stop all the services and delete the containers and networks, run the following command:

    make down

To also remove docker images, run:

    make clean

*Important: Stopping the stack with these commands does **NOT** destroy your website data. All user accounts, blog posts, and database logs remain perfectly preserved in the persistent volumes.*

---

## 3. Accessing the Website and Administration Panel

Because the environment is isolated within a virtualized guest system, network traffic must pass through the designated VirtualBox port forwarding rules.

### Main Website Interface
To access the live front-end of the WordPress website:
1. Open a web browser on your host machine by running this command in your terminal:

    `chromium-browser --host-rules="MAP jfoeller.42.fr 127.0.0.1:8443" --ignore-certificate-errors`

2. Navigate to the following secure URL:

    https://jfoeller.42.fr

3. **SSL Certificate Warning**: Since the infrastructure uses a self-signed SSL certificate generated for security exercises, your browser will display an "Advanced Security Warning". Click **Advanced** and choose **Proceed to jfoeller.42.fr (unsafe)** to view the site.

### Administration Dashboard Panel
To log in and manage the website configurations, plugins, posts, and user privileges:
1. Navigate to the administrator login path:

    https://jfoeller.42.fr/wp-admin

2. You will be greeted by the official WordPress login prompt interface.

---

## 4. Locating and Managing Credentials

All setup secrets, initial database names, keys, and administration profile accounts are strictly centralized inside the configuration environment file.

### Credential Location
- File Path: `srcs/.env` (located within the deployment sources directory).

### Pre-Configured Test Profiles
The initialization scripts automatically populate the relational database with two unique testing profiles:

1. **Primary Website Administrator (Full Controls)**
   - WP_URL=login.42.fr
   - WP_TITLE=your title
   - WP_ADMIN_USER=admin username
   - WP_ADMIN_PASSWORD=admin password
   - WP_ADMIN_EMAIL=admin email
   - Role: Administrator (Can install plugins, change themes, alter core architecture).

2. **Standard Regular User (Content Creator)**
   - WP_USER=username
   - WP_USER_PASSWORD=username password
   - WP_USER_EMAIL=usermail email
   - Role: Author (Can create, edit, and publish their own blog posts, but cannot touch admin configurations).

---

## 5. Checking Service Health and Status

Administrators can easily monitor the operational health of the platform components using built-in evaluation commands.

### Option A: Check Status via Makefile
Run the status check shortcut from the root folder:

    make status

### Option B: Check Status via Docker Compose
Alternatively, execute the query inside the source environment directory:

    cd srcs && docker compose ps

### Understanding the Status Output
A fully operational, perfectly healthy cluster will generate a clean table output matching the schema below:

    NAME        IMAGE        COMMAND                  SERVICE     CREATED        STATUS        PORTS
    mariadb     mariadb      "/usr/local/bin/mari…"   mariadb     X hours ago    Up x minutes  
    nginx       nginx        "nginx -g 'daemon of…"   nginx       X hours ago    Up x minutes  443/tcp, 0.0.0.0:443->8443/tcp
    wordpress   wordpress    "/usr/local/bin/word…"   wordpress   X hours ago    Up x minutes  

**What to Look For**: Verify that the `STATUS` column for all three services (`mariadb`, `nginx`, `wordpress`) reads **`Up`** (or `running`). If any service displays `Exited`, check its internal system outputs using `docker logs <service_name>`.