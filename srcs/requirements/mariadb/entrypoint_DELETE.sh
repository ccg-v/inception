#!/bin/bash

set -e

# Check if the DB is already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing database..."
	mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

	echo "Starting temporary server..."
	mysqld_safe --skip-networking &
	pid="$!"

	# Wait for server to be available
	while ! mysqladmin ping --silent; do
		sleep 1
	done

	echo "Running init.sql..."
	mysql -u root < /docker-entrypoint-initdb.d/init.sql

	echo "Shutting down temporary server..."
	mysqladmin shutdown
fi

echo "Starting MariaDB..."
exec mysqld
