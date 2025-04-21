FROM debian:bullseye

RUN apt update -y && apt upgrade -y
# Run the actual MariaDb server...
RUN apt install -y mariadb-server
# ..and also MariaDb client because it provides the mysql CLI tool
# (we need it to run mysql commands in the configuration script 'init.sh')
RUN apt install -y mariadb-client

# Create runtime directory MariaDB and set correct ownership
# RUN mkdir -p /run/mysqld
# RUN chown -R mysql:mysql /run/mysqld
RUN mkdir -p /var/lib/mysql /var/run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
RUN chmod 777 /var/run/mysqld

# Custom SQL file to initialize DB/user
# MariaDB runs it automatically on first container launch
COPY ./tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh
#RUN /usr/local/bin/init.sh

COPY ./config/custom.cnf /etc/mysql/mariadb.conf.d/
RUN chmod 644 /etc/mysql/mariadb.conf.d/custom.cnf

# Command to launch MariaDB as the `mysql` user
#CMD ["/usr/local/bin/init.sh"]
ENTRYPOINT ["/usr/local/bin/init.sh"]