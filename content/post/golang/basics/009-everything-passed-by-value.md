---
title: Everything Passed by Value - Go
date: 2023-09-2 18:37:04
categories:
 - golang
 - basics
tags:
 - golang
---

Everything passed by value, we have talked that [assignment makes a copy](https://davidzhu.xyz/post/golang/basics/002-assignment-makes-copy/), [value receiver makes a copy](https://davidzhu.xyz/post/golang/basics/013-methods-receivers/) of the struct value on each method call, in this post I'll show you argument is also passed by value. 

## 1. Everything passed by value

> As in all languages in the C family, everything in Go is passed by value. That is, a function always gets a copy of the thing being passed, as if there were an assignment statement assigning the value to the parameter. For instance, passing an `int` value to a function makes a copy of the `int`, and passing a pointer value makes a copy of the pointer, but not the data it points to. 
>
> Source: https://go.dev/doc/faq#methods_on_values_or_pointers
>
> Go does not have reference variables, so Go does not have pass-by-reference function call semantics.
>
> Source: [There is no pass-by-reference in Go | Dave Cheney](https://dave.cheney.net/2017/04/29/there-is-no-pass-by-reference-in-go)

No you know when you pass a value to a function or return a value from a function, this always makes a copy. You pass a value of a struct, there is a copy of that value, you pass a pointer to a value, there is a copy of the pointer's value which is a address. 

But, when we pass a struct value, is this a shallow copy or deep copy? Here I mean will both the underlying value and [direct value ](https://go101.org/article/value-part.html) are copied or just dirct value is copied? We can do a test: 

```go
type Cat struct {
	name string
	age  int
	s    []int
}

func foo(cat Cat) {
  // "cat" will be a copy from the value passed into foo
	cat.name = "Bella"
	cat.s[0] = 99
}

func main() {
	cat := Cat{
		name: "Coco",
		age:  1,
		s:    []int{1, 3, 4, 5, 6, 7},
	}
	foo(cat)
	fmt.Println(cat)
}
// Output: {Coco 1 [99 3 4 5 6 7]}
```

As you can see, the `name` field didn't change which proves there is a copy when we call funciton`foo()`. But the first element of the slice has been changed which means the copy is just copy the direct value of a struct, the underlying value won't be copied. 

How to make a deep copy: you can use encoding/gobs or reflect to impment a deep copy, however these two ways can just copy the exported fields of struct. 

## 2. What is a reference variable?

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

## 3. Go does not have reference variables

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

## 4. struct type 

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

## 5. map & slice

As we talked ablove, for better efficiency we usually choose to pass pointer type. Map and slice often store a lot of elements, should we pass/return a pointer to them when calling a function? 

The answer is no, we don't need to do that. Learn more: [array & slice & map - golang collections](https://shaowenzhu.top/post/golang/basics/003-collections/) 
