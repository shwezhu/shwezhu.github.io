---
title: 关于Golang函数返回局部变量的地址的问题
date: 2023-05-15 22:52:03
categories:
 - Golang
tags:
 - Golang
---

最近在学习Golang, 看到了类似下面的代码, 

```go
func f() *int {
    v := 1
    return &v
}
```

因为最近也在慢慢捡cpp, 然后就条件反射的觉得很奇怪, 怎么能返回一个local变量的地址呢, 查了半天谷歌, 终于找了[官方相关的说法](https://go.dev/doc/faq):

**How do I know whether a variable is allocated on the heap or the stack?**

From a correctness standpoint, you don't need to know. **Each variable in Go exists as long as there are references to it**. The storage location chosen by the implementation is irrelevant to the semantics of the language. 

The storage location does have an effect on writing efficient programs. When possible, the Go compilers will allocate variables that are local to a function in that function's stack frame. However, if the compiler cannot prove that the variable is not referenced after the function returns, then the compiler must allocate the variable on the garbage-collected heap to avoid dangling pointer errors. Also, if a local variable is very large, it might make more sense to store it on the heap rather than the stack. 

In the current compilers, if a variable has its address taken, that variable is a candidate for allocation on the heap. However, a basic *escape analysis* recognizes some cases when such variables will not live past the return from the function and can reside on the stack. 

其实这就和Java很像了, Java里也有引用的概念, 只不过和Go和C++里的引用还不同, Java的gc回收也是通过判断某对象的引用是否为0来决定是否清理对象, 但C++不是, 只要是stack上的, 统统删除, 毕竟C++没有gc啊, 了解更多关于Java引用:[Java中变量(Variables)和引用(References)的区别](https://davidzhu.xyz/2023/05/14/Java/Basics/Variables-vs-References/)

然后写个代码验证一下, 可以看到变量`a`的地址始终没变, 而`b`已经经历了copy和重建, 

```go
func foo1() *int {
	a := 3
	fmt.Println(&a)
	return &a
}

func foo2() int {
	b := 3
	fmt.Println(&b)
	return b
}

func main() {
	pa := foo1()
	fmt.Println(pa)
	fmt.Println("------------------")
	b := foo2()
	fmt.Println(&b)
}

0x1400011a018
0x1400011a018
------------------
0x1400011a038
0x1400011a030
```



