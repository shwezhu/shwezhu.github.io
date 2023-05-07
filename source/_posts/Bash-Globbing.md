---
title: Shell Globbing之具有双重身份的‘*’
date: 2023-05-07 11:30:20
categories:
 - Linux
 - Bash
tags:
 - Linux
 - Bash
---

### 具有双重身份的`*`

这里想说一下`*`这个符号, 在Regex里它的意义是匹配它前面的那个字符出现0或多次, 如

```shell
$ printf "colour\ncolor\ncolouur\n" | egrep 'colou*r'                          
colour
color
colouur
```

但`*`对于shell也有特殊意义, 那就是通配符Wildcard, 看到[一个回答](https://askubuntu.com/a/957504/1690738)总结的很好:

> `*` has a special meaning both as a shell [globbing](http://mywiki.wooledge.org/glob) character ("wildcard") and as a regular expression [metacharacter](http://www.regular-expressions.info/characters.html). You must take both into account, though if you [quote](http://mywiki.wooledge.org/Quotes) your regular expression then you can prevent the shell from treating it specially and ensure that it passes it unchanged to [`grep`](http://manpages.ubuntu.com/manpages/xenial/en/man1/grep.1.html). 

上面说的[shell globbing](http://mywiki.wooledge.org/glob)也就是wildcard是什么呢, 我们看看:

> "Glob" is the common name for a set of Bash features that match or expand specific types of patterns. Some synonyms for globbing (depending on the context in which it appears) are [pattern matching](http://tiswww.case.edu/php/chet/bash/bashref.html#Pattern-Matching), pattern expansion, filename expansion, and so on. A glob may look like `*.txt` and, when used to match filenames, is sometimes called a "wildcard". **All globs are implicitly anchored at both start and end.** Most characters in a glob are treated literally, but **a `*` matches 0 or more characters**, a `?` matches precisely one character, and `[...]` matches any single character in a specified set. 

这里补充一下, Regex里有个概念叫anchors, 就是类似`$`, `^`的符号, 就是用来指定匹配以某个字符(串)开头结尾的string, 感兴趣可以谷歌一下, 好了刚上面说的的shell globbing的一些特性规则, 我们来看看具体例子: 

| `*`        | Matches any string, of any length                            |
| ---------- | ------------------------------------------------------------ |
| `foo*`     | Matches any string beginning with `foo`, 这也就是上面所说的 Globs are implicitly anchored... |
| `*x*`      | Matches any string containing an `x` (beginning, middle or end) |
| `*.tar.gz` | Matches any string ending with `.tar.gz`                     |
| `*.[ch]`   | Matches any string ending with `.c` or `.h`                  |
| `foo?`     | Matches `foot` or `foo$` but not `fools`                     |

Bash expands globs which appear **unquoted** in commands, by matching filenames relative to the current directory. The **expansion** of the glob results in 1 or more words (0 or more, if certain options are set), and those words (filenames) are used in the command. For example:

```shell
# Expands to: tar xvf file1.tar file2.tar file42.tar ...
tar xvf *.tar
# 删除目录下所有以.txt结尾的文件
rm *.txt
## 删除类似filecjbd.txt, fileabssc.txt的文件
$ rm file*.txt
# 使用quote 就不会展开
$ rm "*.txt"
rm: *.txt: No such file or directory
```

### Shell Expansion

上面总是看到expansion这个词, 好像也不难理解, 就是像c里面的预处理, 把我们的通配符给替换展开成真实的文件, 但总感觉少了点什么, 我们来综合看一下这个概念吧, 

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

所以使用参数时为了避免引起歧义, 应该尽量使用`"My backup folder is: ${HOME}backup"`, 而不是`"I like $fruit"`

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

这个时候如果你不确定展开后的指令是啥 ,你就可以先看看, 比如这个指令`grep -r "a.txt" *`, 假如刚开始我不知道`*`代表啥意思, 那我现在就可以这样查看, 

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

可以看到, `*`代表长度大于1的所有字符串, 在这也就是代表当前目录下所有的文件和文件夹. 

### 总结

- `*`有两个身份, 一个是正则表达式里的metacharacter, 表示单个字符出现0到多次, 另一个身份是shell里的wildcard, 表示任何1或多个字符. 

- 使用参数时为了避免引起歧义, 应该尽量使用`"My backup folder is: ${HOME}backup"`, 而不是`"I like $fruit"`

- 查看展开式 `echo rm *.txt`

参考:

- [glob - Greg's Wiki](http://mywiki.wooledge.org/glob)

- [Understanding Shell Expansion | Effective Shell](https://effective-shell.com/part-6-advanced-techniques/understanding-shell-expansion/)
