---
title: 
date: 2023-05-29 00:13:18
categories:
 - Golang
 - Advance
tags:
 - Golang
 - Concurrency
---

实现并发通常有两种方法:

第一种其实就是Java, C++, Python等语言中的多线程。他们线程间通信都是通过共享内存的方式来进行的。非常典型的方式就是，在访问共享数据（例如数组、Map、或者某个结构体或对象）的时候，通过锁来访问，因此，在很多时候，衍生出一种方便操作的数据结构，叫做“线程安全的数据结构”。例如Java提供的包”java.util.concurrent”中的数据结构。

另外一种是Go语言特有的，也是Go语言推荐的：CSP（communicating sequential processes）并发模型, 不同于传统的多线程通过共享内存来通信，CSP讲究的是“以通信的方式来共享内存”, Go的CSP并发模型，是通过`goroutine`和`channel`来实现的, channel 可以防止多个 goroutine 访问同一数据时发生资源争抢的问题, 

**Do not communicate by sharing memory; instead, share memory by communicating.** This approach can be taken too far. Reference counts may be best done by putting a mutex around an integer variable, for instance. But as a high-level approach, using channels to control access makes it easier to write clear, correct programs.

----

首先, go-routines are **user-space threads** not **kernel threads**, kernel threads由OS创建并管理 (sleep, wait, running), OS并不知道user-space threads的存在, Go的做法是把user-space threads映射到kernel threads来执行, 

kernel threads进行context switch时操作系统需要保存其PC, Register等相关信息然后再加载另一个kernel thread, 这又需要导入这个新的thread的上下文信息, 这就是所谓的开销, 但是user-space threads对于OS来说是透明的, 我们可以在退出一个user-space threads的时候不kill掉运行该user-space thread的kernel threads, 而是让其sleep, 等待下一个新的user-space threads被创建, 这样我们就减少了重复创建kernel threads的次数, 也减少了context switch的开销, Go就是这么做的, 具体如何映射goroutine到kernel thread, 这里面有两个重要的东西, 一个是Go Scheduler, 一个是runqueue, 每个kernel thread维护一个runqueue, runqueue保存的是待执行的groutine, 因为一个kernel thread一次只能执行一个goroutine, 所以多余的比如有的在等待io, 即blocked或者sleep状态的goroutine都在runqueue里, 等着被kernel thread拿出来, 至于goroutine的状态则由go scheduler来管理, 具体可参考: https://youtu.be/YHRO5WQGh0k

在这可能会疑惑physical thread和kernel thread的区别, physical thread其实是未来理解CPU core提出来的概念, 就是一个独立执行的thread, 像一根线, 真正干活的还是 CPU core, 然后软件层面就是kernel thread了, kernel thread 运行在 CPU core上:

> A "hardware thread" is just a confusing name for a logical core, aka execution context. It has nothing to do with software threads or kernel threads. One physical core may support more than 1 logical core, e.g. via hyperthreading or other SMT. 
>
> A hardware thread is a set of registers that are able to hold the [*context*](https://en.wikipedia.org/wiki/Context_switch) of a software thread. Having two "hardware threads" enables a single CPU to concurrently execute the instructions of two software threads without help from the OS. P.S.: If a software thread is like an automobile, then a hardware thread is like a lane on a highway in which the automobile can drive. OK, that's kind of a weak anaology, but what I'm trying to say is that a "hardware thread" and a thread in your program don't have much more in common with each other than the lane on the highway has in common with your car.
>
> --[multithreading - Kernel threads VS CPU threads - Stack Overflow](https://stackoverflow.com/questions/73308353/kernel-threads-vs-cpu-threads)

无论语言层面何种并发模型, 到了操作系统一定是运行在kernel thread上的, 上面我们说到Go的做法是把多个user-space threads映射到一个kernel thread, 以减少kernel thread切换时带来的消耗, 那其他语言怎么做的呢? 在C++里, 是通过syscall直接调用OS的kernel thread，线程所有的行为如创建, 终止, 切换等操作都由内核来完成, 一个用户态的线程对应一个系统线程, 这时候C++在频繁创建删除thread的时候就要考虑上下文切换的开销了, 因为操作的直接是kernel thread, 比如来一个tcp连接就创建一个thread, 这开销太大了, 所以这时候就出现了线程池, 说到底我们就是想要减少kernel thread创建切换的次数, 以减少开销,  你看无论C++还是Go都有自己的解决办法, 前者是通过thread pool来对kernel thread重复利用, 而后者因为通过map 多个goroutine到较少个kernel thread, 实现对kernel thread的重复利用, 减少上下文切换的次数, 减少开销, 

参考:

- [GopherCon 2018: Kavya Joshi - The Scheduler Saga](https://www.youtube.com/watch?v=YHRO5WQGh0k)
- [multithreading - Kernel threads VS CPU threads - Stack Overflow](https://stackoverflow.com/questions/73308353/kernel-threads-vs-cpu-threads)
- 书籍《Go并发编程实战》
- [Effective Go - The Go Programming Language](https://go.dev/doc/effective_go#introduction)
-  https://zhuanlan.zhihu.com/p/60613088







### Why goroutines instead of threads?

Goroutines are part of making concurrency easy to use. The idea, which has been around for a while, is to multiplex independently executing functions—coroutines—onto a set of threads. When a coroutine blocks, such as by calling a blocking system call, the run-time automatically moves other coroutines on the same operating system thread to a different, runnable thread so they won't be blocked. The programmer sees none of this, which is the point. The result, which we call goroutines, can be very cheap: they have little overhead beyond the memory for the stack, which is just a few kilobytes.

To make the stacks small, Go's run-time uses resizable, bounded stacks. A newly minted goroutine is given a few kilobytes, which is almost always enough. When it isn't, the run-time grows (and shrinks) the memory for storing the stack automatically, allowing many goroutines to live in a modest amount of memory. The CPU overhead averages about three cheap instructions per function call. It is practical to create hundreds of thousands of goroutines in the same address space. If goroutines were just threads, system resources would run out at a much smaller number.

### Why is there no goroutine ID?

Goroutines do not have names; they are just anonymous workers. They expose no unique identifier, name, or data structure to the programmer. Some people are surprised by this, expecting the `go` statement to return some item that can be used to access and control the goroutine later.

The fundamental reason goroutines are anonymous is so that the full Go language is available when programming concurrent code. By contrast, the usage patterns that develop when threads and goroutines are named can restrict what a library using them can do.

Here is an illustration of the difficulties. Once one names a goroutine and constructs a model around it, it becomes special, and one is tempted to associate all computation with that goroutine, ignoring the possibility of using multiple, possibly shared goroutines for the processing. If the `net/http` package associated per-request state with a goroutine, clients would be unable to use more goroutines when serving a request.

Moreover, experience with libraries such as those for graphics systems that require all processing to occur on the "main thread" has shown how awkward and limiting the approach can be when deployed in a concurrent language. The very existence of a special thread or goroutine forces the programmer to distort the program to avoid crashes and other problems caused by inadvertently operating on the wrong thread.

For those cases where a particular goroutine is truly special, the language provides features such as channels that can be used in flexible ways to interact with it.