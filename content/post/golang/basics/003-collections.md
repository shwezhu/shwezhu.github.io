---
title: array & slice & map - Go collections
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

Check it out here: https://zhuanlan.zhihu.com/p/656805223

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

**If maps are pointers, shouldn’t they be map[key]value?**

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

## 5. `var` vs `make()`

### 5.1. slice

What's the difference between these two statement below:

```go
var cats []string
// or
dogs := make([]string, 0)
```

We have know that any varibles declared with `var` without an explicit initial value are given their zero value, `nil` is zero for `map`, `slice` and `pointer`. 

Therefore, the value of `cats` is `nil` for sure, then for `make([]string, 0)`it allocates a memory with 0 elements, which means `dog != nil`. 

But there probably no difference when you use, cause you and append a `nil` slice directly:

```go
var expired []string
// it's totally fine to do this:
expired = append(expired, "hello")
fmt.Println(expired)
```

### 5.2. map

But this is not the case in a map:

```go
var cats map[string]int
// panic: assignment to entry in nil map
cats["Coco"] = 3
```

Therefore, for map you should use `make` or `map literal`

```go
// They are equivlent
cats := map[string]int{}
dogs := make(map[string]int)
```

Learn more: https://stackoverflow.com/a/53575947/16317008

## 6. Conclusion

- The type `[n]T` is an array of `n` values of type `T`.
  - An array's length is part of its type, so arrays cannot be resized.
- The type `[]T` is a slice with elements of type `T`.
  - An array has a fixed size. A slice, on the other hand, is a dynamically-sized,
  - A slice does not store any data, it just describes a section of an underlying array.
  - Changing the elements of a slice modifies the corresponding elements of its underlying array.
