FROM debian:bullseye
RUN apt update -y && apt upgrade -y
RUN apt install -y mariadb-server

# Create runtime directory MariaDB and set correct ownership
# RUN mkdir -p /run/mysqld
# RUN chown -R mysql:mysql /run/mysqld
RUN mkdir -p /var/lib/mysql /var/run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
RUN chmod 777 /var/run/mysqld

# Custom SQL file to initialize DB/user
# MariaDB runs it automatically on first container launch
COPY ./tools/init.sql /docker-entrypoint-initdb.d/

COPY ./config/custom.cnf /etc/mysql/mariadb.conf.d/
RUN chmod 644 /etc/mysql/mariadb.conf.d/custom.cnf

# Command to launch MariaDB as the `mysql` user
CMD ["mysqld"] 