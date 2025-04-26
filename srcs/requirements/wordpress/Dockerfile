FROM debian:bullseye

# Install dependencies
RUN apt-get update -y \
	&& apt-get install -y php7.4 php7.4-mysql php7.4-fpm curl tar unzip \
	&& apt-get clean

# Create directory for PHP-FPM socket
RUN mkdir -p /run/php

# Download WordPress
RUN mkdir -p /var/www/html \
	&& curl -O https://wordpress.org/latest.tar.gz \
	&& tar -xzf latest.tar.gz \
	&& mv wordpress/* /var/www/html/ \
	&& rm latest.tar.gz \
	&& rm -rf wordpress

# WordPress needs a wp-config.php with your DB credentials, which it doesn't generate on its own without a browser UI.
# We can generate it at runtime using a script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh
#RUN bash /usr/local/bin/setup.sh

# Set working directory
WORKDIR /var/www/html

# Expose port
EXPOSE 9000

# Start php-fpm in the foreground --> moved to the wordpress script in wordpress/tools/setup.sh
# If we run the script during 'RUN bash /usr/local/bin/setup.sh', the wp-config.php file will be 
# created with all our environment variables because the container hasn't started yet and those 
# variables haven't been injected so they are not available.
# Remember: Environment variables from .env file or docker-compose.yml only exist at RUNTIME, not
# build time. Runtime is what happens when the container starts, and container starts when you 
# launch the container with either CMD or ENTRYPOINT
#CMD ["php-fpm7.4", "-F"]
CMD ["bash", "/usr/local/bin/setup.sh"] 
