FROM debian:bookworm

# 1. Mise à jour et installation des outils nécessaires
RUN apt-get update -y && apt-get install -y \
    wget \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client

# 2. Installation de WP-CLI (WordPress Command Line Interface)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# 3. Configuration de PHP pour qu'il écoute les requêtes de NGINX sur le port 9000
RUN sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 9000/g' /etc/php/8.2/fpm/pool.d/www.conf
RUN mkdir -p /run/php

# 4. Copie du script de configuration
COPY ./wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress.sh

# 5. On se place dans le dossier où sera installé le site
WORKDIR /var/www/wordpress

# 6. Lancement du script au démarrage
CMD ["/usr/local/bin/wordpress.sh"]