FROM debian:bullseye

# Install nginx and openssl, remove installation files [1]
RUN apt-get update \
	&& apt-get install -y nginx openssl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Copy our custom nginx configuration
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Create folders if needed
RUN mkdir -p /var/www/html

# Expose the ports
EXPOSE 80 443

# Start nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

# [1] We install Nginx, and the OpenSSL tools needed to generate the certificates
#		After installing, we don't need to keep installation files so we proceeed
#		to remove them:
#		- `apt-get clean` will remove nginx and openssl .deb packages along with
#			their dowloaded dependencies from `var/cache/apt/archives`
#		- `rm -rf /var/lib/apt/lists/*` deletes APT package lists that were 
#			downloaded during apt-get update

