---
title: C++里自定义类型和基础类型应采取何种初始化方式
date: 2023-05-15 15:23:00
categories:
 - C++
 - Basics
tags:
 - C++
---

看段代码, 

```c++
#include <iostream>

class Fraction {
private:
    int m_numerator {};
    int m_denominator {};

public:
    Fraction() { // default constructor
        m_numerator = 0;
        m_denominator = 1;
    }

    int getNumerator() { return m_numerator; }
    int getDenominator() { return m_denominator; }
};

int main() {
    Fraction frac{}; // calls Fraction() default constructor
    std::cout << frac.getNumerator() << '/' << frac.getDenominator() << '\n';

    return 0;
}
```

## Initialization of Fundamental Types

上面的这个代码也可以当作参考, 比如上面的`int m_numerator {};`, 并不是`int m_numerator;`我们在上一篇文章即[C++变量初始化Assignment & Initialization](https://davidzhu.xyz/2023/05/14/C++/Basics/Basics-Initialization/)中介绍了, 前者是value-initialization, 后者是default initialization, 其实还有一个叫zero-initilization即`int m_numerator {0};`关于什么时候应该用哪个, 我们在上篇文章也有说到, **注意我们此时讨论的是针对fundamental types**即`int`, `char`, `double`这种类型, 而不是自定义类型,  

When a variable is list initialized using empty braces, value initialization takes place. In most cases, value initialization will initialize the variable to zero:

```cpp
int width {};   // value initialization
int width {0}; // zero initialization
```

**Q: When should I initialize with `{0}` vs `{}`?**

Use an explicit initialization value if you’re actually using that value.

```cpp
int x { 0 };    // explicit initialization to value 0
std::cout << x; // we're using that zero value
```

Use value initialization if the value is temporary and will be replaced.

```cpp
int x {};      // value initialization
std::cin >> x; // we're immediately replacing that value
```

所以上面的代码里:

```c++
class Fraction {
private:
    int m_numerator {};
    int m_denominator {};
}
```

这段使用value-initialization而不是default initialization或zero-initilization, 就很好理解, 使用default initialization会可能会导致变量未定义(至于为什么可能会导致为定义行为接下面会讨论), 然后一般在构造函数中我们会给予成员变量新的值, 所以采用value initialization.

## Initialization of User-Defined Types

讨论完了fundamental types的初始化, 我们再来讨论自定义类型的初始化, In the above program, we initialized our class object using value-initialization:

```cpp
Fraction frac {}; // Value initialization using empty set of braces
```

We can also initialize class objects using default-initialization:

```cpp
Fraction frac; // Default-initialization, calls default constructor
```

For the most part, **default- and value-initialization of a class object** results in the same outcome: the default constructor is called.

Many programmers favor default-initialization over value-initialization for class objects. This is because when using value-initialization, the compiler may zero-initialize the class members before calling the default constructor in certain cases, which is slightly inefficient (C++ programmers don’t like paying for features they’re not using).

However, favoring default-initialization also comes with a downside: you have to know whether a type will initialize itself, i.e. it is a class-type and all members have an initializer, or there is a default-constructor that initializes all member variables. If you see a defined variable without an initializer, you have to think about whether that’s a mistake or not (depending on what type the object is).

比如下面的代码中` Fraction frac_1;`就会造成undefined behavior, 但` Fraction frac_2 {};`:

```c++
#include <iostream>

class Fraction {
private:
    // Removed initializers
    int m_numerator;
    int m_denominator;

public:
    // Removed default-constructor
    int getNumerator() const { return m_numerator; }
    int getDenominator() const { return m_denominator; }
};

int main() {
    Fraction frac_1; // undefined behavior
    Fraction frac_2 {}; // correct
    std::cout << frac_1.getNumerator() << '/' << frac_1.getDenominator() << '\n';
    std::cout << frac_2.getNumerator() << '/' << frac_2.getDenominator() << '\n';
    return 0;
}

打印:
1/15725056
0/0
```

另外对于default initialization, 要看是针对fundamental types还是针对自定义类型, 比如 `int a;`, 在局部scope的时候会导致未定义行为, 其实对于fundamental types, 这种并不能算是default initialization, 对于自定义类型才是, 比如上面的`Fraction frac;`会自动调用默认构造函数, 

Favoring value initialization for class objects is simple, consistent, and can help you catch errors, particularly while you are learning.

----

做个总结:

- 对于自定义类型: Favor value-initialization over default-initialization for class objects.  
- 对于fundamental types, 使用value-initialization或zero-initilization

综上, 尽量采用List Initialization方式来初始化任何变量, 而不是使用容易导致未定义行为的default initialization来进行初始化, 什么你问List Initialization是啥?

```c++
// List initialization methods (C++11) (preferred)
int d{7};       // initializer in braces (direct list initialization)
int e = {8};   // initializer in braces after equals sign (copy list initialization)
int f {};     // initializer is empty braces (value initialization)
```

参考:

- [13.5 — Constructors – Learn C++](https://www.learncpp.com/cpp-tutorial/constructors/)
