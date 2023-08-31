---
title: Bash基础之Quotes与Expansions
date: 2023-05-07 22:50:26
categories:
 - Linux
tags:
 - Linux
 - Bash
---

## 1. 为什么需要Quotes

之所以需要各种quotes, 是因为Metacharacters的存在, 合适的quote可以让Metacharacters失去其特殊意义, 而不用使用`\`来转义, 

举个例子, 你想打印`<-$1500.**>; (update?) [y|n]`这个信息, 可是`<>*;$`在bash中都有特殊意义, 直接打印肯定不行:

```shell
bash-3.2$ echo <-$1500.**>; (update?) [y|n]
bash: syntax error near unexpected token `;'
```

这个时候可以通过使用转义字符来解决:

```shell
bash-3.2$ echo \<-\$1500.\*\*\>\; \(update\?\) \[y\|n\]
<-$1500.**>; (update?) [y|n]
```

这样太费事, 所以就需要quote, **bash规定, `''`里的 metacharacters 都会失去其特殊意义**, 所以直接使用单引号来解决问题:

```shell
bash-3.2$ echo '<-$1500.**>; (update?) [y|n]'
<-$1500.**>; (update?) [y|n]
```

常见的 Metacharacters:

```shell
* ? [ ] ' " \ $ ; & ( ) | ^ < > new-line space tab
```

## 2. Quotes的种类性质

除了单引号, 我们还有双引号, 以及下面这些:

```shell
Back quote`` 
Double quote"" 
Single quote''
```

| Sr.No. |                    Quoting & Description                     |
| :----: | :----------------------------------------------------------: |
|   1    | **Single quote ** All special characters between these quotes lose their special meaning. |
|   2    | **Backslash** `\` Any character immediately following the backslash loses its special meaning. |
|   3    | **Backquote**  Anything in between back quotes would be treated as a command and would be executed. |
|   4    | The characters ` $`  and ` retain their special meaning within **double quotes**. |

### 2.1. Backquotes

解释一下 backquote 的意义, 

```shell
bash-3.2$ cat a.txt 
hello world
bash-3.2$ A=`cat a.txt`; echo "$A"
hello world
```

`A`直接存储了执行`cat a.txt`后的结果, 也就是说back qoute里面的东西会立即被bash当成command来执行:

```shell
bash-3.2$ `a`
bash: a: command not found
```

参考:

- [Unix / Linux - Shell Quoting Mechanisms](https://www.tutorialspoint.com/unix/unix-quoting-mechanisms.htm)
- [bash - Understanding backtick (`) - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/48392/understanding-backtick)
- [Shell Expansions (Bash Reference Manual)](https://www.gnu.org/software/bash/manual/html_node/Shell-Expansions.html#Shell-Expansions)