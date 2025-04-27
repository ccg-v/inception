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

## 3. Our Inception project

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