---
title: Error handling - Go
date: 2023-09-08 09:13:06
categories:
 - golang
 - basics
tags:
 - golang
---

## 1.`error` interface

The `error` type is an interface type. An `error` variable represents any value that **can** describe itself as a string.

```go
type error interface {
    Error() string
}
```

Interface `error` is a built-in type, as with all other built in types, is [predeclared](https://go.dev/doc/go_spec.html#Predeclared_identifiers) in the [universe block](https://go.dev/doc/go_spec.html#Blocks). The most commonly-used `error` implementation is the [errors](https://go.dev/pkg/errors/) package’s **unexported** `errorString` type.

```go
// errorString is a trivial implementation of error.
type errorString struct {
    s string
}

func (e *errorString) Error() string {
    return e.s
}
```

`errorString` is an unexported type which means we cannot use it directly outside of [errors](https://go.dev/pkg/errors/) package, but we can use `New` function declared in the same package to create a value of `errorString`. 

``` go
// New returns an error that formats as the given text.
func New(text string) error {
    return &errorString{text}
}
```

The type of function returns is an `error` but it actually returns a pointer, a little weird probably for newb from c++. In Go everything can implement a interface an `int`, `string` even a `pointer`. It's all about if the method set of that type contians all the methods declared in a interface, learn more: [Methods Receivers & Concurrency - Go - David's Blog](https://davidzhu.xyz/post/golang/basics/013-methods-receivers/#3-pointer-receiver---a-practical-example)

## 2. Create an error value

### 2.1. Ways to create an error value

You can create an `error` with these functions:

- `errors.New()`, 
- `fmt.Errorf()`, often used to provide conetxt. 
- Use a custom error type, typically used for provide error details. 

Note that `errors.New()` and `fmt.Errorf()` just return an error value that with the string you passed, not something magic. An error value likes an `int` value, struct value or pointer value. Learn more: [Errors are values](https://go.dev/blog/errors-are-values) 

e.g.,

Functions usually need to return an error to indicate an abnormal state in Go. For example, the `os.Open` function returns a non-nil `error` value when it fails to open a file:

```go
func Open(name string) (file *File, err error)
```

If you want return an error you might want use `errors.New` which defined in [errors](https://go.dev/pkg/errors/) package we have talked above:

```go
func Sqrt(f float64) (float64, error) {
    if f < 0 {
        return 0, errors.New("math: square root of negative number")
    }
    // implementation
}
```

### 2.2. Summarize the context when create an error value

**It is the error implementation’s responsibility to summarize the context.** The error returned by `os.Open` formats as “open /etc/passwd: permission denied,” not just “permission denied.” The error returned by our `Sqrt` is missing information about the invalid argument.

To add that information, a useful function is the `fmt` package’s `Errorf`. It formats a string according to `Printf`’s rules and returns it as an `error` created by `errors.New`.

```go
func Sqrt(f float64) (float64, error) {
    if f < 0 {
    	return 0, fmt.Errorf("math: square root of negative number %g", f)
		}
    // implementation
}
```

Sometimes we usually return a new error value which contains the context:

```go
if err != nil {
  return nil, fmt.Errorf("math: failed to calculate sqrt: %v", err)
}
```

## 3. Some common ways for error handling 

We have talked that there are three ways to create an error, now let's discuss how to use them in practice. 

### 3.1. Create error value with a custom error type - provide details

In many cases `fmt.Errorf` is good enough, but since `error` is an interface, you can use arbitrary data structures as error values, to allow callers to inspect the details of the error. 

The [json](https://go.dev/pkg/encoding/json/) package specifies a `SyntaxError` type that the `json.Decode` function returns when it encounters a syntax error parsing a JSON blob.

```go
type SyntaxError struct {
    msg    string // description of error
    Offset int64  // error occurred after reading Offset bytes
}

func (e *SyntaxError) Error() string { return e.msg }
```

The `Offset` field isn’t even shown in the default formatting of the error, but callers can use it to add file and line information to their error messages:

```go
if err := dec.Decode(&val); err != nil {
    if serr, ok := err.(*json.SyntaxError); ok {
        // serr.Offset provide detials about error
        line, col := findLine(f, serr.Offset)
        return fmt.Errorf("%s:%d:%d: %v", f.Name(), line, col, err)
    }
    return err
}
```

### 3.2. Don't return error dirctly - avoid repetitive error handling

#### 3.2.1. Return a `bool` value instead to indicate an abnormal state

Here’s a simple example from the `bufio` package’s [`Scanner`](https://go.dev/pkg/bufio/#Scanner) type. Its [`Scan`](https://go.dev/pkg/bufio/#Scanner.Scan) method performs the underlying I/O, which can of course lead to an error. Yet the `Scan` method does not expose an error at all. Instead, it returns a boolean, and a separate method, to be run at the end of the scan, reports whether an error occurred. Client code looks like this:

```go
scanner := bufio.NewScanner(input)
for scanner.Scan() {
    token := scanner.Text()
    // process token
}
if err := scanner.Err(); err != nil {
    // process the error
}
```

Sure, there is a nil check for an error, but it appears and executes only once. The `Scan` method could instead have been defined as

```go
func (s *Scanner) Scan() (token []byte, error)
```

and then the example user code might be (depending on how the token is retrieved),

```
scanner := bufio.NewScanner(input)
for {
    token, err := scanner.Scan()
    if err != nil {
        return err // or maybe break
    }
    // process token
}
```

This isn’t very different, but there is one important distinction. In this code, the client must check for an error on every iteration, but in the real `Scanner` API, the error handling is abstracted away from the key API element, which is iterating over tokens. With the real API, the client’s code therefore feels more natural: loop until done, then worry about errors. Error handling does not obscure the flow of control.

#### 3.2.1. Return nothing 

```go
_, err = fd.Write(p0[a:b])
if err != nil {
    return err
}
_, err = fd.Write(p1[c:d])
if err != nil {
    return err
}
_, err = fd.Write(p2[e:f])
if err != nil {
    return err
}
// and so on
```

The code above is very repetitive. A function literal closing over the error variable would help:

```go
var err error
write := func(buf []byte) {
    if err != nil {
        return
    }
    _, err = w.Write(buf)
}
write(p0[a:b])
write(p1[c:d])
write(p2[e:f])
// and so on
if err != nil {
    return err
}
```

This pattern works well, but requires a closure in each function doing the writes; a separate helper function is clumsier to use because the `err` variable needs to be maintained across calls (try it).

We can make this cleaner, more general, and reusable by borrowing the idea from the `Scan` method above.

I defined an object called an `errWriter`, something like this:

```go
type errWriter struct {
    w   io.Writer
    err error
}
```

and gave it one method, `write.` It doesn’t need to have the standard `Write` signature, and it’s lower-cased in part to highlight the distinction. The `write` method calls the `Write` method of the underlying `Writer` and records the first error for future reference:

```go
func (ew *errWriter) write(buf []byte) {
    if ew.err != nil {
        return
    }
    _, ew.err = ew.w.Write(buf)
}
```

As soon as an error occurs, the `write` method becomes a no-op but the error value is saved.

Given the `errWriter` type and its `write` method, the code above can be refactored:

```go
ew := &errWriter{w: fd}
ew.write(p0[a:b])
ew.write(p1[c:d])
ew.write(p2[e:f])
// and so on
if ew.err != nil {
    return ew.err
}
```

This is cleaner, even compared to the use of a closure, and also makes the actual sequence of writes being done easier to see on the page. There is no clutter anymore. Programming with error values (and interfaces) has made the code nicer.

In fact, this pattern appears often in the standard library. The [`archive/zip`](https://go.dev/pkg/archive/zip/) and [`net/http`](https://go.dev/pkg/net/http/) packages use it. More salient to this discussion, the [`bufio` package’s `Writer`](https://go.dev/pkg/bufio/) is actually an implementation of the `errWriter` idea. Although `bufio.Writer.Write` returns an error, that is mostly about honoring the [`io.Writer`](https://go.dev/pkg/io/#Writer) interface. The `Write` method of `bufio.Writer` behaves just like our `errWriter.write` method above, with `Flush` reporting the error, so our example could be written like this:

```go
b := bufio.NewWriter(fd)
b.Write(p0[a:b])
b.Write(p1[c:d])
b.Write(p2[e:f])
// and so on
if b.Flush() != nil {
    return b.Flush()
}
```

There is one significant drawback to this approach, at least for some applications: there is no way to know how much of the processing completed before the error occurred. If that information is important, a more fine-grained approach is necessary. Often, though, an all-or-nothing check at the end is sufficient.

We’ve looked at just one technique for avoiding repetitive error handling code. Keep in mind that the use of `errWriter` or `bufio.Writer` isn’t the only way to simplify error handling, and this approach is not suitable for all situations. The key lesson, however, is that errors are values and the full power of the Go programming language is available for processing them.

References:

- [Error handling and Go - The Go Programming Language](https://go.dev/blog/error-handling-and-go)
- [Errors are values - The Go Programming Language](https://go.dev/blog/errors-are-values)