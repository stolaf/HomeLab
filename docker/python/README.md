# Python

``` bash
docker build -f docker/dockerfiles/python/Dockerfile-base -t python:latest .
docker build -f docker/dockerfiles/pwsh/Dockerfile-base -t pwsh:latest .
docker build -f docker/dockerfiles/pwsh/Dockerfile-modules -t pwsh:modules .
```

``` bash
docker run -it pwsh:modules
```
