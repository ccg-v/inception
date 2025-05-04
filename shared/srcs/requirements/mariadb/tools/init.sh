#!/bin/bash
echo "Running init.sh..."
sleep 2

# Start MariaDB without networking (for safe setup) [1]
mysqld_safe &
echo "Starting MariaDB..."
sleep 2

# Wait until MariaDB is ready [2]
until mariadb-admin ping --silent; do
    echo "Waiting for MariaDB to be ready..."
    sleep 1
done

echo "MariaDB is ready, continuing setup..."

# Set up the database and user [3]
mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# Load our dump.sql file to bypass wordpress `wp-admin/install.php` page
#if [ -f "/usr/local/bin/dump.sql" ]; then
#    echo "Importing dump.sql..."
	mariadb -u root -p"$MYSQL_ROOT_PASSWORD" "${MYSQL_DATABASE}" < /usr/local/bin/dump.sql
#else
#    echo "dump.sql not found!"
#fi

# Stop temporary MariaDB instance [4]
mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

# Start MariaDB in the foreground [1]
exec mysqld_safe 


# [1] `mysql_safe` is a wrapper script aroud the mysqld server. It adds extra
#		safety features like logging, restarting mysqld if it crashes and
#		setting permissions and environment variables properly.
#		`&` is used to run in the background, so the script can continue
#		running while MariaDB boots up.
#
# ------------------------------------------------------------------------------
# [2] `mariadb-admin`` is a command-line tool that talks to the MariaDB server
#		and lets you manage it.  We use it here to ping to server and check if
#		it is alive and ccepting connections. Until MariaDB is ready we pause 
#		the script and delay the execution of the forthcoming SQL commands
#
# ------------------------------------------------------------------------------
# [3] We cannot write SQL commands directly in the script:
#			CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE
#			CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' ...;
#			...
#		because bash will interpret them as shell commands and return an error:
#			CREATE: command not found
#		We must send the SQL statements into the mariadb client (asumming `sqld`
#		is running) as root user with `-execute` flag:
#			mariadb -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE"
#			mariadb -u root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' ...;"
#			...
#		When several SQL statements need to be executed, this solution becomes
#		repetitive and inefficient. Each command is executed in a separate client
#		session, so this approach is recommended only for simple or isolated SQL 
# 		statements. The heredoc is ideal to feed those multiple SQL statements
#		through standard input (STDIN), like typing in an interactive session:
#			mariadb -u root <<EOF
#			-- multiple lines of SQL here
#			EOF
#		This is ideal when:
#		- we want clean formatting and less repetition
#		- we want to execute many statements at once
#		- we want to avoid spawning multiple connections (one per `-e`)
#
# ------------------------------------------------------------------------------
# [4] `mmysql_admin` is another admin tool (like `mariadb-admin`) that comes from
#		the MySQL legacy tools. It allows us to gracefully stop the MariaDB server.
#		Here we have to provide the root password because it has already been set 
#		in the last SQL statement.
#
# ------------------------------------------------------------------------------
# [5] The `dump.sql` file pre-populates the MariaDB database with the minimal
#		tables/data Wordpress needs to recognize the site as already installed.
#		- It creates the essential tables (`wp_options`, `wp_users`, etc.).
#		- It inserts the site URL, admin user, and other defaults
#		- It mimics what `wp-admin/install.php` would do during setup.
#		It is useful to bypass the WordPress installation page (`install.php`).
#		WordPress sees the expected database content and boots straight to the
#		login screen or homepage, depending on the setup.