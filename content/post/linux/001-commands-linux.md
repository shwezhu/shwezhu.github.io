---
title: Common Commands in Linux
date: 2023-05-03 12:40:56
categories:
 - linux
tags:
 - linux
---

## 1. Some Commands

You can use `your-command --help `, `man your-command`, `tldr you-command` to check how to use the command. 

```shell
# Rename all file in current directory, from cupper-case to lower-case
$ find . -depth -execdir rename -f 'y/A-Z/a-z/' {} \;
# n: line number, r: recursive
$ grep -nr "ul$" themes/cactus/source/css
# check your ip on Mac
$ ipconfig getifaddr en0 
# check public IP, Mac and Linux
$ curl ifconfig.me && echo
# make a file executable
$ chmod u+x test.sh
# check DNS of domain
$ dig +trace davidzhu.xyz
# check IP of domian
$ dig +short davidzhu.xyz
# check files size under current folder, h: human-readable, *: all, s: sort
$ du  -sh  *
# output file in hexadecimal
$ xxd a.class
# specify header with curl
$ curl localhost:8080/private -H "x-robot-password: beep-boo" -v
# post request with cookie in curl
$ curl localhost:8080/chat/gpt-3 -d "message=tell me more about him" --cookie "session-id=MTY5Mj..."
```

## 2. wget

```shell
# download the file and save it into install.sh
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

## 3. `>` & `>>`

```shell
echo "Hello, World" > output.txt
```

The `>` sign is used for redirecting the output of a program to something other than stdout (standard output, which is the terminal by default).

The `>>` **appends** to a file or creates the file if it doesn't exist.
The `>` **overwrites** the file if it exists or creates it if it doesn't exist.

## 4. find & grep

### 4.1. find

```shell
# -type f is for file, -type d is for directory, -iname is case-insensitive
$ find . -name "*header*" -type f
./content/post/c++/basics/header-files.md
./themes/even/layouts/partials/header.html
./themes/even/assets/sass/_partial/_post/_header.scss
./themes/even/assets/sass/_partial/_header.scss
```

The command below execute in the same folder as above, but output nothing:

```shell
$ find . -name "header" -type f 
```

Which indicates that pathname expansion works in double quotes, learn more: [Shell Expansion - David's Blog](https://davidzhu.xyz/post/linux/003-shell-expansion/)

```shell
# You can try this: find ~/blog -name "clean.*"
$ find ~/blog -name "*.sh"  
/Users/David/blog/node_modules/jake/bin/bash_completion.sh
/Users/David/blog/backup.sh
/Users/David/blog/clean.sh
```

### 4.2. grep

```shell
# `-nr`: 'n' for line number, 'r' for recursive
$ grep -nr "ul$" themes/cactus/source/css
```

> **NOTE:** The difference between `find` and `grep` is that find will search the file recursively, if you want `grep` search files recursively you have to use `-r` option.

## 5. find & xargs

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

还记得在之前的文章中讨论过, bash quote相关的, 比如双引号里`$`会被展开而`*`并不会, 那在这里`*.png`充当的就是bash里面的wildcard而不是正则表达式里的metacharacter, 所以这里有双引号, 应该是find命令本身规定的, 为了防止有的文件名里有空格, 这样就不好确定到底是一个文件还是两个, 所以加个双引号, 然后find收到后, 会再把双引号去掉, 

```
find . -name "*.c" -print
Print out a list of all the files whose names end in .c
```

## 6. `find -print0` & `xargs -0`

看find命令的时候总是看到`-print0`这个option, 查查资料学习一下: 

> The `find` command prints results to standard output by default, so the `-print` option is normally not needed, but `-print0` separates the filenames with a 0 (NULL) byte **so that names containing spaces or newlines can be interpreted correctly**.

上面这段话提到的`0(null)` byte是一个escape sequence characters, 即`\0`在c语言里也是代表字符串的结束, 即在每个文件名后面都加个结束符, 为什么要加呢? 如果我们单用`find`指令, 确实没什么必要, 但有时候我们把`find`的输出作为另一个指令比如`xargs`的输入的时候, 就有必要了. 这是因为命令行指令一般把空格whitespace/blankspace作为参数分隔符, 而有一些文件名里含有空格, 所以, 你想`find`输出的一个文件名是`my project`, 那`xargs`就是会把`my project`看成俩参数即`my`, `project`, 这肯定就错了, 

所以在每个文件名的尾巴那加个结束符, 然后再通过`xargs -0`或者`xargs -null`告诉`xargs`不要把whitespace/blankspace作为参数分隔符, 把结束符即`\0`作为分隔符, 这样就可以保证正确运行了, 了解关于escape character可以到:[Escape Sequence Characters](https://davidzhu.xyz/2023/05/22/Linux/Escape-Characters/). 

> `xargs: -null`: Input items are terminated by a **null character** instead  of  by  **whitespace**,  and  the  quotes  and backslash  are not special (every character is taken literally).  Disables the end of file string, which is treated like any other argument.  Useful when input  items  might  contain  white  space, quote marks, or backslashes.  The GNU find `-print0` option produces input suitable for this mode.  `xargs: -null`=`xargs: -0`

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

参考:

- [Dozens of Unix/Linux 'find' command examples | alvinalexander.com](https://alvinalexander.com/unix/edu/examples/find.shtml)
- [linux - What's meaning of -print0 in following command - Stack Overflow](https://stackoverflow.com/questions/56221518/whats-meaning-of-print0-in-following-command)
- [shell - What's the usage of -exec xargs and -print0? - Super User](https://superuser.com/questions/118639/whats-the-usage-of-exec-xargs-and-print0)
- [explainshell.com - find / -type f -print0 | xargs -0 grep heythere](https://explainshell.com/explain?cmd=find+/+-type+f+-print0+%7C+xargs+-0+grep+heythere)
