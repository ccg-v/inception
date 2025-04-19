## Simplest dockerfile

```Dockerfile
FROM debian:bullseye
RUN apt update -y && apt upgrade -y
RUN apt install -y mariadb-server
CMD ["mysqld"] # Command to launch MariaDB as the `mysql` user
```
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker image build . -t test:mariadb`\
✔ The image is created

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker run test:mariadb` \
✘ Cannot run the container:
> [ERROR] Can't start server: Bind on unix socket: No such file or directory \
> [ERROR] Do you already have another mysqld server running on socket: /run/mysquld/mysqld.sock ? \
> [ERROR] Aborting"

MariaDB is trying to bind to its default UNIX socket file, which should live at `/run/mysqld/mysqld.sock`, but it fails because that folder `run/mysqld` doesn't exist yet in my container.
That folder is used as a runtime space by `mysqld`, and it expects it to exist and **be writable by the `mysql` user** (which is created during the MariaDb installation).

> On a typical Linux system after MariaDB has been installed and started, `/run/mysqld` is \
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`drwxr-xr-x 2 mysql mysql 60 Apr 18 13:00 /run/mysqld` \
> or maybe \
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`drwxrwx--- 2 mysql mysql 4096 Apr 18 13:00 /run/mysqld` \
> which means **owner** is `mysql` and **group** is `mysql` \
> But we are installing MariaDB manually via `apt`, which installs the files and binaries but not the full OS service management logic. So we must simulate that part ourselves:
> - Create `/run/mysqld`
> - Set correct ownership (`mysql:mysql`)

```Dockerfile
FROM debian:bullseye
RUN apt update -y && apt upgrade -y
RUN apt install -y mariadb-server

# Create runtime directory MariaDB and set correct ownership
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

CMD ["mysqld"] # Command to launch MariaDB as the `mysql` user
```