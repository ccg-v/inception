FROM debian:bullseye

# Install dependencies
RUN apt-get update -y \
	&& apt-get install -y php7.4 php7.4-mysql php7.4-fpm curl tar \
	&& apt-get clean

# Create directory for PHP-FPM socket
RUN mkdir -p /run/php

# Downloading and installing WordPress not to be done here, during image building,
# but when running the script to start the container

# Override the default 'www.conf' with our custom version that includes essential
# directives for a WordPress + Nginx setup (with PHP-FPM over TCP)
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# WordPress needs a wp-config.php with your DB credentials, which it doesn't generate on its own without a browser UI.
# We can generate it at runtime using a script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh
#RUN bash /usr/local/bin/setup.sh

# Set working directory
WORKDIR /var/www/html

# Start php-fpm in the foreground --> moved to the wordpress script in wordpress/tools/setup.sh
# If we run the script during 'RUN bash /usr/local/bin/setup.sh', the wp-config.php file will be 
# created with all our environment variables because the container hasn't started yet and those 
# variables haven't been injected so they are not available.
# Remember: Environment variables from .env file or docker-compose.yml only exist at RUNTIME, not
# build time. Runtime is what happens when the container starts, and container starts when you 
# launch the container with either CMD or ENTRYPOINT
#CMD ["php-fpm7.4", "-F"]
CMD ["bash", "/usr/local/bin/setup.sh"] 

# ------------------------------------------------------------------------------
# `curl`
#
# It's a command-line tool to download files from URLs (HTTP, HTTPS, FTP, etc.). 
# We need it to fetch the WordPress files during the image build.
# Without `curl` we would have to manually download WordPress ourselves and copy 
# it into the container using `COPY`, which would be annoying and less dynamic.
# `curl` ensures our image always grabs the latest WordPress version when we 
# build it.
#
# curl URL → Make an HTTP request (default: GET) and print the response.
# Downloading a file (like we did in the Dockerfile) is just a special case of 
# that, the server responds with a file content instead of an HTML page.
# We are not downloading a file when we curl localhost:9000. We are making a 
# network request, and whatever is at the other end responds (if it can).
# In our case, php-fpm doesn't directly serve HTTP responses to browsers — it
# speaks FastCGI protocol, not HTTP. That's why curl localhost:9000 doesn't  
# "work" normally for PHP-FPM: php-fpm expects a FastCGI client, not a curl HTTP
# client.
# 
# Needs an extra flag to save a file (-O to save with the original filename).
#      curl -O https://wordpress.org/latest.tar.gz
# -O = save the file with the same name it has in the URL (latest.tar.gz).
# ------------------------------------------------------------------------------
# PHP is a programming language, mainly used for server-side web development.
#
# 	- `php7.4`
#
# 	Installs the interpreter, i.e the main program that reads and executes .php
# 	files. With just this package, you can already run small PHP scripts from  
# 	the command line or embedded in HTML (but no integration with databases or
#	web servers yet).
# 
# 	- `php7.4-mysql`
#
# 	Adds the necessary functions inside PHP so you can connect to MySQL/MariaDB
# 	databases, run queries, fetch results, etc.
#
# 	- `php7.4-pfm`
#
# 	This installs the PHP-FPM service ("FastCGI Process Manager").
# 		- PHP-FPM is a server dedicated to running PHP scripts.
# 		- It listens either on a TCP port (like 9000) or a Unix socket.
# 		- It accepts requests from a web server (like NGINX) and returns the 
#			generated HTML output.
# 		- It is much faster and more scalable than the old method  
#			(Apache mod_php) because it manages PHP processes independently.
# 	Example of communication:
#		Browser ➔ NGINX ➔ PHP-FPM ➔ WordPress PHP code ➔ Database
# 	Without php7.4-fpm, NGINX wouldn't know how to process PHP files. It would  
# 	only serve static files (HTML, images...).
#
# 	PHP-FPM is a server-side helper that processes PHP code for webservers like
#	NGINX. NGINX cannot execute PHP code by itself, it can only serve static 
#	files (like .html, .jpg, .css).
# 	When NGINX sees a request for a .php file (like index.php in WordPress), it 
#	forwards that request to PHP-FPM.
# 	PHP-FPM reads the PHP code, runs it, and returns the generated HTML to NGINX.
# 	Then NGINX sends the final HTML to the user's browser.
# 	Without PHP-FPM:
# 		- NGINX would download the .php files as if they were static files (like 
#			downloading a .txt file).
# 		- NO execution of PHP would happen.
# 	Without NGINX:
# 		- PHP-FPM alone wouldn't know how to "talk to the outside world" (it just
#			listens internally).
# 		- You would have no web access unless you manually configured something crazy.
