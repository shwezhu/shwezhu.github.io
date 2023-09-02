---
title: Hyper-Threading & Physical Threads
date: 2023-05-28 15:47:18
categories:
 - cs basics
tags:
 - concurrency
 - cs basics
---

## 1. CPU 结构

单核CPU的基本结构如下:

![a](/006-cpu-architecture/a.png)

可以看到CPU核心分为三个部分 ALU, CU 以及 Memory (Register + Cache), 然后由通过总线进行IO与Main Memory进行通信, 

那么多核CPU即有多个这种独立的核心(ALU, CU, Memory (Register + Cache))执行命令, 最后的结果交给与CPU相连的总线进行处理, 多核CPU架构如下:

![b](/006-cpu-architecture/b.png)

## 2. Hyper-Threading & Physical Threads

A single physical CPU core with hyper-threading or simultaneous multithreading appears as two logical CPUs to an operating system. The CPU is still a single CPU, so it’s a little bit of a cheat. While the operating system sees two CPUs for each core, the actual CPU hardware only has a single set of execution resources for each core. The CPU pretends it has more cores than it does, and it uses its own logic to speed up program execution. In other words, the operating system is tricked into seeing two CPUs for each actual CPU core.

Hyper-threading allows the two logical CPU cores to share physical execution resources. This can speed things up somewhat — if one virtual CPU is stalled and waiting, the other virtual CPU can borrow its execution resources. Hyper-threading can speed your system up, but it’s nowhere near as good as having actual additional cores.

Most processors can use a process called simultaneous multithreading or, if it’s an Intel processor, **Hyper-threading** (the two terms mean the same thing) to **split a core into virtual cores, which are called threads**. For example, AMD CPUs with four cores use simultaneous multithreading to provide eight threads, and most Intel CPUs with two cores use Hyper-threading to provide four threads. 

Some apps take better advantage of multiple threads than others. Lightly-threaded apps, like games, don't benefit from a lot of cores, while most video editing and animation programs can run much faster with extra threads.

> **Note:** Strictly speaking, *only* Intel processors have hyper-threading, however, the term is sometimes used colloquially to refer to any kind of simultaneous multithreading. 

The Windows Task Manager shows this fairly well. Here, for example, you can see that this system has one actual CPU (socket) and 8 cores. Simultaneous multithreading makes each core look like two CPUs to the operating system, so it shows 16 logical processors.

![c](/006-cpu-architecture/c.png)

参考:

- [CPU Basics: What Are Cores, Hyper-Threading, and Multiple CPUs?](https://www.howtogeek.com/194756/cpu-basics-multiple-cpus-cores-and-hyper-threading-explained/)
- [Differences Between Core and CPU | Baeldung on Computer Science](https://www.baeldung.com/cs/core-vs-cpu)
- [What Is a CPU Core? A Basic Definition | Tom's Hardware](https://www.tomshardware.com/news/cpu-core-definition,37658.html)

