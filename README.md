# Dockerize the Atomic URL Shortner: An Operations Engineer Challenge

You will take an existing custom software application, the Atomic URL Shortener, and configure it to run in a containerized ecosystem with Docker.

The application is able to be run in this way without any modifications to the provided code base. You should not make any material changes to the application, but may tweak some configuration parameters as necessary.

## Instructions

Specific information about completing the challenge.

### Requirements

- Use [Docker](https://www.docker.com/) to containerize the Atomic URL Shortner.
- Use [docker-compose](https://docs.docker.com/compose/) to orchestrate multiple containers.
- Your Docker containers must be based on Linux (not Windows).
- Provide instructions for running your solution.

### Deliverables

- A link to a GitHub repo (new; not forked from this repo, please!) containing:
  - Any Dockerfile(s) and docker-compose.yml files created.
  - Any supporting scripts or configuration files.
  - A supporting README.
- A link to a public Docker Hub repo where you have pushed your image that can run the Atomic URL Shortener application. (No additional database image necessary.)

### Expectations

We expect to drop your file(s) into the repository, and run "docker-compose -f path/to/docker-compose.yml up".

If we run something like "curl -I http://localhost:3000/test", we expect to get a redirect like:

```
HTTP/1.1 301 Moved Permanently
Location: https://atomicobject.com
[...]
```

### Bonus Points

- Use Alpine Linux for the container.
- Get the Docker image for the application in under 775 MB.
