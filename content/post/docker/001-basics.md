---
title: Docker Basic Operations
date: 2023-10-09 21:09:35
categories:
 - docker
tags:
 - docker
---

{{% youtube "Ozb9mZg7MVM" %}}

Video: https://youtu.be/Ozb9mZg7MVM?si=zFkftI_gXloSrZLh

Assume the `Dockerfile` under the `file-station` folder. 

## 1. Dockerfile

```dockerfile
FROM golang:alpine

LABEL authors="David"

# All the following command will treated as inside this folder of docker
WORKDIR /app
# copy all the files of our project into the /app folder of docker
COPY ./ ./
RUN go mod download

# Optional:
# To bind to a TCP port, runtime parameters must be supplied to the docker command.
# But we can document in the Dockerfile what ports
# the application is going to listen on by default.
# https://docs.docker.com/engine/reference/builder/#expose
EXPOSE 8080

# GOOS=linux: set target os to linux
# CGO_ENABLED=0: CGO is a feature in the Go programming language used for calling C code, 
# this parameter's purpose is to disable CGO.
# 'go build -o /server .': 'go build' is a command, '-o /server' output,
# '.' tells the compiler to build the Go program located in the current directory.
RUN CGO_ENABLED=0 GOOS=linux  go build -o /server .

CMD ["/server"]
```

To simplify things, and because this is a simple application, we statically compile the binary by setting `CGO_ENABLED=0`. This means that the resulting binary will not be linked to any C libraries. If your application uses any system libraries (like the system’s cryptography library) then you will not be able to statically compile the binary like this.

```shell
$ docker run -p 80:80 shwezhu/file-station:v1
2023/10/10 02:06:25 failed to connect database

2023/10/10 02:06:25 /app/main.go:12
[error] failed to initialize database, got error Binary was compiled with 'CGO_ENABLED=0', go-sqlite3 requires cgo to work. This is a stub
```

Source: [Containerize Your Go Developer Environment - Part 1 | Docker](https://www.docker.com/blog/containerize-your-go-developer-environment-part-1/)

## 2. Build image

The `docker build` command is used to build a Docker image from a Dockerfile and a "context". 

```shell
$ docker build [OPTIONS] PATH | URL | -
```

The Docker **build context** is the collection of files and directories that will be accessible to the Docker engine when we run *`docker build`*, and anything that is not part of the build context will not be accessible to commands in our [Dockerfile](https://docs.docker.com/engine/reference/builder/).

During the build, those files (build context) are sent to the Docker **daemon** so that the **image** can use them as files. The **build context** is usually at the current folder.  

```shell
# -t image_name:tag_name
$ docker build -t go-learning:1 . 
```

The `build` command optionally takes a `--tag` or `-t` flag. This flag is used to label the image with a string value, which is easy for humans to read and recognise. If you do not pass a `--tag`, Docker will use `latest` as the default value.

> When use `-t` with `dcoker build`  ensure that the `FROM` instruction in the *Dockerfile* does not specify the `latest` tag explicitly. If the FROM instruction is like FROM base_image:latest, it will inherit the "latest" tag from the base image. Which means `-t` won't take effect. 

After build image, you can check your images:

```shell
$ docker image ls                      
REPOSITORY    TAG       IMAGE ID       CREATED          SIZE
go-learning   1         5907982380c7   11 seconds ago   299MB
```

Delete your image:

```shell
# docker rmi image_name:tage_name
$ docker rmi go-learning:1
```

## 3. `.dockerignore` File

In order to reduce the Docker build context. We can use the *.dockerignore* file to solve the build context issue.

**The Docker CLI searches for a file named \*.dockerignore\* in the context’s root directory before sending it to the Docker daemon.** In case the file exists, the CLI excludes directories and files that match its patterns. This will prevent large files or sensitive directories from being sent unnecessarily to the Docker daemon.

Here, we’ll add the *jdk-8u202-linux-x64.tar.gz* file into the *.dockerignore* file in order to ignore it while creating the build:

```bash
$ echo "jdk-8u202-linux-x64.tar.gz" > .dockerignoreCopy
```

Let’s now build the Docker image:

```bash
$ docker build -t baeldung  .
Sending build context to Docker daemon  178.4MB
Step 1/3 : FROM   centos:7
 ---> eeb6ee3f44bdCopy
```

Here, we can clearly see that the Docker build context sent to the Docker daemon has been reduced from *372.5MB* to *178.4MB.*

> Now you should understand that "docker image is built from a `Dockerfile` and a "context" ". 

Source: [Reduce Build Context for Docker Build Command | Baeldung](https://www.baeldung.com/ops/docker-reduce-build-context)

## 4. Run your image as a container

### 4.1. Run container

In the previous parts we created a `Dockerfile` for our example application and then we created our Docker image using the command `docker build`. Now that we have the image, we can run that image and see if our application is running correctly.

A container is a normal operating system process except that this process is isolated and has its own file system, its own networking, and its own isolated process tree separate from the host.

To run an image inside of a container, we use the `docker run` command. It requires one parameter and that is the image name. Let’s start our image and make sure it is running correctly. Execute the following command in your terminal.

```shell
$ docker run go-learning:1
```

> Note that if you are deploying a web server to a container, you need to publish a port for your container. 

### 4.2. Publish a port

To publish a port for our container, we’ll use the `--publish` flag (`-p` for short) on the docker run command. The format of the `--publish` command is `[host_port]:[container_port]`. So if we wanted to expose port `8080` inside the container to port `3000` outside the container, we would pass `3000:8080` to the `--publish` flag.

```shell
$ docker run -p 80:80 go-learning:1
```

This is my web server which is listening on port `80`, 

```go
func main() {
	srv := http.NewServeMux()
	srv.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		_, _ = fmt.Fprint(w, "hello world")
	})
	_ = http.ListenAndServe(":80", srv)
}
```

Then when I run my image, I use `docker run -p 80:80 go-learning:1`, then I can make a http request successfully:

```shell
$ curl http://localhost:80
hello world
```

### 4.3. Run in detached mode

This is great so far, but our sample application is a web server and we should not have to have our terminal connected to the container. Docker can run your container in detached mode, that is in the background. To do this, we can use the `--detach` or `-d` for short. Docker will start your container the same as before but this time will “detach” from the container and return you to the terminal prompt.

```shell
$ docker run -d -p 80:80 go-learning:1
0908f98ed45af3f6481e49031a9cc24aa5e7c1bd77a375da07371880812415f6
```

### 4.4. Operations on containers

```shell
$ docker ps
CONTAINER ID   IMAGE           COMMAND     CREATED          STATUS          PORTS                          NAMES
0908f98ed45a   go-learning:1   "/server"   45 seconds ago   Up 44 seconds   0.0.0.0:80->80/tcp, 8080/tcp   stupefied_hellman

$ docker stop stupefied_hellman
stupefied_hellman
```

Source: https://docs.docker.com/language/golang/run-containers/

## 5. Share your image

Learn more: https://docs.docker.com/get-started/04_sharing_app/

Note that the image name should be same to the remote repository, the name of your image should include your docker hub username:

```shell
$ docker build -t davidzhu/go-learning:1 . 
```

Then push:

```shell
$ docker push shwezhu/file-station:v1
```

## 6. Install docker on Ubuntu

[How To Install and Use Docker on Ubuntu 20.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)

Then pull the shared repository:

```shell
$ sudo docker pull davidzhu/file-station:v1
```

Then run the image in docker container:

```shell
$ sudo docker run -d -p 80:80 shwezhu/file-station:v1
```

## 7. Build CGO with errors

When run image:

```
$ docker run -p 80:80 shwezhu/file-station:v1
2023/10/10 02:15:15 /app/main.go:12
[error] failed to initialize database, got error Binary was compiled with 'CGO_ENABLED=0', go-sqlite3 requires cgo to work. This is a stub
```

Then change the dockerfile above to:

```dockerfile
RUN apk update
RUN apk add \
  g++ \
  git \
  musl-dev \
  go \
  tesseract-ocr-dev

RUN CGO_ENABLED=1 GOOS=linux go build -o /server .

...
```

Then it works, but because my computer is arm64, and my EC2 server is amd64, so I need built a amd64 image:

```dockerfile
FROM --platform=linux/amd64 golang:alpine

LABEL authors="David"

# All the following command will treated as inside this folder of docker
WORKDIR /app
# copy all the files of our project into the /app folder of docker
COPY ./ ./
RUN go mod download

EXPOSE 80

RUN apk update
RUN apk add \
  g++ \
  git \
  musl-dev \
  go \
  tesseract-ocr-dev

RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o /server .

CMD ["/server"]
```

It takes about 5 mintues to build this image. 

Note that if you don't add `--platform=linux/amd64` after `FROM` then you will get error:

```
1.346 # runtime/cgo
1.346 gcc: error: unrecognized command-line option '-m64'
```