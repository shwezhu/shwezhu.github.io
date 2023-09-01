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

```go
// Declaring an Array
var arr [10]int
// Initialize
x := [5]int{}
x := [...]int{10, 20, 30}
```

> **Note:** An array's length is part of its type, so arrays cannot be resized. 

## 2. Declare & Init Slice

An array has a fixed size. A slice, on the other hand, is a dynamically-sized, flexible view into the elements of an array. Slices have a **capacity** and **length** property. 

- Create Empty Slice

```go
var intSlice []int
var strSlice []string
```

- Declare Slice using Make

Slice can be created using the built-in function `make()`:

```go
var intSlice = make([]int, 10)
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

- Slice of slices

二维数组即一个数组里的元素也是数组, 在Go里用make生成:

```go
var board = make([][]bool, height)
```

这就是个二维数组了, 只不过这个数组现在看起来还是个“1维”的, 它的元素是空的(本来应该是每个元素都是另一个数组):

```go
func main() {
  height : = 4
	boards := make([][]bool, height)
	for y, _ := range boards {
		fmt.Printf("%v", boards[y])
	}
}
// 打印:
[][][][]
```

这时候我们需要为其每个元素再几个数组:

```go
func main() {
  hetght := 4
  width  := 4
  // 创建二维数组
	boards := make([][]bool, height)
	for y, _ := range boards {
		fmt.Printf("%v", boards[y])
	}
  
  // 指定数组的每个元素是一个长度为width的数组
	for i, _ := range boards {
		boards[i] = make([]bool, width)
	}

	fmt.Printf("\n")

	for y, _ := range boards {
		fmt.Printf("%v", boards[y])
	}
}

[][][][]
[false false false false][false false false false][false false false false][false false false false]
```

根据输出可以看到, 二维数组就是多个并列的数组, 访问第3个数组的第2个元素即`board[2][1]`:

```go
func main() {
	board := make([][]bool, height)
	for i := range board {
		board[i] = make([]bool, width)
	}
	board[2][1] = true
	for y := range board{
		for _, v := range board[y] {
			fmt.Printf("%v ", v)
		}
		println()
	}
}

false false false 
false false false 
false true false 
false false false 
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

> ⚠️ **Like slices**, maps hold references to an underlying data structure. If you pass a map to a function that changes the contents of the map, the changes will be visible in the caller. So like slices, when a function return or accept, don't need to take a pointer to map, [source](https://go.dev/doc/effective_go#maps)

### 3.1. Copy Map

Find a [blog](https://web.archive.org/web/20171006194258/https://stackoverflow.com/documentation/go/732/maps/9834/copy-a-map#t=20171006194258443316) talks copy map, share it here:

Like slices, maps hold **references** to an underlying data structure. So by assigning its value to another variable, only the reference will be passed. To copy the map, it is necessary to create another map and copy each value:

```go
// Create the original map
originalMap := make(map[string]int)
originalMap["one"] = 1
originalMap["two"] = 2

// Create the target map
targetMap := make(map[string]int)

// Copy from the original map to the target map
for key, value := range originalMap {
  targetMap[key] = value
}
```

Same as slice, copy a map have deep copy and shallow copy, for deep copy a map, visit: [dictionary - How to deep copy a map and then clear the original? - Stack Overflow ](https://stackoverflow.com/questions/23057785/how-to-deep-copy-a-map-and-then-clear-the-original)

## 4. Slice 

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

## 5. Loop Slice

```go
func main() {
	var strSlice = []string{"India", "Canada", "Japan", "Germany", "Italy"}

	fmt.Println("\n---------------Example 1 --------------------\n")
	for index, element := range strSlice {
		fmt.Println(index, "--", element)
	}

	fmt.Println("\n---------------Example 2 --------------------\n")
	for _, value := range strSlice {
		fmt.Println(value)
	}

	j := 0
	fmt.Println("\n---------------Example 3 --------------------\n")
	for range strSlice {
		fmt.Println(strSlice[j])
		j++
	}
}
```

## 6. Conclusion

- The type `[n]T` is an array of `n` values of type `T`.
  - An array's length is part of its type, so arrays cannot be resized.
- The type `[]T` is a slice with elements of type `T`.
  - An array has a fixed size. A slice, on the other hand, is a dynamically-sized,
  - A slice does not store any data, it just describes a section of an underlying array.
  - Changing the elements of a slice modifies the corresponding elements of its underlying array.

learn more: [A Tour of Go](https://go.dev/tour/moretypes/7)
