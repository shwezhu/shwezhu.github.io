---
title: C++匿名对象
date: 2023-05-16 23:2:06
categories:
 - C++
 - Basics
tags:
 - C++
---

看到一个概念, 还挺有意思, 可以帮助理解函数的传参返回值行为, 记录一下, 

In certain cases, we need a variable only temporarily. For example, consider the following situation:

```c++
#include <iostream>

int add(int x, int y) {
    int sum{ x + y };
    return sum;
}

int main() {
    std::cout << add(5, 3) << '\n';
    return 0;
}
```

Here is the `add()` function rewritten using an **anonymous object**:

```c++
#include <iostream>

int add(int x, int y) {
    // an anonymous object is created to hold and return the result of x + y
    return x + y; 
}

int main() {
    std::cout << add(5, 3) << '\n';
    return 0;
}
```

When the expression `x + y` is evaluated, the result is placed in an anonymous object. A copy of the anonymous object is then returned to the caller by value, and the anonymous object is destroyed. 

This works not only with return values, but also with function parameters. For example, instead of this:

```c++
#include <iostream>

void printValue(int value) {
    std::cout << value;
}

int main() {
    int sum{ 5 + 3 };
    printValue(sum);
    return 0;
}
```

We can write this:

```c++
#include <iostream>

void printValue(int value) {
    std::cout << value;
}

int main() {
    printValue(5 + 3);
    return 0;
}
```

In this case, the expression `5 + 3` is evaluated to produce the result 8, which is placed in an anonymous object. A copy of this anonymous object is then passed to the `printValue()` function, (which prints the value 8) and then is destroyed.

Note how much cleaner this keeps our code -- we don’t have to litter the code with temporary variables that are only used once.

----

In C++, anonymous objects are primarily used either to pass or return values without having to create lots of temporary variables to do so. Memory allocated dynamically is also done so anonymously (which is why its address must be assigned to a pointer, otherwise we’d have no way to refer to it).

It is also worth noting that because anonymous objects have expression scope, they can only be used once (unless bound to a constant l-value reference, which will extend the lifetime of the temporary object to match the lifetime of the reference). If you need to reference a value in multiple expressions, you should use a named variable instead.

原文:

- [13.16 — Anonymous objects – Learn C++](https://www.learncpp.com/cpp-tutorial/anonymous-objects/)