## Flow:

1. **MariaDB**: make it run and initialized
	> To check if the container is running and wordpress database has been created:
	> - Run the container with `docker exec -it mariadb bash`
	> - Once inside the container, run the mysql CLI with `mysql -u root -p`
	> - Enter the root password we have defined in the `.env` file
	> - Run `'SHOW DATABASES` and verify that wordpress is among the databases:
	> 	
	>	```bash
	>	MariaDB [(none)]> SHOW DATABASES;
	>	+--------------------+
	>	| Database           |
	>	+--------------------+
	>	| information_schema |
	>	| mysql              |
	>	| performance_schema |
	>	| wordpress          |
	>	+--------------------+
	>	4 rows in set (0.000 sec)

2. **WordPress**: 
	At this point we won't be able to test it in a browser because there is no web server yet, but we can ensure that WordPress and PHP-FPM are running correctly and are ready to be served. verify that:
	+ The `php-fpm` process is running

		> To check if PHP-FPM is listening to a socket, into the container run `ps aux | grep php-fpm` \
		> We should see `php-fpm` processes running like:
		>
		> 	```bash
		> 	root           1  0.0  0.2 194088 19048 ?        Ss   01:12   0:00 php-fpm: master process (/etc/php/7.4/fpm/php-fpm.conf)
		> 	www-data      12  0.0  0.0 194088  5568 ?        S    01:12   0:00 php-fpm: pool www
		> 	www-data      13  0.0  0.0 194088  5568 ?        S    01:12   0:00 php-fpm: pool www
		> 	```
		> To check if the socket exists, run `ls -l /run/php` \
		> The output should be like:
		>
		>	```bash
		>	-rw-r--r-- 1 root     root     1 Apr 26 01:12 php7.4-fpm.pid
		>	srw-rw---- 1 www-data www-data 0 Apr 26 01:12 php7.4-fpm.sock
		>	```
		> If the socket is missing, it means PHP-FPM failed to start correctly.

	+ The WordPress files are in `/var/www/html`
	+ The `wp-config.php` file was created with the correct database values (if they aren't, check consistency across `.env`, `wordpress/tools/setup.sh` and `var/www/html/wp-config.php`)
	+ The container doesn't exit but stays alive

3. **Nginx** (serve WordPress via reverse proxy over port 443 with SSL)

Then refine:

- Network settings
- Volumes
- TLS certs
- Healthchecks
- Security hardening