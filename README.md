*This activity has been created as part of the 42 curriculum by jfoeller.*

# Inception - System Administration & Docker Virtualization

## Description
The goal of the **Inception** project is to broaden knowledge of system administration by implementing a complete, automated web infrastructure using Docker. Instead of using a heavy Virtual Machine for every service, this project leverages containerization to build a robust, scalable, and isolated environment.

The infrastructure consists of three main components working together:
1.  **NGINX**: A web server acting as the sole entry point, configured to accept only secure HTTPS connections (TLSv1.2 & TLSv1.3).
2.  **WordPress**: The core website engine running on PHP-FPM.
3.  **MariaDB**: A relational database securely storing the website's data.

All services are orchestrated via Docker Compose, communicate through a private internal network, and store their critical data on persistent local volumes.

---

## Project Description & Architecture

### Use of Docker and Sources
In this project, ready-made Docker images (like the official `nginx` or `wordpress` images) are strictly forbidden. The infrastructure is built entirely from scratch using a base operating system (`debian:bookworm`). Every service is constructed using custom `Dockerfile`s and custom bash initialization scripts (`.sh` or `.conf`). The orchestration is fully managed by a `docker-compose.yml` file located in the `srcs/` directory.

### Main Design Choices
- **Separation of Concerns**: One container equals one service.
- **Security First**: NGINX is the only container with a port exposed to the host system. MariaDB and WordPress are completely isolated in an internal network.
- **Resilience**: The system relies on Bash scripts (`mariadb.sh`, `wordpress.sh`) that act as entrypoints to dynamically configure the services and wait for dependencies to be ready before starting.

### Technical Comparisons

* **Virtual Machines vs Docker**
    Virtual Machines (VMs) virtualize physical hardware. Every VM runs its own full-blown Operating System (Guest OS), which makes them heavy and slow to boot. Docker, on the other hand, virtualizes the OS level. Containers share the Host OS kernel, making them extremely lightweight, fast to deploy, and highly efficient in terms of memory and CPU usage.

* **Secrets vs Environment Variables**
    Environment variables are passed to containers at runtime (often via `.env` files). They are easy to use but can be considered less secure because they are visible to anyone with access to the container's environment or process tree. Docker Secrets are a more secure mechanism (specifically designed for Swarm/production) that mounts sensitive data into the container's temporary in-memory filesystem (`tmpfs`), ensuring credentials are never written to disk or exposed in environment dumps.

* **Docker Network vs Host Network**
    The Host Network mode removes the network isolation between the container and the Docker host. The container uses the host's IP and port space directly, which can lead to port conflicts and security risks. A custom Docker Network (like the `srcs_inception` bridge network used in this project) creates an isolated, secure LAN for the containers. They can communicate seamlessly via Docker's internal DNS using their container names, without exposing their ports to the outside world.

* **Docker Volumes vs Bind Mounts**
    Docker Volumes are entirely managed by Docker and stored in a protected area of the host filesystem (`/var/lib/docker/volumes/`). They are the best choice for generic persistence. Bind Mounts, however, link a specific, user-defined path on the host machine (e.g., `/home/jfoeller/data/`) directly into the container. This project uses Bind Mounts to ensure absolute control over the data's location and to guarantee that the database and website files survive even if Docker is completely purged from the system.

---

## Instructions

### Prerequisites
- A Debian-based Linux environment.
- `docker` and `docker compose` installed.
- `make` installed.
- Local domain resolution configured: You must map the project domain to your localhost by adding this line to your `/etc/hosts` file:

        127.0.0.1   jfoeller.42.fr

### Execution
The entire setup is automated via the `Makefile` located at the root of the repository.
1.  Navigate to the root directory.
2.  Ensure you have created a valid `.env` file inside the `srcs/` folder containing your credentials.
3.  Launch the infrastructure:

        make all
        
    *This command will build the custom images, create the local data directories if they don't exist, and launch the containers in detached mode.*

### Management & Cleanup
- To stop the services without losing persistent data:

        make clean
        
- To completely wipe the environment **(WARNING: This deletes the database and website files)**:

        make fclean

---

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WP-CLI (WordPress Command Line Interface)](https://make.wordpress.org/cli/handbook/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

### Artificial Intelligence Usage
During the development of this project, an AI assistant (Google Gemini) was used as a coding partner and system administration tutor. AI was primarily utilized for:
- Debugging specific syntax errors in advanced Bash initialization scripts.
- Clarifying the theoretical differences between Docker networking layers and port forwarding mechanisms (Host vs Guest VMs).
- Structuring and drafting the initial templates for the project's documentation files (DEV_DOC, USER_DOC, and README), which were then manually reviewed and adapted.
- Simulating live-coding evaluation scenarios to test the resilience of the infrastructure's configuration.