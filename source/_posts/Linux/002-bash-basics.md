---
title: Bash Shell Basic Syntax
date: 2023-05-03 17:43:59
categories:
 - Linux
tags:
 - Linux
 - Bash
---

## 1. Bash

**Bash is a Unix shell and command language** written by Brian Fox for the GNU Project as a free software replacement for the Bourne shell. [Wikipedia](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) 

A **Unix shell** is both a **command interpreter** and a **programming language**. As a command interpreter, the shell provides the user interface to the rich set of GNU utilities. The programming language features allow these utilities to be combined.  [What is a shell? (Bash Reference Manual)](https://www.gnu.org/software/bash/manual/html_node/What-is-a-shell_003f.html) 

得到如下结论, 

- Bash=Unix Shell

- Unix Shell 有两个身份**command interpreter**和**programming language**

## 2. Specify Interpreter

首先在第一行指定你的Bash interpreter的位置, 你可以使用`which bash`来查看:

```shell
$ which bash
/usr/bin/bash
```

然后添加到你的脚本`a.sh`第一行, 如下:

```shell
#!/usr/bin/bash
echo "hello world"
```

运行前赋予可执行权限`chmod u+x a.sh`, 

注意bash interpreter的位置不要写错(其实你可以省略不写, 这个时候会调用你默认的bash来执行sh文件):

```shell
$ cat a.sh 
#!/bin/ash
echo "hello world"

$ ./a.sh 
zsh: ./a.sh: bad interpreter: /bin/ash: no such file or directory
```

## 3. Bash Variables Are Untyped

Bash does not type variables like C and related languages, defining them as integers, floating points, or string types. In Bash, all variables are strings. A string that is an integer can be used in integer arithmetic, which is the only type of math that Bash is capable of doing. 

The assignment `VAR=10` sets the value of the variable `VAR` to 10. To print the value of the variable, you can use the statement `echo $VAR`. 

> *Note: The syntax of variable assignment is very strict. There must be no spaces on either side of the equal `=` sign in the assignment statement.*

It is not suitable for scientific computing or anything that requires decimals, such as financial calculations. 

## 4. Declear Variable

-r `readonly`, This is the rough equivalent of the **C** *const* type qualifier. An attempt to change the value of a *readonly* variable fails with an error message.

 ```shell
 declare -r var1=1
 echo "var1 = $var1"   # var1 = 1
 (( var1++ ))          # x.sh: line 4: var1: readonly variable
 ```

-i `*integer*`

```shell
declare -i number
# The script will treat subsequent occurrences of "number" as an integer.		
number=3
echo "Number = $number"     # Print: Number = 3
```

## 5. Control Operators

- `;`: 前面指令错了, 后面的也会执行
- `&&`: 前面指令错了, `&&`则会直接中断执行
-  `||`: It executes the command on the right only if the command on the left returned an error.

```shell
$ cd fd.sh; ls
cd: not a directory: fd.sh
economic fd.sh    test.sh

$ cd fd.sh && ls
cd: not a directory: fd.sh

$ cd fd.sh || ls
cd: not a directory: fd.sh
economic fd.sh    test.sh
```

## 6. `let`关键字以及`$((...))`

Bash 解释器的行为与常见的编程语言也不同, 所以不能凭这着直觉写:

```shell
#!/usr/bin/bash
$ a=3; b=5; c=a+b; echo $c
# Print: a+b 
```

打印正确结果方式:

```shell
$ a=3; b=5; c=$((a+b)); echo $c     
$ a=3; b=5; echo $((a+b))
$ a=3; b=5; let c="a+b"; echo $c
```

- `$((...))` is called [arithmetic expansion](http://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_06_04), which is typical of the `bash` and `ksh` shells. This allows doing simple *integer* arithmetic, no floating point stuff though. The result of the expression replaces the expression, as in `echo $((1+1))` would become `echo 2`
- `((...))` is referred to as [arithmetic evaluation](https://wiki-dev.bash-hackers.org/syntax/ccmd/arithmetic_eval) and can be used as part of `if ((...)); then` or `while ((...)) ; do` statements. Arithmetic expansion `$((..))` substitutes the output of the operation and can be used to assign variables as in `i=$((i+1))` but cannot be used in conditional statements.
- `let` is a `bash` and `ksh` keyword which allows for variable creation with simple arithmetic evaluation. If you try to assign a string there like `let a="hello world"` you'll get a syntax error.

## 7. Conclusion

- There must be no spaces on either side of the equal `=` sign in the assignment statement.
- 如果赋值涉及计算, 使用类似`let c="a+b"`或者`$((...))`算数符号: `a=3; b=5; c=$((a+b)); echo $c `
- *Bash variables are character strings*, but, depending on context, Bash permits arithmetic operations and comparisons on variables. 
  - The determining factor is whether the value of a variable contains only digits.
- Three control operators: `;`, `||`, `&&`
- 切换 bash 和 zsh, 直接输入对应名字+回车, 设置默认shell, `chsh -s /bin/zsh`
- 查看对应shell版本, 切换到对应的shell然后执行 `echo "$ZSH_VERSION"`, `echo "$BASH_VERSION"`
- 查看所有的 shells `cat /etc/shells`

```shell
$ cat /etc/shells      
# List of acceptable shells for chpass(1).
# Ftpd will not allow users to connect who are not using
# one of these shells.
/bin/bash
/bin/csh
/bin/dash
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh
```



