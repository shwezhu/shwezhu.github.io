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

## 2. Function has type too

```go
func sub(age int, name *string) int {
	// ...
	return 0
}

func main() {
	fmt.Printf("%T", sub)
}
// func(int, *string) int
```

Which means we can use function as a parameter or return type of another function:

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

## 4. Anonymous functions & closures

A function literal (or lambda) is a function without a name. 

````go
// Pass an anonymous function as a argument directly
func Slice(slice interface{}, less func(i, j int) bool)
people := []string{"Alice", "Bob", "Dave"}

sort.Slice(people, func(i, j int) bool {
		return len(people[i]) < len(people[j])
})

fmt.Println(people)

// Assigns an anonymous function to a variable: sayHelloWorld
var sayHelloWorld = func() {
	fmt.Println("Hello World !")
}
func main() {
	sayHelloWorld() // Hello World !
}
````

An anonymous function defined into another function `F` can use elements that are not defined in its scope but in the scope of `F`. A closure is formed when a function references variables not defined in its own scope.

```go
func printer() func() {
    k := 1
    return func() {
        fmt.Printf("Print n. %d\n", k)
        k++
    }
}

func main() {
    p := printer()
    p()
    // Print n. 1
    p()
    // Print n. 2
    p()
    // Print n. 3
}
```

> A closure is a persistent scope which holds on to local variables even after the code execution has moved out of that block.  [Closure - Stackoverflow](https://stackoverflow.com/a/7464475/16317008)

Credit: [First-Class Functions in Golang](https://levelup.gitconnected.com/first-class-functions-in-golang-ef2a5001bb4f) 

## 5. a confusion in initilizing function type

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

## 6. Wrapper

There is a advanced use case for function, called wrapper, you can learn more by visiting these blogs:

- [The http.Handler wrapper technique in #golang UPDATED | by Mat Ryer | Medium](https://medium.com/@matryer/the-http-handler-wrapper-technique-in-golang-updated-bc7fbcffa702)
- [Error handling and Go - The Go Programming Language](https://go.dev/blog/error-handling-and-go), at the *Simplifying repetitive error handling* part
- [Structuring Applications in Go. How I organize my applications in Go | by Ben Johnson | Medium](https://medium.com/@benbjohnson/structuring-applications-in-go-3b04be4ff091)

Learn more [dotGo 2016 - Dave Cheney - Do not fear first class functions](https://www.youtube.com/watch?v=5buaPyJ0XeQ&list=WL&index=7&t=273s): 

{{% youtube "5buaPyJ0XeQ" %}}
