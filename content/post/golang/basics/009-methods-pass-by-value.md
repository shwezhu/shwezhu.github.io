---
title: Golang值传递分析之传递指针的规则介绍(Methods, Functions & interface value)
date: 2023-05-16 17:25:04
categories:
 - golang
 - basics
tags:
 - golang
---

类似C语言 [Go文档](https://go.dev/doc/faq#methods_on_values_or_pointers) 指出所有传递都是值传递:

> As in all languages in the C family, everything in Go is passed by value. That is, a function always gets a copy of the thing being passed, as if there were an assignment statement assigning the value to the parameter. For instance, passing an `int` value to a function makes a copy of the `int`, and passing a pointer value makes a copy of the pointer, but not the data it points to. 

即然是值传递, 那就必须要考虑到参数传递以及函数返回时因拷贝导致的效率问题, 刚好Go里有指针的概念, 我们可以通过传递一个指向较大数据的指针来提高传递的效率, 那什么时候通过传递指针呢, Go文档也有说:

> There are **two reasons** to use a pointer receiver. The first is so that the method can modify the value that its receiver points to. The second is to avoid copying the value on each method call. This can be more efficient if the receiver is a large struct, for example. 

同时这个规则也适用于 methods的 receiver argument, Go文档里专门讨论这个 [choosing a value or pointer receiver](https://go.dev/tour/methods/8). Function的参数传递是传递指针还是值这个很好理解, 我们来验证一下methods的receiver argument, 是不是真的是传递值的时候会复制value:

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

可以看出, 确实我们在使用 struct value `person`调用 `foo1` 的时候并不是它调用的, 而是它的复制本, 在这注意下Go里的概念, 即我们把一个 struct 的 instance 叫 struct value, 而不是 object, Go 里面没有 object 的概念, 但后面为了方便理解, 依然称 struct value 为对象, 

再举个例子:

```go
type Rect struct {
	width float32
	height float32
}

func getRect() Rect {
	rect := Rect{3, 2}
	fmt.Printf("in getRect(): %p\n", &rect)
	return rect
}

func main() {
	rect := getRect()
	fmt.Printf("outside getRect(): %p\n", &rect)
}

// in getRect(): 0x1400011a020
// outside getRect(): 0x1400011a018
```

因此, 在函数中一般返回对象的指针 (reference of struct value), 而不是直接返回对象的值, 如:

``` go
type Page struct {
    Title string
    Body  []byte
}

func loadPage(title string) *Page {
    filename := title + ".txt"
    body, _ := os.ReadFile(filename)
    return &Page{Title: title, Body: body}
}
// https://go.dev/doc/articles/wiki/
```

----

说一下 slice 和 map, 在[Golang容器之Array & Slice & Map](https://davidzhu.xyz/2023/05/13/Golang/Basics/003-collections/) 中提到 Slices are like references to arrays. A slice does not store any data, it just describes a section of an underlying array. 官方[FAQs Doc](https://go.dev/doc/faq)里有细节介绍, 拷贝一些: 

> *Map* and *slice* values behave like pointers: they are descriptors that contain pointers to the underlying map or slice data. **Copying a map or slice value doesn't copy the data it points to**. [Copying an **interface value**](https://stackoverflow.com/a/37851764/16317008) makes a copy of the thing stored in the interface value. If the interface value holds a struct, copying the interface value makes a copy of the struct. If the interface value holds a pointer, copying the interface value makes a copy of the pointer, but again not the data it points to.
>
> Note that this discussion is about the semantics of the operations. Actual implementations may apply optimizations to avoid copying as long as the optimizations do not change the semantics.

上面有个短语 interface value, 这是什么? 好在我们又在[Go文档](https://go.dev/doc/faq)里找到了相关的解释:

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
