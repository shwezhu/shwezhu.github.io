---
title: CGO Cross Compilation Issue in Docker
date: 2023-10-11 15:27:35
categories:
 - docker
tags:
 - docker
 - go
---

## 1. A compile issue with gcc

```dockerfile
FROM golang:alpine

WORKDIR /app
COPY ./ ./
# Note that the `WORKDIR` instruction sets the working directory 
# for any `RUN`, `CMD`, ... instructions that follow it in the `Dockerfile`. 
RUN go build -o server .

CMD ["./server"]
```

Then I got:

```shell
$ docker build -t docker-learning:v1 .
 => ERROR [4/4] RUN go build -o server .                    0.1s
------
 > [4/4] RUN go build -o server .:
0.130 package go-learning: build constraints exclude all Go files in /app
```

The reason is that the cgo was disabled by default, then I change the code to:

```dockerfile
RUN CGO_ENABLED=1 go build -o server .
```

Then I got:

```shell
$ docker build -t docker-learning:v1 .
> [4/4] RUN CGO_ENABLED=1 go build -o server .:
1.195 # runtime/cgo
1.195 cgo: C compiler "gcc" not found: exec: "gcc": executable file not found in $PATH
```

This means there is no `gcc` in the container which based on `golang:alpine`. 

Reference: https://docs.docker.com/engine/reference/builder/#cmd

## 2. Alpine linux

> [Alpine Linux](https://alpinelinux.org/) is a Linux distribution built around [musl libc](https://www.musl-libc.org/) and [BusyBox](https://www.busybox.net/). The image is only 5 MB in size. Learn more: [alpine - Official Image | Docker Hub](https://hub.docker.com/_/alpine)

Use like you would any other base image:

```dockerfile
FROM alpine:3.14
RUN apk add --no-cache mysql-client
ENTRYPOINT ["mysql"]
```

This example has a virtual image size of only 36.8MB. Compare that to our good friend Ubuntu:

```dockerfile
FROM ubuntu:20.04
RUN apt-get update \
    && apt-get install -y --no-install-recommends mysql-client \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["mysql"]
```

This yields us a virtual image size of about 145MB image.

## 3. Solve the issue

Based on above, we can install `gcc` on the container whose system is based on alpine linux. 

```dockerfile
RUN apk add --no-cache --update go gcc g++
```

Then the build process will succeed. Final Dockerfile:

```dockerfile
FROM golang:alpine

RUN apk add --no-cache --update go gcc g++
WORKDIR /app
COPY ./ ./
RUN CGO_ENABLED= go build -o server .

CMD ["./server"]
```

BTW, if you want build for other platform, cross-compilation, you can set the parameter for docker client when building image:

```shell
$ docker build --platform linux/amd64 -t shwezhu/file-station:v2 .
```

Learn more: 

[Multi-platform images | Docker Docs](https://docs.docker.com/build/building/multi-platform/)

[Builders | Docker Docs](https://docs.docker.com/build/builders/)

[Docker Build architecture | Docker Docs](https://docs.docker.com/build/architecture/)