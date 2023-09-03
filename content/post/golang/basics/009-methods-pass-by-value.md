---
title: pass by value or reference - golang
date: 2023-09-2 18:37:04
categories:
 - golang
 - basics
tags:
 - golang
---

## 1. everything in Go is passed by value

> As in all languages in the C family, everything in Go is passed by value. That is, a function always gets a copy of the thing being passed, as if there were an assignment statement assigning the value to the parameter. For instance, passing an `int` value to a function makes a copy of the `int`, and passing a pointer value makes a copy of the pointer, but not the data it points to. 
>
> Source: https://go.dev/doc/faq#methods_on_values_or_pointers

> Go does not have reference variables, so Go does not have pass-by-reference function call semantics.
>
> Source: [There is no pass-by-reference in Go | Dave Cheney](https://dave.cheney.net/2017/04/29/there-is-no-pass-by-reference-in-go)

## 2. what is a reference variable?

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

Learn more: [array & slice & map - golang collections](https://shaowenzhu.top/post/golang/basics/003-collections/) 

