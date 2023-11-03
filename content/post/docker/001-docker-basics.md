---
title: Docker Basics
date: 2023-10-09 21:09:35
categories:
 - docker
tags:
 - docker
 - golang
---

## 1. Docker client commands

```shell
#-------------- build and delete image --------------
$ docker build -t go-learning:1 . 
$ docker rmi shwezhu/file-station:v1
# if docker is in-use, delete with -f
$ docker rmi -f shwezhu/file-station:v1
$ docker image ls -a

#------------------ run image ----------------------
# --rm automatically removes the container when it exits,
# -d: Run container in background
$ docker run -d -p 80:80 --rm go-learning:1
# -it: allocates a pseudo-TTY and attaches it to the container
# then you can use command line to intercat with the current running container
$ docker run -it --rm docker-learning:v1 sh

#------------- show and delete container --------------
$ docker container ls -a
$ docker rm container_id

# publish and pull image to repo
$ docker push shwezhu/file-station:v1
$ docker pull davidzhu/file-station:v1
```

## 2. Dockerfile

```dockerfile
FROM golang:alpine

# All the following command will treated as inside this folder of docker
WORKDIR /app
# copy all the files of our project into the /app folder of docker
COPY ./ ./
RUN go mod download
RUN go build -o /server

CMD ["/server"]
```

## 3. Build image

The `docker build` command is used to build a Docker image from a Dockerfile and a "context". 

During the build, those files (build context) are sent to the Docker **daemon** so that the **image** can use them as files. The **build context** is usually at the current folder.  

```shell
# -t image_name:tag_name
# . specifies the build context as the current directory
$ docker build -t go-learning:1 . 
```

## 4. `.dockerignore` File

During the build, those files (build context) are sent to the Docker **daemon** so that the **image** can use them as files. 

When you build a Docker image, Docker takes all the files and directories in the build context and sends them to the Docker daemon, which then processes and includes them in the image. By using a `.dockerignore` file, you can specify patterns of files and directories that should be ignored during the build process. 

By excluding unnecessary files and directories, you can significantly **reduce the size of the Docker image**. This is particularly important when building images for production environments or when transferring images across networks.

## 5. Image vs container

**A container is an isolated place** where an application runs without affecting the rest of the system and without the system impacting the application. Because they are isolated, containers are well-suited for securely running software like databases or web applications that need access to sensitive resources without giving access to every user on the system. However, containers can be much more efficient than virtual machines because they don’t need the overhead of an entire operating system. They share a single kernel with other containers and boot in seconds instead of minutes.

**Images are read-only templates** containing instructions for creating a container. A Docker image creates containers to run on the Docker platform. Docker images are immutable, so you cannot change them once they are created. If you need to change something, create another container with your changes, then save those as another image. Or, just run your new container using an existing image as a base and change that one. 

An image is composed of multiple stacked layers, like layers in a photo editor, each changing something in the environment. Images contain the code or binary, runtimes, dependencies, and other filesystem objects to run an application. The image relies on the host operating system (OS) kernel. For example, to build a web server image, start with an image that includes Ubuntu Linux (a base OS). Then, add packages like Apache and PHP on top. 

**Think of a Docker container as a running image instance**. You can create many containers from the same image, each with its own unique data and state. Although images are not the only way to create containers, they are a common method.

Source: [Docker image vs container: What are the differences? | CircleCI](https://circleci.com/blog/docker-image-vs-container/)

## 6. Image with cross platform

Docker images are typically built for a specific CPU architecture, such as x86-64 (64-bit Intel/AMD processors). By default, Docker images are built for the architecture of the system where the image is built. However, it is possible to build and run Docker images for different architectures using a technique called multi-architecture or cross-platform support.

**Docker images can support multiple platforms**, which means that a single image may contain variants for different architectures, and sometimes for different operating systems, such as Windows. When you run an image with multi-platform support, Docker automatically selects the image that matches your OS and architecture. 

Most of the Docker Official Images on Docker Hub provide a [variety of architecturesopen_in_new](https://github.com/docker-library/official-images#architectures-other-than-amd64). For example, the `busybox` image supports `amd64`, `arm32v5`, `arm32v6`, `arm32v7`, `arm64v8`, `i386`, `ppc64le`, and `s390x`. When running this image on an `x86_64` / `amd64` machine, the `amd64` variant is pulled and run.

Learn more: [Multi-platform images | Docker Docs](https://docs.docker.com/build/building/multi-platform/)

## 7. Share your image

Learn more: https://docs.docker.com/get-started/04_sharing_app/

Note that the image name should be same to the remote repository, the name of your image should include your docker hub username:

```shell
$ docker build -t davidzhu/go-learning:1 . 
```

Then push:

```shell
$ docker push shwezhu/file-station:v1
```

Then pull the shared repository on another machine:

```shell
$ sudo docker pull davidzhu/file-station:v1
```

Then run the image in docker container:

```shell
$ sudo docker run -d -p 80:80 shwezhu/file-station:v1
```

> Make sure the image suits the cpu architecture: [Building multi-platform images](https://docs.docker.com/build/building/multi-platform/#building-multi-platform-images)
