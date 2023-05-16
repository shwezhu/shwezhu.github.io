---
title: Golang值传递分析之传递指针的规则介绍(Methods, Functions & interface value)
date: 2023-05-16 17:25:04
categories:
 - Golang
 - Basics
tags:
 - Golang
---

类似C语言, [Go文档](https://go.dev/doc/faq#methods_on_values_or_pointers)指出所有传递都是值传递:

> As in all languages in the C family, everything in Go is passed by value. That is, a function always gets a copy of the thing being passed, as if there were an assignment statement assigning the value to the parameter. For instance, passing an `int` value to a function makes a copy of the `int`, and passing a pointer value makes a copy of the pointer, but not the data it points to. 

即然是值传递, 那就必须要考虑到参数传递以及函数返回时因拷贝导致的效率问题, 刚好Go里有指针的概念, 我们可以通过传递一个指向较大数据的指针来提高传递的效率, 那什么时候通过传递指针呢, Go文档也有说:

> There are **two reasons** to use a pointer receiver. The first is so that the method can modify the value that its receiver points to. The second is to avoid copying the value on each method call. This can be more efficient if the receiver is a large struct, for example.  

同时这个规则也适用于methods的receiver argument, Go文档里有专门讨论这个的, [choosing a value or pointer receiver](https://go.dev/tour/methods/8). Function的参数传递是传递指针还是值这个很好理解, 我们来验证一下methods的receiver argument, 是不是真的是传递值的时候会复制value:

```go
type Person struct {
	name string
	age  int
}

func (person Person) foo1() *Person {
	return &person
}

func (person *Person) foo2() *Person {
	return person
}

func main() {
	person := Person{"John", 18}
	fmt.Printf("main: %p\n", &person)
	fmt.Printf("foo1: %p\n", person.foo1())
	fmt.Printf("foo2: %p\n", person.foo2())
}

main: 0x140000a8018
foo1: 0x140000a8030
foo2: 0x140000a8018
```

可以看出, 确实我们在使用struct value `person`调用`foo1`的时候并不是它调用的, 而是它的复制本, 在这注意下Go里面的名字, 即我们把一个struct的instance叫 struct value, 而不是object, Go里面没有object的概念. 

这里还要说一些slice和map, 在[Golang容器之Array & Slice & Map](https://davidzhu.xyz/2023/05/13/Golang/Basics/Basic-Collections/)中我们提到 Slices are like references to arrays. **A slice does not store any data, it just describes a section of an underlying array**. 也举了一些例子, 官方[FAQs Doc](https://go.dev/doc/faq)里有细节介绍, 我们拷贝过来一些查看一下:

> Map and slice values behave like pointers: they are descriptors that contain pointers to the underlying map or slice data. Copying a map or slice value doesn't copy the data it points to. Copying an **interface value** makes a copy of the thing stored in the interface value. If the interface value holds a struct, copying the interface value makes a copy of the struct. If the interface value holds a pointer, copying the interface value makes a copy of the pointer, but again not the data it points to.
>
> Note that this discussion is about the semantics of the operations. Actual implementations may apply optimizations to avoid copying as long as the optimizations do not change the semantics.

上面有个短语 interface value, 这是什么? 好在我们又在[Go文档](https://go.dev/doc/faq)里找到了相关的解释:

> Under the covers, interfaces are implemented as two elements, a type `T` and a value `V`. `V` is a **concrete value** such as an `int`, `struct` or pointer, never an interface itself, and has type `T`. For instance, if we store the `int` value 3 in an interface, the resulting interface value has, schematically, (`T=int`, `V=3`). The value `V` is also known as the interface's *dynamic* value, since a given interface variable might hold different values `V` (and corresponding types `T`) during the execution of the program. 

上面的concrete value有个对应的词叫concrete type, 其中concrete type就是非interface的类型, 因为interface只可以有函数签名, 所以并不能说是concrete type, 这样想应该会好理解, 然后其他的类型比如int, string, 或者你的自定义struct, 都可以有自己的instance, 他们就是concrete type, 而他们的instance就是concrete value. 

[Go的教程](https://go.dev/tour/methods/11)也说了interface value是什么:

Under the hood, **interface values** can be thought of as a tuple of a value and a **concrete type**:

```go
(value, type)
```

An interface value holds a value of a specific underlying concrete type. 

Calling a method on an interface value executes the method of the same name on its underlying type. 这句话的意思就是实现多态的基础,  即假如我们有个struct如`Circle`, 实现了一个interface如`Shape`的`Area()`如下:

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

那我们就说`Circle`就是interface `Shape`的underlying type, 当然`Circle`也就是上面所谓的concrete type. 
