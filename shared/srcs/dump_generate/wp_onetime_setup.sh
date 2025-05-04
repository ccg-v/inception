#!/bin/bash

# Create a temporary Docker network
docker network create wp-temp-net

# Start temporary MariaDB container
docker run --rm -d --name temp-mariadb \
  --network wp-temp-net \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=ccarrace \
  -e MYSQL_PASSWORD=wppass \
  -e MYSQL_ROOT_PASSWORD=rtpass \
  mariadb

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to initialize..."
sleep 10

# Start temporary WordPress container
docker run --rm -d --name temp-wp \
  --network wp-temp-net \
  -e WORDPRESS_DB_NAME=wordpress \
  -e WORDPRESS_DB_USER=ccarrace \
  -e WORDPRESS_DB_PASSWORD=wppass \
  -e WORDPRESS_DB_HOST=temp-mariadb:3306 \
  -p 8080:80 \
  wordpress

echo "WordPress is starting at http://localhost:8080"
echo "Go through the setup in your browser, then Ctrl+C this script when you're done."

