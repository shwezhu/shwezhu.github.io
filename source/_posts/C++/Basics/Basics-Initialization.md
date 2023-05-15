---
title: C++变量初始化Assignment & Initialization 笔记
date: 2023-05-14 18:29:32
categories:
 - C++
 - Basics
tags:
 - C++
---

感觉这句话说得很好, 道明了变量的本质:

> In the previous lesson ([1.3 -- Introduction to objects and variables](https://www.learncpp.com/cpp-tutorial/introduction-to-objects-and-variables/)), we covered how to define a variable that we can use to store values. In this lesson, we’ll explore how to actually put values into variables and use those values.

然后看看define, assignment和initialization的区别:

这是define:

```c++
int x;    // define an integer variable named x
int y, z; // define two integer variables, named y and z
```

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

When we assign value 7 to variable *width*, the value 5 that was there previously is **overwritten**. Normal variables can only hold one value at a time. 注意这里的overwritten, 

Java里的Reference概念更像C++里面的Variables, 赋值的时候多数情况是改变Reference的指向而不是C++这种overwritten内存, 哦, 注意在Java里一个字符串常量就是个String对象, 而不是单纯的“值”, 

