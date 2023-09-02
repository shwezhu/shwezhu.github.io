---
title: Linux常用命令行
date: 2023-05-03 12:40:56
categories:
 - linux
tags:
 - linux
---

## 1. 常用指令

使用 `--help `, `man your-command` 查看用法

```shell
# 重命名所有文件 大写到小写
$ find . -depth -execdir rename -f 'y/A-Z/a-z/' {} \;
# `-nr`: n显示line number行号, r是recursive, 可以理解为遍历文件文件夹
$ grep -nr "ul$" themes/cactus/source/css
# Mac下查看本地IP
$ ipconfig getifaddr en0 
# 查看自己的Public IP, Mac和Linux皆可
$ curl ifconfig.me && echo
# 赋予可执行权限
$ chmod u+x test.sh
# 追踪域名DNS
$ dig +trace davidzhu.xyz
# 查看IP
$ dig +short davidzhu.xyz
# 查看当前文件夹下的内容size, 其中h: human-readable, *: all, s: 整合列出
$ du  -sh  *
# 查看/下的文件size
$ df -l
# 把指定文件转换为16进制输出
$ xxd a.class
# specify header with curl
$ curl localhost:8080/private -H "x-robot-password: beep-boo" -v
# post request with cookie in curl
$ curl localhost:8080/chat/gpt-3 -d "message=tell me more about him" --cookie "session-id=MTY5Mj..."
```

## 2. wget

```shell
# 下载文件并保存为指定名字
wget -O install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# 不输出任何内容, -q即quiet, 但是依然下载了文件并保存
wget -qO install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# 输出install.sh的内容, 并不会保存文件, Output to stdout
wget -O- install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
```

## 3. sh -c

网络上的脚本下载之后再执行需要下载后再赋予可执行权限, 有点麻烦, 分享一个简单执行脚本的方法, 使用 sh 配合 wget 直接拉去网上脚本内容然后执行, 即此处 sh 执行 wegt 的输出, 

```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

`sh` calls the program `sh` as interpreter and the `-c` flag means execute the following command as interpreted by this program. 

```shell
[root@vultr BashLearning]# which sh
/usr/bin/sh
```

> 注意这样不安全, 因为你要确定网上的脚本没有人任何安全问题, 若执行时需要赋予管理员权限, 就要认真看看脚本内容了, 别把整个磁盘给删了, 

## 4. `>` & `>>`

```shell
echo "Hello, World" > output.txt
```

`>`不是追加而是覆盖, 并且只能重定向标准输出, 注意标准输出即打印到屏幕, 所以并不只是`echo`可以, `cat`, `ls`都可以

```shell
cat a.txt
ls a.txt
```

`>>`是追加,

The `>` sign is used for redirecting the output of a program to something other than stdout (standard output, which is the terminal by default).

The `>>` **appends** to a file or creates the file if it doesn't exist.
The `>` **overwrites** the file if it exists or creates it if it doesn't exist.

## 6. find

可以说这个是最可以帮助我们省事的命令了,

指定查找的文件名以及文件类型:

```shell
# -type f 指定找的是文件, -type d指定找的是文件夹
$ find ~/blog -name clean.sh -type f       
/Users/David/blog/clean.sh
# globs 也可以这么用: "clean.*"
$ find ~/blog -name "*.sh"  
/Users/David/blog/node_modules/jake/bin/bash_completion.sh
/Users/David/blog/backup.sh
/Users/David/blog/clean.sh
```

忽略名字的大小写:

```shell
# case-insensitive searching
find . -iname foo  # find foo, Foo, FOo, FOO, etc.
```

指定查找的目录:

```shell
# search multiple dirs
find /opt /usr /var -name foo.scala -type f
```

## 7. find & xargs

> **xargs** takes input and runs the commands provided as arguments with the data it reads from the input. 

```shell
xargs <options> <command>
```

**e.g., Find out all the `.png` images and archive them using `tar`.**

先看下`tar`怎么用的: This command creates a tar file called file.tar.gz which is the Archive of `.c` files:

```shell
$ tar cvzf file.tar.gz *.c
```

了解更多关于`tar`: [tar command](https://www.geeksforgeeks.org/tar-command-linux-examples/). 

```shell
$ find Pictures/tecmint/ -name "*.png" -type f -print0 | xargs -0 tar -cvzf images.tar.gz
```

还记得在之前的文章中讨论过, bash quote相关的, 比如双引号里`$`会被展开而`*`并不会, 那在这里`*.png`充当的就是bash里面的wildcard而不是正则表达式里的metacharacter, 所以这里有双引号, 应该是find命令本身规定的, 为了防止有的文件名里有空格, 这样就不好确定到底是一个文件还是两个, 所以加个双引号, 然后find收到后, 会再把双引号去掉, 

```
find . -name "*.c" -print
Print out a list of all the files whose names end in .c
```

## 8. `find -print0` & `xargs -0`

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
