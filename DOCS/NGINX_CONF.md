# NGINX config file

Minimal template:

```nginx
events {} 

http {
    server 1 {
        # Port listening

        # Server domain

        # TLS certificates and protocol settings

        # Set root and default file 

        # Set locations:
		#	- Location to handle static files or fallback to WordPress permalinks
        #	- Location to handle PHP files via FastCGI (WordPress)
        #	- Location to Deny access to hidden files like .htaccess or .env [7]
	}

	# Optional: Add additional `server {}` blocks for HTTP redirect, admin interface, etc.
	server 2 {
        (...)
	}

	server 3 {
        (...)
	}

    (...)
}
```

## 1. `Events` block

Syntactically, the `events` block is mandatory in the main context of `nginx.conf`, even if it's empty. Being empty does nott mean that the server won't handle incoming connections (that's the role of the `events` block), it's just that we are not customizing any of the event settings. We are simply telling Nginx to use the default event handling settings.


## 2. `http` block

Likewise, for syntactical reasons all the `server` blocks must live inside `http` block, which is where Nginx configures settings for handling HTTP/S traffic.

## 3. `listen` directive

Controls how and where a server block should accept incoming connections. It can define multiple things at once:

**Element** | **Example** | **Meaning**
--------|---------|---------
**Port** | `listen 443`; | Listen on TCP port 443
**Address** (IPv4/IPv6) | `listen 127.0.0.1:80;` / `listen [::]:80;` | Bind to a specific IP version or address
**Protocol(SSL)** | `listen 443 ssl;` | Exepct encrypted TSL/SSL connections
**Default server** | `listen 80 default_server;` | Marks this server block as default for unmatched requests
**HTTP/2 support** | ``listen 443 ssl http2;``| Enables HTTP/2 (with SSL) \



We are telling Nginx to listen for HTTPS connections on port 433 over IPv4: \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`listen 443 ssl`

and IPv6:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`listen [::]:443 ssl`

The `ssl` flag explicitly tells Nginx that this block handles TLS(HTTPS) traffic.

It is a clean and modern way to declare dual-stack support in Nginx. We are ensuring maximum compatibility with any client.