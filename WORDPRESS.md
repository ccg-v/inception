## Wordpress

WordPress is a PHP application, so we need:

- A PHP runtime + web server (usually Apache or Nginx + PHP-FPM).
- WordPress source code (we’ll download it in the Dockerfile).
- A connection to MariaDB (configured via wp-config.php).
- Environment variables for DB connection (e.g. WORDPRESS_DB_HOST, etc.).

### 1. First steps:

```Dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php php-mysql php-fpm curl unzip \
    mariadb-client \
    && apt-get clean

# Download WordPress
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress /var/www/html && \
    rm latest.tar.gz

# Copy a custom wp-config.php later using COPY

# Set working directory
WORKDIR /var/www/html

# Expose port (you might proxy through nginx later)
EXPOSE 9000

CMD ["php-fpm7.3", "-F"]
```