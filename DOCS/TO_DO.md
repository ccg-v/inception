WordPress website (for logging into WordPress)
 - site title:	my42inception
 - usernames:	master/editor
 - passwords:	masterpass/editorpass
 - e-mail:		master@my42inception.com

Check bookmarks!!!

# MariaDB:

Xplanations:
- running `mariadb-client`
- `context` keyboard
- why do we start mariadb in script WITHOUT NETWORKING. Shall I keep this when I add the rest of services?

Pending:
- FINISHING `custom.cnf`???

hostname:
- store in an env variable?
- or modify /hosts?

Set certificate paths/names in .env and replace them in nginx.conf

Secrets? Ignore .env?

Am I hardcoding the env variables somewhere? It worked when I had wrong syntax in .env file,so I was presumibly passing the values somehow...

Warning in wordpress logs about root user -> normal?


revisar CMD/ENTRYPOINT

setting certificate paths as vars
 