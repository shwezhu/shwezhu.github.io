---
title: The Router of Go Web App - ServeMux 
date: 2023-09-19 23:49:55
categories:
 - golang
 - practice
tags:
 - golang
---

This article enlightened by:

- [Understanding Mux and Handler concept](https://dev.to/kliukovkin/writing-server-with-http-package-mux-and-handler-concept-40cn)
- [GopherCon 2019: Mat Ryer - How I Write HTTP Web Services after Eight Years](https://www.youtube.com/watch?v=rWBSMsLG8po&list=WL&index=1&t=1231s)

## 1. Hello world - 2 ways

### 1.1. Implementing a Handler Interface - way 1

To run a server, we need to implement `http.Handler` interface:

```go
type Handler interface{
   ServeHTTP(ResponseWriter, *Request)
}
```

To achieve that we need to create an empty struct and provide a method for it:

```go
type handler struct{} 

func (h *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) { 
  	_, _ = fmt.Fprint(w, "hello world\n")
}

func main() {
    h := &handler{} // 1
    http.Handle("/", h) // 3
    _ = http.ListenAndServe(":8080", nil) //4
}
```

> Note that the signature of `http.Handle()`:
>
> ```go
> // Handle() registers the handler for the given pattern in the DefaultServeMux. 
> func Handle(pattern string, handler Handler)
> ```
>
> the `http.ListenAndServe()`
>
> ```go
> // The handler is typically nil, in which case the DefaultServeMux is used.
> func ListenAndServe(addr string, handler Handler) error
> ```

Test:

```shell
$ curl localhost:8080
hello world
```

1. We creating an empty struct that implements `http.Handler` interface
2. `http.Handle()` will register our `handler` for the given pattern, in our case, it is **“/”**. Why pattern and not URI? Because under the hood when your server is running and getting any request - it will find the closest pattern to the request path and dispatch the request to the corresponding handler. That means that if you will try to call '[http://localhost:8000/some/other/path?value=foo](http://localhost:8000/?value=foo)' it will still be dispatched to our registered handler, even if it is registered under the **“/”** pattern. 
3. On the last line with `http.ListenAndServe` we starting server on the port 8000. Keep in mind the second argument, which is nil for now, but we will consider it in detail in a few moments.

### 1.2. Using handler function  - way 2

```go
func handler(w http.ResponseWriter, r *http.Request) {
	_, _ = fmt.Fprint(w, "hello world\n")
}

func main() {
	http.HandleFunc("/", handler)
	_ = http.ListenAndServe(":8080", nil)
}
```

> Note that the `http.HandleFunc()` above:
>
> ```go
> // HandleFunc() registers the handler function for the given pattern in the DefaultServeMux.
> func HandleFunc(pattern string, handler func(ResponseWriter, *Request))
> ```

Test:

```shell
$ curl localhost:8080
hello world
```

This example looks very similar to the previous one, but it is a little bit shorter and easier to develop. We don’t need to implement any interface.

Notice that under the hood `http.HandleFunc()` is just syntax sugar for **avoiding the creation of `http.Handler` instances on each pattern**. `http.HandleFunc()` is an adapter that converts a function to a struct with `serveHTTP()` method. So instead of this:

```go
type root struct{} 
func (t *root) ServeHTTP(w http.ResponseWriter, r *http.Request) {...}

type home struct{} 
func (t *home) ServeHTTP(w http.ResponseWriter, r *http.Request) {...}

type login struct{} 
func (t *login) ServeHTTP(w http.ResponseWriter, r *http.Request) {...}
//...
http.Handle("/", root)
http.Handle("/home", home)
http.Handle("/login", login)
```

We can just use this approach:

```go
func root(w http.ResponseWriter, r *http.Request) {...}
func home(w http.ResponseWriter, r *http.Request) {...}
func login(w http.ResponseWriter, r *http.Request) {...}
...
http.HandleFunc("/", root)
http.HandleFunc("/home", home)
http.HandleFunc("/login", login)
```

## 2. ServeMux - the Router

### 2.1. Register patterns for ServeMux

You've probably noticed that above:

```go
// HandleFunc() registers the handler function for the given pattern in the DefaultServeMux.
func HandleFunc(pattern string, handler func(ResponseWriter, *Request))

// Handle() registers the handler for the given pattern in the DefaultServeMux. 
func Handle(pattern string, handler Handler)

// ListenAndServe() listens on the TCP network address addr and then calls Serve with handler to handle requests on incoming connections. 
// The handler is typically nil, in which case the DefaultServeMux is used.
func ListenAndServe(addr string, handler Handler) error
```

The comment of `Handle()` is quite confusing, what does "register" mean? We can check what this function does:

```go
// Handle registers the handler for the given pattern
// in the DefaultServeMux.
func Handle(pattern string, handler Handler) { DefaultServeMux.Handle(pattern, handler) }
```

This is the definition of `DefaultServeMux.Handle(pattern, handler)` (I've deleted some codes):

```go
func (mux *ServeMux) Handle(pattern string, handler Handler) {
  // check if the pattern has existed
	if _, exist := mux.m[pattern]; exist {
		panic("http: multiple registrations for " + pattern)
	}
  // add (register) the pattern and its corresponding hander into ServeMux
	e := muxEntry{h: handler, pattern: pattern}
	mux.m[pattern] = e
}
```

```go
type ServeMux struct {
	mu    sync.RWMutex
	m     map[string]muxEntry
	es    []muxEntry // slice of entries sorted from longest to shortest.
	hosts bool
}

type muxEntry struct {
	h       Handler
	pattern string
}
```

You can think `ServeMux` uses a map `m` to store the patterns and its corresponding hander. Functions `http.Handle()` and `http.HandleFunc()` will call `ServeMux`'s two method `DefaultServeMux.HandleFunc(pattern, handler)` and `DefaultServeMux.Handle(pattern, handler)` which will add (register) pattern into the default `ServeMux`.

We don't need to call functions `http.Handle()` and `http.HandleFunc()` to register patterns for `ServeMux`, we can create our own  `ServeMux` and we call its method `HandleFunc()` and `Handle()` directly. 

> Note that there are four functions, first two is `http.HandleFunc()` and `http.Handle()` which were used above in the `main` code. Another two are the methods of `ServeMux`. They do different things, the first two just call the last two.
>
> **A method contains a receiver, and a function does not contain a receiver.**

### 2.2 ServeMux - a request dispatcher (Router)

`ServeMux` implements the function `ServeHTTP()` which means it implements `http.Handler` interface, `ServeMux` is a `http.Handler` itself:

```go
// ServeHTTP dispatches the request to the handler whose
// pattern most closely matches the request URL.
func (mux *ServeMux) ServeHTTP(w ResponseWriter, r *Request) {
  // mux.Handler() returns the handler to use for the given request
	h, _ := mux.Handler(r)
	h.ServeHTTP(w, r)
}
```

Do you remember we said:

> Notice that under the hood `http.HandleFunc()` is just syntax sugar for avoiding the creation of `http.Handler` instances on each pattern. `HandleFunc()` is an adapter that **converts a function to a struct** with `serveHTTP()` method. 

Actually it converts a function into another function type `HandlerFunc` which has implemented `http.Handler`, I'll show you:

```go
func handler(w http.ResponseWriter, r *http.Request) {
	_, _ = fmt.Fprint(w, "hello world\n")
}

func main() {
	http.HandleFunc("/", handler)
	_ = http.ListenAndServe(":8080", nil)
}

//------------http.HandleFunc()----------->
// HandleFunc registers the handler function for the given pattern
// in the DefaultServeMux.
// The documentation for ServeMux explains how patterns are matched.
func HandleFunc(pattern string, handler func(ResponseWriter, *Request)) {
	DefaultServeMux.HandleFunc(pattern, handler)
}

//-------DefaultServeMux.HandleFunc(pattern, handler)----------->
// HandleFunc registers the handler function for the given pattern.
func (mux *ServeMux) HandleFunc(pattern string, handler func(ResponseWriter, *Request)) {
	if handler == nil {
		panic("http: nil handler")
	}
	mux.Handle(pattern, HandlerFunc(handler))
}

//------------HandlerFunc-------------->
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

Now you know that when develop a web app we have to deal with http requests, and we do this by regisering some patterns (urls) with its handler which is an instance of `http.Handler` into a `ServeMux`. We can take advantage of`func HandleFunc(pattern string, handler func(ResponseWriter, *Request))` which helps us create an instance of `http.Handler` for the `pattern`. 

> ServeMux is an HTTP request multiplexer. It matches the URL of each incoming request against a list of **registered patterns** and **calls the handler** for the pattern that most closely matches the URL. [ServeMux - Go](https://pkg.go.dev/net/http#ServeMux)
>
> Keep in mind that servemux, provided by Go will process each request in a separate goroutine. 

## 3. Creating own ServeMux

At part one we create two hello wrold example and we pass `nil` to `ListenAndServe()`:

```go
func main() {
	http.HandleFunc("/", handler)
	_ = http.ListenAndServe(":8080", nil)
}
```

We can check the source code:

```go
// The handler is typically nil, in which case the DefaultServeMux is used.
func ListenAndServe(addr string, handler Handler) error {
	server := &Server{Addr: addr, Handler: handler}
	return server.ListenAndServe()
}
```

Therefore, we can create our own `ServeMux` and pass it to `ListenAndServe()`, and we can register patterns to ServeMux directly which means we don't need to use ``http.HandleFunc()`` and ``http.Handle()` to help us register anymore. 

```go
func newServer() *server {
	s := &server{
		router: http.NewServeMux(),
	}
	s.routes()
	return s
}

// you can put dependencies here, like a db
type server struct {
	router *http.ServeMux
}

// make our server as a http.Handler 
// so that we can pass it to ListenAndServe()
// don't hide any logic here, which means don't write any other code
// if you want do something before a request, valide request for example
// use a middleware instead, 
// middleware: https://davidzhu.xyz/post/golang/practice/008-closures-go/#22-creating-middleware
// learn more: https://youtu.be/rWBSMsLG8po?si=qwtUTKF3J4EtWRQC
// I'll explain why we call s.router.ServeHTTP(w, r) later
func (s *server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.router.ServeHTTP(w, r)
}

// register patterns for ServeMux directly
func (s *server) routes() {
	s.router.HandleFunc("/", s.handleIndex)
	s.router.HandleFunc("/favicon.ico", s.handleFavicon)
}

func (s *server) handleFavicon(_ http.ResponseWriter, _ *http.Request) {}

func (s *server) handleIndex(w http.ResponseWriter, _ *http.Request) {
	_, _ = fmt.Fprint(w, "hello there")
}

func main() {
  // As we have talked befor, don't need to register patterns here
  // because we have registered patterns to ServeMux directly in routes() method
	s := newServer()
  // s is a http.Handler, so we can pass it here
	log.Fatal(http.ListenAndServe(":8080", s))
}
```

The code above has this:

```go
func (s *server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	s.router.ServeHTTP(w, r)
}
```

Recall that  `ServeHTTP()` method of ServeMux is used to dispatches the http requests to the handler function, we pass our server  to `http.ListenAndServe()` which means http package will treat our server as the "DefaultServeMux", which means that the `ServeHTTP()` method of our server will be called to "dispatche" the http request by the http packet. But as you can see, there is nothing but a call for `s.router.ServeHTTP(w, r)`, yes, http packet calls the `ServeHTTP()` method of our server to dispatche http request, but actually the `ServeHTTP()` method of our server call the `ServeHTTP()` of our `ServeMux` to dispatche http request.

```go 
// ServeHTTP dispatches the request to the handler whose
// pattern most closely matches the request URL.
func (mux *ServeMux) ServeHTTP(w ResponseWriter, r *Request) {
  // mux.Handler() returns the handler to use for the given request
	h, _ := mux.Handler(r)
	h.ServeHTTP(w, r)
}
```

Actually we can delete the method `ServeHTTP` of our server and just pass our `ServeMux` to `ListenAndServe()`:

```go
...
log.Fatal(http.ListenAndServe(":8080", s.router))
```

But this probably looks not as elegant as:

```go
log.Fatal(http.ListenAndServe(":8080", s))
```

Now you should understand the nature of `ServeMux`: a router of our web application. 