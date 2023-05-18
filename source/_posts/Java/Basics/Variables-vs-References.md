---
title: Java中变量(Variables)和引用(References)的区别
date: 2023-05-14 19:31:26
categories:
 - Java
 - Basics
tags:
 - Java
---

## Primitive Variables vs Object Reference Variables

In Java, **all objects** are allocated on Heap. This is different from C++ where objects can be allocated memory either on Stack or on Heap. 

- Whenever you use `new`, an object is created on the heap.
- Local variables are stored on the stack. That includes primitives (such as `int`) and the references to any objects created. The actual objects themselves aren't created on the stack, as I mentioned when you use `new` they'll be created on the heap. https://stackoverflow.com/a/8061692/16317008

对上面叙述有个疑问`int age = 9;` 首先cat是个reference, 位于stack上, 然后cat指向对象Cat在heap的地址. 那`9`在哪里? age又是个什么, reference吗?

答案是, 对于基础数据类型, 比如age, 它里面的内容就是`9`, 而不是heap的某块地址. age就是个variable, 它的值就是9. 

这里不得不clearify一下两个概念(primitive variables, object reference variables)并说明二者区别:

> Just as men and women are fundamentally different (according to John Gray, author of Men Are from Mars, Women Are from Venus), **primitive variables** and **object reference variables** differ from each other in multiple ways. The basic difference is that **primitive variables store the actual values**, whereas reference variables store the addresses of the objects they refer to. Let’s assume that a class Person is already defined. If you create an int variable a, and an object reference variable person, they will store their values in memory as shown in figure 2.13. https://stackoverflow.com/a/32049775/16317008

```java
int a = 77;
Person person = new Person();
```

![a](a.png)

![b](b.png)