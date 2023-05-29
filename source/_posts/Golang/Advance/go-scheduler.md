---
title: 文章阅读 - Go Scheduler
date: 2023-05-28 18:06:20
categories:
 - Golang
 - Advance
tags:
 - Golang
 - Concurrency
---

注意并发和并行不是一个概念: Parallelism is about multiple tasks or subtasks of the same task that literally run at the same time on a hardware with multiple computing resources like multi-core processor, while concurrency is about multiple tasks which start, run, and complete in overlapping time periods, in no specific order.

----

原文: [Scheduling In Go : Part II - Go Scheduler](https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part2.html)

In the [first part](https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part1.html) of this scheduling series, I explained aspects of the operating-system scheduler that I believe are important in understanding and appreciating the semantics of the Go scheduler. In this post, I will explain at a semantic level how the Go scheduler works and focus on the high-level behaviors. The Go scheduler is a complex system and the little mechanical details are not important. What’s important is having a good model for how things work and behave. This will allow you to make better engineering decisions.

### Your Program Starts

When your Go program starts up, it’s given a Logical Processor (P) for every **virtual core** that is identified on the host machine. If you have a processor with multiple **hardware threads** per **physical core** (**Hyper-Threading**), each hardware thread will be presented to your Go program as a **virtual core**. To better understand this, take a look at the system report for my MacBook Pro. 即利用 Hyper-Threading 技术, 一个 physical core 对应两个 virtual cores, 所以程序所在机器的CPU有几个 physical threads, 就有几个Logical Processor **P**, 这样也就理解了什么是P, 即 physical threads, 

![a](a.png)

You can see I have a single processor with 4 physical cores. What this report is not exposing is the number of hardware threads I have per physical core. The Intel Core i7 processor has Hyper-Threading, which means there are 2 hardware threads per physical core. This will report to the Go program that 8 virtual cores are available for executing OS Threads in parallel. 

To test this, consider the following program:

```go
func main() {
    // NumCPU returns the number of logical
    // CPUs usable by the current process.
    fmt.Println(runtime.NumCPU())
}
```

When I run this program on my local machine, the result of the `NumCPU()` function call will be the value of 8. Any Go program I run on my machine will be given 8 P’s. 

Every P is assigned an OS Thread (“M”). The ‘M’ stands for machine. This Thread is still managed by the OS and the OS is still responsible for placing the Thread on a Core for execution, as explained in the [last post](https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part1.html). This means when I run a Go program on my machine, I have 8 threads available to execute my work, each individually attached to a P.

Every Go program is also given an initial Goroutine (“G”), which is the path of execution for a Go program. A Goroutine is essentially a Coroutine but this is Go, so we replace the letter “C” with a “G” and we get the word Goroutine. You can think of Goroutines as application-level threads and they are similar to OS Threads in many ways. Just as **OS Threads are context-switched on and off a core, Goroutines are context-switched on and off an M.**

另外的我电脑是芯片是M1, 信息如下:

```
Total Number of Cores: 8 (4 performance and 4 efficiency)
```

执行上面Go程序, 仍为8, 推断M1没有利用Hyper-Threading技术, 这个技术是Intel的, 当然其他制造商也有类似技术, 

