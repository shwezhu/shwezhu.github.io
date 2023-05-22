---
title: Escape Sequence Characters
date: 2023-05-22 14:33:11
categories:
 - Linux
tags:
 - Linux
---

We cannot print a newline directly in any programming language(C, C++, Java, and C#) by just hitting the **enter key**. So here backslash `\` is called “**escape character**“.

Use **escape characters** and some other characters combination, we use to print some impossible characters. In c, all escape sequences consist of two or more characters, it is a combination of **backslash** `\` and **characters**.

```shell
code: │   name:                │Hex to integer:
──────│────────────────────────│──────────────
\n    │  # Newline             │  Hex 0A = 10
' '   │  # Space/Blank         │  Hex 20 = 32
\0    │  # Null(Termination of the string)   │  Hex 0 = 0
\t    │  # Horizontal Tab      │  Hex 09 = 9
\v    │  # Vertical Tab        │  Hex 0B = 11
\b    │  # Backspace           │  Hex 08 = 8
\r    │  # Carriage Return     │  Hex 0D = 13
\f    │  # Form feed           │  Hex 0C = 12
\a    │  # Audible Alert (bell)│  Hex 07 = 7
\\    │  # Backslash           │  Hex 5C = 92
\?    │  # Question mark       │  Hex 3F = 63
\'    │  # Single quote        │  Hex 27 = 39
\"    │  # Double quote        │  Hex 22 = 34
```

这里注意, 空格也就是Blank Space就是`' '`, 不像其它的如换行符`\n`, 或结束符`\0`是这种表示, 

![a](a.png)

参考:

- https://stackoverflow.com/a/52861631/16317008
- [File:ASCII-Table-wide.svg - Wikimedia Commons](https://commons.wikimedia.org/wiki/File:ASCII-Table-wide.svg)