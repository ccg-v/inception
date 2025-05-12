# Wordpress Config File

Minimal template:

```ini
[pool_name]

; --- User and Group ---
...

; --- Listening interface ---
...

; --- Process management ---
...

```

## 1. Pool name

The pool name is essential. It is part of the **PHP_FPM (FastCGI Process Manager)** configuration system.
Headers here define **named pools of PHP worker processes**.

> The PHP-FPM **pools** are all **groups of PHP _workers_**. \
> Each **_worker_** is a single PHP process from a pool, handling one request at a time:
> - PHP is single-threaded, so each worker can only handle one request at a time.
> - Therefore, to handle concurrent users, PHP-FPM launches multiple workers in each pool.

PHP-FPM allows you to run multiple independent pools, each with:

- Its own user/group
- Different settings (ports, sockets, memory limits, etc.)
- Isolation between applications

This is useful when you want to host multiple apps (e.g., WordPress, Laravel, etc.) on the same server but keep them separate:

```ini
[wordpress]
user = wp-user
listen = 127.0.0.1:9001
...

[laravel]
user = laravel-user
listen = 127.0.0.1:9002
...
```

Each `[pool_name]` block:

- Creates a separate pool
- Runs its own PHP processes
- Has independent settings (user, port/socket, process limits)

You can have as many headers as you want, as long as:

- Each one has a **unique name**
- Each one has its own `listen` value, to avoid port/socket conflicts

Use cases:

- Hosting multiple PHP apps with different resource needs
- Running pools under different users for security
- Isolating high-traffic sites from low-traffic ones

`[www]` is a common default name.

## 2. User and group

Running PHP-FPM (or any service) **under a specific user** controls:
1. File access
    - PHP scripts can only read/write files that the user has permission for.
	- If PHP runs as www-data, it cannot access /home/user/private.txt unless you allow it.

2. Security isolation
	- If you're hosting multiple apps (e.g., WordPress and Laravel), running each pool under a different user (e.g., wp-user, laravel-user) prevents them from accessing each other's files.
	- This is critical in multi-tenant setups.

3. Resource control (optional)
	- In advanced setups, different users can have different cgroup limits, disk quotas, or audit rules.

`www-data` is a **low-privilege system user and group**.
It is commonly used by:
- Web servers (like NGINX, Apache)
- PHP-FPM workers

The idea is: <u>serve web content using **a restricted user** to minimize potential damage if the process is compromised.</u>

`www-data` is a safe default for PHP-FPM, but it’s not mandatory. We may use a different user when we want better **security isolation**, **file permission control**, or **multi-app separation**.

## 3. Accept FastCGI requests via TCP (not socket)

In Docker, TCP is often preferred, because:
- NGINX and PHP-FPM run in **separate containers**
- They communicate over an **internal Docker network**
- **Unix sockets don’t work across containers**

By default, PHP-FPM is set in `www.conf` to listen on a Unix socket. But instead of using a Unix socket like `/run/php/php7.4-fpm.sock`, we want PHP-FPM to:
- Listen for FastCGI requests over the network -via TCP/IP-
- On port `9000`
- On all available network interfaces (`0.0.0.0`)

**That is exactly what `listen = 0.0.0.0:9000` means**.

Binding to `0.0.0.0` means it listens on all interfaces (even public ones) unless the Docker network restricts access. So we should:
- Limit exposure via firewall or Docker networking
- Avoid exposing port `9000` to the outside world

## 4. PHP-FPM Process Management

This section controls how PHP-FPM spawns and manages worker processes (remember PHP is single-threaded, so each worker can only handle one request at a time -see [pool name](#1-pool-name) section above-).

- `pm = dynamic`

	Enables dynamic process management (as opposed to `static` or `ondemand`). We are telling PHP-FPM to manage worker processes automatically. Therefore, PHP-FPM will:
	+ Start with a few processes
	+ Increase them when under load
	+ Reduce them when idle

- `pm.max_children = 5`

	Sets the **maximum number of workers** PHP-FPM can create at any time. If we hit the hard upper limit, new requests will be queued or dropped.

- `pm.start_servers = 2`

	Sets the number of workers PHP-FPM starts **immediately** when the service boots.

- `pm.min_spare_servers = 1` \
  `pm.max_spare_servers = 3`

	These control how many **idle (waiting)** workers PHP-FPM keeps around:
	+ If there are **fewer than** `min_spare_servers`, it will **spawn more**. \
	+ If there are **more than** `max_spare_servers`, it will **kill some**. 

Example flow:

- PHP-FPM starts with 2 workers.
- If it detects more demand, it spawns more (up to 5 total).
- If the demand drops and it has more than 3 idle workers, it will kill some.
- If idle workers fall below 1, it spawns new ones.

This allows PHP-FPM to **scale with demand**, **save memory** when idle, and avoid **spikes in CPU/memory** from creating too many processes.

## 5. Extended PHP-FPM Pool Configuration Template for WordPress

```ini
[pool_name]

; --- User and Group ---

; --- Listening interface ---

; --- Process management ---

; --- Logging ---
access.log = /proc/self/fd/1      ; Log to stdout (for Docker)
slowlog = /var/log/php-fpm/slow.log
request_slowlog_timeout = 5s      ; Log scripts slower than this

; --- Error Logging ---
php_admin_value[error_log] = /proc/self/fd/2
php_admin_flag[log_errors] = on

; --- Timeouts and Limits ---
request_terminate_timeout = 30s   ; Kill request if it takes too long
request_terminate_timeout = 30
rlimit_files = 1024               ; Max open file descriptors
rlimit_core = 0                   ; Disable core dumps

; --- Environment Variables (if needed) ---
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp

; --- Security (Optional) ---
security.limit_extensions = .php .php3 .php4 .php5 .php7 .phtml
```