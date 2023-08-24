---
title: Golang并发学习之Goroutine和Channel
date: 2023-08-24 20:06:10
categories:
 - Golang
 - Basics
tags:
 - Golang
 - Concurrency
---

## channels

A Go channel is a means of communication that enables data sharing between goroutines. Each channel has a type associated with it. 

```go
data := <- a // read from channel a  
a <- data // write to channel a  
```

### 1.1. unbuffered channel 

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

### 1.2. buffered channel

You can also specify the buffer size of a channel when creating it. A buffered channel allows for multiple values to be stored in the channel at once before they shall be read.

```go
ch := make(chan int, 3)
```

### 1.3. buffered channel vs unbuffered channel 

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

## 2. uses of go channels

### 2.1. synchronization between goroutines

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
