---
title: Go并发学习之为何Goroutine很轻量
date: 2023-05-27 21:05:17
categories:
 - Golang
 - Advance
tags:
 - Go
 - Concurrency
---



### Why goroutines instead of threads?

Goroutines are part of making concurrency easy to use. The idea, which has been around for a while, is to multiplex independently executing functions—coroutines—onto a set of threads. When a coroutine blocks, such as by calling a blocking system call, the run-time automatically moves other coroutines on the same operating system thread to a different, runnable thread so they won't be blocked. The programmer sees none of this, which is the point. The result, which we call goroutines, can be very cheap: they have little overhead beyond the memory for the stack, which is just a few kilobytes.

To make the stacks small, Go's run-time uses resizable, bounded stacks. A newly minted goroutine is given a few kilobytes, which is almost always enough. When it isn't, the run-time grows (and shrinks) the memory for storing the stack automatically, allowing many goroutines to live in a modest amount of memory. The CPU overhead averages about three cheap instructions per function call. It is practical to create hundreds of thousands of goroutines in the same address space. If goroutines were just threads, system resources would run out at a much smaller number.

### Why is there no goroutine ID?

Goroutines do not have names; they are just anonymous workers. They expose no unique identifier, name, or data structure to the programmer. Some people are surprised by this, expecting the `go` statement to return some item that can be used to access and control the goroutine later.

The fundamental reason goroutines are anonymous is so that the full Go language is available when programming concurrent code. By contrast, the usage patterns that develop when threads and goroutines are named can restrict what a library using them can do.

Here is an illustration of the difficulties. Once one names a goroutine and constructs a model around it, it becomes special, and one is tempted to associate all computation with that goroutine, ignoring the possibility of using multiple, possibly shared goroutines for the processing. If the `net/http` package associated per-request state with a goroutine, clients would be unable to use more goroutines when serving a request.

Moreover, experience with libraries such as those for graphics systems that require all processing to occur on the "main thread" has shown how awkward and limiting the approach can be when deployed in a concurrent language. The very existence of a special thread or goroutine forces the programmer to distort the program to avoid crashes and other problems caused by inadvertently operating on the wrong thread.

For those cases where a particular goroutine is truly special, the language provides features such as channels that can be used in flexible ways to interact with it.