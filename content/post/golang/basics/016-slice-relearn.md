---
title: Relearn slice - Go
date: 2023-08-19 21:43:59
categories:
 - golang
 - basics
tags:
 - golang
typora-root-url: ../../../../static
---

## 1. Slice is not an Array

- The type `[n]T` is an array of `n` values of type `T`.
  - An array's length is part of its type, so arrays cannot be resized. 

- The type `[]T` is a slice with elements of type `T`.
  - A slice is a dynamically-sized. Slices have a **capacity** and **length** property. 
  - The length and capacity of a slice `s` can be obtained using the expressions `len(s)` and `cap(s)`.

## 2. Array

An array’s size is fixed; its length is part of its type (`[4]int` and `[5]int` are distinct, incompatible types). The in-memory representation of `[4]int` is just four integer values laid out sequentially:

![1](/016-slice-string-relearning/1.png)

Go’s arrays are values. An array variable denotes the entire array; it is not a pointer to the first array element (as would be the case in C). This means that when you assign or pass around an array value you will make a copy of its contents. (To avoid the copy you could pass a *pointer* to the array, but then that’s a pointer to an array, not an array.) 

```go
// the type of b is [2]string, you canse see, the [2] is part of its type
b := [2]string{"Penn", "Teller"}
fmt.Printf("Type of b: %T\n", b)
```

## 3. Slice

Ways to create slice,

-  slice literal 

```go
letters := []string{"a", "b", "c", "d"}
```

- make

```go
// func make([]T, len, cap) []T
s := make([]byte, 5, 5)
// When the capacity argument is omitted, it defaults to the specified length.
s := make([]byte, 5)
```

- slicing

A slice can also be formed by “slicing” **an existing slice or array**: 

```go
b := []byte{'g', 'o', 'l', 'a', 'n', 'g'}
// s == []byte{'o', 'l', 'a'}, sharing the same storage as b
s := b[1:4] 
```

### 3.1. Slice is just a Struct

A slice is a descriptor of an array segment. It consists of a pointer to the array, the length of the segment, and its capacity (the maximum length of the segment). A slice is essentially just this:

```go
type slice struct {
    data uintptr
    len int
    cap int
}
```

Slicing does not copy the slice’s data. It creates **a new slice value that points to the original array**:

```go
d := []byte{'r', 'o', 'a', 'd'}
e := d[2:] // NOTE: 'e' is a totally new slice, e == []byte{'a', 'd'}
e[1] = 'm'
// e == []byte{'a', 'm'}
// d == []byte{'r', 'o', 'a', 'm'}
```

> If a function takes a slice argument, changes it makes to the elements of the slice will be visible to the caller, analogous to passing a pointer to the underlying array. A `Read` function can therefore accept a slice argument rather than a pointer and a count;  `func (f *File) Read(buf []byte) (n int, err error)` [Effective Go](https://go.dev/doc/effective_go#slices)

```go
d := []int{1, 3, 5, 7}
e := d[:2] // e == int{1, 3}
fmt.Println(e) // [1 3]
fmt.Println(len(e)) // 2
fmt.Println(cap(e)) // 4
```

There is a trick, we usually use `d = d[:0]` to generate a new slice `d` whose length is 0 but capacity not change, which can make program more efficient. 

Learn more about slice: [Go Slices: usage and internals](https://go.dev/blog/slices-intro)

## 4. Conclusion

- It’s important to understand that even though a slice contains a pointer, it is itself a value. Under the covers, it is a struct value holding a pointer and a length. It is *not* a pointer to a struct.
- A slice does not store any data, it just describes a section of an underlying array. 
  - Therefore, your function can return a slice directly or accept a slice as a argument. 
  - You don't need to return a pointer to a slice. 
- In Go, a string is in effect a read-only slice of bytes. 
  - Only use `*string` if you have to distinguish an empty string from no strings.


References:

- [Go Slices: usage and internals - The Go Programming Language](https://go.dev/blog/slices-intro)
- [A Tour of Go](https://go.dev/tour/moretypes/7)
- [Arrays, slices (and strings): The mechanics of 'append' - The Go Programming Language](https://go.dev/blog/slices)
- [Strings, bytes, runes and characters in Go - The Go Programming Language](https://go.dev/blog/strings)