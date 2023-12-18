---
title: Useful Commands in Linux
date: 2023-05-03 12:40:56
categories:
 - linux
tags:
 - linux
---

## 1. Some Commands

You can use `xxx --help `, `man xxx`, `tldr you-command` to check the usage of the command. 

```shell
$ brew services list
# detach a program from cli, after executed, exit cli, don't do Ctrl+C
$ nohup ./server -p 8080 &
# kill a specific program
$ ps aux | grep ./server
$ zip -r root.zip root
# display information about running processes
# kill PID
$ ps -ef
# "A Dog" = git log --all --decorate --oneline --graph
$ git log --all --decorate --oneline --graph
$ ls -lh xxx
# dns stub status
$ systemctl status systemd-resolved
# server is an executable binary compiled from Go program, 
# this will print: server: Mach-O 64-bit executable arm64
$ file server
# Print details about the current machine and the operating system running on it.
$ uname -a
$ otool/xdd
# output file in hexadecimal
$ xxd a.class
# -type f is for file, -type d is for directory, -iname is case-insensitive
$ find themes/source/css -name "*header*" -type f
# n: line number, r: recursive
$ grep -nr 'ul$' themes/source/css
# curl -v verbose
$ curl localhost:8080 -H "Content-Type: application/json" -d "{"username":"david", age:3}" -v
# make a file executable
$ chmod +x test.sh
# check your ip on Mac
$ ipconfig getifaddr en0 
# >: overwirte, >> append
$ echo "Hello, World" > output.txt
# check DNS of domain
$ dig +trace davidzhu.xyz
# check IP of domian
$ dig +short davidzhu.xyz
# Rename all file in current directory, from cupper-case to lower-case
$ find . -depth -execdir rename -f 'y/A-Z/a-z/' {} \;
# check files size under current folder, h: human-readable, *: all, s: sort
$ du  -sh  *
# disk usage
$ df -lh
```

## 2. wget

```shell
# -O write documents to FILE: download the file and save it into install.sh
wget -O install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# -q quiet, same as above but output nothing
wget -qO install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# just output the content to stdout, no file saving
wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
```

In the command `wget -O-`, the option `-O` is used to specify the output file or destination. In this case, the hyphen (`-`) after `-O` indicates that the output should be sent to the standard output (stdout) instead of saving it to a file.

### 2.1. sh -c with wget

```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

`sh` calls the program `sh` as interpreter and the `-c` flag means execute the following command as interpreted by this program. 

```shell
[root@vultr BashLearning]# which sh
/usr/bin/sh
```

> **NOTE:** this is execute the command directly, which may not safe, don't do this on you production server. Don't give it system admin permission: `sudo`. 

## 3. find

```shell
# -type f is for file, -type d is for directory, -iname is case-insensitive
# find search the file recursively, don't need -r option
$ find . -name "*header*" -type f
./content/post/c++/basics/header-files.md
./themes/even/layouts/partials/header.html
./themes/even/assets/sass/_partial/_post/_header.scss
./themes/even/assets/sass/_partial/_header.scss
```

```shell
# You can try this: find ~/blog -name "clean.*"
$ find ~/blog -name "*.sh"  
/Users/David/blog/node_modules/jake/bin/bash_completion.sh
/Users/David/blog/backup.sh
/Users/David/blog/clean.sh
```

Pathname expansion doesn't work in double quotes actually, only `$` and back quote retain their special meaning in double quote, asterisk won't, `"*.sh"` is just a pattern for `find`,  learn more: [Shell Script Basic Syntax - David's Blog](https://davidzhu.xyz/post/linux/002-bash-basics/)

## 4. find & xargs

> **xargs** takes input and runs the commands provided as arguments with the data it reads from the input. 

```shell
xargs <options> <command>
```

**e.g., Find out all the `.png` images and archive them using `tar`.**

`tar`: this command creates a tar file called file.tar.gz which is the Archive of `.c` files:

```shell
$ tar cvzf file.tar.gz *.c
```

Learn more aboute `tar`: [tar command](https://www.geeksforgeeks.org/tar-command-linux-examples/). 

```shell
$ find Pictures/tecmint/ -name "*.png" -type f -print0 | xargs -0 tar -cvzf images.tar.gz
```

### 4.1. `find -print0` & `xargs -0`

The `find` command prints results to standard output by default, so the `-print` option is normally not needed, but `-print0` separates the filenames with a 0 (NULL) byte (`\0`) **so that names containing spaces or newlines can be interpreted correctly**.

"`\0`" in the C language stands for the end of a string. However, why do we need "print0"? If we only use the "find" command, it is not necessary. In the command line, whitespace is generally treated as the argument delimiter. For example, there is a file named`my project`,  "xargs" will mistakenly interpret it as two separate arguments: `my` and `project`. This is obviously incorrect. `print0` is often used together with `xargs -0`. By using "xargs -0" or "xargs -null," we inform "xargs" not to consider whitespace or blank space as the argument delimiter but to use the end-of-line character (`\0`) as the delimiter. This ensures that the command runs correctly. 

> `xargs -0`: Input items are terminated by a **null character** instead  of  by  **whitespace**,  and  the  quotes  and backslash  are not special (every character is taken literally).  Disables the end of file string, which is treated like any other argument.  Useful when input  items  might  contain  white  space, quote marks, or backslashes.  The GNU find `-print0` option produces input suitable for this mode.  `xargs: -null`=`xargs: -0`

> `find -print0`: print  the  full file name on the standard output, **followed by a null character (instead of the newline character** that -print uses).  This allows file names that contain newlines  or  other types  of  white space to be correctly interpreted by programs that process the find output. This option corresponds to the -0 option of xargs.

```shell
bash-3.2$ find .
.
./CCABELD.mdx
./CCABELD.css
./vocabulary.css

bash-3.2$ find . -print0
../CCABELD.mdx./CCABELD.css./vocabulary.css
```

References:

- [Dozens of Unix/Linux 'find' command examples | alvinalexander.com](https://alvinalexander.com/unix/edu/examples/find.shtml)
- [linux - What's meaning of -print0 in following command - Stack Overflow](https://stackoverflow.com/questions/56221518/whats-meaning-of-print0-in-following-command)
- [shell - What's the usage of -exec xargs and -print0? - Super User](https://superuser.com/questions/118639/whats-the-usage-of-exec-xargs-and-print0)
- [explainshell.com - find / -type f -print0 | xargs -0 grep heythere](https://explainshell.com/explain?cmd=find+/+-type+f+-print0+%7C+xargs+-0+grep+heythere)
