## Writing MariaDB Dockerfile

We start with a simple file containing the very basic instructions

```Dockerfile
FROM debian:bullseye
RUN apt update -y && apt upgrade -y
RUN apt install -y mariadb-server
# Command to launch MariaDB as the `mysql` user
CMD ["mysqld"] 
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

# Command to launch MariaDB as the `mysql` user
CMD ["mysqld"] 
```

Right now, the container starts MariaDB but:
- No **database** is created
- No **user** is set
- No **password** is enforced

We need to complete these steps in order to succesfully connect later MariaDB from WordPress. So we will provide all this information in a `custom_setup.sql` file that we will store in `srcs/requirements/mariadb/tools`:

```sql
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY 'wppass';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
FLUSH PRIVILEGES;
```

- This SQL instructions ensure that we always run a fresh DB with a known state.
	> - The `@'%'` means _"this user can connect from any IP address"_ (used for Docker networking, we will see that later)
	> - `GRANT ALL PRIVILEGES ON wordpress.* TO 'vwpuser'@'%';` gives the user full permissions on **everything inside the wordpress database**, so he can read, write, create tables, delete, etc.
	> - `FLUSH PRIVILEGES` reloads the user permissions in MariaDB so changes take effect immediately (kinda like _"save changes and refresh"_)

- The file will run only the first time the container creates a fresh DB volume. Later runs skip it, unless we delete the volume and start fresh.
- The name of the file doesn't matter at all, it can be `setup.sql`, `init.sql` or whatever we want, as long as it is copied into `/docker-entrypoint-initdb.d/`. This is a built-in behaviour in MariaDB Docker images, the entrypoint script looks inside that folder and runs **all *.sql or *.sh files** it finds, in alphabetical order.

Once we have written and stored the sql file, we add the copy instructions in the Dockerfile:

```Dockerfile
FROM debian:bullseye
RUN apt update -y && apt upgrade -y
RUN apt install -y mariadb-server

# Create runtime directory MariaDB and set correct ownership
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Custom SQL file to initialize DB/user
# MariaDB runs it automatically on first container launch
COPY ./tools/init.sql /docker-entrypoint-initdb.d/

# Command to launch MariaDB as the `mysql` user
CMD ["mysqld"] 
```

------
# Setting database environment variables

1. Defining them in environment key within docker-compose.yml:

    - **These are runtime environment variables**.
    - They’re passed to the container when it starts, not when it's being built.

		_docker-compose.yml_:
		```yaml
		services:
		   mariadb:
		      environment:
			    - MYSQL_DATABASE: wordpress
				- ...
		```

    - That’s why they work in init.sh script when it runs as part of ENTRYPOINT or CMD.

		_init.sh_:
		```bash
		mariadb -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
		...
		```
	 + Used when you want to pass runtime config to your app, scripts, or services.
	 + ✔️ Simple and standard
	 + ✔️ Clear separation of concerns (build vs. runtime)
	 + ✔️ Best practice - what official images (like MySQL, WordPress) expect

	 - The variables can also be defined in an `.env` file

		_.env_:
		```
		MYSQL_DATABASE=wordpress
		MYSQL_USER=wpuser
		```
		And then in `docker-compose.yml`, just use:

		_docker-compose.yml_:
		```yaml
		services:
		   mariadb:
		      environment:
			    - MYSQL_DATABASE: ${MYSQL_DATABASE}
				- ...
		```
		+ ✔️ Keeps secrets and config outside `docker-compose.yml`
		+ ✔️ Good for sharing values across multiple Compose files (**just don't commit secrets!**)

2. Defining them in build.args in docker-compose.yml:

    - **These are build-time arguments**.
    - Used to pass values into the Dockerfile via ARG declarations:

		_docker-compose.yml_:
		```yml
		services:
		   mariadb:
		      build:
		         context: ./requirements/mariadb
		         args:
		            - MYSQL_DATABASE=wordpress
	                - ...
		```

    - <ins>Only available during docker build, not at runtime unless you explicitly promote `ARG` to `ENV`</ins>:

		_Dockerfile_:
		```Dockerfile
		FROM debian:bullseye
		ARG MYSQL_DATABASE
		ENV MYSQL_DATABASE=$MYSQL_DATABASE
		...
		```
		+ ✔️ Used when you’re building a one-off image that always expects the same config baked in.
		+ ✘✘✘ Not promoting to env and starting MariaDB manually during build:
			- Breaks layering philosophy (build should not rely on service startup)
			- Super hacky and unreliable