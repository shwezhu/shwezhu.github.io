---
title: Linux常用命令行
date: 2023-05-03 12:40:56
categories:
 - Linux
 - Basics
tags:
 - Linux
---

平时常用的命令总是会忘, 一些参数查起来也挺费事时间, 记录一下~ 😁

简单的命令会直接记录使用方法, 另外一个指令的 `--help`参数基本都是help页面, 或者使用`man your-command`

```shell
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
# Mac下查看本地IP
$ ipconfig getifaddr en0 
# 查看自己的Public IP, Mac和Linux皆可
$ curl ifconfig.me && echo
# -c 表示只编译不链接
$ gcc –c SimpleSection.c
```

### 1. wget

```shell
# 下载文件并保存为指定名字
wget -O install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# 不输出任何内容, -q即quiet, 但是依然下载了文件并保存
wget -qO install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# 输出install.sh的内容, 并不会保存文件, Output to stdout
wget -O- install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
```

### 2. sh

输出`install.sh`的内容不保存, 就像pipe传给sh, 由sh执行输出的东西, 这样很省事, 不用下载了, 再赋予可执行权限, 然后执行再删除, 就很麻烦, 注意这种并不是sh去执行下载的install.sh文件, 而是执行wegt输出的内容(即install.sh的内容), 所以这种并不用赋予可执行权限. 

```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

`sh` calls the program `sh` as interpreter and the `-c` flag means execute the following command as interpreted by this program. 

```shell
[root@vultr BashLearning]# which sh
/usr/bin/sh
```

### 3. `>` & `>>`

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

### 4. 批量查找文件内容

```shell
grep -nr "ul$" themes/cactus/source/css
```

`-nr`: n显示line number行号，r是recursive，可以理解为遍历文件文件夹

### 5. grep

**5.1. 匹配单个文件:**

```shell
$ grep "string" /path/to/filename
```

**5.2. 匹配多个文件 `-r`:**

```shell
# Search for a string in your current directory and all other subdirectories
$ grep -r "hello" *  
a.txt:hello world
sub/c.txt:hello, this is...
sub/b.txt:hello, this is...
# 如果好奇通配符*代表什么意思, 可以使用echo查看一下展开式, 如下:
$ echo grep -r "a.txt" *        
grep -r a.txt a.txt b.txt sub
# 假如sub是个文件夹
$ grep -r "hello" sub                 
sub/c.txt:hello, this is...
sub/b.txt:hello, this is...
```

这里想说一下`*`这个符号, 在Regex里它的意义是匹配它前面的那个字符出现0或多次, 如

```shell
$ printf "colour\ncolor\ncolouur\n" | egrep 'colou*r'                          
colour
color
colouur
```

但`*`对于shell也有特殊意义, 那就是通配符Wildcard, 看到[一个回答](https://askubuntu.com/a/957504/1690738)总结的很好:

> `*` has a special meaning both as a shell [globbing](http://mywiki.wooledge.org/glob) character ("wildcard") and as a regular expression [metacharacter](http://www.regular-expressions.info/characters.html). You must take both into account, though if you [quote](http://mywiki.wooledge.org/Quotes) your regular expression then you can prevent the shell from treating it specially and ensure that it passes it unchanged to [`grep`](http://manpages.ubuntu.com/manpages/xenial/en/man1/grep.1.html). 

**5.3. 匹配时忽略大小写 `-i`:**

```shell
grep -i "linux" welcome.txt
```

**5.4. 输出对应行数 `-n`:**

```shell
$ grep -n "Linux" welcome.txt
```

**5.5. 匹配固定的某个单词而不是相似单词 `-w`:**

```shell
grep -w "opensource" welcome.txt
```

**5.6. 只显示符合pattern的文件名 `-l`:**

```shell
$ grep -l "hello" *.txt
a.txt
b.txt
```

参考:

- [Grep Command in Linux/UNIX | DigitalOcean](https://www.digitalocean.com/community/tutorials/grep-command-in-linux-unix)

### 6. find

可以说这个是最可以帮助我们省事的命令了,

指定查找的文件名以及文件类型:

```shell
# -type f 指定找的是文件, -type d指定找的是文件夹
$ find ~/blog -name clean.sh -type f       
/Users/David/blog/clean.sh
# Wildcard, 也可以这么用: "clean.*"
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

与grep搭配:

```shell
# find files by text in the file (find + grep)
find . -type f -name "*.java" -exec grep -l StringBuffer {} \;    # find StringBuffer in all *.java files
find . -type f -name "*.java" -exec grep -il string {} \;         # ignore case with -i option
find . -type f -name "*.gz" -exec zgrep 'GET /foo' {} \;          # search for a string in gzip'd files
```

参考:

- [Dozens of Unix/Linux 'find' command examples | alvinalexander.com](https://alvinalexander.com/unix/edu/examples/find.shtml)
