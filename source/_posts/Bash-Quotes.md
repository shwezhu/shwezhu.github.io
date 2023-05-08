---
title: Bash基础之Quotes与Expansions
date: 2023-05-07 22:50:26
categories:
 - Linux
 - Bash
tags:
 - Linux
 - Bash
---

先来看看Metacharacters都有什么:

```shell
* ? [ ] ' " \ $ ; & ( ) | ^ < > new-line space tab
```

## 为什么需要各种Quotes

之所以需要各种quotes, 是因为Metacharacters的存在, 合适的quote可以让Metacharacters失去其特殊意义, 而不用使用`\`来转义, 以及可以允许bash进行正确的expansion, 不然它怎么知道什么时候展开什么时候不展开呢? 

举个例子, 你想打印`<-$1500.**>; (update?) [y|n]`这个信息, 可是`<>*;$`在bash中都有特殊意义, 直接打印如下面这样肯定不行:

```shell
bash-3.2$ echo <-$1500.**>; (update?) [y|n]
bash: syntax error near unexpected token `;'
```

这个时候可以通过使用转义字符来解决, 如下:

```shell
bash-3.2$ echo \<-\$1500.\*\*\>\; \(update\?\) \[y\|n\]
<-$1500.**>; (update?) [y|n]
```

但这样也太费事了吧, 所以这个时候我们就需要quote了, **bash规定, 单引号`''`里面的metacharacters都会失去其特殊意义**, 所以我们就可以直接使用单引号来解决问题:

```shell
bash-3.2$ echo '<-$1500.**>; (update?) [y|n]'
<-$1500.**>; (update?) [y|n]
```

这就是quote的作用, 

## Quotes的种类以及性质

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
|   3    | **Back quote**  Anything in between back quotes would be treated as a command and would be executed. |

### Double Quote的性质

Single Quote的性质很简单就是所有特殊字符都是失去其意义, 没什么好说的了, 双引号的作用类似单引号, 只不过它是让部分特殊字符失去意义, 保留部分特殊字符本身意义, 

```txt
The characters $ and ` retain their special meaning within double quotes.
```

但这样也会有缺点, 就是你每次想打印`$`和`back quote`的时候都得使用转义字符, 好处就是使用`$`的时候可以进行expansion, 如下:

```shell
bash-3.2$ VAR=ZARA; echo "$VAR owes <-\$1500.**>; [ as of (`date +%m/%d`) ]"
ZARA owes <-$1500.**>; [ as of (05/07) ]
```

单引号就不能实现上面的效果, 前面我们已经举过例子, 

Double quotes take away the special meaning of all characters except the following −

- **$** for parameter substitution
- Backquotes for command substitution
- **\$** to enable literal dollar signs
- **\`** to enable literal backquotes
- **\"** to enable embedded double quotes
- **\\** to enable embedded backslashes
- All other **\** characters are literal (not special)

### Backquotes的性质

> Putting any Shell command in between **backquotes** executes the command.

上面说的是什么意思呢, 看下面这个例子, 

```shell
bash-3.2$ cat a.txt 
hello world
bash-3.2$ A=`cat a.txt`; echo "$A"
hello world
```

即, `A`直接存储了执行`cat a.txt`后的结果, 也就是说back qoute里面的东西会立即被bash当成command来执行. 假如我们输入如下, 那`a`就会被当成command来执行:

```shell
bash-3.2$ `a`
bash: a: command not found
```

## Shell Expansions

Expansion is performed on the command line after it has been split into `token`s. There are seven kinds of expansion performed:

- brace expansion
- tilde expansion
- parameter and variable expansion
- command substitution
- arithmetic expansion
- word splitting
- filename expansion

了解更多: [Shell Expansions (Bash Reference Manual)](https://www.gnu.org/software/bash/manual/html_node/Shell-Expansions.html#Shell-Expansions)

参考:

- [Unix / Linux - Shell Quoting Mechanisms](https://www.tutorialspoint.com/unix/unix-quoting-mechanisms.htm)
- [bash - Understanding backtick (`) - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/48392/understanding-backtick)
- [Shell Expansions (Bash Reference Manual)](https://www.gnu.org/software/bash/manual/html_node/Shell-Expansions.html#Shell-Expansions)