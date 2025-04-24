FROM debian:bullseye

RUN apt update -y && apt upgrade -y \
	&& php php-mysql php-fpm curl unzip \
	&& apt-get clean

# Download WordPress
RUN curl -0 https://wordpress.org/latest.tar.gz \
	&& tar -xzf latest.tar.gz \
	&& mv wordpress /var/www/html \
	&& rm latest.tar.gz

# Copy a custom wp-config.php later

# Set working directory
WORKDIR /var/www/html

# Expose port
EXPOSE 9000

CMD ["php-fpm7.3", "-F"]