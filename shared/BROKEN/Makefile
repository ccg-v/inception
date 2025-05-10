# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ccarrace <ccarrace@student.42barcelona.    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/05 19:41:07 by ccarrace          #+#    #+#              #
#    Updated: 2025/05/10 21:24:16 by ccarrace         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME			= inception
USER			= ccarrace
DOMAIN			= ccarrace.42.fr
COMPOSE			= docker compose
COMPOSE_FILE	= srcs/docker-compose.yml


all: set_host set_volumes build-up

# Append my domain to existing '127.0.0.1' entry in system's /etc/hosts file
set_host:
	@if ! grep -q "${DOMAIN}" /etc/hosts; then \
		sudo sed -i "/^127.0.0.1/s/$$/ ${DOMAIN}/" /etc/hosts; \
	fi

unset_host:
	@sudo sed -i "s/ ${DOMAIN}//g" /etc/hosts

skip_host:
	@echo "Skipping domain injection. Make sure ${DOMAIN} resolves to 127.0.0.1"
	$(MAKE) build-up

# Create mandatory binding paths where containers will mount the volumes [1]
set_volumes:
	sudo mkdir -p /home/${USER}/data/mariadb
	sudo chown -R 101:101 /home/${USER}/data/mariadb
	sudo chmod -R 755 /home/${USER}/data/mariadb

	sudo mkdir -p /home/${USER}/data/wordpress
	sudo chown -R 33:33 /home/${USER}/data/wordpress
	sudo chmod -R 755 /home/${USER}/data/wordpress

build:
	$(COMPOSE) -f $(COMPOSE_FILE) build

up:
	$(COMPOSE) -f $(COMPOSE_FILE) up -d

build-up:
	$(COMPOSE) -f $(COMPOSE_FILE) up --build -d

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

start:
	$(COMPOSE) -f $(COMPOSE_FILE) start

stop:
	$(COMPOSE) -f $(COMPOSE_FILE) stop

restart: stop start

clean:
	$(COMPOSE) -f $(COMPOSE_FILE) down --volumes --remove-orphans

fclean: clean
	$(COMPOSE) -f $(COMPOSE_FILE) down --rmi all
	$(MAKE) unset_host
	sudo rm -rf /home/${USER}/data/mariadb
	sudo rm -rf /home/${USER}/data/wordpress

re: fclean all

.PHONY: all build up down start stop restart clean fclean re

# [1] A UID (User Identifier) is a numeric value that uniquely identifies a user
#		on a Unix-like system.
#		- Every user on a Linux system is assigned a UID
#		- UID 0 is always reserved for the `root` user
#		- Regular users tipically have UIDs starting from 1000
#		- System/service users usually have lower UIDs, like 33 for `www-data 
#			(used by NGINX/Apache) or 999 for a MariaDB user.
#
#		To know which UID corresponds to, for instance, MariaDB:
#			grep "^mariadb:" /etc/passwd
#		Output should be:
#			mariadb:x:999:999::/home/mariadb:/usr/sbin/nologin
#		Third field is the UID, fourth is the GID (Group Identifier)
#		If no output appears, the user does not exist on the host system. In
#		Docker containers, users like mariadb or www-data (used by WordPress) 
#		typically exist inside the container, not on the host.
#
#		Actually, when trying to find out what UID and GID MariaDB was using 
#		inside my custom image, to bypass the init script I ran:
#			`docker run --rm -it --entrypoint /bin/sh mariadb:inception`
#			`id mysql`
#		and the output was:
#			uid=101(mysql) gid=101(mysql) groups=101(mysql)
#		It turns out that MariaDB container is using UID 101, not 999.
#		Thus, we must change the ownership of `home/mariadb/data` to 101, not
#		999. But after changes if we list (`ls  -la`) the path, instead of seeing
#		'mysql:mysql` as owner:group, we'll see 'systemd-network:systemd-journal'.
#		Why does this happens?
#		The mapping of a UID/GID (like 101:101) to a username (like mysql) happens
#		entirely in userspace, based on the host’s `/etc/passwd` and `/etc/group`.
#		But the container and the host are two isolated user databases, so:
#		- On the host, UID 101 might map to systemd-network.
#		- While inside the container, UID 101 maps to mysql.
#		Docker doesn’t “correct” the labels shown on the host, it just ensures
#		numeric UID/GID consistency.

