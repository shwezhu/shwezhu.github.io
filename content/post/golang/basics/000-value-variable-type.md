---
title: Value Variable and Types in Golang 
date: 2023-09-05 22:00:20
categories:
 - golang
 - basics
tags:
 - golang
---

## 1. Go is statically typed

Go is statically typed. Every variable has **only one static type**, that is, exactly one type known and fixed at compile time: `int`, `float32`, `*MyType`, `[]byte`, and so on. If we declare

```go
type MyInt int

var i int
var j MyInt
```

then `i` has type `int` and `j` has type `MyInt`. The variables `i` and `j` have distinct static types and, although they have the same underlying type, they cannot be assigned to one another without a conversion.

This is also true for an interface:

```go
// Reader is an interface defined in io package
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

> **Statically typed** means that before source code is compiled, the type associated with each and every single variable must be known.

## 2. Value & variable

**There is no object in Go, just variable and the value of a variable**, we declare a variable of interface here:

```go
var r io.Reader
```

Then we say the type of variable `r` is `io.Reader`, not `r` is an object of `io.Reader`. Did you catch that?

Btw, for simplicity reason, we usually use value/variable verbally. So here we can say `r` is a value of `io.Reader`, `r` is an interface value. Actually the variable `r` is just a nice name for address. 

> A variable is a **storage location** for holding a value. 
>
> A variable is a **storage location** for holding a value. The set of permissible values is determined by the variable's type. 
>
> Source: [The Go Programming Language Specification ](https://go.dev/ref/spec#Variables)

### 2.1. Value size

| Kinds of Types     | Value Size | [Required](https://golang.org/ref/spec#Size_and_alignment_guarantees) by [Go Specification](https://golang.org/ref/spec#Numeric_types) |
| ------------------ | ---------- | ------------------------------------------------------------ |
| bool               | 1 byte     | not specified                                                |
| int8, uint8 (byte) | 1 byte     | 1 byte                                                       |
| int, uint          | 1 word     | architecture dependent, 4 bytes on 32-bit architectures and 8 bytes on 64-bit architectures |
| string             | 2 words    |                                                              |
| slice              | 3 words    |                                                              |
| pointer            | 1 word     |                                                              |
| map                | 1 word     |                                                              |

NOTE: Here I call it **value size** not type size, this word is important, `var a int`, `a` is a **variable/value** whose type is `int`, and the size of this variable/value is 1 word on my arm64 cpmputer its size is 8 bytes. 

### 2.2. How the size of a struct value is calculated?

The size of a value means how many bytes the [direct part](https://go101.org/article/value-part.html) of the value will occupy in memory. The indirect underlying parts of a value don't contribute to the size of the value. 

I'll give you an example, 

```go
func main() {
	cat := Cat{
		name: "Coco",
		age:  1,
		s:    []int{1, 3, 4, 5, 6, 7},
	}
	fmt.Printf("cat: %T, %d\n", cat, unsafe.Sizeof(cat))
	fmt.Printf("a.age: %T, %d\n", cat.age, unsafe.Sizeof(cat.age))
	fmt.Printf("a.name: %T, %d\n", cat.name, unsafe.Sizeof(cat.name))
	fmt.Printf("cat.s: %T, %d\n", cat.s, unsafe.Sizeof(cat.s))
}

cat: main.Cat, 48
cat.s: []int, 24
a.age: int, 8
a.name: string, 16
```

> The sizes of two string values are always equal, same as string, the sizes of two slice values are also always equal. **Values of a specified type always have the same value size.** 

Learn more: [Go Value Copy Costs -Go 101](https://go101.org/article/value-copy-cost.html)

## 3. Variable declarations

### 3.1. `:=` vs `var`

- The ***`:=`*** can **only** be used in inside a function, which is called **short variable declarations**. 

- A ***`var`*** statement can be at package or function level, which is called **regular variable declarations**. 

### 3.2. Zero value

**Variables declared without an explicit initial value are given their zero value.** The zero value is:

- `0` for numeric types,
- `false` for the boolean type, and
- `""` (the empty string) for strings.
- `nil` for pointer
- `nil` for map and slice

```go

func main() {
	var i int
	var f float64
	var b bool
	var s string
	var p *string
	var sl []int
	var m map[string]string
	fmt.Printf("%v %v %v %q %v %v %v \n", i, f, b, s, p, sl==nil, m==nil)
}
// 0 0 false "" <nil> true true 
```

Dereferencing a nil pinter will cause panic, don't do that.

```go
kitten := Cat{Name: "Coco"}
// nil is zero value for a pointer
var cat *Cat
*cat = kitten  // runtime error: invalid memory address or nil pointer dereference
```

### 3.2. `var` vs `new`

It's a little harder to justify `new`. The main thing it makes easier is creating pointers to non-composite types. The two functions below are equivalent. One's just a little more concise:

```go
func newInt1() *int { return new(int) }

func newInt2() *int {
    var i int
    return &i
}
```

Source: https://stackoverflow.com/a/9322182/16317008

## 4. Variable redeclarations 

Unlike regular variable declarations, a short variable declaration may *redeclare* variables provided they were originally declared earlier in the same block **with the same type**, and **at least one of the non-[blank](https://go.dev/ref/spec#Blank_identifier) variables is new**. As a consequence, redeclaration can only appear in a multi-variable short declaration. Redeclaration does not introduce a new variable; it just assigns a new value to the original. 

```go
func main() {
	y, x := 1, 2
	z, x := 2, 3 // z must be new
	fmt.Println(x, y, z)
}
```

This is useful when handle error, 

```go
// func (s *memoryStore) generateID(n int) (string, error)
id, err := s.generateID(32) 
if err != nil {
	return nil, err
}
// func (r *Request) Cookie(name string) (*Cookie, error)
c, err := r.Cookie(name) // redeclare err 
...
```

## 5. Type conversions

The expression `T(v)` converts the value `v` to the type `T`. Some numeric conversions:

```go
var i int = 42
var f float64 = float64(i)
var u uint = uint(f)
```

Or, put more simply:

```go
i := 42
f := float64(i)
u := uint(f)
```

Unlike in C, in Go assignment between items of different type requires an explicit conversion, this enchances the type safety of Golang. 

## 6. Type assertions

A *type assertion* provides access to an **interface value's** underlying concrete value. 

```go
str := value.(string)
```

But if it turns out that the value does not contain a string, the program will crash with a run-time error. To guard against that, use the "comma, ok" idiom to test, safely, whether the value is a string:

```go
str, ok := value.(string)
if ok {
    fmt.Printf("string value is: %q\n", str)
} else {
    fmt.Printf("value is not a string\n")
}
```

similar syntax - 1:

```go
users := make(map[string]int)
users["jack"] = 13
users["john"] = 15

user, ok := users["milo"]
if ok {
	fmt.Println(user)
} else {
	fmt.Println("no such user")
}
```

similar syntax - 2:

```go
ele, ok:= <-channel_name
```

If the value of `ok` is true, this indicates that the channel is open and read operations can be done. 

### 7.1. Type assertion use case

Type assertion only can be used when value's type is interface, 

```go
var m map[interface{}]interface{}
_, isMap := m.(map[interface{}]interface{}) 
```

The snippet above will cause error: `Invalid type assertion: m.(map[interface{}]interface{}) (non-interface type map[interface{}]interface{} on the left`. 

The code below works fine:

```go
var m map[interface{}]interface{}
var t interface{}
t = m
_, isMap := t.(map[interface{}]interface{})
fmt.Println(isMap)
// print: true
```

## 8. Conclusion

- `ele, ok:= <-channel_name`, `user, ok := users["milo"]`, `str, ok := value.(string)` 
-  type assertions only can be used by interface type.
- assignment, pass as an arguments and function return always makes a copy.
