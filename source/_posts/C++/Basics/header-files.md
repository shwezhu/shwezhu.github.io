---
title: C++编写头文件内容推荐做法
date: 2023-05-16 22:08:05
categories:
 - C++
 - Basics
tags:
 - C++
---

**“为什么c++要“在头文件中声明，在源文件中定义”？**

在Stackoverflow看到一个[清晰的回答](https://stackoverflow.com/a/1164190/16317008):

You should *declare* the variable in a header file:

```c
extern int x;
```

and then *define* it in *one* C file:

```c
int x;
```

In C, the difference between a definition and a declaration is that the definition reserves space for the variable, whereas the declaration merely introduces the variable into the symbol table (and will cause the linker to go looking for it when it comes to link time). 

另一个[知乎上的回答](https://www.zhihu.com/question/58547318/answer/157444718):

第一，预编译指令`#include`的作用是将所包含的文件全文复制到#include的位置，相当于是个展开为一个文件的宏。

第二，C++允许多次声明，但只允许一次实现。比如`int foo();`就是一次声明，而`int foo(){}`就是一次实现。

如果编译时有多个`.cpp`文件中`#include`了同一个含有函数实现的`.h`，这时候链接器就会在多个目标文件中找到这个函数的实现，而这在C++中是不允许的，此时就会引爆LNK1169错误: 找到一个或多个重定义的符号。

因此为了让函数可以在各个`.cpp`中共享，正确的做法就是在`.h`中只声明函数，并在另【 一个（重点）】`.cpp`中实现这个函数。这样就不会冲突了。
