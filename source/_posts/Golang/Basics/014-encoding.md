---
title: encoding/json & encoding/gob in golang
date: 2023-08-19 19:38:20
categories:
 - Golang
 - Basics
tags:
 - Golang
---

## 1. encoding/json

- `Marshal()` → to encode GO values to JSON in string format
- `Unmarshal()` → to decode JSON data to GO values

```go
func Marshal(v interface{}) ([]byte, error)
func Unmarshal(data []byte, v interface{}) error
```

### 1.1. `json.Marshal()`

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

## 1.2. `json.Marshal()`

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

## 2. encoding/gob
