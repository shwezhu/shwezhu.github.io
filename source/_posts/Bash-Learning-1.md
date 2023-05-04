---
title: Bash Shell脚本学习
date: 2023-05-03 17:43:59
categories:
 - Linux
 - Script
tags:
 - Linux
 - Script
---

### 1. Bash是什么

>  **Bash is a Unix shell and command language** written by Brian Fox for the GNU Project as a free software replacement for the Bourne shell. [Wikipedia](https://en.wikipedia.org/wiki/Bash_(Unix_shell))

> A **Unix shell** is both a **command interpreter** and a **programming language**. As a command interpreter, the shell provides the user interface to the rich set of GNU utilities. The programming language features allow these utilities to be combined.  [What is a shell? (Bash Reference Manual)](https://www.gnu.org/software/bash/manual/html_node/What-is-a-shell_003f.html)

得到如下结论, 

- Bash=Unix Shell

- Unix Shell 有两个身份**command interpreter**和**programming language**

### 2. 指定翻译器位置

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

### 3. 基础语法之变量(Bash Variables Are Untyped)

Bash does not type variables like C and related languages, defining them as integers, floating points, or string types. In Bash, all variables are strings. A string that is an integer can be used in integer arithmetic, which is the only type of math that Bash is capable of doing. If more complex math is required, the [**bc** command](https://www.gnu.org/software/bc/manual/html_mono/bc.html) can be used in CLI programs and scripts.

Variables are assigned values and can be used to refer to those values in CLI programs and scripts. The value of a variable is set using its name but not preceded by a `$` sign. The assignment `VAR=10` sets the value of the variable VAR to 10. To print the value of the variable, you can use the statement `echo $VAR`. 

> *Note: The syntax of variable assignment is very strict. There must be no spaces on either side of the equal `=` sign in the assignment statement.*

As mentioned, Bash can perform integer arithmetic calculations, which is useful for calculating a reference to the location of an element in an array or doing simple math problems. It is not suitable for scientific computing or anything that requires decimals, such as financial calculations. There are much better tools for those types of calculations.

```shell
# 注意, "Result = $((Var1*Var2))"有空格是因为这不是复制, 是打印字符串, 赋值不能有空格
$ Var1="7" ; Var2="9" ; echo "Result = $((Var1*Var2))"
Result = 63
```

What happens when you perform a math operation that results in a floating-point number?

```shell
$ Var1="7" ; Var2="9" ; echo "Result = $((Var1/Var2))" 
Result = 0
$ Var1="7" ; Var2="9" ; echo "Result = $((Var2/Var1))"
Result = 1
```

**The result is the nearest integer**. Notice that the calculation was performed as part of the `echo` statement. The math is performed before the enclosing echo command due to the Bash order of precedence. For details see the Bash man page and search "precedence."

上面已经说过了, 在这在重复一下, Unlike many other programming languages, Bash does not segregate its variables by "type." Essentially, *Bash variables are character strings*, but, depending on context, Bash permits arithmetic operations and comparisons on variables. The determining factor is whether the value of a variable contains only digits. [Bash Variables Are Untyped](https://tldp.org/LDP/abs/html/untyped.html)

本节参考:

- [How to program with Bash: Syntax and tools | Opensource.com](https://opensource.com/article/19/10/programming-bash-syntax-tools)

### 4. 基础语法之声明变量

接下来我们了解一下声明变量, 平时也很少用到, 就介绍几个, 感觉在bash里的变量更像个reference,

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
echo "Number = $number"     # Number = 3
number=three
echo "Number = $number"     # Number = 0
# Tries to evaluate the string "three" as an integer.
```

注意, Bash把String的值看作为0, 即一个数加一个字符串, 等于其本身. 

本节参考: 

- [Typing variables: declare or typeset](https://tldp.org/LDP/abs/html/declareref.html)

### 5. 基础语法之Control Operators

一共三个: `;`, `&&`, `||`

前两个对比一下就知道了, `;`即使是前面的指令错了, 后面的也会执行, 而`&&`则会直接中断执行:

```shell
$ cd fd.sh; ls
cd: not a directory: fd.sh
economic fd.sh    test.sh

$ cd fd.sh && ls
cd: not a directory: fd.sh
```

来看看`||`, `||` is the OR operator. It executes the command on the right only if the command on the left returned an error. [source](https://unix.stackexchange.com/a/190546/571057)

```shell
$ cd fd.sh || ls
cd: not a directory: fd.sh
economic fd.sh    test.sh
```

本节参考:

- [How to program with Bash: Syntax and tools | Opensource.com](https://opensource.com/article/19/10/programming-bash-syntax-tools)

### 6. 其它

Bash解释器的行为和平时常见的编程语言也不同, 所以你也不能凭这着直觉写, 最好参考官方文档, 看下面的赋值例子, 

```shell
#!/usr/bin/bash
a=3; b=5; c=a+b; echo $c
a+b 
```

怎么才能打印8呢, 下面三种都可以打印8, 

```shell
$ a=3; b=5; c=$((a+b)); echo $c     
$ a=3; b=5; echo $((a+b))
$ a=3; b=5; let c="a+b"; echo $c
```

> 注意我用的是bash, 如果你使用的是zsh, 可能会有不同行为, 比如在我机器上(使用的zsh)执行`a=3; b=5; c="a+b"; echo $c`, `a=3; b=5; c=a+b; echo $c`的结果都是8, 切换很简单, 你直接输入`bash`+回车,就切换到bash了.  

查了一下, 发现了原来这是有语法规则的, 

- `$((...))` is called [arithmetic expansion](http://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_06_04), which is typical of the `bash` and `ksh` shells. This allows doing simple *integer* arithmetic, no floating point stuff though. The result of the expression replaces the expression, as in `echo $((1+1))` would become `echo 2`
- `((...))` is referred to as [arithmetic evaluation](https://wiki-dev.bash-hackers.org/syntax/ccmd/arithmetic_eval) and can be used as part of `if ((...)); then` or `while ((...)) ; do` statements. Arithmetic expansion `$((..))` substitutes the output of the operation and can be used to assign variables as in `i=$((i+1))` but cannot be used in conditional statements.
- `let` is a `bash` and `ksh` keyword which allows for variable creation with simple arithmetic evaluation. If you try to assign a string there like `let a="hello world"` you'll get a syntax error.

来源: 

- [Difference between let, expr](https://askubuntu.com/a/939299/1690738)

### 7. 总结

- Bash的变量是没类型的, 或者说都是字符串, 但当字符串都是数字的时候, 可以执行简单的算术运算
- 赋值如果涉及计算, 使用类似`let c="a+b"`或者`$((...))`算数符号
- 赋值的时候`=`两侧不可以有空格
- 切换bash和zsh, 直接输入对应名字然后回车
- 查看对应shell版本, 切换到对应的shell然后执行 `echo "$ZSH_VERSION"`, `echo "$BASH_VERSION"`
- 查看所有的shells`cat /etc/shells`
- 声明一个变量为只读`declare -r var1=1`

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

