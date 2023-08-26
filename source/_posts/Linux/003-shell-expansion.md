---
title: Shell Expansion
date: 2023-08-26 11:30:20
categories:
 - Linux
tags:
 - Linux
 - Bash
---

## 1. Shell Expansion

When the shell receives a command, either from the user typing at the keyboard, or from a shell script, it breaks it up into words. After this happens, the shell performs seven operations on the words, which can change how they are interpreted. There are seven operations are collectively known as 'shell expansion'. 

The seven operations that the shell performs are:

1. Brace Expansion - expanding values between braces, such as `file{1..3}` into `file1 file2 file3`
2. Tilde Expansion - expanding the `~` tilde symbol for the home directory into the path to the home directory, such as `~/effective-shell` into `/home/dwmkerr/effective-shell`
3. Parameter Expansion - expanding terms that start with a `$` symbol into parameter values, such as `$HOME` into the value of the variable named `HOME`
4. Command Substitution - evaluation of the contents of `$(command)` sequences, which are used to run commands and return the results to the shell command line
5. Arithmetic Expansion - evaluation of the contents of `$((expression))` sequences, which are used to perform basic mathematical operations
6. Word Splitting - once all of the previous operations are run, the shell splits the command up into 'words', which are the units of text that you can run loops over
7. Pathname Expansion - the shell expands wildcards and special characters in pathnames, such as `*.txt` into the set of files that are matched by the sequence

**Brace Expansion**

```shell
mkdir /tmp/{one,two,three}
# The line above is expanded to:
mdkir /tmp/one /tmp/two /tmp/three

touch file{1..5}.txt
# The line above is expanded to:
touch file1.txt file2.txt file3.txt file4.txt file5.txt

for x in {0..10..2}; do print $x; done
# The line above is expanded to:
for x in 0 2 4 6 8 10; do print $x; done
```

**Parameter Expansion**

```shell
fruit=apples
echo "I like $fruit"
# The line above is expanded to:
echo "I like apples"
```

When using parameter expansion it is generally preferable to surround the name of the parameter with braces - this allows you to tell the shell unambiguously what the name of the parameter is. For example:

```shell
echo "My backup folder is: ${HOME}backup"
# The line above is expanded to:
echo "My backup folder is: /home/dwmkerrbackup"
```

应该尽量使用`"My backup folder is: ${HOME}backup"`, 而不是`"I like $fruit"`

**Tilde Expansion**

```shell
cd ~/effective-shell
# The line above is expanded to:
cd $HOME/effective-shell
```

这里在插一段, 如果我们想看实际的expansion, 就像上面的例子那样, 我们怎么看呢? 通过`echo`就可以看到了, 

```shell
$ ls
one.txt
two.txt
three.dat
$ echo rm *.txt
rm one.txt two.txt
```

假如刚开始我不知道`*`代表什么, 那我现在就可以这样查看展开后的指令:

```shell
$ tree -L 2
.
├── a.txt
├── b.txt
└── sub
    └── a.txt
$ echo grep -r "a.txt" *        
grep -r a.txt a.txt b.txt sub
```

## 2. Wildcard Pattern

A string is a ***wildcard pattern*** if it contains one of the characters `?`, `*`, or `[`,  Globbing is the operation that expands a wildcard pattern into the list of **pathnames** matching the pattern.  Matching is defined by: 

- A `?` (not between brackets) matches any single character. 
- A `*` (not between brackets) matches any string, including the empty string.

在上面已经提到,在 shell 中 `*` 会被 interpreter 展开, 前提是它不能在双引号里, 否则无特殊意义, 

```shell
# Expands to: tar xvf file1.tar file2.tar file42.tar ...
tar xvf *.tar
# 删除目录下所有以.txt结尾的文件
rm *.txt
# 使用quote就不会展开
$ rm "*.txt"
rm: *.txt: No such file or directory
```

> Bash expands globs which appear **unquoted** in commands, by matching filenames relative to the current directory. 

Note that wildcard patterns are not regular expressions, although they are a bit similar.  First of all, **they match filenames, rather than text**, and secondly, the conventions are not the same: for example, in a regular expression '*' means zero or more copies of the preceding thing.

`*` 在 Regex 里的意义是匹配它前面的字符出现 0 或多次:

```shell
$ printf "colour\ncolor\ncolouur\n" | egrep 'colou*r'                          
colour
color
colouur
```

Wildcard Pattern 例子, 使用 grep 查找文件内容:

```shell
# Search for a string in your current directory and all other subdirectories
$ grep -r ‘hello’ *  
a.txt:hello world
sub/c.txt:hello, this is...
sub/b.txt:hello, this is...
# 如果好奇通配符*代表什么意思, 可以使用echo查看一下展开式, 如下:
$ echo grep -r ‘hello’ *
```

## Conclusion

- Bash一般用 `“ ”` quote 字符串, 为了防止 bash 解释错误, 写 Regex 表达式用 `‘ ’` 来 quote, 
  - You should always [quote](https://www.gnu.org/software/bash/manual/bash.html#Quoting) regular expressions for `grep`--and [single quotes](https://www.gnu.org/software/bash/manual/bash.html#Single-Quotes) are usually best.  [source](https://askubuntu.com/a/957504/1690738) 
- 单引号中, 所有特殊字符都失去其本身意义
- Bash expands globs which appear **unquoted** in commands. `rm "*.txt"` won't expand. 
- 应该尽量使用`"My backup folder is: ${HOME}backup"`, 而不是 `"I like $fruit"`

参考:

- [glob(7) - Linux manual page](https://man7.org/linux/man-pages/man7/glob.7.html)

- [Understanding Shell Expansion | Effective Shell](https://effective-shell.com/part-6-advanced-techniques/understanding-shell-expansion/)
