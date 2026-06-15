FROM debian:bookworm

# Installation de MariaDB
RUN apt-get update -y
RUN apt-get install mariadb-server -y

# Copie du script d'initialisation
COPY ./mariadb.sh /usr/local/bin/

# On donne le droit d'exécution au script
RUN chmod +x /usr/local/bin/mariadb.sh

# Lancement du script au démarrage du conteneur
CMD ["/usr/local/bin/mariadb.sh"]