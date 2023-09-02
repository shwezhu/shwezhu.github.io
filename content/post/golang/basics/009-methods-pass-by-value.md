---
title: pass by value or reference - golang
date: 2023-05-16 17:25:04
categories:
 - golang
 - basics
tags:
 - golang
---

> As in all languages in the C family, everything in Go is passed by value. That is, a function always gets a copy of the thing being passed, as if there were an assignment statement assigning the value to the parameter. For instance, passing an `int` value to a function makes a copy of the `int`, and passing a pointer value makes a copy of the pointer, but not the data it points to. 
>
> Source: https://go.dev/doc/faq#methods_on_values_or_pointers

> Go does not have reference variables, so Go does not have pass-by-reference function call semantics.
>
> Source: [There is no pass-by-reference in Go | Dave Cheney](https://dave.cheney.net/2017/04/29/there-is-no-pass-by-reference-in-go)

## 1. what is a reference variable?

In languages like C++ you can declare an *alias*, or an *alternate name* to an existing variable. This is called a *reference variable*.

```c++
#include <stdio.h>

int main() {
        int a = 10;
        int &b = a;
        int &c = b;

        printf("%p %p %p\n", &a, &b, &c); // 0x7ffe114f0b14 0x7ffe114f0b14 0x7ffe114f0b14
        return 0;
}
```

You can see that `a`, `b`, and `c` all refer to the same memory location. A write to `a` will alter the contents of `b` and `c`. This is useful when you want to declare reference variables in different scopes–namely function calls.

## 2. go does not have reference variables

Unlike C++, each variable defined in a Go program occupies a unique memory location.

```go
func main() {
        var a, b, c int
        fmt.Println(&a, &b, &c) // 0x1040a124 0x1040a128 0x1040a12c
}
```

It is not possible to create a Go program where two variables share the same storage location in memory. It is possible to create two variables whose contents *point* to the same storage location, but that is not the same thing as two variables who share the same storage location.

```go
func main() {
        var a int
        var b, c = &a, &a
        fmt.Println(b, c)   // 0x1040a124 0x1040a124
        fmt.Println(&b, &c) // 0x1040c108 0x1040c110
}
```

In this example, `b` and c hold the same value–the address of `a`–however, `b` and `c` themselves are stored in unique locations. Updating the contents of `b` would have no effect on `c`.

## 2. struct type 

Therefore, when a function returns a value of struct type or pass a struct value as argument, we usually use a pointer type for better efficiency. If you don't want to modiy the original value of struct, don't pass it as a pointer.  

> The value of a struct here means the object of a struct. 

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

## 3. map & slice

As we talked ablove, for better efficiency we usually choose to pass pointer type. Map and slice often store a lot of elements, should we pass/return a pointer to them when calling a function?

Learn more: https://shaowenzhu.top/post/golang/basics/003-collections/

## 3. assignment always makes a copy

> Similar to C++, a variable is just an adress location. But unlike C++, each variable defined in a Go program occupies a unique memory location. 

```go
func main() {
    kitten := Cat{Name: "Coco"}
    // do not think bella and kitten is a reference which points to a same object, this is java and python
    bella := kitten // makes a copy
    bella.Name = "Bella"
    fmt.Printf("kitten.Name:%v, bella.Name:%v\n", kitten.Name, bella.Name)
}
// kitten.Name:Coco, bella.Name:Bella
```

> For a mental model, you can treat variable names as references, which exists till their scope exists.
>
> For implementation, Go's variables are NOT references - for reference, use a pointer.
>
> These variables can be allocated on the stack, or on the heap. Both have pros and cons, the compiler decides. For correctness, it does not make any difference. "You don't have to know". 
>
> [source](https://www.reddit.com/r/golang/comments/s0m2h9/comment/hs2kvyo/?utm_source=share&utm_medium=web2x&context=3) 

```golang
type temp struct{
   val int
}

variable1 := temp{val:5}  // 1 makes a copy
variable2 := &temp{val:6} // 2
```

`temp{val:5}` is a [composite literal](https://go.dev/ref/spec#Composite_literals), it creates a value of type `temp`.

In the first example you used a [short variable declaration](https://go.dev/ref/spec#Short_variable_declarations), which is equivalent to

```golang
var variable1 = temp{val: 5}
```

There is a single variable created here (`variable1`) which is initialized with the value `temp{val: 5}`.

In the second example you take the address of a composite literal. That does create a variable, initialized with the literal's value, and the address of this variable will be the result of the expression. This pointer value will be assigned to the variable `variable2`.





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
