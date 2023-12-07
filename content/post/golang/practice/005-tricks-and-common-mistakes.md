---
title: Tricks and Common Mistakes - Go
date: 2023-08-27 17:12:55
categories:
 - golang
 - practice
tags:
 - golang
---

```go
// get data from bytes.Buffer
bytes := buff.Bytes()
str := string(bytes)
// Ext returns the file name extension used by path.
ext := path.Ext(filename)
// 
```

## Rules

### 1. Return a pointer or value

I list some type to which you don't need to return a pointer point:

- A **slice** does not store any data, it just describes a section of an underlying array. 
  - Therefore, your function can return a slice directly or accept a slice as a argument. 
  - You don't need to return a pointer to a slice. 
  - learn more: https://davidzhu.xyz/post/golang/basics/016-slice-relearn/
- In Go, a **string** is in effect a read-only slice of bytes. 
  - Only use `*string` if you have to distinguish an empty string from no strings.
  - learn more: https://davidzhu.xyz/post/golang/basics/015-string-runes-bytes
- *A **map** value is a pointer to a* `runtime.hmap` *structure.* 
  - A map is just a pointer itself, therefore, you don't need returen a pinter of a map value.
  - learn more: https://davidzhu.xyz/post/golang/basics/003-collections/#3-maps

- Like maps, **channels** are allocated with `make`, and the resulting value acts as a reference to an underlying data structure.

> As you can see, slice, string, map, channel is just a struct which holds the the reference to underlying value. You can think them are reference type, assigning or passing them is very cheap, but a array, normal struct, or peimitive types like integer,  boolean, which is a value type, when you assign or pass them, you need to consider the overhead. (assigning or passing an integer, small struct is very cheap)
>
> Generally, in practice, we seldom use pointer types whose base types are `slice` types, `map` types, `channel` types, `function` types, `string` types and `interface` types. The costs of copying values of these assumed base types are very small.
>
> Of curse, all are values in Golang, above is just for easy understanding and catagorizing, 
>
> Maps, like channels, but **unlike** slices, are just pointers to `runtime` types. As you saw above, a map is just a pointer to a `runtime.hmap` structure.  
>
> Source: https://go101.org/article/value-copy-cost.html

## Tricks

### 3. handle `close()`

```go
// credit to: https://gist.github.com/benbjohnson/9eebd201ec096ab6430e1f33411e6427
func doSomething() error {
	f, err := os.Create("foo")
	if err != nil {
		return err
	}
  // ensure that it's definitely closed by the end
	defer f.Close()
	if _, err := f.Write([]byte("bar"); err != nil {
		return err
	}
  return f.Close()
}
```

Why we bother to care about getting error from `f.Close()`? We have got error from  `f.Write()`. Well, there are a lot to say, learn more: [Don't Defer Close() on Writable Files - Go Notes](https://davidzhu.xyz/post/golang/advance/010-defer-close/)

## Common mistakes

#### 1. Encoding non-exported fields struct value with gobs

gobs can encode the exported fields of a struct value, if a sturct without exported field, when you try encode its value, you will get a `nil`. 

> Functions and channels will not be sent in a gob. Attempting to encode such a value at the top level will fail. A struct field of chan or func type is treated exactly like an unexported field and is ignored. 

#### 2. Use `var` to declare channel 

Variables declared without an explicit initial value are given their zero value. Zero value for a channel is `nil`, read and write a `nil` channel will block forever. The code below is a common mistake:

```go
go func() {
		var expiredSessions chan []*Session // expiredSessions == nil
		var errSession := chan error // errSession == nil
		store.GetExpiredSessions(expiredSessions, errSession)
		select {
		case sessions, _ := <-expiredSessions:
      ...
		}
	}()
```

**Don't use `var` to declare** **channel**, **map** **or slice values**, use `make()`, keep this convension you will won't make mistakes. 

Learn more: https://davidzhu.xyz/post/golang/basics/003-collections/#5-var-vs-make

#### 3. Using goroutines on a loop iterator variable

In Go, the loop iterator variable is a single variable that takes different values in each loop iteration. 

```go
func main() {
	var out []*int
	for i := 0; i < 3; i++ {
		out = append(out, &i)
	}
	fmt.Println("Values:", *out[0], *out[1], *out[2])
	fmt.Println("Addresses:", out[0], out[1], out[2])
}

Values: 3 3 3
Addresses: 0x40e020 0x40e020 0x40e020
```

For example, you might write something like this, using a closure:

```go
// this is bad
for _, val := range values {
	go func() {
		fmt.Println(val)
	}()
}
```

Because the closures are all only bound to that one variable, **there is a very good chance that** when you run this code you will see the last element printed for every iteration instead of each value in sequence, because the goroutines will probably not begin executing until after the loop.

The proper way to write that closure loop is:

```go
for _, val := range values {
	go func(val interface{}) {
		fmt.Println(val)
	}(val)
}
```

> Avoid mixing anonymous functions and goroutines. [Concurrency Made Easy](https://youtu.be/DqHb5KBe7qI?si=IW3zRKFc1Wtk4ZJh) 

Learn more: 

- https://go.dev/doc/effective_go#channels
- https://github.com/golang/go/wiki/CommonMistakes





