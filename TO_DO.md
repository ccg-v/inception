bash -c "docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null"

WordPress website (for logging into WordPress)
 - site title:	my42inception
 - username:	admin
 - password:	adminpass
 - e-mail:		admin@my42inception.com

Check bookmarks!!!

# docker-compose
service:
	<service_name>
		init: true
		build:
			dockerfile: Dockerfile
		env_file:	.env
		restart: (always)(on-failure)// The volume?


- network?
- volumes: Set name? External? Driver?

# MariaDB:

Xplanations:
- running `mariadb-client`
- `context` keyboard
- why do we start mariadb in script WITHOUT NETWORKING. Shall I keep this when I add the rest of services?

Pending:
- moving env vars definition from `Docker-compose.yml` to `.env` file
- FINISHING `custom.cnf`???

hostname:
- store in an env variable?
- or modify /hosts?

remove exposed ports from MDB and WP Dockerfiles

Secrets? Ignore .env?

Document hash creation, wp-cli installation, as part of dump.sql
 - what is dump.sql for

Set certificate paths/names in .env and replace them in nginx.conf

Am I hardcoding the env variables somewhere? It worked when I had wrong syntax in .env file,so I was presumibly passing the values somehow...

Warning in wordpress logs about root user -> normal?

NO APARECEN LOS COMENTARIOS
SEGUNDO USUARIO?
POR QUE EMPIEZO DE CERO Y EN EL BLOG HAY PARTES PERSONALIZADAS?