#!/bin/bash

# Wait for WordPress:9000 to be ready
until nc -z wordpress 9000; do
  echo "Waiting for WordPress (php-fpm) to be ready..."
  sleep 1
done

# Now start nginx in the foreground
nginx -g 'daemon off;'

# In Docker Compose, containers start concurrently, not in dependency order, even
# if you define depends_on. That directive controls start order, not readiness.
# My current startup flow:
# 	- WordPress container is building and starting php-fpm.
#	- NGINX container starts right away and tries to connect to WordPress:9000.
#	- Since php-fpm isn’t yet listening, NGINX logs 504 errors.
#	- Later, php-fpm is up, but NGINX never retries.
#	- If I reload NGINX manually, it now successfully connects.
# This script is indeed a patch to wait until PHP-FPM is listening before starting
# NGINX.