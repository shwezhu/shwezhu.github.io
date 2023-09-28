---
title: First-Class Functions - Go
date: 2023-08-14 22:28:20
categories:
 - golang
 - basics
tags:
 - golang
---

## 1. Function can be assigned to variable

```go
func sub(age int, name string) int {
	// ...
	return 0
}

func main() {
	foo := sub
	foo(1, "123")
	fmt.Printf("%T", foo)
}
// func(int, string) int
```

## 2. Function value has a type too

```go
func sub(age int, name *string) int {
	return 0
}

func main() {
	fmt.Printf("%T", sub) // func(int, *string) intß
}
```

Function is just a value just like other values in Go and this means we can pass a function as a argument or return a function from another function (returning a anonymous function often forms a [closure in Go](https://davidzhu.xyz/post/golang/practice/008-closures-go/). 

``` go
func main() {
	handler1 := func(w http.ResponseWriter, r *http.Request) {
		io.WriteString(w, "Hello from a HandleFunc #1!\n")
	}
	handler2 := func(w http.ResponseWriter, r *http.Request) {
		io.WriteString(w, "Hello from a HandleFunc #2!\n")
	}
	http.HandleFunc("/", handler1)
	http.HandleFunc("/endpoint", handler2)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
```

`http.HandleFunc` signature:

```go
 func HandleFunc(pattern string, handler func(ResponseWriter, *Request))
```

## 3. Function type declaration

```go
// Declare a function type
type Handler func(int, string) int

// Parameter foo is a value of Handler type
// You can think aa value is an object of a class
// however, there is no class and object in golang, just struct and value
func GenerateValue(age int, name string, foo Handler) {
	foo(age, name)
}

func sub(age int, name string) int {
	// ...
	return 0
}

func main() {
	GenerateValue(3, "david", sub)
}
```

## 4. A confusion in initilizing function type

```go
// struct declaring
type Cat struct {
	name string
	age uint
}

// funciton declaring
type MathOperation func(l float32, r float32) (float32, error)
```

Initilize a struct, we use `{}`, e.g.,

```go
cat := Cat{name: "Kitten", age: 1}
```

But initilize a function type, we use `()`

``` go
divideOperation := MathOperation(func(l float32, r float32) (float32, error) {
		if r == 0 {
			return 0, errors.New("denominator cannot be 0")
		}
		return l/r, nil
	})
```

## 5. Use case - pass behaviour



Next post: [closure in Go](https://davidzhu.xyz/post/golang/advance/006-closures-go/)

{{% youtube "5buaPyJ0XeQ" %}}

Video: https://youtu.be/5buaPyJ0XeQ?si=k3t7k1RGVlBZypMu
