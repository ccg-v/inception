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

Next we run a busybox container folowed by a command:

`docker run busybox ls`


	
 