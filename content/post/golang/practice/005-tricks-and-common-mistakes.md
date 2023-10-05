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

> Generally, in practice, we seldom use pointer types whose base types are `slice` types, `map` types, `channel` types, `function` types, `string` types and `interface` types. The costs of copying values of these assumed base types are very small. 
>
> Source: https://go101.org/article/value-copy-cost.html

## Tricks

### 1. `map`

```go
// as a counter
counts := make(map[string]int)
for name := range users {
	counts[name]++
}
// check if exist, O(1)
ele, ok := m["key"]
if !ok {...}
```

### 2. slice

#### 2.1. Reslicing - imporve performance

> Note that the elements has not been removed actually, they still in the underlying array. But this doesn't matter, the slice has been changed that's what we need. And this is why reslicing can improve performance, there is no new array was created, alwasys use the old one. 

Remove elements by reslicing:

```go
func (s *MemoryStore) gc() {
	ticker := time.NewTicker(s.gcInterval)
	defer ticker.Stop()
	var expired []string
	for range ticker.C {
    // "remove" all elements in expired
		expired = expired[:0]
    // add elements to expired
    ...
    // after use the elements in expired, the elments is useless now, we can drop them
    // which is expired = expired[:0] above
		for i := range expired {
			...
		}
	}
}
```

```go
// Stimulate stack
stack := make([]rune, 0)
for _, r := range s {
	if _, ok := pairs[r]; ok {
		stack = append(stack, r)
	} else {
    // reslice, "delete" the last one element
		stack = stack[:len(stack)-1]
	}
}
```

#### 2.2. Passing a slice to channel

```go
func main() {
	ready := make(chan []string)
  
	go func() {
		var expired []string
		expired = append(expired, "Coco")
		expired = append(expired, "Bella")
		ready<- expired
	}()
  
	go func() {
    // this will block until there is a data sent to the channel "ready"
		for s := range ready {
			for _, name := range s{
				fmt.Println(name)
			}
		}
	}()
  
	time.Sleep(time.Second)
}
```

Bacsuse a slice likes a pointer, the two goroutines above share a same underlying array. You have to consider if there is a data race, if yes, consider make a deep copy of the slice: [Everything Passed by Value - Go - David's Blog](https://davidzhu.xyz/post/golang/basics/009-everything-passed-by-value/) 

> Note that [iteration variable is re-used in each iteration](https://github.com/golang/go/wiki/CommonMistakes). 

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

It [“won’t blow shit up if you call f.CLose() twice."](https://twitter.com/benbjohnson/status/874289044800368640), you can check the source code. 

Why we bother to care about getting error from `f.Close()`? We have got error from  `f.Write()`. 

Well, there are a lot to say, learn more: 010-defer-close

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

