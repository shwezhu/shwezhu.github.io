---
title: 正则表达式常用符号
date: 2023-05-01 23:14:22
categories:
 - Regex
tags:
 - Regex
---

注意 Bash一般都是用`“ ”`来quote字符串, 所以为了有时候bash解释错误, 我们写任何Regex表达式的时候都用`‘ ’`进行quote. 

>  You should always [quote](https://www.gnu.org/software/bash/manual/bash.html#Quoting) regular expressions for `grep`--and [single quotes](https://www.gnu.org/software/bash/manual/bash.html#Single-Quotes) are usually best.  来源: https://askubuntu.com/a/957504/1690738

### 1. `?`, `*`, `.`

`?` The question mark indicates zero or one occurrences of the **preceding element**. For example, `colou?r` matches both "color" and "colour". 英文的 "颜色" 一字, 有两种拼法: color 及 colour。 用 regexp 表达, 可以一石两鸟: colou?r 其中的 ? 表示 「前面的字符可有可无」

```shell
$ printf "colour\ncolor\ncolouur\n" | egrep 'colou?r'
colour
color
```

`*` The **asterisk** indicates zero or more occurrences of the preceding element. For example, ab*c matches "ac", "abc", "abbc", "abbbc", and so on.

```shell
$ printf "colour\ncolor\ncolouur\n" | egrep 'colou*r'                          
colour
color
colouur
```

`.`Matches any single character (many applications exclude newlines, and exactly which characters are considered newlines is flavor-, character-encoding-, and platform-specific, but it is safe to assume that the line feed character is included). Within POSIX bracket expressions, the dot character matches a literal dot. For example, `a.c` matches "abc", etc., but `[a.c]` matches only "a", ".", or "c".

```shell
$ printf "colour\ncolor\ncolouur\n" | egrep 'colo.r'                           
colour
$ printf "colour\ncolor\ncolouur\n" | egrep 'colou.r'                          
colouur
```

| `+`  | 代表出現1次以上  |
| ---- | ---------------- |
| `*`  | 代表出現0次以上  |
| `?`  | 代表出現0次或1次 |

### 2. `\d`, `\w`, `\s` 

- `\d` 其实就是 `[0-9]`, "任何一个数字"
- `\D` 其实就是 `[^0-9]`, "任何一个非数字"
- `\w` 其实就是 `[a-zA-Z0-9_]`, "任何一个文数字"
- `\W` 其实就是 `[^a-zA-Z0-9_]`, "任何一个非文数字"
- `\s` 其实就是 `[ \t\n]`, "任何一个空白类字符",  注意`[ \t\n]`是前面故意有个空格, 
- `\S` 其实就是 `[^ \t\n]`, "任何一个非空白类字符"

计数用, 表达 「前面的样版重复出现多少次」 的 quantifier:

- `{5}` 重复 5 次
- `{3,7}` 重复 3 到 7 次
- `{3,}` 重复至少 3 次
- `?` 可有可无。 相当于 `{0,1}`
- `*` 重复出现任意次， 包含 0 次。 相当于 `{0,}`
- `+` 重复出现任意次, 至少 1 次。 相当于 `{1,}`

国内的手机号是11位, 所以要查手机号, 我们可以简单的查找大于等于11位数字的字符串, 下面用7位的举例子, 

```shell
$ printf "12345\n12345678\n123\n234567\n1234567" | egrep '\d{7}'        
12345678
1234567
```

如果想要查找就是7位的数字呢?

```shell
$ printf "12345\n12345678\n123\n234567\n1234567" | ggrep -E '\b[0-9]{7}\b' 
1234567
```

### 3. `\b`

想要找 "port" 与 "ports", 但又不希望找到 "export", "portable", "important" 等等一大堆不相关的单字, 该怎么办? 用 `\bports?\b` 这里的` \b` 表示 boundary, 旁边不可有其他文数字。 所谓文数字, 就是英文本母, 数字, 及底线 "_"。

```shell
$ printf "The port is...\nTo export it...\nThere are many ports...\nportable" | egrep '\bports?\b'
The port is...
There are many ports...
```

### 4. `+`

The pattern `a+` will match one or more occurrences of the letter 'a'. It will match strings like "a", "aa", "aaa", and so on, but it will not match an empty string or a string without any 'a' characters.

```shell
$ printf "aaa\nadd\nsra\ndfgh" | egrep 'a+'
aaa
add
sra
$ printf "aaa\nadd\nsra\ndfgh" | egrep '\ba+\b'
aaa
```

### 5. `$` & `^`

`$` The pattern `hello$` will match the word "hello" only if it appears at the end of a line.

```shell
$ printf "My name is Jack\nHi Jack, this is John\nYou and Jack will come..\ndfHelloJack" | egrep 'Jack$'
My name is Jack
dfHelloJack
```

 `^` Can be used to match the start of a line. For instance, the pattern `^Hello` will match any line that begins with "Hello."

For example, the pattern `^hello$` will only match the exact string "hello" and not "hello world" or "say hello."

```shell
$ printf "Hell 123\n123456\n123\n123 hello" | egrep '^\d+$'        
123456
123
$ printf "Hell 123\n123456\n123\n123 hello" | egrep '\d{3}'        
Hell 123
123456
123
123 hello
$ printf "Hell 123\n123456\n123\n123 hello" | egrep '\b\d{3}\b'    
Hell 123
123
123 hello
```

### 6. e.g., 

在一篇文章当中, 抓出所有 「看起来像是机场代码的字符串」 (例如 TPE 台北, KHH 高雄, LAX 洛杉矶, ... 等等): `\b[A-Z][A-Z][A-Z]\b`。 这里的 `[A-Z]` 是 [ABCDEFGHIJKLMNOPQRSTUVWXYZ] 的简写, 意思是 「任何一个大写字母」

如何在一大片文本, 银行账号, 信用卡号... 当中, 找出看来像是移动电话号码的字符串, 例如 0912345678 或是 0912-345678 或是 0912-345-678 之类的? `09\d\d-?\d\d\d-?\d\d\d` 这里的` \d` 是 [0-9] 的简写, 这又是 [0123456789] 的简写, 意思是 「任何一个数字字符」

想要找一组数字 ip (例如 168.95.1.1 或 163.17.9.176 之类的) 印象中在某个文件内曾看过, 但既不记得精确的数字, 也不记得在那个文件看过, 该怎么办? 可以搜索 `\d+\.\d+\.\d+\.\d+` 抓出所有数字 ip。 这里的` +` 表示 「前面的东西, 可以重复出现 1 次, 2 次, 3 次, ... 任意次」。 因为 . 在 regexp 当中有特殊的意义: 「任何一个字符」; 但在这里我们就是要找 "." 于是在前面加上 \ 以取消它的特殊意义。

可以把一个文本文件里面的所有空白列都删掉吗? 这个 regexp 可以抓出所有空白列: `^\s*$`。 在 regexp 最前面放一个 `^` 表示您只对 「出现在一列之首」 的样版有兴趣; 在 regexp 的最后面放一个 `$` 表示您只对 「出现在一列之尾」 的样版有兴趣。 `\s` 是` [\t\n]` 的简写, 意思是 「任何一个空白字符」 (包含空格, tab, 等等)。 `*` 表示 「前面的东西, 可以重复出现 0 次, 1 次, 2 次, ... 任意次」。 这个样版翻译成中文, 就是 「从头到尾都是一片空白的那种列」。

| `\`     | `\` is used to escape special chars: `\*`matches `*` |
| ------- | ---------------------------------------------------- |
| [abc]   | any of a, b, or c                                    |
| [^abc]  | not a, b, or c                                       |
| [a-g]   | character between a & g                              |
| [^adgf] | 代表不是a, d, g或f的字符                                |

```shell
# 忽略大小写
$ printf "Hello\nHeal\ntold\nhello" | egrep '(?i)LL' 
Hello
hello
# 找出带后缀的文件
$ ls /etc/ | egrep '\.\w+$'  
```

参考:

- [Regexp 是什么东东?](https://www.cyut.edu.tw/~ckhung/b/re/intro.php)

- [Top 15 Commonly Used Regex - Digital Fortress](https://digitalfortress.tech/tips/top-15-commonly-used-regex/)

- [Perl 常用的 regexp 规则列表](https://www.cyut.edu.tw/~ckhung/b/re/rules.php)
