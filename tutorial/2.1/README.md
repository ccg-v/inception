## Exercise:
# 2.1. Simple service writing to log

## Instructions


Let us now leverage the Docker Compose with the simple webservice that we used in the Exercise 1.3. \
Without a command `devopsdockeruh/simple-web-service` will create logs into its `/usr/src/app/text.log`.\
Create a _docker-compose.yml_ file that starts devopsdockeruh/simple-web-service and saves the logs into your filesystem.\
Submit the _docker-compose.yml_, and make sure that it works simply by running docker compose up if the log file exists.

---

<details> 

<summary><h2>My solution</h2></summary> 

To ensure the log file exists in the host, I create it in advance (if I don't, Docker creates `text.log` as a folder and docker compose fails):

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`touch text.log`

This is my _docker-compose.yml`:

```bash
services:
 simple-web-service:
  image: devopsdockeruh/simple-web-service
  container_name: exercise-2.1		
  volumes:
    - ./text.log:/usr/src/app/text.log
```

</details> 
