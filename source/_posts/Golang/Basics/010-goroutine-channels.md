---
title: Goroutine & Channel - Go Basics
date: 2023-08-24 10:06:10
categories:
 - Golang
 - Basics
tags:
 - Golang
 - Concurrency
---

## 1. goroutines

When a program starts, its only goroutine is the one that calls the `main` function, so we call it the *main goroutine*. The `go` statement itself completes immediately:

```go
f()    // call f(); wait for it to return
go f() // create a new goroutine that calls f(); don't wait
```

The code below will just print `helllo`, this because when `main` function returns, all goroutines are abruptly terminated and the program exits. 

```go
func main() {
	go func() {
		time.Sleep(time.Millisecond * 100)
		fmt.Println("hello form another goroutine")
	}()
	fmt.Println("hello")
}
```

Other than (除了) by returning from `main` or exiting the program, there is no programmatic way for one goroutine to stop another, but there are ways to communicate with a goroutine to request that it stop itself.

## 2. channels

A Go channel is a means of communication that enables data sharing between goroutines. Each channel has a type associated with it. 

```go
data := <- a // read from channel a  
a <- data // write to channel a  
```

### 2.1. unbuffered channel 

This creates an unbuffered channel of type `int`. An unbuffered channel is one that can only hold one value at a time. 

```go
ch := make(chan int)
```

Sends and receives on an unbuffered channel will block until the corresponding operation is ready to proceed. Run this will cause a dealock error, 

```go
func main() {
	ch := make(chan int)
  // This send operation will block until there is a receive operation
  // ready to proceed.
	ch <- 42
  // This receive operation will block until there is a send operation
  // ready to proceed.
	val := <-ch
	fmt.Println(val)
}
```

With the nature of unbuffered channel, we can do something like this:

```go
func main() {
	ch := make(chan bool)
	go func() {
		// Do some work
		ch <- true
	}()
	// Wait for the goroutine to finish on another goroutine,
	// main() function for example
	<-ch
}
```

### 2.2. buffered channel

You can also specify the buffer size of a channel when creating it. A buffered channel allows for multiple values to be stored in the channel at once before they shall be read.

```go
ch := make(chan int, 3)
```

### 2.3. buffered channel vs unbuffered channel 

`ch := make(chan int, 1)` is totally different from `ch := make(chan int)`, the code below won't get deadlock error: 

```go
func main() {
	ch := make(chan int, 1)
	ch <- 42
  // if you put another "ch <- 42" below, there will be a deadlock error
	val := <-ch
	fmt.Println(val)
}
```

### 2.4. operations on channel

We can also check whether a channel is open or closed with the help of the given syntax:

```go
ele, ok:= <- channel_name
```

If the value of `ok` is true, this indicates that the channel is open and read operations can be done. 

An attempt to send value to a ***closed channel*** will panic.

```go
ch = make(chan bool)
ch <- true
close(ch)
// this will get a panic
ch <- true
```

An attempt to send value to a ***nil channel*** will block that goroutine forerver.

```go
func main() {
	s := make(chan bool, 1)
	s<- true
	<-s
	go func() {
		s = nil
		s<- true
		fmt.Println("hello from goroutine 2")
	}()
	fmt.Println("hello from goroutine 1")
	time.Sleep(time.Second * 3)
	fmt.Println("hi from goroutine 1 after seconds")
}
---------------------------------------

hello from goroutine 1
hi from goroutine 1 after seconds
```

> If you don't know whether a channel is closed or not and blindly write to it, then you have a badly designed program. Redesign it so that there is no way to write into it after it is closed. [A comment from Stack Overflow](https://stackoverflow.com/questions/39213230/how-to-test-if-a-channel-is-close-and-only-send-to-it-when-its-not-closed)

How to know if a channel is closed only by sending value to it? Answer: You can't. 

learn more: https://stackoverflow.com/a/61101887/16317008

## 3. uses of go channels

### 3.1. synchronization between goroutines

Traditional threading models (commonly used when writing Java, C++, and Python programs, for example) require the programmer to communicate between threads using shared memory. Typically, shared data structures are protected by locks, and threads will contend over those locks to access the data. 

Go’s concurrency primitives - goroutines and channels - provide an elegant and distinct means of structuring concurrent software. Instead of explicitly using locks to mediate access to shared data, Go encourages the use of channels to pass references to data between goroutines. This approach ensures that **only one goroutine has access to the data at a given time**. 

Channels can be used to ensure that one goroutine doesn't proceed until another goroutine has completed its work. This is particularly useful in scenarios where data needs to be shared between two or more goroutines, and it's important to ensure that the data isn't modified by multiple goroutines at the same time.

> *Do not communicate by sharing memory; instead, share memory by communicating.*

Consider a program that polls a list of URLs. In a traditional threading environment, one might structure its data like so:

```go
type Resource struct {
    url        string
    polling    bool
    lastPolled int64
}

type Resources struct {
    data []*Resource
    lock *sync.Mutex
}
```

And then a Poller function (many of which would run in separate threads) might look something like this:

```go
func Poller(res *Resources) {
    for {
        // get the least recently-polled Resource
        // and mark it as being polled
        res.lock.Lock()
        var r *Resource
        for _, v := range res.data {
            if v.polling {
                continue
            }
            if r == nil || v.lastPolled < r.lastPolled {
                r = v
            }
        }
        if r != nil {
            r.polling = true
        }
        res.lock.Unlock()
        if r == nil {
            continue
        }

        // poll the URL

        // update the Resource's polling and lastPolled
        res.lock.Lock()
        r.polling = false
        r.lastPolled = time.Nanoseconds()
        res.lock.Unlock()
    }
}
```

Let’s take a look at the same functionality implemented using Go idiom. In this example, Poller is a function that receives Resources to be polled from an input channel, and sends them to an output channel when they’re done.

```go
type Resource string

func Poller(in, out chan *Resource) {
    for r := range in {
        // poll the URL

        // send the processed Resource to out
        out <- r
    }
}
```

There are many omissions from the above code snippets. For a walkthrough of a complete, idiomatic Go program that uses these ideas, see the Codewalk [*Share Memory By Communicating*](https://go.dev/doc/codewalk/sharemem/).

References:

- [Share Memory By Communicating - The Go Programming Language](https://go.dev/blog/codelab-share)
- [Understanding Go Channels: An Overview for Beginners](https://www.atatus.com/blog/go-channels-overview/)
- [Closing the Channel in Golang - Scaler Topics](https://www.scaler.com/topics/golang/closing-the-channel-in-golang/)
