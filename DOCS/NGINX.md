## 1. What is NGINX?

NGINX is a **web server**. But it can also act as a **reverse proxy**, a **load balancer**, and a **cache**.
In our project, we will mainly use it as:

- A web server: to receive HTTP requests from the browser.
- A reverse proxy: to forward those requests internally to PHP-FPM.

## 2. NGINX’s role in WordPress setup

| Service  | Responsibility 
|----------|----------------
| NGINX	   | Accepts HTTP connections from users (port 443 or 80). Sends static files (HTML, CSS, images) directly to users. Sends PHP files to PHP-FPM for processing.
| PHP-FPM  | Takes PHP code (like WordPress), processes it (with MySQL queries) and sends the final HTML back to NGINX.
| MariaDB  | Stores all the actual data: posts, users, settings, etc. WordPress connects to it behind the scenes.

So NGINX is the "door" to oour WordPress site. It knows when to serve files directly, and when to "ask" PHP-FPM to generate dynamic content.

Reasons for keeping NGINX separated from PHP-FPM:
- Separation of concerns: each tool does what it’s best at.
- Security: if PHP crashes, NGINX still stands and can show an error page.
- Performance: NGINX is extremely fast at serving static files (images, CSS, etc.) directly without involving PHP at all.

In short, we never want PHP to handle CSS files, and we never want NGINX to "think" about PHP code — it just forwards PHP files to PHP-FPM.

## 3. NGINX in our Inception project

We must create a separate NGINX container, whose role will be:
- To listen on port 443 (because we need HTTPS in Inception!).
- To connect internally (inside Docker network) to the WordPress (PHP-FPM) container on port 9000.
- To serve WordPress beautifully to browsers.

When a user opens our WordPress site, the flow will be:

- Browser → NGINX container (port 443 HTTPS)
- NGINX serves static files itself (CSS, JS, images)
- Or NGINX sends PHP files to WordPress container (php-fpm)
- WordPress talks to MariaDB container for data
- Resulting HTML goes all the way back to Browser.

| Concept | Description 
|---------|-------------
| NGINX	  | Web server and reverse proxy. Front gate.
| PHP-FPM |	PHP interpreter. Only processes .php files.
| MariaDB |	Database engine. Holds your site's content.

## 4. Building and running NGINX container

### 4.1 Dockerfile structure

```Dockerfile
FROM debian:bullseye

# Install Nginx
RUN apt-get update \
	&& apt-get install -y nginx openssl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# 2. Create default web root for NGINX
RUN mkdir -p /var/www/html

# Create SSL folders if they don't exist
# (standard Linux locations inside nginx container's Linux small file system)
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# Generate SSL key and certificate
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
  -out /etc/ssl/certs/yourdomain.crt \
  -keyout /etc/ssl/private/yourdomain.key \
  -subj "/C=XX/ST=City/L=City/O=42School/OU=Inception/CN=yourdomain.com"

# Set proper permissions
RUN chmod 644 /etc/ssl/certs/yourdomain.crt \
    && chmod 600 /etc/ssl/private/yourdomain.key

# Copy our custom nginx configuration
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Expose port 443 for HTTPS
EXPOSE 443

# Start nginx (in foreground mode!)
CMD ["nginx", "-g", "daemon off;"]
```

2. `/var/www/html` folder is the default web root for NGINX. NGINX serves files (HTML, PHP, etc.) from /var/www/html by default, unless otherwise specified in your nginx.conf.
	We need it if:
	- We are serving static content (like HTML files), or
	- We are proxying to something like PHP-FPM which expects the root there. \
We don't need it:
	- Our custom `nginx.conf` sets a different root and we are not using this path at all.

### 4.2 Configuration file logical structure

The `nginx.conf` file is not written in a general-purpose programming language like Python, C or PHP. Instead, it is written in **Nginx configuration syntax**, that is, a custom configuration language specifically invented for Nginx.

It has these characteristics:

- **Block-based**: uses `{}` to group directives.
- **Directive-oriented**: almost everything is a _directive_ (like `listen`, `server_name`, `ssl_protocols`, etc.).
- **Semicolon-ended**: most lines end with a `;`.
- **Hierarchical**: the structure is nested (e.g., `http` block → inside it `server` block → inside it `location` block).

It's a bit like **JSON** or **YAML** mixed with **Bash syntax**, but lighter and more directive-focused.

Structure description:

```nginx
# 1. Main (Global) Context
events {
    # Event-related settings (e.g., max simultaneous connections)
}

# 2. HTTP Context (for handling web traffic)
http {
    # General settings (compression, mime-types, logging, etc.)

	# 3. This defines ONE website (a "virtual host")
    server {
        listen 443 ssl;            # Which port to listen on (and SSL!)
        server_name yourdomain.com; # Domain name
        
		# 4. SSL settings
        ssl_certificate /path/to/cert.pem;       # SSL certificate
        ssl_certificate_key /path/to/cert.key;    # SSL key
        ssl_protocols TLSv1.2 TLSv1.3;             # TLS version restrictions

		# 5. Web root
        root /var/www/html;        # Root directory of files
        index index.php index.html;

		# 6. Main location block (what to do when someone visits "/")
        location / {
            try_files $uri $uri/ =404; # Try to find file/folder, otherwise 404
        }

        # 7. Special handling for PHP files
        location ~ \.php$ {
            include fastcgi_params; # load default FastCGI settings
            fastcgi_pass wordpress:9000; # forward requests to php-fpm at container wordpress
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; # Correct path for PHP
        }
    }
}
```

| **Block**	   | **Purpose**
|--------------|------------
| `events`     | How the server deals with incoming connections
| `http`       | All web-related configuration (websites, MIME types, caching, etc.)
| `server`     | Defines one website (or one service)
| `location`   | Defines routes (what happens when someone visits a path, like /login or /index.php)

- Inside `http` you can have many `server {}` blocks → this is how you host multiple websites (called virtual hosts).
- Inside a `server`, you can have many `location {}` blocks → each dealing with a different type of request or path.
- `ssl_protocols TLSv1.2 TLSv1.3;` → accept only secure versions of TLS.
- The `fastcgi_pass` connects Nginx to PHP-FPM service to execute PHP code.

> ### Locations: Nginx request handling order
> NGINX evaluates `location` blocks in this order (simplified): 
> - **Exact match** (`location = /about`)
> - **Prefix match (longest)** (`location /static/`): among all prefix matches, the longest path wins
> - **Regex match** (`location ~ \.php$`) or `location ~* \.JPG$`: only considered _after_ prefix matches
> - If none of the above match, Nginx falls back to serving static files under `root` and applying index `index.php`
> This is why `location /` (a general prefix) often acts as a fallback, but will _not_ override a longer prefix like `location /static/` or a regex.
> Example:
> ```nginx
> server {
>    root /var/www/html;
>    index index.php;
>
>    location = /about {
>        return 200 "About page";
>    }
>
>    location /blog/ {
>        # WordPress or static blog files
>    }
>
>    location ~ \.php$ {
>        # PHP handler
>    }
>
>    location / {
>        try_files $uri $uri/ =404;
>    }
> }
> ```
> Request path: `/blog/post1`
> 1. Not an exact match (=), so rule #1 is skipped.
> 2. Prefix /blog/ matches — rule #2 wins here.
> 3. Regex is ignored because a stronger prefix match already won.
> 4. The file is looked up under /var/www/html/blog/post1, or internally passed to PHP, depending on logic inside that location.


> [!NOTE]
> - **Certificates**: We must create or generate a **certificate** (`.crt`) and a **private key** (`.key`) and put them inside the container.
> - **wordpress:9000**: wordpress must match the service name in the `docker-compose.yml`.
> - **443**: Port 443 is the standard port for HTTPS (SSL/TLS).

## 4. TSL/SSL settings

https://www.globalsign.com/es/centro-de-informacion-ssl/que-es-un-certificado-ssl
https://en.wikipedia.org/wiki/Public_key_certificate

SSL certificates prove two things to users:
- Identity → _"I am really who I claim to be."_
- Encryption → _"We are talking in secret, no one else can spy on us."_

**TLS (HTTPS encryption) requires a certificate (.crt) and a private key (.key).**

**Certificate (CRT file)**: Public file shared with clients (browser downloads it).
**Private key (KEY file)**: Secret file kept on the server only.
Together, they allow encrypted communication.

In the real world, big websites pay "Certificate Authorities" (like GlobalSign, Let's Encrypt, Google Trust, etc.) to issue certificates — official certificates trusted by browsers.
In our Docker project, we generate our own fake certificate, signed by ourselves ("self-signed certificate").It's good enough for local tests.
Browsers will give a security warning ("not trusted"), but it's fine for our 42 project.

Reminder:
- Always separate certificates and keys.
- Always put private keys under `/etc/ssl/private/`, not with public certs.
- Permissions: Make sure later the key files aren't world-readable (only Nginx user needs access).
- Name files clearly.

**We must disable old versions (like TLS 1.0 and TLS 1.1) — only allow TLS 1.2 and TLS 1.3.**

OpenSSL command:
```Dockerfile
openssl req -x509 -sha256 -nodes \
  -newkey rsa:4096 \
  -days 365 \
  -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=ccarrace/CN=ccarrace.42.fr" \
  -keyout ${CERTS_KEY} \
  -out ${CERTS_CRT} 
```

- `openssl`	The tool for crypto stuff (encrypt, certificates, etc.)
- `req`		Means: "create a Certificate Signing Request (CSR)" (and a certificate if combined with -x509)
- `-x509`	Instead of a CSR, create a self-signed X.509 certificate directly
- `-sha256`	Use strong SHA-256 hashing (modern standard)
- `-nodes`	No DES encryption on private key = key isn't password protected (needed for Nginx)
- `-newkey rsa:4096`	Create a brand-new RSA private key of 4096 bits (stronger security)
- `-days 365`	Certificate valid for 1 year
- `-subj`	Pre-fill all the organization info to avoid interactive questions
	+ `/C=`	Country code (e.g., FR, BR, US)
	+ `/ST=`	State or region
	+ `/L=`	Locality (City)
	+ `/O=`	Organization (put "42School" or "42")
	+ `/OU=`	Organizational Unit (e.g., "Inception")
	+ `/CN=`	Common Name → The domain name users will visit (e.g., your login .42.fr)
- `-keyout`	Where to save the private key
- `-out`	Where to save the public certificate 




- **TLS (HTTPS encryption) requires a certificate (.crt) and a private key (.key).**
- **Nginx must listen on port 443 for HTTPS.**
- **We must disable old versions (like TLS 1.0 and TLS 1.1) — only allow TLS 1.2 and TLS 1.3.**
- **PHP-FPM will run separately, so Nginx will proxy PHP requests to PHP-FPM through the socket or a TCP port (in our case, localhost:9000 inside Docker).**