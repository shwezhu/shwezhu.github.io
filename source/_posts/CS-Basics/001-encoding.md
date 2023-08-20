---
title: 说说编码 - encoding
date: 2023-06-01 22:13:25 
categories:
  - CS Basics
tags:
  - Python
  - Reflection
---

编码问题很常见, 比如要读文件有时候打开是乱码, 有的语言说自己字符串采用unicode表示字符, 可又来utf-8编码, 这都是什么? 

## 1. ASCII vs Unicode

先来看看ASCII, 说到编码最开始肯定就是ASCII了, 电脑只能看懂二进制数, 所以得想办法把人类语言用二进制表示, 这就是编码的目的, 即用电脑磁盘存储数据, 刚开始电脑没有普及, 也就限制在少部分人用, 而他们说英语, 所以他们就做了个表, 规定数字`65`代表字符`A`, `66`代表字符`B`依次类推, 然后一些标点符号比如`#`由数字`35`代表, 具体细节可以查看ASCII表内容, 然后十进制数字转为二进制就可以存储在电脑了, 这些字符刚好128个, 其实也不是刚好他们应该是故意凑成128个的, 也就是刚好可以用1字节的数据来表示, 1字节8位二进制, 即1^8 = 128, 所以ASCII表其实就是一个map, 把字符匹配到一个二进制数(编码 encoding), 或者把一个8位二进制数解释为一个字符(decoding, 解码), 

到后来计算机普及, 全世界又都使用不同语言, 此时就需要电脑表示不同的语言字符, 那ASCII只能表示128个字符, 肯定不够, 所以需要新的用数字代表字符的标准, 不然我们说用`36`代表汉字`牛`, 韩国说用`36`代表字符`&`, 当我输入`牛`, 软件就把`0010 0100`存入磁盘, 然后我把文件传给韩国的朋友, 他们的程序认为`36`即`0010 0100`代表`&`, 那这岂不是无法沟通, 这也是乱码产生的原因: 软件尝试使用与文件编码不同的编码方式来解码文件, 

接着说, 到后来计算机普及, .. 所以我们需要一个标准, 全世界都遵守的那种, 这样我们才能无差错沟通, 我发送一串二进制在我这代表字符`A`, 你的软件收到这串二进制后翻译出的也是字符`A`, 而不是`B`或者`C`, 

这时候Unicode就出来了, 它就是使用`0~0x10FFFF`的数字来表示世界上所有的字符, 如汉字 `在` 的Unicode值是 `0x5728`, 注意`0x`代表值`5728`是十六进制, 又如字符 `A` 的Unicode值是`0x41`, 这里说一下, Unicode表示的字符里英文字符的值和ASCII表是相同的, 

> 注意`0~0x10FFFF`我写成了十六进制的形式, 你也可以转为十进制写上, 或者二进制八进制, 无所谓数字而已

来看看[文档](https://docs.python.org/3/howto/unicode.html)怎么表述的:

The Unicode standard describes how characters are represented by **code points**. A code point value is an integer in the range 0 to 0x10FFFF. In the standard and in this document, a code point is written using the notation `U+265E` to mean the character with value `0x265e` (9,822 in decimal). 

A Unicode string is a sequence of code points, which are numbers from 0 through `0x10FFFF` (1,114,111 decimal). The rules for translating a Unicode string into a sequence of bytes are called a **character encoding**, or just an **encoding**. 

再看Python文档下面这段话, 是不是知道他们在说什么了: 

> Python’s string type uses the Unicode Standard for representing characters, which lets Python programs work with all the characters from the world. [Source](https://docs.python.org/3/howto/unicode.html)

## 2. Unicode vs UTF-8

Unicode 是个表就, 像ASCII表一样, 提供给不同的 encoding scheme 参考, 而 utf-8 encoding 就是把一个字符的Unicode的code points编码成其它二进制数, 

> UTF-8 is an encoding system for Unicode. It can translate any Unicode character to a matching unique binary string, and can also translate the binary string back to a Unicode character. This is the meaning of “UTF”, or “Unicode Transformation Format.”

举个例子, 这是utf-8的编码规则, 

```
Binary format of bytes in sequence
1st Byte    2nd Byte    3rd Byte    4th Byte    Number of Free Bits   Maximum Expressible Unicode Value
0xxxxxxx                                                7             007F hex (127)
110xxxxx    10xxxxxx                                (5+6)=11          07FF hex (2047)
1110xxxx    10xxxxxx    10xxxxxx                  (4+6+6)=16          FFFF hex (65535)
11110xxx    10xxxxxx    10xxxxxx    10xxxxxx    (3+6+6+6)=21          10FFFF hex (1,114,111)
```

汉字`汉`的Unicode值是两字节即 `6C49`, 二进制为: `0110 1100 0100 1001` 根据上标经过utf-8编码变成 `11100110 10110001 10001001`, 成了三字节, 汉字在 utf-8 编码里占3字节 (gbk编码里, 一个汉字占2字节), 注意, 最终写入文件的是其三字节的 utf-8 encoding `11100110 10110001 10001001`, 而不是其Unicode `0110 1100 0100 1001` , 可以使用 `xxd` 查看,

```shell
$ xxd text.md
00000000: e6b1 89  
$ file text.md
text.md: Unicode text, UTF-8 text
```

`xxd`可以以16进制格式输出文件内容, `e6b1 89` 的二进制是`11100110 10110001 10001001`, 所以你知道了utf-8是怎么根据Unicode把code points编码成另一个二进制, 也知道了编码的意义, 体现在了文件的实际内容里, 解码 decoding 就是 encoding 的反过程了,

> 注意: 有时候也说ASCII编码, 其实意思就是告诉你你看到字符`A`, 那他的数值就是`0x41`, 不要太纠结到底ASCII是编码方式, 还是其他, 弄清楚本质就好了, 

> 注意: encoding=编码, scheme 不知道咋翻译比较准确, 所以以后都说 encoding scheme

> 注意: “编码就是把字符对应的数值以一定的规则编码成二进制” 是我自己对utf-8的理解, 普遍的理解是map, 即把字符`A`对应到数字`0x41`的过程就是编码, encoding, 我在这这么说是为了区分Unicode在编码中的作用角色, 

读到[一篇文章](http://www.imkevinyang.com/2010/06/%E5%85%B3%E4%BA%8E%E5%AD%97%E7%AC%A6%E7%BC%96%E7%A0%81%EF%BC%8C%E4%BD%A0%E6%89%80%E9%9C%80%E8%A6%81%E7%9F%A5%E9%81%93%E7%9A%84.html)总结的很好 分享片段:

在Unicode出现之前，所有的字符集都是和具体编码方案绑定在一起的，都是直接将字符和最终字节流绑定死了，例如ASCII编码系统规定使用7比特来编码ASCII字符集；GB2312以及GBK字符集，限定了使用最多2个字节来编码所有字符，并且规定了字节序。这样的编码系统通常用简单的查表，也就是通过代码页就可以直接将字符映射为存储设备上的字节流了。例如下面这个例子：

![a](a.png)

这种方式的缺点在于，字符和字节流之间耦合得太紧密了，从而限定了字符集的扩展能力。假设以后火星人入住地球了，要往现有字符集中加入火星文就变得很难甚至不可能了，而且很容易破坏现有的编码规则。

因此Unicode在设计上考虑到了这一点，**将字符集和字符编码方案分离开**:

![b](b.png)

也就是说，**虽然每个字符在Unicode字符集中都能找到唯一确定的编号（字符码，又称Unicode码），但是决定最终字节流的却是具体的字符编码**。例如同样是对Unicode字符“A”进行编码，UTF-8字符编码得到的字节流是0x41，而UTF-16（大端模式）得到的是0x00 0x41。

> 这段总结的很好, 可以看出和上面我们分析的是一样的, 所谓英雄所见略同(真不要脸, hhh

### 3. 常见 Unicode 编码方式

任何能够将Unicode字符映射为字节流的编码都属于Unicode编码。中国的GB18030编码，覆盖了Unicode所有的字符，因此也算是一种Unicode编码。只不过他的编码方式并不像UTF-8或者UTF-16一样，将Unicode字符的编号通过一定的规则进行转换，而只能通过查表的手段进行编码。

至于utf-8, utf-16就不同说了, 看名字都知道属于Unicode编码, 

**Unicode编码和以前的字符集编码区别:**

早期字符编码、字符集和代码页等概念都是表达同一个意思。例如GB2312字符集、GB2312编码，936代码页，实际上说的是同个东西。但是对于Unicode则不同，Unicode字符集只是定义了字符的集合和唯一编号，Unicode编码，则是对UTF-8、UCS-2/UTF-16等具体编码方案的统称而已，并不是具体的编码方案。所以当需要用到字符编码的时候，你可以写gb2312，codepage936，utf-8，utf-16，但请不要写unicode（看过别人在网页的meta标签里头写charset=unicode，有感而发）。

### 4. 修改文件编码方式


最后需要注意, 如果你直接把utf-8编码的文件转为其它编码比如gbk, 那转换之后你的文件肯定是乱码, 因为在你写入一些内容比如`汉`到你的文本文件, 此时这个文件的编码方式为`utf-8`, 那你保存此文件后, 此文件的内容已经是经过utf-8编码的unicode code, 即:`11100110 10110001 10001001`也就是`e6b1 89`就是上面的汉字`汉`, 此时你硬要把文件的编码方式改为gbk, 而gbk采用完全与utf-8不同的编码方式(2字节1个字符),  此时当其他软件是图打开你这个文本文件时, 就会查看你文件的编码信息, 他们看到是gbk编码, 那就会把`11100110 10110001 10001001`即`e6b1 89`中的前两个字节解释为一个字符, 然后他们查找`11100110 10110001`即`e6b1`, 那肯定匹配不到`汉`, 就会把`11100110 10110001`解释为不可打印字符或者英文或者其它语言,,,

但也可以实现不同编码的安全转换, 一个思路是, 我们知道这个文件是用的utf-8编码, 所以我们先把该文件的字符转换为unicode code, 然后再利用gbk进行编码这些unicode code, 具体做法如下:

```python
import sys

file_path = 'article_1.md'
with open(file_path, encoding="utf-8") as f:
    utf_8_str = f.read()
    if utf_8_str is None:
        print("Contents of Text cannot be None!")
        sys.exit()
    else:
        gbk_str = utf_8_str.encode("gbk")

with open("article_2.md", "wb") as f:
    f.write(gbk_str)
    f.encoding = "gbk"
```

注意, 上面代码`utf_8_str = f.read()`, 此时`utf_8_str`已经是unicode code, 第二我们写如文件时, 要以二进制写入, 不然你写入的就是长得像16进制数的字符串, 而不是真正的写入二进制数据, 

### 5. Bytes in Python

电脑只能存储二进制数, 而python也有个bytes类用来代表二进制字符串, 

所以这里有两个概念, string和bytes string, 他们是不同的类, 拥有的函数不同, 对于一个普通的string, 它有个函数叫`encode()`, 该函数的返回类型是`bytes`, 如下:

```python
bytes_str = 'AB'.encode('ascii')
print(type(bytes_str))
print(bytes_str.hex())

<class 'bytes'>
4142
```

然后对于bytes类, 有个函数叫`decode()`, 该函数的返回类型为`str`:

```python
bytes_str = 'AB'.encode('ascii')
a = bytes_str.decode('ascii')
print(type(a))

<class 'str'>
```

所以在往一个文件写入的时候想好是直接写入二进制还是写入编码后的字符串, 即**注意文件的打开方式**:

```python
# 文件的内容: 汉在
# 文件的编码方式: gbk, 每个汉字2字节
with open("article_2.md", "rb") as f:
    bin_str = f.read()
    print(type(bin_str))
    print(bin_str)

<class 'bytes'>
b'\xba\xba\xd4\xda'


with open("article_2.md", "r", encoding='gbk') as f:
    text_str = f.read()
    print(type(text_str))
    print(text_str)
    
<class 'str'>
汉在
```

因为`article_2.md`采用gbk编码方式, 而python默认是utf-8解码, 所以这里需要指定编码方式, 否则肯定乱码或者出错, 

写入也要**注意打开文件的方式**:

```python
bin_str = 'AB'.encode('utf-8')
with open("text.md", "wb") as f:
    f.write(bin_str)
    f.encoding = "utf-8"
```

查看文件的内容:

```shell
$ xxd text.md
00000000: 4142                                     AB
```

如果我们不指定以二进制写入, 则会报错:

```python
bin_str = 'AB'.encode('utf-8')
with open("text.md", "w") as f:
    f.write(bin_str)
    f.encoding = "utf-8"

# error: TypeError: write() argument must be str, not bytes
```

注意, python挺好有报错, 但是有的语言比如C的接口, 就不会提醒, 你写入什么就是什么, 如果你打开方式不是二进制, 然后写入了二进制的字符串, 那结果就是, 这些二进制的字符串被当作普通字符串写入文件...

参考:

- [Unicode HOWTO — Python 3.11.3 documentation](https://docs.python.org/3/howto/unicode.html)
- [python - What is the difference between a string and a byte string? - Stack Overflow](https://stackoverflow.com/questions/6224052/what-is-the-difference-between-a-string-and-a-byte-string)
- [关于字符编码，你所需要知道的（ASCII,Unicode,Utf-8,GB2312…)](http://www.imkevinyang.com/2010/06/%E5%85%B3%E4%BA%8E%E5%AD%97%E7%AC%A6%E7%BC%96%E7%A0%81%EF%BC%8C%E4%BD%A0%E6%89%80%E9%9C%80%E8%A6%81%E7%9F%A5%E9%81%93%E7%9A%84.html)
