#!/bin/bash

# Petit temps de pause pour laisser le temps à MariaDB de démarrer
sleep 10

# On vérifie si WordPress est déjà installé (pour éviter d'écraser le site au redémarrage)
if [ ! -f "wp-config.php" ]; then
    echo "WordPress is not installed. Starting installation..."

    # 1. Téléchargement des fichiers sources de WordPress
    wp core download --allow-root

    # 2. Création du fichier de configuration wp-config.php
    # On lie WordPress au conteneur 'mariadb' sur le réseau interne
    wp config create \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=mariadb \
        --allow-root

    # 3. Installation du site et création du compte Administrateur
    wp core install \
        --url=$WP_URL \
        --title=$WP_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --skip-email \
        --allow-root

    # 4. Création du second utilisateur (non admin)
    wp user create \
        $WP_USER \
        $WP_USER_EMAIL \
        --role=author \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root

    echo "WordPress has been successfully installed!"
else
    echo "WordPress is already installed."
fi

# Lancement de PHP-FPM au premier plan (option -F) pour garder le conteneur en vie
echo "Starting PHP-FPM..."
exec php-fpm8.2 -F