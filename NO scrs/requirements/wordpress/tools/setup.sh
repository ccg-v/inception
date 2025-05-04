#!/bin/bash

# Copy sample config
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Replace database values 
sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/html/wp-config.php
sed -i "s/username_here/${MYSQL_USER}/" /var/www/html/wp-config.php
sed -i "s/password_here/${MYSQL_PASSWORD}/" /var/www/html/wp-config.php
sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php

# Start php-fpm in the foreground
exec php-fpm7.4 -F
