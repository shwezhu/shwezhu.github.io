---
title: C++头文件内容相关规则
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

---

关于类定义:

Member functions defined inside the class definition are considered implicitly inline. 

Member functions defined outside the class definition are treated like normal functions, and are subject to the one definition per program part of the one-definition rule. Therefore, those functions should be defined in a code file, not inside the header. One exception is for template functions, which are also implicitly inline.

- For classes used in only one file that aren’t generally reusable, define them directly in the single `.cpp` file they’re used in.
- For classes used in multiple files, or intended for general reuse, define them in a `.h` file that has the same name as the class.
- Trivial member functions (trivial constructors or destructors, access functions, etc…) can be defined inside the class.
- Non-trivial member functions should be defined in a `.cpp` file that has the same name as the class.

**Default parameters** for member functions should be declared in the class definition (in the header file), where they can be seen by whomever #includes the header.

拓展阅读:

Separating the class definition and class implementation is very common for libraries that you can use to extend your program. Throughout your programs, you’ve #included headers that belong to the standard library, such as iostream, string, vector, array, and other. Notice that you haven’t needed to add iostream.cpp, string.cpp, vector.cpp, or array.cpp into your projects. Your program needs the declarations from the header files in order for the compiler to validate you’re writing programs that are syntactically correct. However, the implementations for the classes that belong to the C++ standard library are contained in a precompiled file that is linked in at the link stage. You never see the code.

Outside of some open source software (where both .h and .cpp files are provided), most 3rd party libraries provide only header files, along with a precompiled library file. There are several reasons for this: 1) It’s faster to link a precompiled library than to recompile it every time you need it, 2) a single copy of a precompiled library can be shared by many applications, whereas compiled code gets compiled into every executable that uses it (inflating file sizes), and 3) intellectual property reasons (you don’t want people stealing your code).

Having your own files separated into declaration (header) and implementation (code file) is not only good form, it also makes creating your own custom libraries easier. Creating your own libraries is beyond the scope of these tutorials, but separating your declaration and implementation is a prerequisite to doing so.

原文: [13.11 — Class code and header files – Learn C++](https://www.learncpp.com/cpp-tutorial/class-code-and-header-files/)