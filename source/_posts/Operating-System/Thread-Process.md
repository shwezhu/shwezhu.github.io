---
title: 并发学习之线程进程及Thread Stack
date: 2023-05-27 18:05:16
categories:
 - OS
tags:
 - OS
 - Concurrency
---

相关文章: 

## 1. Thread

A thread is a segment or part of a process that executes some tasks of the process. A process can have multiple threads which can **run concurrently** within the process. Each thread has its own thread stack but multiple threads of a process share a common heap area of that process.

### 1.1. Thread Stack

Each thread has its own call stack, "call stack" and "thread stack" are the same thing. Calling it a "thread stack" just emphasizes that the call stack is specific to the thread. 仔细想想也是, 你看我们写代码时, 每个thread就是单独并发的执行一个函数, 

The *stack* is used to store variables used on the inside of a function (including the `main()` function). It’s a LIFO, “**L**ast-**I**n,-**F**irst-**O**ut”, structure. Every time a function declares a new variable it is “pushed” onto the stack. Then when a function finishes running, all the variables associated with that function on the stack are deleted, and the memory they use is freed up. This leads to the “local” scope of function variables. The stack is a special region of memory, and automatically managed by the CPU – so you don’t have to allocate or deallocate memory. Stack memory is divided into successive frames where each time a function is called, it allocates itself a fresh **stack frame**. 

Note that there is generally a limit on the size of the stack – which can vary with the operating system (for example OSX currently has a default stack size of 8MB). If a program tries to put too much information on the stack, **stack overflow** will occur. Stack overflow happens when all the memory in the stack has been allocated, and further allocations begin overflowing into other sections of memory. Stack overflow also occurs in situations where recursion is incorrectly used.

## 2. Process

A program is a set of instructions. It is stored on a disk of a computer and hence it is **Passive**. When the same program is loaded into the main memory and the OS assigns some heap memory to this program(application) is under execution is called a **Process**. Hence a process is a program under execution. So we can say it is **Active**. A process can create child processes by using the **fork** system calls. 

## 3. The Relation Between a Thread and a CPU Core

A CPU core is a physical processing unit in a computer’s central processing unit (CPU) that can execute instructions independently. A thread, on the other hand, is a unit of execution within a process, which represents a sequence of instructions that can be executed independently by a CPU.

In general, the number of threads that can be executed simultaneously on a CPU is limited by the number of cores available in the CPU. Each core can execute one thread at a time, so having multiple cores allows for multiple threads to be executed in parallel, potentially leading to improved performance.

However, the relationship between threads and CPU cores is more complex than just one-to-one mapping.

In modern computer systems, threads can be scheduled dynamically on different cores by the operating system, and a single core can switch between multiple threads in order to maximize the utilization of available resources and CPU cores.

Additionally, some systems may also use techniques such as hyper-threading, where a single physical core is treated as multiple virtual cores, potentially allowing for even more threads to be executed simultaneously.

参考:

- [Process and Thread Context Switching, Do You Know the Difference? ](https://medium.com/javarevisited/process-and-thread-context-switching-do-you-know-the-difference-updated-8fd93877dff6)
- [java - Difference between "call stack" and "thread stack" - Stack Overflow](https://stackoverflow.com/questions/31145052/difference-between-call-stack-and-thread-stack)
- [Memory in C – the stack, the heap, and static – The Craft of Coding](https://craftofcoding.wordpress.com/2015/12/07/memory-in-c-the-stack-the-heap-and-static/)

