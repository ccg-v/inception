#!/bin/bash

# Download and install WordPress, if it does not exist
if [ ! -f /var/www/html/index.php ]; then
    echo "Installing WordPress..."
    mkdir -p /var/www/html
    curl -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv wordpress/* /var/www/html/
    rm -rf wordpress latest.tar.gz
else
    echo "WordPress already installed."
fi

# Copy sample config
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Replace database values 
sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/html/wp-config.php
sed -i "s/username_here/${MYSQL_USER}/" /var/www/html/wp-config.php
sed -i "s/password_here/${MYSQL_PASSWORD}/" /var/www/html/wp-config.php
sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php

# Start php-fpm in the foreground
exec /usr/sbin/php-fpm7.4 -F
