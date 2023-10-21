---
title: CGO Compile Error Building Docker Image
date: 2023-10-21 10:24:22
categories:
 - bugs
tags:
 - bugs
 - docker
---

I choose a sqilte3 library which uses cgo, the Dockerfile:

```dockerfile
FROM golang:alpine

WORKDIR /app
COPY ./ ./
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux  go build -o /server .

CMD ["/server"]
```

After build successfully and run image:

```shell
$ docker run -p 80:80 shwezhu/file-station:v1
2023/10/10 02:15:15 /app/main.go:12
[error] failed to initialize database, got error Binary was compiled with 'CGO_ENABLED=0', go-sqlite3 requires cgo to work. This is a stub
```

Then change the dockerfile above to:

```dockerfile
...
# Install gcc to compile cgo
RUN apk add --no-cache --update go gcc g++
RUN go build -o /server .

CMD ["/server"]
```

And build with command:

```shell
$ docker build -t shwezhu/file-station:v2 .
```

Because my local machine is linux/arm64, the image was built to arm64 by default, but my EC2 server is linux/amd64, there is an error when run the image on EC2 server:

```shell
$ docker run -p 80:80 shwezhu/file-station:v1
WARNING: The requested image's platform (linux/arm64) does not match the detected host platform (linux/amd64) and no specific platform was requested
```

I need to built an image for  linux/amd64 architecture:

```shell
$ docker build --platform linux/amd64 -t shwezhu/file-station:v2 .
```

Because there is `--platform linux/amd64`, you can remove `CGO_ENABLED=1 GOOS=linux`. It takes about 5 mintues to build this image. 

> Docker images are typically built for a specific CPU architecture, such as x86-64 (64-bit Intel/AMD processors). By default, Docker images are built for the architecture of the system where the image is built. 

