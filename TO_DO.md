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