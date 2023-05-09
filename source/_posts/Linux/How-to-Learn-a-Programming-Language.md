---
title: 如何开始学习一门程式语言
date: 2023-05-03 19:11:30
categories:
 - Favorite
tags:
 - Favorite
---

之前就在想每次学习一个新的语言的时候不知道从哪开始, 要么跟着教程要么就写个hello world不知道该干嘛了, 其实只要弄明白两个东西, 就可以边写边学了. 首先应该弄明白它是compiled language还是interpreted language, 然后再去搞明白它的data type system, 

前者是为了弄明白这个语言实现以及它的优缺点, 显然编译型语言执行的速度会更快, 因为不用在运行时检查data type, 而且在run-time也不容易出错, 因为编译器可以帮助我们检查很多错误, 除以上之外还要弄明白其类型检查机制是dynamically checking 还是 statically checking, 这里需要注意一下, 一个语言是否是编译型与它是dynamically checking或statically checking没关系, 尽管我们常见的的如Python, PHP, Perl and Ruby都是dynamically checking然后还都是interpreted languages. 弄明白这些概念, 我们在使用该语言的时候时候会有一个更高角度的看待, 至于是否type safety那就自己慢慢探索, 

而后者即搞明白data type system的目的是分清这个语言的系统支持什么变量操作, 因为编程主要就是使用变量(对象也暂且认为是变量)和函数, 弄明白了这两个东西, 再慢慢研究其它特性, 如标准库, 支持的容器数组等, 垃圾回收, 内存结构等, 我想学习Bash的时候我们不会研究其标准库以及支持的容器操作, 因为没有(我猜的, 别信我), hhh, 至于其他的, 我们慢慢来研究, 

上面我们提到了几个概念, dynamically checking和statically checking, 以及compiled language和interpreted language, 这些是什么呢?

翻了一下以前记的笔记, 找不到出处了, 实在抱歉, 

> Programming languages are for humans to read and understand. The program (source code) must be translated into machine language so that the computer can execute the program. **The time when this translation occurs** depends on whether the programming language is a compiled language or an interpreted language. Instead of translating the source code into machine language **before the executable file is created**, an interpreter converts the source code into machine language **at the same time** the program runs. So you can't say a language doesn’t have compilation step, because any language needs to be translated to machine code.  

> Dynamically checking languages (where type checking happens at run time) can also be strongly typed. Note that in dynamically checking languages, values have types, not variables.

> strongly typed or weakly typed (loosely typed) is ambiguous. 判断是否是Type safety才准确. 

至于上面说的为什么dynamically checking或statically checking跟一个语言的类型没关系, 我找到了[一个回答](https://stackoverflow.com/a/1413550/16317008), 希望可以提供一些思路:

**[问题](https://stackoverflow.com/questions/1393883/why-is-dynamic-typing-so-often-associated-with-interpreted-languages)描述**:

Simple question folks: I do a lot of programming (professionally and personally) in compiled languages like C++/Java and in interpreted languages like Python/Javascript. I personally find that my code is almost always more robust when I program in statically typed languages. However, almost every interpreted language I encounter uses dynamic typing (PHP, Perl, Python, etc.). I know why compiled languages use static typing (most of the time), but I can't figure out the aversion to static typing in interpreted language design.

**[回答](https://stackoverflow.com/a/1413550/16317008)**: 

Interesting question. BTW, I'm the author/maintainer of [phc](http://phpcompiler.org/) (compiler for PHP), and am doing my PhD on compilers for dynamic languages, so I hope I can offer some insights.

I think there is a mistaken assumption here. The authors of PHP, Perl, Python, Ruby, Lua, etc didn't design "interpreted languages", they designed dynamic languages, and implemented them using interpreters. They did this because interpreters are much much easier to write than compilers.

Java's first implementation was interpreted, and it is a statically typed language. Interpreters do exist for static languages: Haskell and OCaml both have interpreters, and there used to be a popular interpreter for C, but that was a long time ago. They are popular because they allow a [REPL](http://en.wikipedia.org/wiki/Read-eval-print_loop), which can make development easier.

That said, there is an aversion to static typing in the dynamic language community, as you'd expect. They believe that the static type systems provided by C, C++ and Java are verbose, and not worth the effort. I think I agree with this to a certain extent. Programming in Python is far more fun than C++.

To address the points of others:

- [dlamblin says](https://stackoverflow.com/questions/1393883/why-is-dynamic-typing-so-often-associated-with-interpreted-languages/1394651#1394651): "I never strongly felt that there was anything special about compilation vs interpretation that suggested dynamic over static typing." Well, you're very wrong there. Compilation of dynamic languages is very difficult. There is mostly the `eval` statement to consider, which is used extensively in Javascript and Ruby. phc compiles PHP ahead-of-time, but we still need a run-time interpreter to handle `eval`s. `eval` also can't be analysed statically in an optimizing compiler, though there is a [cool technique](http://www.cs.umd.edu/~jfoster/papers/cs-tr-4935.pdf) if you don't need soundness.
- To damblin's response to [Andrew Hare](https://stackoverflow.com/questions/1393883/why-is-dynamic-typing-so-often-associated-with-interpreted-languages/1393907#1393907): you could of course perform static analysis in an interpreter, and find errors *before* run-time, which is exactly what Haskell's `ghci` does. I expect that the style of interpreter used in functional languages requires this. dlamblin is of course right to say that the analysis is not part of interpretation.
- [Andrew Hare's answer](https://stackoverflow.com/questions/1393883/why-is-dynamic-typing-so-often-associated-with-interpreted-languages/1393907#1393907) is predicated on the questioners wrong assumption, and similarly has things the wrong way around. However, he raises an interesting question: "how hard is static analysis of dynamic languages?". Very very hard. Basically, you'll get a PhD for describing how it works, which is exactly what I'm doing. Also see the previous point.
- The most correct answer so far is that of [Ivo Wetzel](https://stackoverflow.com/questions/1393883/why-is-dynamic-typing-so-often-associated-with-interpreted-languages/1394363#1394363). However, the points he describes can be handled at run-time in a compiler, and many compilers exist for Lisp and Scheme that have this type of dynamic binding. But, yes, its tricky.

参考:

- [type systems - Why Is Dynamic Typing So Often Associated with Interpreted Languages? - Stack Overflow](https://stackoverflow.com/questions/1393883/why-is-dynamic-typing-so-often-associated-with-interpreted-languages)