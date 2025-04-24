#!/bin/bash
echo "🎉 INIT.SH IS RUNNING!"
sleep 2

# Start MariaDB without networking (for safe setup)
mysqld_safe &
echo "⏳ Starting MariaDB..."
sleep 2
# Wait until MariaDB is ready to accept connections
until mariadb-admin ping --silent -u root -p"$MYSQL_ROOT_PASSWORD"; do
    echo "⏳ Waiting for MariaDB to be ready..."
    sleep 1
done

echo "✅ MariaDB is ready, continuing setup..."

# Debugging: Output the environment variables to confirm they're set
echo "MYSQL_DATABASE: $MYSQL_DATABASE"
echo "MYSQL_USER: $MYSQL_USER"
echo "MYSQL_PASSWORD: $MYSQL_PASSWORD"
echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
sleep 2

# Set up the database and user
mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown


# Stop temporary MariaDB instance
mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

# Start MariaDB in the foreground
exec mysqld_safe
