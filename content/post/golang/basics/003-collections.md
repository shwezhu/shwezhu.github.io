---
title:  array & slice & map - golang collections
date: 2023-05-13 10:23:59
categories:
 - golang
 - basics
tags:
 - golang
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

> *A map value is a pointer to a* `runtime.hmap` *structure.* 

When you write the statement

```go
m := make(map[int]int)
```

The compiler replaces it with a call to [`runtime.makemap`](https://golang.org/src/runtime/hashmap.go#L222), which has the signature

```go
// makemap implements a Go map creation make(map[k]v, hint)
// If the compiler has determined that the map or the first bucket
// can be created on the stack, h and/or bucket may be non-nil.
// If h != nil, the map can be created directly in h.
// If bucket != nil, bucket can be used as the first bucket.
func makemap(t *maptype, hint int64, h *hmap, bucket unsafe.Pointer) *hmap
```

```go
func main() {
	var m map[int]int
	var p uintptr
	fmt.Println(unsafe.Sizeof(m), unsafe.Sizeof(p)) // 8 8 (linux/amd64)
}
```

**If maps are pointers, shouldn’t they be *map[key]value?**

> *In the very early days what we call maps now were written as pointers, so you wrote \*map[int]int. We moved away from that when we realized that no one ever wrote `map` without writing `\*map`.*
>
> Maps, like channels, but *unlike* slices, are just pointers to `runtime` types. As you saw above, a map is just a pointer to a `runtime.hmap` structure.

Source: [If a map isn’t a reference variable, what is it? | Dave Cheney](https://dave.cheney.net/2017/04/30/if-a-map-isnt-a-reference-variable-what-is-it) 

> ⚠️ Map value just a pointer, therefore, we don't need to pass a pointer to a map for better performance. This is similar to slices, slice just a struct that has a pointer element which pointer to an underlaying array, so we don't need to set a pointer of slice as a paramter. This also applys function's return type. 

### 3.1. Copy Map

Find a [blog](https://web.archive.org/web/20171006194258/https://stackoverflow.com/documentation/go/732/maps/9834/copy-a-map#t=20171006194258443316) talks copy map, share it here:

Like slices, maps hold references to an underlying data structure. So by assigning its value to another variable, only the reference will be passed. To copy the map, it is necessary to create another map and copy each value:

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

How to deep copy a map or slice: [encoding/gob & encoding/json in golang - David's Blog](https://shaowenzhu.top/post/golang/basics/014-gob-json-encoding/#24-values-are-flattened)

## 4. Slice 

**A slice does not store any data, it just describes a section of an underlying array**. Changing the elements of a slice modifies the corresponding elements of its underlying array. Other slices that share the same underlying array will see those changes. 

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

## 5. Conclusion

- The type `[n]T` is an array of `n` values of type `T`.
  - An array's length is part of its type, so arrays cannot be resized.
- The type `[]T` is a slice with elements of type `T`.
  - An array has a fixed size. A slice, on the other hand, is a dynamically-sized,
  - A slice does not store any data, it just describes a section of an underlying array.
  - Changing the elements of a slice modifies the corresponding elements of its underlying array.
