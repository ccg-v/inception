#!/bin/bash

# Start MariaDB without networking (for safe setup)
#mysqld_safe --skip-networking &
#sleep 5  # Wait for it to boot

# Debugging: Output the environment variables to confirm they're set
#echo "MYSQL_DATABASE: $MYSQL_DATABASE"
#echo "MYSQL_USER: $MYSQL_USER"
#echo "MYSQL_PASSWORD: $MYSQL_PASSWORD"
#echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
#sleep 10

# Set up the database and user
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
mariadb -u root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb -u root -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
#mariadb -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');"
mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mariadb -u root -e "FLUSH PRIVILEGES;"

# Stop temporary MariaDB instance
#mysqladmin -u root shutdown

# Start MariaDB in the foreground
exec mysqld_safe
