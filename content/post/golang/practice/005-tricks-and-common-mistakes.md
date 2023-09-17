---
title: Tricks and Common Mistakes - Go
date: 2023-08-27 17:12:55
categories:
 - golang
 - practice
tags:
 - golang
---

## Tricks

### 1. `map[string]int`

```go
counts := make(map[string]int)
for name := range users {
	counts[name]++
}
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
func longestCommonPrefix(s []string) string {
	pref := s[0]
	for i := 1; i < len(s); i++ {
		for !strings.HasPrefix(s[i], pref) {
      // reslice, "delete" the last one element
			pref = pref[:len(pref)-1]
		}
	}
	return pref
}
```

#### 2.2. Stimulate stack

```go
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

#### 2.3. Passing a slice to channel

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
    // this will block until there is a data sent to the cahnnel "ready"
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

