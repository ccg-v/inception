FROM debian:bullseye

# Update and install dependencies [1]
RUN apt update -y && apt upgrade -y
RUN apt install -y mariadb-server mariadb-client #

# Create runtime directory MariaDB and set correct ownership
RUN mkdir -p /var/lib/mysql /var/run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
RUN chmod 777 /var/run/mysqld

# Custom script and config file to initialize DB/user
COPY ./tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

COPY ./config/custom.cnf /etc/mysql/mariadb.conf.d/
RUN chmod 644 /etc/mysql/mariadb.conf.d/custom.cnf

# We don't need to expose port 3306 but I keep it for documentation purposes [2]
EXPOSE 3306

# Command to launch MariaDB as the `mysql` user
ENTRYPOINT ["/bin/bash", "/usr/local/bin/init.sh"]

# [1] Run the actual MariaDb server, and also MariaDb client because it provides
# 		the mysql CLI tool that we will need later to run mysql commands in the 
# 		configuration script 'init.sh'.
# ------------------------------------------------------------------------------
#
# [2] 	In our project port 3306 is going to be reachable only internally in the
#		Docker network by MariaDB, so there's no need to EXPOSE it to the host or
#		internet. Under no circumstances EXPOSE makes the port accessible outside
#		the container, it is 'ports' directive in 'docker-compose.yml' or 'RUN'
# 		in Dockerfile that actually opens the port to the host and can create
#		a security risk if misused. EXPOSE is totally safe, it's only metadata
#		signaling that MariaDB listens on 3306 but it doesn't open the port. 