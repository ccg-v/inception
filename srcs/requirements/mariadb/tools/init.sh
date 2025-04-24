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

# Set up the database and user (using a here-document to avoid having to type authentication repeatedly in every line)
mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# Stop temporary MariaDB instance
mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

# Start MariaDB in the foreground
exec mysqld_safe
