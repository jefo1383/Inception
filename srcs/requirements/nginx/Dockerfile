FROM debian:bookworm

# 1. Installation de NGINX et OpenSSL
RUN apt-get update -y && apt-get install -y \
    nginx \
    openssl

# Suppression de la configuration par défaut de Debian qui écoute sur le port 80
RUN rm -f /etc/nginx/sites-enabled/default

# 2. Création du dossier pour stocker les certificats SSL
RUN mkdir -p /etc/nginx/ssl

# 3. Génération du certificat auto-signé (valable 365 jours)
# Remplis les informations du certificat (le CN doit être le login.42.fr)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=PACA/L=Marseille/O=42/OU=Inception/CN=jfoeller.42.fr"

# 4. Copie de notre fichier de configuration NGINX
COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

# 5. Création du dossier requis par NGINX pour tourner correctement
RUN mkdir -p /var/run/nginx

# 6. Lancement de NGINX au premier plan (daemon off) pour maintenir le conteneur en vie
CMD ["nginx", "-g", "daemon off;"]