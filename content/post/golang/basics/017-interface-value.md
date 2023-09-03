---
title: Interface Value - Golang
date: 2023-09-02 18:57:04
categories:
 - golang
 - basics
tags:
 - golang
---

> [Copying an interface value](https://stackoverflow.com/a/37851764/16317008) makes a copy of the thing stored in the interface value. If the interface value holds a struct, copying the interface value makes a copy of the struct. If the interface value holds a pointer, copying the interface value makes a copy of the pointer, but again not the data it points to.
>
> Note that this discussion is about the semantics of the operations. Actual implementations may apply optimizations to avoid copying as long as the optimizations do not change the semantics.

上面有个短语 interface value 这是什么? 好在我们又在[Go文档](https://go.dev/doc/faq)里找到了相关的解释:

> Under the covers, interfaces are implemented as two elements, a type `T` and a value `V`. `V` is a **concrete value** such as an `int`, `struct` or pointer, never an interface itself, and has type `T`. For instance, if we store the `int` value 3 in an interface, the resulting interface value has, schematically, (`T=int`, `V=3`). The value `V` is also known as the interface's *dynamic* value, since a given interface variable might hold different values `V` (and corresponding types `T`) during the execution of the program. 

上面的 concrete value 有个对应的词叫 concrete type, 其中 concrete type 就是非 interface 的类型, 因为 interface 只可以有函数签名, 所以并不能说是 concrete type, 其他的类型如 int, string 或自定义 struct 都可以有自己的 instance, 它们的 instance 就是 concrete value. 

[Go的教程](https://go.dev/tour/methods/11) 也说了 interface value 是什么:

Under the hood, **interface values** can be thought of as a tuple of a value and a **concrete type**:

```go
(value, type)
```

An interface value holds a value of a specific underlying concrete type. Calling a method on an interface value executes the method of the same name on its underlying type. 

解释一下, 假如我们有个 struct `Circle`, 实现了一个 interface 如 `Shape` 的 `Area()`:

```go
type Shape interface {
	area() float64
}

type circle struct {
	radius float64
}

func (c circle) area() float64 {
	return math.Pi * c.radius * c.radius
}

func main() {
	...
}
```

则 Circle 为 `Shape ` 的 underlying type, `Circle`也就是上面的 concrete type. 