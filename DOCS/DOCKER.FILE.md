## Dockerfile
Basic structure:

- Download base image (**FROM** key)
- Install packages
- Copy configuration files
- Set permissions if needed
- Expose the port
- Start the service with **CMD** or **ENTRYPOINT** (or both)