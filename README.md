# Docker

## Basic commands

- docker **`pull`** <image>	: Fetches the given image from the Docker registry
- docker **`images`**		: Lists all images fetched to our system
- docker **`run`** <image>	: Runs a Docker container based on the provided image
- docker **`ps`**			: (**p**rocess **s**tatus) Shows all the containers that we have currently running 
- docker **`ps -a`**		: Shows all the containers that we have ran but are currently inactive
- docker <command> `--help`	: Displays help (basically available options) about provided command

---------------------------

## 1. Running a container

BusyBox is a tiny Linux distro that packages many common Unix utilities (`ls`, `sh`, `cat`, ...) into a single binary, resulting in a very small image (usually less than 1 Mb.)

First we are going to pull busybox image from Docker hub:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker pull busybox`

Now we run a busybox container followed by a command:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker run busybox ls -la`

We can give the container a name with the **<ins>--name</ins>** flag. If we don't specify any name, Docker will assign to our container a funny random one.

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker run --name < my_custom_container> busybox ls -la`

The Docker client[^1] finds the image, creates a command and runs the `ls -la` command in that container:

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

The command is executed within the container, and the process stops. If we want to start an interactive session, the **`-it`** option allows to interact with the container via a shell:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker run -it busybox sh`

- `-i` option (i stands for interactive) tells Docker to keep STDIN open on the container, allowing it to receive input like typed commands or piped data
- `-t` option (stands for teletype/terminal) allocates a pseudo-tty which gives you a terminal interface on your machine
	
> The `sh` command to start shell is not really necessary in this case, and an interactive shell will start even if we run the container without any command because `sh` is the default command defined in the BusyBox image. The image has something like `CMD[sh]` in its Dockerfile so whe you don't specify a command Docker falls back to that default, which happens to be the shell.
> Specifiying the command wuld matter using an image where the default command is not a shell, for instance
>   `docker run -it python sh`

To finish shell session, use the <ins>**`exit`**</ins> command.

---------------------------

## 2. Container isolation. Restarting/executing containers.

<ins>**`docker ps -a`**</ins> displays a list of all the containers, even the stopped ones:

```bash
CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS                      PORTS     NAMES
116268d6f047   alpine    "ash"     10 minutes ago   Exited (0) 9 minutes ago              reverent_volhard
a8ee7dd5130a   alpine    "sh"      12 minutes ago   Exited (0) 11 minutes ago             awesome_gauss
309a1b13c3bb   busybox   "sh"      13 minutes ago   Exited (0) 12 minutes ago             practical_elion
```

In the example we see that even though each `docker container run` command used the same alpine image, each execution was a separate, isolated container. Each container has a separate filesystem and runs in a different namespace; by default a container has no way of interacting with other containers, even those from the same image. Any change done within a container (e.g. creating a new file) will not affect the rest. This is a critical security concept in the world of Docker containers.

To restart a container session, we can use docker command <ins>**`start`**</ins>. However, running

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;~~`docker start 116`~~

makes the container run in the underground quietly with no terminal attached, so we cannot interact with it. To do so, before starting the container we need to <ins>**`attach`**</ins> to it:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker start 116268`\
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker attach 1162`

Or, alternatively, we can combine both commands in one go using `-a` (attach) and `-i` (interactively) options:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker start -ai 116268d6f`

We can send a command in to the container to run by using the <ins>**`exec`**</ins> command:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker exec <container_ID> ls -la`

This command can also be used as a third way to start an interactive session with a stopped container:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker start 116268d6f047`\
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker exec -it 116268d6f047 sh`

---------------------------

## 3. Deleting containers

Leaving all those stray containers eat up disk space. To clean up once we have done with them, use the <ins>**`rm`**</ins> command:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker rm <container ID>`

To delete a bunch of containers in one go:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker rm $(docker ps -a -q -f status=exited)`

In later versions, `docker container prune` command does the same.

---------------------------

## Creating our own images

We can pull an existing image, run it in a container and modify it as needed. E.g.:

```bash
docker container run -it ubuntu bash
apt-get update
apt-get install -y figlet
figlet "Hello!"
```

Our container installs the _figlet_ package and runs it, displaying 'Hello' in an ASCII-art way. If we want to share our new application, we must <ins>**`commit`**</ins> our changes:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker container commit <container_ID>`

We can also <ins>**`tag`**</ins> our custom image so that it is easier to identify when we display a list of our system `images`:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker image tag <container_ID> <my_image_name>`

In case we want to list the files that were added or changed to the original container, we can use the <ins>**`diff`**</ins> command:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker container diff <container_ID>`

Now we can run a container based on our newly created _<my_image_name>_ image:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker container run my_image_name figlet hello!`

---------------------------

## 4. Creating our images using a Dockerfile

What we have just created is a static binary image, that is, a file system with the modified files, executables and configs. These are "raw binary files" in the sense that it’s just the built, saved state of the container at that moment.
- This image can be run but you don't know how it was built.
- You can't easily reproduce, modify or update its content unless you reverse-engineer it.

A Dockerfile supplies the instructions for building the image, rather than just the raw binary files. This is useful because it becomes much easier to manage changes, especially as your images get bigger and more complex. It's kind of a Makefile, where you supply the instructions for building the executable, instead of just providing the binary file.

Let's create a Dockerfile to build our own 'hello world' application in bash. This is the script we are going to run, _hello.sh_:

```bash
#!/bin/sh 
echo "hello from $(hostname)"
```

To build our image, we will use alpine as the base OS image, copy our source code -the script- into the container and specify the default command to be run upon container creation:

```bash
FROM alpine
COPY hello.sh /app/hello.sh
RUN chmod +x /app/hello.sh
WORKDIR /app
CMD ["/app/hello.sh"]
```

> Should our script be written in bash (just change the _shebang_ to `#!/bin/bash`), Alpine would not be able to run it because it does not include by default. In this case, we would have to add a line to our Dockerfile:\
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`RUN apk update && apk add bash`\
> to install Bash.

To <ins>**build**</ins> the image:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker image build -t hello:bash .`

And to run it:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`docker container run hello:bash`

Finally, this is our output:

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hello from b1ebb08fb32e






[^1]: The *Docker client* is the command line tool that allows the user to interact with the *Docker daemon*[^2]

[^2]: The *Docker daemon* is the background service running on the host that manages building, running and distributing Docker containers.