# Docker

## Basic commands
- docker `pull` <image>	: Fetches the given image from the Docker registry
- docker `images`		: Lists all images fetched to our system
- docker `run` <image>	: Runs a Docker container based on the provided image
- docker `ps`			: Shows all the containers that we have currently running
- docker `ps -a`		: Shows all the containers that we have ran but are currently inactive

## Running a container

BusyBox is a tiny Linux distro that packages many common Unix utilities (`ls`, `sh`, `cat`, ...) into a single binary, resulting in a very small image (usually less than 1 Mb.)

First we are going to pull busybox image from Docker hub:

   `docker pull busybox`

Next we run a busybox container followed by a command:

   `docker run busybox ls -la`

The BusyBox `ls -la` command is ran and the content of the container is displayed

```bash
drwxr-xr-x    1 root     root          4096 Apr  9 16:22 .
drwxr-xr-x    1 root     root          4096 Apr  9 16:22 ..
-rwxr-xr-x    1 root     root             0 Apr  9 16:22 .dockerenv
drwxr-xr-x    2 root     root         12288 Sep 26  2024 bin
drwxr-xr-x    5 root     root           340 Apr  9 16:22 dev
drwxr-xr-x    1 root     root          4096 Apr  9 16:22 etc
drwxr-xr-x    2 nobody   nobody        4096 Sep 26  2024 home
drwxr-xr-x    2 root     root          4096 Sep 26  2024 lib
lrwxrwxrwx    1 root     root             3 Sep 26  2024 lib64 -> lib
dr-xr-xr-x  441 nobody   nobody           0 Apr  9 16:22 proc
drwx------    2 root     root          4096 Sep 26  2024 root
dr-xr-xr-x   13 nobody   nobody           0 Apr  9 16:22 sys
drwxrwxrwt    2 root     root          4096 Sep 26  2024 tmp
drwxr-xr-x    4 root     root          4096 Sep 26  2024 usr
drwxr-xr-x    4 root     root          4096 Sep 26  2024 var
```

The command is executed within the container, and the process stops. If we want to start an interactive session, the `-it` option allows to interact with the container via a shell:

   `docker run -it busybox sh`

- `-i` option (i stands for interactive) tells Docker to keep STDIN open on the container, allowing it to receive input like typed commands or piped data
- `-t` option (stands for teletype/terminal) allocates a pseudo-tty which gives you a terminal interface on your machine
	
> The `sh` command to start shell is not really necessary in this case, and an interactive shell will start even if we run the container without any command because `sh` is the default command defined in the BusyBox image. The image has something like `CMD[sh]` in its Dockerfile so whe you don't specify a command Docker falls back to that default, which happens to be the shell.
> Specifiying the command wuld matter using an image where the default command is not a shell, for instance
>   `docker run -it python sh`