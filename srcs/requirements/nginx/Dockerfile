FROM debian:bullseye

# Install nginx
RUN apt-get update \
	&& apt-get install -y nginx
	&& apt-get clean

# Copy our custom nginx configuration
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Create folders if needed
RUN mkdir -p /var/www/html

# Expose the ports
EXPOSE 80 443

# Start nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]