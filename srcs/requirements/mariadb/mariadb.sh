#!/bin/bash

# 1. Configuration du réseau : on autorise MariaDB à écouter les autres conteneurs
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf
# changement du port d'ecoute:
#sed -i '/\[mysqld\]/a port = 3307' /etc/mysql/mariadb.conf.d/50-server.cnf

# On donne les droits d'ecriture a Mariadb sur la base de donnees
chown -R mysql:mysql /var/lib/mysql

# 2. On vérifie si la base de données existe déjà (pour ne pas la recréer si le conteneur redémarre)
if [ ! -d "/var/lib/mysql/$SQL_DATABASE" ]; then
    echo "Initializing the database..."

    # On lance le service en arrière-plan temporairement pour pouvoir le configurer
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    service mariadb start
    sleep 2

    # Création de la base de données et des utilisateurs en utilisant les variables du .env
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    mysql -e "FLUSH PRIVILEGES;"

    # On éteint le service temporaire proprement avec le nouveau mot de passe root
    mysqladmin -u root -p$SQL_ROOT_PASSWORD shutdown
else
    echo "Database already exists."
fi

# 3. Lancement de MariaDB en premier plan (ce qui garde le conteneur actif)
echo "Starting MariaDB..."
exec mysqld_safe