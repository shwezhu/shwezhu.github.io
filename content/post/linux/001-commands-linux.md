---
title: Commands Commonly Used in Linux
date: 2023-05-03 12:40:56
categories:
 - linux
tags:
 - linux
---

```bash
$ ls -lh folder_name 
```

> `-l` means "long listing format":
>
> It displays detailed information about each file or directory, including: File permissions, Number of links, Group, File size, Last modification date/time. 
>
> `-h`: human-readable file sizes (e.g., 1K, 234M, 2G)

```bash
$ df -lh
```

>`df`: disk filesystem
>
>`-l` means "local file systems only": It limits the output to local file systems, excluding any network or special file systems. 

```bash
$ du  -sh  *
```

> `du`: disk usage.
>
> `-s`: stands for "summarize". It tells `du` to display only a total for each argument (each item (folder, file) in the current directory).
>
> Without `-s`:
>
> ```bash
> $ du -h downloads
> 4.0K    downloads/file1.txt
> 8.0K    downloads/videos/learn.mp4
> 12K     downloads/videos/bbc.mp4
> ...
> ```
>
> With `-s`:
>
> ```bash
> $ du -sh downloads
> 16K     downloads
> ```
> 

----

```shell
$ scp -rp tls/* root@86.150.206.117:/root/tls/
$ nohup ./server -p 8080 &

$ uname -a # Displays all system information (kernel, hostname, version, etc.).
$ file server 
$ otool # macOS tool for examining object files and executables.
$ xxd main.class # Display the contents in hexadecimal format.

$ chmod +x test.sh
$ ipconfig getifaddr en0  # check your ip on Mac

$ find themes/source/css -name "*header*" -type f
$ grep -nr 'ul$' themes/source/css  # n: line number, r: recursive

$ git log --all --decorate --oneline --graph # "A Dog" 
```

----

**`netstat`**

The basic `netstat` command without any options will list all **active TCP connections** and listening ports. Alternatively, you can use `lsof -i` on Mac.

With the `-a` option, `netstat` can show all listening and non-listening sockets.

With `-p` option, `netstat` can display the process ID (PID) and the program name associated with each network connection, on Linux & Windows. 

```shell
# lsof -i on Mac
$ netstat -anp | grep 127.0.0.53

❯ lsof -n -i
COMMAND    PID  USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
Raycast    688 David   42u  IPv6 0x91b82f8c4899      0t0  TCP *:7265 (LISTEN)
redis-ser  726 David    6u  IPv4 0x918862f10b09      0t0  TCP 127.0.0.1:6379 (LISTEN)
WeChat    1137 David  161u  IPv4 0x91bbc886151b1      0t0  TCP 192.168.2.15:51295->43.130.30.247:http (ESTABLISHED)
Arc\x20He 1269 David   21u  IPv4 0x91c91fd81e559      0t0  UDP 192.168.2.15:50307->142.251.35.174:https
```

e.g., you can use `netstat -anp | grep 8080` to find the PID of the process, so that you can kill it by `kill PID`.

You can also use `ps aux` to find a specific process by name, then use `netstat` to find the ip and port of the process.

---

**`ps`**

The ps command, short for Process Status, is used to view information related to the processes running in a Linux system. 

`ps aux`: a: show processes for all users, u: display the process's user/owner, x: also show processes not attached to a terminal.

The key info listed by `ps` are:
```shell
❯ ps aux
USER   PID   COMMAND

PID: Process ID.
COMMAND: The command that started this process.
```

e.g., you can use `ps aux | grep ./server` to find the PID of `./server` process, so that you can kill it by `kill PID`.

---

 **`brew services list`**

```shell
❯  brew services list
Name              Status  User  File
mongodb-community none    David
mysql             started David ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
redis             started David ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
unbound           none

❯ brew services start mongodb-community
==> Successfully started `mongodb-community` (label: homebrew.mxcl.mongodb-community)

❯ brew services list
Name              Status  User  File
mongodb-community started David ~/Library/LaunchAgents/homebrew.mxcl.mongodb-community.plist
...
```

----

 **`systemctl`**

The `systemctl` command is used to manage systemd services and units, such as starting, stopping, and checking the status of units. 

- Starting a Service: To start a service, you can use `systemctl start <service-name>`.
- Stopping a Service: To stop a service, you can use `systemctl stop <service-name>`.
- Checking the Status of a Service: To check the status of a service, you can use `systemctl status <service-name>`.

The systemd is a service manager for Linux operating systems. It is responsible for initializing and managing system services, daemons, and other processes during the boot process and while the system is running.

---

**wget**

```shell
# -O write documents to FILE: download the file and save it into install.sh
wget -O install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# -q quiet, same as above but output nothing
wget -qO install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# just output the content to stdout, no file saving
wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh

sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
