---
title: C++类学习之构造函数
date: 2023-05-15 18:56:01
categories:
 - C++
 - Basics
tags:
 - C++
---

#### **You have already been using classes without knowing it**

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

----

