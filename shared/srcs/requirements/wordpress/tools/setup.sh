#!/bin/bash

set -e

WP_PATH="/var/www/html"

# Download, unpack and move WordPress source files to web root [1]
if [ ! -f "$WP_PATH/index.php" ]; then
    echo "Downloading WordPress..."
    mkdir -p "$WP_PATH"
    curl -o /tmp/latest.tar.gz https://wordpress.org/latest.tar.gz
    tar -xzf /tmp/latest.tar.gz -C /tmp
    mv /tmp/wordpress/* "$WP_PATH/"
    rm -rf /tmp/wordpress /tmp/latest.tar.gz
fi

# Generate wp-config.php
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Creating wp-config.php..."
    wp core config \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --path="$WP_PATH" \
		--allow-root \
        --skip-check
fi

# Wait for MariaDB to become available
echo "Waiting for MariaDB at $WORDPRESS_DB_HOST..."
until wp db check --path="$WP_PATH" --allow-root >/dev/null 2>&1; do
    echo "MariaDB is not ready yet..."
    sleep 2
done

# Install WordPress (only if not already installed)
if ! wp core is-installed --path="$WP_PATH"; then
	echo "Installing WordPress..."
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="MySite" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path="$WP_PATH" \
		--allow-root
        
    # Create second user
    wp user create "$WP_SECOND_USER" "$WP_SECOND_EMAIL" \
        --role=editor \
        --user_pass="$WP_SECOND_PASS" \
        --path="$WP_PATH" \
		--allow-root
fi

# Start php-fpm in the foreground
exec php-fpm7.4 -F

# [1] This is not installing WordPress, it is just downloading the WordPress
#		source files, unpacking them and moving them into the web root. At
#		this point, WordPress has no idea what our site is about: no DB tables,
#		no users, no settings. If we visit our domain now, we will get the 
#		web-based install form.