FROM debian:bullseye

# Install nginx and openssl, remove installation files [1]
RUN apt-get update \
	&& apt-get install -y nginx openssl netcat \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# 2. Create default web root for NGINX
RUN mkdir -p /var/www/html

# Create SSL folders if they don't exist
# (standard Linux locations inside nginx container's Linux small file system)
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# Generate SSL key and certificate
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
  -out /etc/ssl/certs/ccarrace.crt \
  -keyout /etc/ssl/private/ccarrace.key \
  -subj "/C=SP/ST=CAT/L=barcelona/O=42/OU=42barcelona/CN=ccarrace.42.fr"

# Set proper permissions
RUN chmod 644 /etc/ssl/certs/ccarrace.crt \
    && chmod 600 /etc/ssl/private/ccarrace.key

# Copy our custom nginx configuration
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Copy our initialization script (will delay Nginx start til PHP-FPM is listening)
COPY ./tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 443

# Start nginx (in foreground mode!) -> Moved to tools/init.sh, to delay the start
# until PHP-FPM is listening
# CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["bash", "/usr/local/bin/init.sh"]


# [1] We install Nginx, and the OpenSSL tools needed to generate the certificates
#		After installing, we don't need to keep installation files so we proceeed
#		to remove them:
#		- `apt-get clean` will remove nginx and openssl .deb packages along with
#			their dowloaded dependencies from `var/cache/apt/archives`
#		- `rm -rf /var/lib/apt/lists/*` deletes APT package lists that were 
#			downloaded during apt-get update
