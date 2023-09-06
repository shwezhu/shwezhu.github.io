---
title: Assignment always Makes a Copy in Go
date: 2023-09-05 23:30:20
categories:
 - golang
 - basics
tags:
 - golang
---

Similar to C++, a variable is just an address location. But unlike C++, each variable defined in a Go program occupies a unique memory location. We have talked this in [last post](https://davidzhu.xyz/post/golang/basics/001-value-variable-type/). 

```go
func main() {
    kitten := Cat{Name: "Coco"}
    bella := kitten // makes a copy
    bella.Name = "Bella"
    fmt.Printf("kitten.Name:%v, bella.Name:%v\n", kitten.Name, bella.Name)
}
// kitten.Name:Coco, bella.Name:Bella
```

Do not treat variable `bella` and `kitten` as a reference which point to a same object, that's java and python. We have talked about this in [previous post](https://davidzhu.xyz/post/golang/basics/009-methods-pass-by-value/). A variable is just a nice name for address in Go. 

> Go's variables are NOT references - for reference, use a pointer.
>
> These variables can be allocated on the stack, or on the heap. Both have pros and cons, the compiler decides. For correctness, it does not make any difference. "You don't have to know". 
>
> Source: [there is no reference](https://www.reddit.com/r/golang/comments/s0m2h9/comment/hs2kvyo/?utm_source=share&utm_medium=web2x&context=3)

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



