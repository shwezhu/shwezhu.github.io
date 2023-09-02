---
title: Relearn slice in Golang
date: 2023-08-19 21:43:59
categories:
 - golang
 - basics
tags:
 - golang
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

- slicing, 

A slice can also be formed by “slicing” **an existing slice or array**: 

```go
b := []byte{'g', 'o', 'l', 'a', 'n', 'g'}
// s == []byte{'o', 'l', 'a'}, sharing the same storage as b
s := b[1:4] 
```

### 3.1. Slice is just a Struct

Note that new slice shares the same storage as `b`, namely, same underlying array, why?  Let me show you, 

A slice is a descriptor of an array segment. It consists of a pointer to the array, the length of the segment, and its capacity (the maximum length of the segment). A slice is essentially just this:

![2](/016-slice-string-relearning/2.png)

```go
type slice struct {
    data uintptr
    len int
    cap int
}
```

Our variable `s`, created earlier by `make([]byte, 5)`, is structured like this:

![3](/016-slice-string-relearning/3.png)

The length is the number of elements referred to by the slice. The capacity is the number of elements in the underlying array. The distinction between length and capacity will be made clear as we walk through the next example. 

As we slice `s`, observe the changes in the slice data structure and their relation to the underlying array:

![4](/016-slice-string-relearning/4.png)

Slicing does not copy the slice’s data. It creates a new slice value that points to the original array. This makes slice operations as efficient as manipulating array indices. Therefore, modifying the *elements* (not the slice itself) of a re-slice modifies the elements of the original slice:

```go
d := []byte{'r', 'o', 'a', 'd'}
e := d[2:]
// e == []byte{'a', 'd'}
e[1] = 'm'
// e == []byte{'a', 'm'}
// d == []byte{'r', 'o', 'a', 'm'}
```

> A slice does not store any data, it just describes a section of an underlying array. Changing the elements of a slice modifies the corresponding elements of its underlying array. Other slices that share the same underlying array will see those changes. 

Earlier we sliced `s` to a length shorter than its capacity. We can grow s to its capacity by slicing it again:

```go
s = s[:cap(s)]
```

![5](/016-slice-string-relearning/5.png)

A slice cannot be grown beyond its capacity. Attempting to do so will cause a runtime panic, just as when indexing outside the bounds of a slice or array. Similarly, slices cannot be re-sliced below zero to access earlier elements in the array.

> Slices hold references to an underlying array, and if you assign one slice to another, both refer to the same array. If a function takes a slice argument, changes it makes to the elements of the slice will be visible to the caller, analogous to passing a pointer to the underlying array. A `Read` function can therefore accept a slice argument rather than a pointer and a count;  `func (f *File) Read(buf []byte) (n int, err error)` [Effective Go - The Go Programming Language](https://go.dev/doc/effective_go#slices)

### 3.2. Growing slices (the copy and append functions)

To increase the capacity of a slice one must create a new, larger slice and copy the contents of the original slice into it. This technique is how dynamic array implementations from other languages work behind the scenes. The next example doubles the capacity of `s` by making a new slice, `t`, copying the contents of `s` into `t`, and then assigning the slice value `t` to `s`:

```
t := make([]byte, len(s), (cap(s)+1)*2) // +1 in case cap(s) == 0
for i := range s {
        t[i] = s[i]
}
s = t
```

The looping piece of this common operation is made easier by the built-in copy function. As the name suggests, copy copies data from a source slice to a destination slice. It returns the number of elements copied.

```
func copy(dst, src []T) int
```

## 4. strings

In Go, a string is in effect a read-only slice of bytes. 

## 5. Conclusion

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