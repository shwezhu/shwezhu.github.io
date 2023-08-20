---
title: encoding/json & encoding/gob in golang
date: 2023-08-19 19:38:20
categories:
 - Golang
 - Basics
tags:
 - Golang
---

You probably want read this: [说说编码 - encoding| 橘猫小八的鱼](https://davidzhu.xyz/2023/06/01/CS-Basics/001-encoding/)

## 1. why do we need encoding

> To transmit a data structure across a network or to store it in a file, it must be encoded and then decoded again. Cause computer just know binary. 

There are many encodings available, of course: [JSON](http://www.json.org/), [XML](http://www.w3.org/XML/), Google’s [protocol buffers](http://code.google.com/p/protobuf), and more. And now there’s another, provided by Go’s [gob](https://go.dev/pkg/encoding/gob/) package. 

learn more: [Gobs of data - The Go Programming Language](https://go.dev/blog/gob)

## 2. encoding/json

- `Marshal()` → to encode GO values to JSON in string format
- `Unmarshal()` → to decode JSON data to GO values

```go
func Marshal(v interface{}) ([]byte, error)
func Unmarshal(data []byte, v interface{}) error
```

### 2.1. `json.Marshal()`

```go
type Cat struct {
	// lowercase field cannot be exported
	// `json:"name"` makes "Name" to "name" in json string after apply json.Marshal()
  // check in output
	Name string `json:"name"`
	Age int
	IsAdult bool
}

func main() {
	data, _ := json.Marshal(Cat{
		Name: "Kitten",
		Age: 2,
		IsAdult: true,
	})
	println(data)
	println(string(data))

	data, _ = json.Marshal("Hello")
	println(data)
	println(string(data))
}
----------------------------------
[40/48]0x140000161b0
{"name":"Kitten","Age":2,"IsAdult":true}
[7/8]0x1400001c1a8
"Hello"
```

> ⚠️Note: *Channel*, complex, and *function* values cannot be encoded in JSON. Attempting to encode such a value causes *Marshal* to return an UnsupportedTypeError. [json package - encoding/json - Go Packages](https://pkg.go.dev/encoding/json)

### 2.2. `json.Marshal()`

```go
func main() {
	data, _ := json.Marshal(Cat{
		Name: "Kitten",
		Age: 2,
		IsAdult: true,
	})

	cat := Cat{}
	 _ = json.Unmarshal(data, &cat)
	fmt.Println(cat)
}
----------------------------------
{Kitten 2 true}
```

## 3. encoding/gob

> Gob is much more preferred when communicating between Go programs. However, gob is currently supported only in Go and, well, [C](https://code.google.com/archive/p/libgob/), so only ever use that when you're sure no program written in any other programming language will try to decode the values.[difference between encoding/gob and encoding/json](https://stackoverflow.com/questions/41179453/difference-between-encoding-gob-and-encoding-json) 

- [gob package - encoding/gob - Go Packages](https://pkg.go.dev/encoding/gob)
- [Gobs of data - The Go Programming Language](https://go.dev/blog/gob)
- [Golang Benchmark: gob vs json](https://gist.github.com/evalphobia/a2ba2636acbc112f68dcd89e8b81d349)
- [gob - The Go Programming Language](https://www.cs.ubc.ca/~bestchai/teaching/cs416_2015w2/go1.4.3-docs/pkg/encoding/gob/index.html)
