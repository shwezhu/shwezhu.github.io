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

#### 1. wget

```shell
# 下载文件并保存为指定名字
wget -O install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# 不输出任何内容, -q即quiet, 但是依然下载了文件并保存
wget -qO install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# 输出install.sh的内容, 并不会保存文件, Output to stdout
wget -O- install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
```

#### 2. sh

输出`install.sh`的内容不保存, 就像pipe传给sh, 由sh执行输出的东西, 这样很省事, 不用下载了, 再赋予可执行权限, 然后执行再删除, 就很麻烦, 注意这种并不是sh去执行下载的install.sh文件, 而是执行wegt输出的内容(即install.sh的内容), 所以这种并不用赋予可执行权限. 

```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

`sh` calls the program `sh` as interpreter and the `-c` flag means execute the following command as interpreted by this program. 

```shell
[root@vultr BashLearning]# which sh
/usr/bin/sh
```

#### 3. `>` & `>>`

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

### 5. find command

可以说这个是最可以帮助我们省事的命令了,

