Comment to add to docker-compose:

In Docker Compose, environment variables in the .env file are automatically loaded and can be referenced in the docker-compose.yml file, but there are some nuances to be aware of:
Why it works despite not defining HOST_DATA_PATH in environment section:

    Environment Variables in docker-compose.yml:
    The variables you define in .env are substituted into the docker-compose.yml file automatically during the build process, but they are not automatically added to the container’s environment unless explicitly set under the environment section of the service.

    Volume Configuration with ${} Syntax:
    When you use ${HOST_DATA_PATH} in the volume's device field, Docker Compose will substitute the value of HOST_DATA_PATH from the .env file before starting the containers. This is why your volume mapping works correctly, even though you did not explicitly add HOST_DATA_PATH to the environment section of the mariadb service.

    Why the container doesn’t show HOST_DATA_PATH:
    The reason you don't see HOST_DATA_PATH in the environment inside the mariadb container (echo $HOST_DATA_PATH is blank) is that the environment variables in .env are only used for substitution within the docker-compose.yml file, and they are not automatically passed to the container unless explicitly defined in the environment section of the service. Since you didn’t define HOST_DATA_PATH in the mariadb service’s environment section, it’s not available inside the container.

Why it seems to work:

    The volume binding works fine because the .env file variables are expanded by Docker Compose before the container starts. The container doesn't need to have access to HOST_DATA_PATH as an environment variable for the volume mount to work. Docker Compose simply uses the value during container setup to bind the host volume properly.

How to fix or improve:

    If you want HOST_DATA_PATH to be available as an environment variable inside the mariadb container, you should explicitly define it under the environment section of your mariadb service:

    services:
      mariadb:
        environment:
          - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
          - MYSQL_DATABASE=${MYSQL_DATABASE}
          - MYSQL_USER=${MYSQL_USER}
          - MYSQL_PASSWORD=${MYSQL_PASSWORD}
          - WORDPRESS_DB_HOST=${WORDPRESS_DB_HOST}
          - HOST_DATA_PATH=${HOST_DATA_PATH}  # Add this line

This way, the HOST_DATA_PATH variable will be available inside the mariadb container, and echo $HOST_DATA_PATH will print the expected value.
Conclusion:

The volume mount works fine because Docker Compose handles the .env substitution at the time of container creation. However, environment variables in .env are not automatically passed into the container's environment unless you explicitly include them under the environment section of the docker-compose.yml.