# MariaDB config file

Minimal template:

```ini
# Authentication Plugin
...

# Network Configuration
...

# DNS Optimization
...
```

## 1. Header

The `[mysqld]` section header is essential in a MariaDB (or MySQL) configuration file. It specifies that the settings under it **apply to the MariaDB server daemon** (`mysqld`). Without it, MariaDB won’t know which component the settings belong to, and they may be ignored.

MariaDB uses sections to organize config. Common sections include:

- `[mysqld]`: Settings for the server daemon
- `[client]`: Settings for the MySQL/MariaDB client
- `[mysqld_safe]`: Settings for the safe server launcher
- `[mysql]`: Settings for the mysql CLI tool

Each section controls a different part of the MariaDB ecosystem.

## 2. Default authentication method

MariaDB (and MySQL) supports multiple authentication plugins. Each one defines h**ow passwords are stored and verified** when users connect. `mysql_native_password` is the classic, widely supported plugin. Newer plugins (like `caching_sha2_passwor`d or `ed25519`) offer better security or performance, but may not be compatible with older clients or tools.

So explicitly setting the authentication method to `mysql_native_password`

```yaml
[mysqld]
default_authentication_plugin = mysql_native_password
```
we are basically **forcing MariaDB to use a traditional password system for new users**, in order to ensure compatibility with older clients and avoid connection errors like _"client does  not support authentication protocol"_

## 3. Disabling DNS resolution

By default, when a client connects, MariaDB tries to **resolve the client's IP address to a hostname** (via reverse DNS). This can:
- Slow down connections if DNS is misconfigured or slow.
- Fail if reverse DNS lookups are blocked or unavailable.

By setting

```yaml
[mysqld]
skip-name-resolve
```
we are telling MariaDB not to try to resolve IPs into hostnames and just use IP addresses as-is.

When this is enabled, you must define users using IP addresses, 

```sql
CREATE USER 'myuser'@'%' IDENTIFIED BY 'password';
```

not hostnames:

```sql
CREATE USER 'myuser'@'myhost.example.com' IDENTIFIED BY 'password';
```

## 4. Extended  MariaDB (MySQL) `.cnf` Configuration Template for Docker

```ini
[mysqld]

# Authentication Plugin
default_authentication_plugin = mysql_native_password

# Network Configuration
bind-address = 0.0.0.0

# DNS Optimization
skip-name-resolve

# (Optional) Basic Security & Limits
# max_connections = 100
# sql_mode = STRICT_ALL_TABLES
# character-set-server = utf8mb4
# collation-server = utf8mb4_unicode_ci

# (Optional) Logging for debugging
# general_log = 1
# general_log_file = /var/log/mysql/general.log
# slow_query_log = 1
# slow_query_log_file = /var/log/mysql/slow.log

```