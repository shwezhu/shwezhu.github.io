---
title: Dockerfile Synatax
date: 2023-10-11 12:27:35
categories:
 - docker
tags:
 - docker
---

## 1. WORKDIR

```dockerfile
WORKDIR /path/to/workdir
```

The `WORKDIR` instruction sets the working directory for any `RUN`, `CMD`, `ENTRYPOINT`, `COPY` and `ADD` instructions that follow it in the `Dockerfile`. If the `WORKDIR` doesn't exist, it will be created even if it's not used in any subsequent `Dockerfile` instruction.

The `WORKDIR` instruction can be used multiple times in a `Dockerfile`. If a relative path is provided, it will be relative to the path of the previous `WORKDIR` instruction. For example:

```dockerfile
WORKDIR /a
WORKDIR b
RUN pwd
```

The output of the final `pwd` command in this `Dockerfile` would be `/a/b`.

If not specified, the default working directory is `/`. In practice, if you aren't building a Dockerfile from scratch (`FROM scratch`), the `WORKDIR` may likely be set by the base image you're using.

Therefore, **to avoid unintended operations in unknown directories, it is best practice to set your `WORKDIR` explicitly.**

## 2. COPY

We usually the following code in `Dockerfile`:

```dockerfile
...
WORKDIR /app
COPY ./test ./
```

And when build the image, we use `docker build -t docker-learning:v1 .`

So the `COPY ./test ./` will be executed when we build the image, what `COPY ./test ./` does is just **copy** all the files under `./test` on your computer into the `/app` folder of the container. Because `./` means current folder, and we set  our current folder to `/app` by using `WORKDIR /app` in `Dockerfile`. 

> Note that  `.dockerignore` file is not considered here, if you add `.dockerignore` file, then before execute `COPY ./test ./`,  docker will check the `.dockerignore` file first, if the file in the `./test` folder machs the file list in `.dockerignore` file, then `COPY ./test ./` will skip that file. 

And note that the build command `docker build -t docker-learning:v1 .`, the last `.` sign is used to specify the context, in `COPY ./test ./`, the `./test` is the `test` folder under the context. 

You can build a image and run it with `docker run -it --rm docker-learning:v1 sh` to check. 

## 3. RUN vs CMD

`RUN` - command triggers while we build the docker image.

`CMD` - command triggers while we launch the created docker image.

> There can only be one `CMD` instruction in a `Dockerfile`. If you list more than one `CMD` then only the last `CMD` will take effect.

You can check the output when build a image:

```dockerfile
FROM ubuntu

# The following will run when build image
WORKDIR /app
COPY ./ ./

# The following will run when run image
CMD ["pwd"]
```

```shell
$ docker build -t docker-learning:v1 .
=> CACHED [2/4] WORKDIR /app          0.0s
=> [3/4] COPY ./ ./                   0.0s
```

Note that there just are `COPY ./ ./` and `WORKDIR /app` get triggered, and when I run the image, `CMD ["pwd"] ` get triggered. 

```shell
$ docker run --rm docker-learning:v1  
/app
```

## 4. ENTRYPOINT vs CMD

### 4.1. An example

```dockerfile
FROM alpine:latest

ENTRYPOINT ["ls"]
```

After build the image and run the image:

```shell
$ docker build -t docker-learning:v1 . 
...
$ docker run --rm docker-learning:v1
bin
dev
etc
home
...
```

The ENTRYPOINT instruction here means Docker runs the `ls` command when the container starts. As because no `CMD` is set, the command is called without arguments. You can pass arguments directly through to the command by appending them to your `docker run` statement:

```shell
$ docker run --rm docker-learning:v1 -all
total 64
drwxr-xr-x    1 root     root          4096 Oct 11 19:05 .
drwxr-xr-x    1 root     root          4096 Oct 11 19:05 ..
-rwxr-xr-x    1 root     root             0 Oct 11 19:05 .dockerenv
...
```

Everything after the image name gets passed to the ENTRYPOINT as its arguments, resulting in `ls -all` being called in the container. 

### 4.2. How Does ENTRYPOINT Work

The[ ENTRYPOINT Dockerfile instruction](https://docs.docker.com/engine/reference/builder/#entrypoint) sets the **process**(进程) that’s executed when your container starts. In this example, the container will run `/usr/bin/my-app`:

```dockerfile
ENTRYPOINT ["/usr/bin/my-app"]
```

The somewhat misleadingly named [CMD instruction](https://docs.docker.com/engine/reference/builder/#cmd) sets the default arguments that are passed to the ENTRYPOINT process. It determines the final form of the command string that will be executed. In the following example, the container will run `/usr/bin/my-app help`:

```dockerfile
ENTRYPOINT ["/usr/bin/my-app"]
CMD ["help"]
```

> Images can only have one ENTRYPOINT. If you repeat the Dockerfile instruction more than once, the last one will apply. When an image is created without an ENTRYPOINT, Docker defaults to using `/bin/sh -c`.

> There can only be one `CMD` instruction in a `Dockerfile`. If you list more than one `CMD` then only the last `CMD` will take effect.

### 4.3. Difference between `docker run` and ENTRYPOINT

The [`docker run` command](https://docs.docker.com/engine/reference/commandline/run) starts a new container using a specified image. When no further arguments are given, the process that runs in the container will exactly match the ENTRYPOINT and CMD defined in the image:

```bash
# Executes /usr/bin/my-app help
$ docker run my-image:latest
```

You can change the CMD by supplying arguments to the `docker run` command, after the name of your image:

```bash
# Executes /usr/bin/my-app version
$ docker run my-image:latest version
```

Note that this *always* changes the CMD, not the ENTRYPOINT. Therefore, the `docker run` command **starts** new containers **and** **sets** the CMD that’s passed as arguments (`version` here) to the image’s ENTRYPOINT. 

Technically, it is possible to override the ENTRYPOINT using `docker run` by setting its `--entrypoint` flag. Although this is rarely required, the technique can be useful if you want to launch a shell inside a container, such as to inspect the contents of an image’s filesystem:

```bash
# Executes bash -c "ls /"
$ docker run --entrypoint bash my-image:latest -c "ls /"
```

Note that there is no `bash` under the `/bin` folder of  `alpine:latest` linux system which our container based on, there just two shells: `ash ` and `sh`. So the command above will get an error. 

```shell
docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: exec: "bash": executable file not found in $PATH: unknown.
```

You can try:

```shell
$ docker run --entrypoint /bin/sh docker-learning:v1 -c "cat /etc/shells"
# valid login shells
/bin/sh
/bin/ash
```

Or

```shell
$ docker run docker-learning:v1 cat /etc/shells  
# valid login shells
/bin/sh
/bin/ash
```

Both of these are same, because the default entrypoint is `/bin/sh -c`. 

## 5. ENTRYPOINT vs CMD

CMD and ENTRYPOINT are two Dockerfile instructions that together define the command that runs when your container starts. *ENTRYPOINT* sets the process to run, while *CMD* supplies default arguments to that process.

- **ENTRYPOINT** is the **process** that’s executed inside the container.
- **CMD** is the default set of **arguments** that are supplied to the ENTRYPOINT process.

```dockerfile
FROM alpine:latest
ENTRYPOINT ["ls"]
CMD ["-all"]
```

```shell
$ docker run --rm docker-learning:v1
```

equals to:

```dockerfile
FROM alpine:latest
ENTRYPOINT ["ls"]
```

```shell
$ docker run --rm docker-learning:v1 -all
```

So in this case the CMD is overwritten. 

Reference: 

- [Dockerfile reference | Docker Docs](https://docs.docker.com/engine/reference/builder/)
- [Docker ENTRYPOINT and CMD : Differences & Examples](https://spacelift.io/blog/docker-entrypoint-vs-cmd)







