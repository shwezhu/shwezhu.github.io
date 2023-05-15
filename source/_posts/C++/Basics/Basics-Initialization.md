---
title: C++变量初始化Assignment & Initialization
date: 2023-05-14 18:29:32
categories:
 - C++
 - Basics
tags:
 - C++
---

感觉这句话说得很好, 道明了变量的本质:

> In the previous lesson ([1.3 -- Introduction to objects and variables](https://www.learncpp.com/cpp-tutorial/introduction-to-objects-and-variables/)), we covered how to define a variable that we can use to store values. In this lesson, we’ll explore how to actually put values into variables and use those values.

然后看看define, assignment和initialization的区别,

## 1. Define

这是define:

```c++
int x;    // define an integer variable named x
int y, z; // define two integer variables, named y and z
```

## 2. Variable Assignment

然后来看看assignment, after a variable has been defined, you can give it a value (in a separate statement) using the *= operator*. This process is called **copy assignment** (or just **assignment**) for short:

```c++
int width; // define an integer variable named width
width = 5; // copy assignment of value 5 into variable width
// variable width now has value 5
```

Copy assignment is named such because it copies the value on the right-hand side of the *= operator* to the variable on the left-hand side of the operator. The `=` operator is called the **assignment operator**. Here’s an example where we use assignment twice:

```c++
int main() {
	int width;
	width = 5; // copy assignment of value 5 into variable width
	// variable width now has value 5
	width = 7; // change value stored in variable width to 7
	// variable width now has value 7
	return 0;
}
```

When we assign value 7 to variable *width*, the value 5 that was there previously is **overwritten**. Normal variables can only hold one value at a time. 注意这里的overwritten, 在Java里, 对于primitive类型的数据来说赋值的时候也是这种overwritten,  但是Java里Reference的赋值行为只是改变指向, 且所有的对象(不论是否local)都是存在Heap的, 而只有primitive和reference存储在stack, 而c/c++里则不是, 具体Java行为请参考这篇文章(链接失效可在站内搜索文章名): [Java中变量(Variables)和引用(References)的区别 | 橘猫小八的鱼](https://davidzhu.xyz/2023/05/14/Java/Basics/Variables-vs-References/). 哦, 注意在Java里一个字符串常量就是个String对象, 而不是单纯的“值”, 

## 3. Initialization

接下来看看initialization, 

One downside of assignment is that it requires at least two statements: one to define the variable, and one to assign the value. These two steps can be combined. When a variable is defined, you can also provide an initial value for the variable at the same time. This is called **initialization**. The value used to initialize a variable is called an **initializer**.

Initialization in C++ is surprisingly complex, so we’ll present a simplified view here.

There are 6 basic ways to initialize variables in C++:

```c++
int a;         // no initializer (default initialization)
int b = 5;    // initializer after equals sign (copy initialization)
int c(6);    // initializer in parenthesis (direct initialization)

// List initialization methods (C++11) (preferred)
int d{7};       // initializer in braces (direct list initialization)
int e = {8};   // initializer in braces after equals sign (copy list initialization)
int f {};     // initializer is empty braces (value initialization)
```

### 3.1. Default Initialization

When no initialization value is provided (such as for variable *a* above), this is called **default initialization**. In most cases, default initialization leaves a variable with an indeterminate value.

```c++
int a;         // no initializer (default initialization)
```

We’ll discuss this case further in lesson ([1.6 -- Uninitialized variables and undefined behavior](https://www.learncpp.com/cpp-tutorial/uninitialized-variables-and-undefined-behavior/)).

### 3.2. Copy Initialization

When an initializer is provided after an equals sign, this is called **copy initialization**. This form of initialization was inherited from C. 

```c++
int width = 5; // copy initialization of value 5 into variable width
```

Much like copy assignment, this copies the value on the right-hand side of the equals into the variable being created on the left-hand side. In the above snippet, variable `width` will be initialized with value `5`.

Copy initialization had fallen out of favor in modern C++ due to being less efficient than other forms of initialization for some complex types. However, C++17 remedied much of these issues, and copy initialization is now finding some new advocates. You will also find it used in older code (especially code ported from C), or by developers who simply think it looks better.

> Copy initialization is also used whenever values are implicitly copied or converted, such as when passing arguments to a function by value, returning from a function by value, or catching exceptions by value.

### 3.3. List Initialization

The modern way to initialize objects in C++ is to use a form of initialization that makes use of curly braces: **list initialization** (also called **uniform initialization** or **brace initialization**). List initialization comes in three forms:

```c++
int width {5};    // direct list initialization of value 5 into variable width
int height = {6}; // copy list initialization of value 6 into variable height
int depth {};     // value initialization (see next section)
```

List initialization has an added benefit: it disallows “narrowing conversions”. This means that if you try to brace initialize a variable using a value that the variable can not safely hold, the compiler will produce an error. For example:

```cpp
int width { 4.5 }; // error: a number with a fractional value can't fit into an int
```

### 3.4. Value Initialization and Zero Initialization

When a variable is list initialized using empty braces, **value initialization** takes place. In most cases, **value initialization** will initialize the variable to zero (or empty, if that’s more appropriate for a given type). In such cases where zeroing occurs, this is called **zero initialization**.

```cpp
int width {}; // value initialization / zero initialization to value 0
```

**Q: When should I initialize with { 0 } vs {}?**

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

## 4. **Initializing Multiple Variables**

In the last section, we noted that it is possible to define multiple variables *of the same type* in a single statement by separating the names with a comma:

```c++
int a, b; // no initializer (default initialization)
```

We also noted that best practice is to avoid this syntax altogether. However, since you may encounter other code that uses this style, it’s still useful to talk a little bit more about it, if for no other reason than to reinforce some of the reasons you should be avoiding it.

You can initialize multiple variables defined on the same line:

```c++
int a = 5, b = 6;          // copy initialization
int c( 7 ), d( 8 );        // direct initialization
int e { 9 }, f { 10 };     // direct brace initialization (preferred)
int g = { 9 }, h = { 10 }; // copy brace initialization
int i {}, j {};            // value initialization
```

## 5. Summary

- Default initialization, Copy initialization, List Initialization
- Copy initialization is also used whenever values are implicitly copied or converted, such as when passing arguments to a function by value, returning from a function by value, or catching exceptions by value.
- 注意Copy initialization的行为, 初始化就使用List Initialization

参考:

[1.4 — Variable assignment and initialization – Learn C++](https://www.learncpp.com/cpp-tutorial/variable-assignment-and-initialization/)
