---
title: Trivial Tricks and Common Mistakes in Practice - Go
date: 2023-08-27 17:12:55
categories:
 - golang
 - practice
tags:
 - golang
 - practice
---

## Tricks

### 1. `map[string]int`

```go
// Dup1 prints the text of each line that appears more than
// once in the standard input, preceded by its count.
counts := make(map[string]int)
input := bufio.NewScanner(os.Stdin)
for input.Scan() {
	counts[input.Text()]++
}
```

### 2. slice

```go
func (s *MemoryStore) gc() {
	ticker := time.NewTicker(s.gcInterval)
	defer ticker.Stop()
	var expired []string
	for range ticker.C {
    // create a new enpty slice whose capacity has not been changed.
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

## Common mistakes

#### 1. Encoding non-exported fields struct value with gobs

gobs can encode the exported fields of a struct value, if a sturct without exported field, when you try encode its value, you will get a `nil`. 

> Functions and channels will not be sent in a gob. Attempting to encode such a value at the top level will fail. A struct field of chan or func type is treated exactly like an unexported field and is ignored. 

### 2. Use `var` to declare channel 

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

Don't use `var` to declare channel, map or slice values, use `make()`, keep this convension you will won't make mistakes. 

### 3. Using goroutines on a loop iterator variable

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

Learn more: 

- https://go.dev/doc/effective_go#channels
- https://github.com/golang/go/wiki/CommonMistakes

