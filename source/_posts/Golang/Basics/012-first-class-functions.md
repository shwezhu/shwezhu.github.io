---
title: First-Class Functions in Golang
date: 2023-08-14 22:28:20
categories:
 - Golang
 - Basics
tags:
 - Golang
---

## 1. 函数可以赋值给变量

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

## 2. 函数也有类型

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

即然函数也有类型, 便可以把函数当作参数传递, 这种用法就是简单的 callback function, 

``` go
func main() {
	h1 := func(w http.ResponseWriter, _ *http.Request) {
		io.WriteString(w, "Hello from a HandleFunc #1!\n")
	}
	h2 := func(w http.ResponseWriter, _ *http.Request) {
		io.WriteString(w, "Hello from a HandleFunc #2!\n")
	}

	http.HandleFunc("/", h1)
	http.HandleFunc("/endpoint", h2)

	log.Fatal(http.ListenAndServe(":8080", nil))
}

// http.HandleFunc 原型: 
func HandleFunc(pattern string, handler func(ResponseWriter, *Request))
```

## 3. 声明函数类型 Declaring Function Types

函数类型主要用在声明函数 参数 和 返回值类型, 

```go
// Declaring Function Types
type Handler func(int, string) int

// foo 是类型Handler的一个instance
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

## 4. Anonymous Functions & Closures

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

## 5. 





```go
type Handler interface {
	ServeHTTP(ResponseWriter, *Request)
}

// The HandlerFunc type is an adapter to allow the use of
// ordinary functions as HTTP handlers. If f is a function
// with the appropriate signature, HandlerFunc(f) is a
// Handler that calls f.
type HandlerFunc func(ResponseWriter, *Request)

// ServeHTTP calls f(w, r).
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
	f(w, r)
}
```









参考:

- [First-Class Functions in Golang. In Go, you can assign functions to… | by Radhakishan Surwase | Level Up Coding](https://levelup.gitconnected.com/first-class-functions-in-golang-ef2a5001bb4f)
- 





In this example, the `HandlerFunc` type is defined as a function type that takes a `ResponseWriter` and a pointer to a `Request` and returns an `error`. The `MyHandler` function matches this signature and can be assigned to a variable of type `HandlerFunc`. 

```go
type HandlerFunc func(ResponseWriter, *Request) error

func MyHandler(w ResponseWriter, r *Request) error {
    // Implementation of the handler function
    return nil
}

func main() {
    var handler HandlerFunc
    handler = MyHandler

    // Call the handler
    err := handler(w, r)
    if err != nil {
        // Handle the error
    }
}
```



主要应用如下:

```go
// http.HandlerFunc 原型: type HandlerFunc func(ResponseWriter, *Request)
func demo(fn http.HandlerFunc) {}

func handler(w http.ResponseWriter, r *http.Request) {}

func main() {
  demo(handler)
}
```

想想为什么 demo 可以接受 handler() function, 



```go
func helloHandler(db *sql.DB) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var name string
		// Execute the query.
		row := db.QueryRow("SELECT myname FROM mytable")
		if err := row.Scan(&name); err != nil {
			http.Error(w, err.Error(), 500)
			return
		}
		// Write it back to the client.
		fmt.Fprintf(w, "hi %s!\n", name)
	})
}
```



```go
type HandlerFunc func(ResponseWriter, *Request)

// ServeHTTP calls f(w, r).
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
	f(w, r)
}


```

