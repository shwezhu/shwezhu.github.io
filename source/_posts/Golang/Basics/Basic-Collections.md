---
title: Golang容器之Array & Slice & Map
date: 2023-05-13 10:23:59
categories:
 - Golang
 - Basics
tags:
 - Golang
---

## 1. Declare & Init Array

- Declaring an Array

```go
// Declaring an Array
var arr [10]int
```

- Initializing an Array with an Array Literal

```go
x := [5]int{10, 20, 30, 40, 50}   // Intialized with values
var y [5]int = [5]int{10, 20, 30} // Partial assignment
```

- Initializing an Array with ellipses`...`

```go
func main() {
	x := [...]int{10, 20, 30}
}
```

> **Note:** An array's length is part of its type, so arrays cannot be resized. 

## 2. Declare & Init Slice

An array has a fixed size. A slice, on the other hand, is a dynamically-sized, flexible view into the elements of an array. Slices have a **capacity** and **length** property. In practice, slices are much more common than arrays.

- Create Empty Slice

```go
var intSlice []int
var strSlice []string
```

- Declare Slice using Make

Slice can be created using the built-in function `make()`:

```go
var intSlice = make([]int, 10)        // when length and capacity is same
var strSlice = make([]string, 10, 20) // when length and capacity is different
```

- Nil slices

A nil slice has a length and capacity of 0 and has no underlying array.

```go
func main() {
	var s []int
	fmt.Println(s, len(s), cap(s))
	if s == nil {
		fmt.Println("nil!")
	}
}
```

- len & cap

The length and capacity of a slice `s` can be obtained using the expressions `len(s)` and `cap(s)`.

```go
func main() {
	s := []int{2, 3, 5, 7, 11, 13}
	printSlice(s)

	// Slice the slice to give it zero length.
	s = s[:0]
	printSlice(s)

	// Extend its length.
	s = s[:4]
	printSlice(s)

	// Drop its first two values.
	s = s[2:]
	printSlice(s)
}

func printSlice(s []int) {
	fmt.Printf("len=%d cap=%d %v\n", len(s), cap(s), s)
}

len=6 cap=6 [2 3 5 7 11 13]
len=0 cap=6 []
len=4 cap=6 [2 3 5 7]
len=2 cap=4 [5 7]
```

## 3. Maps

The `make` function returns a map of the given type, initialized and ready for use.

```go
func main() {
	m := make(map[string]int)

	m["Answer"] = 42
	fmt.Println("The value:", m["Answer"])

	m["Answer"] = 48
	fmt.Println("The value:", m["Answer"])

	delete(m, "Answer")
	fmt.Println("The value:", m["Answer"])

	v, ok := m["Answer"]
	fmt.Println("The value:", v, "Present?", ok)
}
```

## 4. Slice 补充

Slices are like references to arrays. **A slice does not store any data, it just describes a section of an underlying array**. Changing the elements of a slice modifies the corresponding elements of its underlying array. Other slices that share the same underlying array will see those changes. 

- e.g., 

```go
func main() {
	names := [4]string{
		"John",
		"Paul",
		"George",
		"Ringo",
	}
	fmt.Println(names)

	a := names[0:2]
	b := names[1:3]
	fmt.Println(a, b)

	b[0] = "XXX"
	fmt.Println(a, b)
	fmt.Println(names)
}

[John Paul George Ringo]
[John Paul] [Paul George]
[John XXX] [XXX George]
[John XXX George Ringo]
```
