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

# Extract host and port from WORDPRESS_DB_HOST
host=$(echo "$WORDPRESS_DB_HOST" | cut -d: -f1)
port=$(echo "$WORDPRESS_DB_HOST" | cut -d: -f2)

# Wait for MariaDB to become FULLY initialized [2]
echo "Waiting for MariaDB at $host:$port..."
until mysqladmin ping -h"$host" -P"$port" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" >/dev/null 2>&1; do
    echo "MariaDB is not ready yet..."
    sleep 2
done

# Install WordPress (only if not already installed)
if ! wp core is-installed --path="$WP_PATH"; then
	echo "Installing WordPress..."
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="42Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path="$WP_PATH" \
		--allow-root
fi

# Always try to create second user, but guard against duplication
if ! wp user get "$WP_SECOND_USER" --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
    echo "Creating second user..."
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
#
# ------------------------------------------------------------------------------
#
# [2] `mysqladmin ping`` check confirms that MariaDB is fully initialized and
#		ready to accept authenticated connections. It sends a lightweight
#		command that requires:
#		- The MySQL daemon to be fully up and running
#		- A valid network connection
#		- Authentication using the provided credentials
#		Faster approaches can be implemented, like a netcat client:
#
#			while ! nc -z mariadb 3306; do
#				echo "Waiting until MariaDB is ready at mariadb:3306..."
#				sleep 1
#			done
#
#		But netcat will only confirm port availability. To be absolutely 
#		confident that MariaDB is ready to serve WordPress, its better to stick
#		with `mysqladmin ping`
