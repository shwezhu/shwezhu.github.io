---
title: Pointer Receiver vs Value Receiver in Golang
date: 2023-08-15 17:18:20
categories:
 - golang
 - basics
tags:
 - golang
---

## Pointer Receiver Error

 `error` interface:

```go
type error interface {
    Error() string
}
```

 `errorString`  implements  `error` interface in package `errors` :

```go
// errorString is a trivial implementation of error.
type errorString struct {
    s string
}

func (e *errorString) Error() string {
    return e.s
}

// New returns an error that formats as the given text.
func New(text string) error {
    return &errorString{text}
}
```

If you can notice that, the return type of `New()` function is `error`, but it actually returns a pointer type `&errorString{text}`, why? I find a [good explaination](https://www.reddit.com/r/golang/comments/15rz3fe/question_about_errors_package/):

The `Error()` method is implemented on `*errorString` (the pointer type), not `errorString` (the value type), so it's `*errorString` that implements the `error` interface, and so `New` must return `&errorString{..}` instead of `errorString{..}`.

That distinction is also important to make `errors.New` act correctly on `==`. Docs for `errors.New` say:

> Each call to New returns a distinct error value even if the text is identical.

Translation:

```
e1 := errors.New("foo")
e2 := errors.New("foo")
fmt.Println(e1 == e2) // false
```

This works because it returns `&errorString{..}`, so the `==` compares the pointers (which are unique for each call to New) instead of the error messages.

We can do a experiment:


A custom struct `MyError` implements `error` interface:

```go
type MyError struct {
	message string
}

func (receiver *MyError) Error() string {
	return receiver.message
}

func New(text string) error {
  // return &MyError{message: text} // correct way
	return MyError{message: text} // The complier will complain
}
```

```
Cannot use 'MyError{message: text}' (type MyError) as the type error Type does not implement 'error' as the 'Error' method has a pointer receiver
```

There is a good explaination: https://stackoverflow.com/a/46307148/16317008

If your interface is declared like this:

```golang
type Person interface {
    BasicInfo() MemberBasicInfo
}
```

Then any type that implements a `BasicInfo() MemberBasicInfo` will fulfil the interface.

In your case, you then created this method:

```golang
func (member *Member) BasicInfo() MemberBasicInfo
```

That means that the type `*Member` fulfils the interface.

But.. note the `*` there. `Member` does not implement the interface, it is `*Member` who does.

## Pointer Receiver or Value Receiver

There are two reasons to use a pointer receiver:

- The first is so that the method can modify the value that its receiver points to.

- The second is to avoid copying the value on each method call. This can be more efficient if the receiver is a large struct, for example.

But you should notice that *value receivers* are concurrency safe, while *pointer receivers* are not concurrency safe. So if there is no a lot copy, and you don't need modify any field of the value, try to use value receiver, I find a snippet in go source code, e.g.,

```go
type Handler interface {
	ServeHTTP(ResponseWriter, *Request)
}

type HandlerFunc func(ResponseWriter, *Request)

// 1. We don't need to modify any filed of HandlerFunc, it's just a function
// 2. There is no a lot copies
// So choose value receiver, not pointer
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
	f(w, r)
}
```

Source: [A Tour of Go](https://go.dev/tour/methods/8)
