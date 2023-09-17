---
title: os.Getenv() function
date: 2023-08-16 21:28:55
categories:
 - golang
 - practice
tags:
 - golang
---

## 什么是环境变量

开发程序的时候会用到一些密钥, 如 [session key](https://en.wikipedia.org/wiki/Session_key) 用来加密解密一个会话 session message, 再比如拿到 openai 的密钥用来与 gpt 对话, 把这些 key 提交到 GitHub 是很危险的, 所以一般不存储在源码, 而是保存在一个配置文件里或者环境变量中, 常用的方法就是设置一个环境变量, 程序运行的时候获取对应的值, 

可以用 `printenv` 查看电脑的环境变量:

```shell
$ printenv
SHELL=/bin/zsh
HOME=/Users/David
LOGNAME=David
USER=David
PATH=/Users/David/Downloads/Programs/apache-maven-3.9.1/bin:/opt/homebrew/opt/grep/libexec/gnubin:/Users/David/sdk/go1.20.4/bin/:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:
M2_HOME=/Users/David/Downloads/Programs/apache-maven-3.9.1
...
```

从输出可以看到熟悉的 PATH, 最常用的一个环境变量了, 之前错误的认为环境变量只有 PATH, 

## 设置和获取方法

可以在 `.zshrc` 中设置环境变量, 比如新加一个环境变量 `SESSION_KEY`, 

```shell
export SESSION_KEY="schskac#iuhc.nsicauh-nurwtqyup"
```

保存: 输入 `source .zshrc` 使其生效, 

验证: 输入 `printenv`, 查看是否有一项为 `SESSION_KEY=schskac#iuhc.nsicauh-nurwtqyup`

在 go 代码中可使用 ` os.Getenv()` 来获取 env, 

``` go
func main() {
	fmt.Println(os.Getenv("SESSION_KEY"))
}
// 打印: schskac#iuhc.nsicauh-nurwtqyup
```

> ⚠️注意: 若总是打印空值, 则需要重启 IDE, 才能正确打印