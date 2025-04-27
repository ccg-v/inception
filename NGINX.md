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
RUN apt-get update && apt-get install -y nginx && apt-get clean

# Copy our custom nginx configuration
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Create folders if needed
RUN mkdir -p /var/www/html

# Expose the ports
EXPOSE 80 443

# Start nginx (in foreground mode!)
CMD ["nginx", "-g", "daemon off;"]

```

### 4.2 Configuration file logical structure

The `nginx.conf` file is not written in a general-purpose programming language like Python, C or PHP. Instead, it is written in **Nginx configuration syntax**, i.e. a custom configuration language specifically invented for Nginx.

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

> [!NOTE]
> - **Certificates**: We must create or generate `my_cert.pem` and `my_key.pem` and put them inside the container.
> - **wordpress:9000**: wordpress must match the service name in the `docker-compose.yml`.
> - **443**: Port 443 is the standard port for HTTPS (SSL/TLS).