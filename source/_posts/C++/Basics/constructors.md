---
title: C++类学习之构造函数
date: 2023-05-15 18:56:01
categories:
 - C++
 - Basics
tags:
 - C++
---

## Member initialization list

A **member initialization list** can also be used to initialize members that are classes: 

```cpp
#include <iostream>

class A {
public:
    explicit A(int x = 0) { std::cout << "A " << x << '\n'; }
};

class B {
private:
    A m_a{};
public:
    // call A(int) constructor to initialize member m_a
    explicit B(int y) : m_a{ y - 1 } {
        std::cout << "B " << y << '\n';
    }
};

int main() {
    B b{ 5 };
    return 0;
}

A 4
B 5
```

When variable b is constructed, the `B(int)` constructor is called with value 5. **Before the body of the constructor executes, `m_a` is initialized,** calling the `A(int)` constructor with value 4. This prints “A 4”. Then control returns back to the B constructor, and the body of the B constructor executes, printing “B 5”. 

这里注意, 如果你不使用member initializer lists对变量进行初始化的话, 那你在构造函数体内只能对他们进行赋值, 而不是初始化, 这就意味着, 人家的构造函数已经调用了, 你又进行了一次赋值, 这就涉及到了拷贝, 析构. 什么? 你不相信, 要验证一下?

```c++
// Cat.h
#pragma once

#include <string>
#include <iostream>
#include <utility>

class Cat {
private:
    int age{};
    std::string name{};
public:
    Cat() : age(0){
        std::cout << "Cat: Default constructor is called" << std::endl;
    };
    Cat(int age, std::string name) : age(age), name(std::move(name)) {
        std::cout << "Cat: Constructor with two parameter is called" << std::endl;
    }

    Cat(const Cat& other) {
        std::cout << "Cat: Copy Constructor called" << std::endl;
    }

    Cat& operator=(const Cat& other) {
        std::cout << "Cat: Assignment Operator called" << std::endl;
        return *this;
    }

    ~Cat() {
        std::cout << "Cat: Destructor with parameter is called" << std::endl;
    }
};
```

```c++
// main.cpp
#include <iostream>
#include <utility>
#include "Cat.h"

class B {
private:
    Cat cat_2{};
public:
    // call A(int) constructor to initialize member m_a
    explicit B(int age, const std::string& name){
        cat_2 = Cat(age, name);
        std::cout << "B: Default constructor is called" << std::endl;
    }
};

int main() {
    B b{ 1, "kitty" };
    return 0;
}

Cat: Default constructor is called
Cat: Constructor with two parameter is called
Cat: Assignment Operator called
Cat: Destructor with parameter is called
B: Default constructor is called
Cat: Destructor with parameter is called
```

如果改成下面这样, 其它不变:

```cpp
explicit B(int age, const std::string& name) : cat{age, name}{
        std::cout << "B: Default constructor is called" << std::endl;
}

Cat: Constructor with two parameter is called
B: Default constructor is called
Cat: Destructor with parameter is called
```

> **Member initializer lists allow us to initialize our members rather than assign values to them.** This is the only way to initialize members that require values upon initialization, such as const or reference members, and it can be more performant than assigning values in the body of the constructor. Member initializer lists work both with fundamental types and members that are classes themselves. 

## Initializer list order

Perhaps surprisingly, variables in the initializer list are not initialized in the order that they are specified in the initializer list. Instead, **they are initialized in the order in which they are declared in the class**.

For best results, the following recommendations should be observed:

1. Don’t initialize member variables in such a way that they are dependent upon other member variables being initialized first (in other words, ensure your member variables will properly initialize even if the initialization ordering is different).
2. Initialize variables in the initializer list in the same order in which they are declared in your class. This isn’t strictly required so long as the prior recommendation has been followed, but your compiler may give you a warning if you don’t do so and you have all warnings turned on.

## Constructor notes

Many new programmers are confused about whether constructors create the objects or not. They do not -- the compiler sets up the memory allocation for the object prior to the constructor call.

Constructors actually serve two purposes.

1. Constructors determine who is allowed to create an object of the class type. That is, an object of a class can only be created if a matching constructor can be found.
2. Constructors can be used to initialize objects. Whether the constructor actually does an initialization is up to the programmer. It’s syntactically valid to have a constructor that does no initialization at all (the constructor still serves the purpose of allowing the object to be created, as per the above).

However, much like it is a best practice to initialize all local variables, it’s also a best practice to initialize all member variables on creation of the object. This can be done via a constructor or via non-static member initialization.

---

**Use the `default` keyword to tell the compiler to create a default constructor:**

```c++
class Date {
private:
    int m_year{ 1900 };
    int m_month{ 1 };
    int m_day{ 1 };
public:
    // Tell the compiler to create a default constructor, even if
    // there are other user-provided constructors.
    Date() = default;

    Date(int year, int month, int day) { // normal non-default constructor
        m_year = year;
        m_month = month;
        m_day = day;
    }
};

int main() {
    Date date{}; // date is initialized to Jan 1st, 1900
    Date today{ 2020, 10, 14 }; // today is initialized to Oct 14th, 2020
}
```

Using `= default` is longer than writing a constructor with an empty body, but expresses better what your intentions are (To create a default constructor), and it’s safer, because **it can zero-initialize members even if they have not been initialized at their declaration**. 

这句话是什么意思呢?  就是上面你把`int m_year{ 1900 };`写成`int m_year`, 若你使用value initialization`Date date{};`,  `m_year`会被初始化为0. 

> If you have constructors in your `class` and need a default constructor that does nothing (e.g. because all your members are initialized using non-static member initialization), use `= default`.

---

**You have already been using classes without knowing it**

It turns out that the C++ standard library is full of classes that have been created for your benefit. std::string, std::vector, and std::array are all class types! So when you create an object of any of these types, you’re instantiating a class object. And when you call a function using these objects, you’re calling a member function.

```c++
#include <string>
#include <array>
...
int main() {
    std::string s { "Hello, world!" }; // instantiate a string class object
    std::array<int, 3> a { 1, 2, 3 }; // instantiate an array class object
    std::vector<double> v { 1.1, 2.2, 3.3 }; // instantiate a vector class object
    std::cout << "length: " << s.length() << '\n'; // call a member function
}
```

> Use the struct keyword for data-only structures. Use the class keyword for objects that have both data and functions.

原文:

[13.2 — Classes and class members – Learn C++](https://www.learncpp.com/cpp-tutorial/classes-and-class-members/)

参考:

- [13.5 — Constructors – Learn C++](https://www.learncpp.com/cpp-tutorial/constructors/)