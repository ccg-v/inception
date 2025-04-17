## Exercise:
# 2.2. Simple service with browser

## Instructions

The familiar image `devopsdockeruh/simple-web-service` can be used to start a web service, see the exercise 1.10.\
Create a _docker-compose.yml_, and use it to start the service so that you can use it with your browser.\
Read about how to add the command to docker-compose.yml from the [documentation](https://docs.docker.com/reference/compose-file/services/#command).\
Submit the _docker-compose.yml_, and make sure that it works simply by running `docker compose up`.

---

<details> 

<summary><h2>My solution</h2></summary>

```bash
services:
  simple-web-service:
    image: devopsdockeruh/simple-web-service
    container_name: exercise-2.2
    ports:
      - 8080:8080
    command: server
```
</details>