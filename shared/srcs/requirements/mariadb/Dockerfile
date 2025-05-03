FROM debian:bullseye

RUN apt update -y && apt upgrade -y
# Run the actual MariaDb server, and also MariaDb client because it provides the mysql CLI tool
# (we need it to run mysql commands in the configuration script 'init.sh')
RUN apt install -y mariadb-server mariadb-client

# Create runtime directory MariaDB and set correct ownership
RUN mkdir -p /var/lib/mysql /var/run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
RUN chmod 777 /var/run/mysqld

# Custom SQL file to initialize DB/user
# MariaDB runs it automatically on first container launch
COPY ./tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

COPY ./config/custom.cnf /etc/mysql/mariadb.conf.d/
RUN chmod 644 /etc/mysql/mariadb.conf.d/custom.cnf

EXPOSE 3306

# Command to launch MariaDB as the `mysql` user
#CMD ["/usr/local/bin/init.sh"]
RUN ls -l /usr/local/bin/init.sh && head -n 10 /usr/local/bin/init.sh
ENTRYPOINT ["/bin/bash", "/usr/local/bin/init.sh"]