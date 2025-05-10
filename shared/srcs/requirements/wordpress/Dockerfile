FROM debian:bullseye

# Update and install dependencies [1][2][3]
RUN apt-get update -y && \
	apt-get install -y php7.4 php7.4-mysql php7.4-fpm curl tar mariadb-client && \
	apt-get clean

# Install WP-CLI (this installs `wp` globally as `/usr/local/bin/wp`)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Create directory for PHP-FPM socket
RUN mkdir -p /run/php

# Downloading and installing WordPress not to be done here, during image building,
# but later during execution of the script that configures/starts the container.

# Override the default 'www.conf' with our custom version
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copy the setup script and change permissions [3]
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Set working directory
WORKDIR /var/www/html

# We don't need to expose port 9000 but I keep it for documentation purposes [4]
EXPOSE 9000

# Run the setup script
CMD ["bash", "/usr/local/bin/setup.sh"] 

# ------------------------------------------------------------------------------
#
# [1]`curl`
#
# 	It's a command-line tool to download files from URLs (HTTP, HTTPS, FTP,...). 
# 	We need it to fetch the WordPress files during the image build.
# 	Without `curl` we would have to manually download WordPress ourselves and
# 	copy it into the container using `COPY`, which would be annoying and less
#	dynamic.
# 	`curl` ensures our image always grabs the latest WordPress version when we 
# 	build it.
#
# 	curl URL: Make an HTTP request (default: GET) and print the response.
# 	Downloading a file (like we did in the Dockerfile) is just a special case
# 	of that, the server responds with a file content instead of an HTML page.
# 	We are not downloading a file when we `curl localhost:9000`. We are making
# 	a network request, and whatever is at the other end responds (if it can).
# 	In our case, php-fpm doesn't directly serve HTTP responses to browsers, it
# 	speaks FastCGI protocol, not HTTP. That's why curl localhost:9000 doesn't  
# 	"work" normally for PHP-FPM: php-fpm expects a FastCGI client, not a curl
# 	HTTP client.
# 
# 	Needs an extra flag to save a file (-O to save with the original filename).
#      curl -O https://wordpress.org/latest.tar.gz
# 	-O = save the file with the same name it has in the URL (latest.tar.gz)
#
# ------------------------------------------------------------------------------
#
# [2] PHP
#
#	It is a programming language, mainly used for server-side web development.
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
# 	PHP-FPM reads the PHP code, runs it and returns the generated HTML to NGINX.
# 	Then NGINX sends the final HTML to the user's browser.
# 	Without PHP-FPM:
# 		- NGINX would download the .php files as if they were static files (like 
#			downloading a .txt file).
# 		- NO execution of PHP would happen.
# 	Without NGINX:
# 		- PHP-FPM alone wouldn't know how to "talk to the outside world" (it 
#			just listens internally).
# 		- You would have no web access unless you manually configured something
#			crazy.
#
# ------------------------------------------------------------------------------
#
# [3] `wp-config.php`
#
#	WordPress needs a wp-config.php with our DB credentials. Users normally 
#	providedata via browser UI during Wordpress manual installation, and the file
#	is automatically generated.
#	But since we must do the whole process programatically we generate the file
#	AT RUNTIME (in the CMD command) using a script where we inject our values to
#   the `wp-config.php` file using the WP_CLI tools that we have just installed.
#
#	Running the script in the Dockerfile with 'RUN bash /usr/local/bin/setup.sh'
#	will not work because the container hasn't started yet. Remember:
#
#	- Environment variables from .env file or docker-compose.yml only exist at 
#		RUNTIME, not build time.
#	- Runtime is what happens when the container starts, and container starts
#		when you launch the container with either CMD or ENTRYPOINT
#
# ------------------------------------------------------------------------------
#
# [4] EXPOSE
#
#	In our project port 9000 is going to be reachable only internally in the
#	Docker network by NGINX, o there is no need to EXPOSE it to the host or the
#	internet. Under no circumstances EXPOSE makes the port accessible outside
#	the container, it is the 'ports' directive in 'docker-compose.yml' or the 
# 	'RUN' command in the Dockerfile that actually opens the port to the host and 
#	can create a security risk if misused. EXPOSE is totally safe, it's only 
#	metadata signaling that MariaDB listens on 3306 but it doesn't open the port.

