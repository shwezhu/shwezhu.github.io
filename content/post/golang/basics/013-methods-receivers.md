---
title: Pointer Receiver or Value Receiver - Golang
date: 2023-08-15 17:18:20
categories:
 - golang
 - basics
tags:
 - golang
---

## 1. different behaviors - pointer and value receiver

There are two reasons to use a pointer receiver:

- The first is so that the method can modify **the value** that its receiver points to.

- The second is to avoid copying **the value** on each method call. This can be more efficient if the receiver is a large struct, for example.

> "the value" above refers to an object of the struct, but there is no object in golang, we call all of them **value**. 

I'll explain it to you the different behaviors between pointer receiver and value receiver first, see the code below:

```go
type Person struct {
	name string
}

func (p Person) foo() *Person {
	// As in all languages in the C family, everything in Go is passed by value.
	// 'p' here, is a copy of 'coco'
	return &p
}

func (p Person) setName(name string) {
  // 'p' here, is a copy of 'coco'
	p.name = name
}

func (p Person) getName() string {
	return p.name
}

func main() {
	coco := Person{name: "Coco"}
	coco.setName("Bella")
	fmt.Println(coco.getName()) // print: Coco
}
```

As you can see here, value receiver method will make a copy of that "object". There is no object in golang, using term "object" here is for easy understanding. This is that if you want to avoid copying the value of the struct **on each method call**, try to use a pointer receiver. And if you want modify the value's fields, try to use a pointer receiver. 

 I find a snippet in go source code, e.g.,

```go
type Handler interface {
	ServeHTTP(ResponseWriter, *Request)
}

type HandlerFunc func(ResponseWriter, *Request)

// 1. We don't need to modify any fileds of the value of HandlerFunc, just a function
// 2. There is no a lot copies, when we call this method, just a copy of function type, 
// small as a pointer so choosing a value receiver probably more appropriate here
// or thinking in this way probably better
// I know what I do, this is a function type, it has no filed
// no concurrency issues we mentioned above
func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) {
	f(w, r)
}
```

## 2. method receivers in concurrency

I came across a satement about when to use value receiver but forget where I found:

> You should notice that ***value receivers* are concurrency safe, while *pointer receivers* are not concurrency safe.** So if there is no a lot copy, and you don't need modify any field of the value, try to use value receiver.

Is this correct, yes it's correct to some extend, but things probably are more complicated when come across concurrent programming. 

I find a good [blog](https://dave.cheney.net/2016/03/19/should-methods-be-declared-on-t-or-t) talks about this written by [Dave Cheney](https://dave.cheney.net/), and I'll share some parts of the blog here:

Obviously if your method mutates its receiver, it should be declared on `*T`. However, if the method does not mutate its receiver, is it safe to declare it on `T` instead `*T`?

It turns out that the cases where it is safe to do so are very limited. For example, it is well known that you should not copy a `sync.Mutex` value as that breaks the invariants of the mutex. As mutexes control access to other things, they are frequently wrapped up in a `struct` with the value they control:

```go
package counter

type Val struct {
        mu  sync.Mutex
        val int
}

func (v *Val) Get() int {
        v.mu.Lock()
        defer v.mu.Unlock()
        return v.val
}

func (v *Val) Add(n int) {
        v.mu.Lock()
        defer v.mu.Unlock()
        v.val += n
}
```

Most Go programmers know that it is a mistake to forget to declare the `Get` or `Add` methods on the pointer receiver `*Val`. However any type that embeds a `Val` to utilise its zero value, must also only declare methods on its pointer receiver otherwise it may inadvertently copy the contents of its embedded type’s values.

```go
type Stats struct {
        a, b, c counter.Val
}

func (s Stats) Sum() int {
        return s.a.Get() + s.b.Get() + s.c.Get() // whoops
}
```

A similar pitfall can occur with types that maintain slices of values, and of course there is the possibility for an [unintended data race](http://dave.cheney.net/2015/11/18/wednesday-pop-quiz-spot-the-race).

In short, I think that you should prefer declaring methods on `*T` unless you have a strong reason to do otherwise.

## 3. pointer receiver - a practical example

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
