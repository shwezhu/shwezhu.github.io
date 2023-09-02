---
title: Context Switching
date: 2023-05-27 16:29:15
categories:
 - cs basics
tags:
 - concurrency
 - cs basics
---

## 1. Context Switch

In a CPU, the term "context" refers to the data in the registers and program counter (PC) at a specific moment in time. A register holds the current CPU instruction. A program counter, also known as an instruction address register, is a small amount of fast memory that holds the **address of the instruction** to be executed immediately after the current one.

In computing, a context switch is the process of storing the state of a process or thread, so that it can be restored and resume execution at a later point, and then restoring a different, previously saved, state. 分两步, 先存一个线程或进程的state然后再恢复另一个的state去执行. 

## 2. Two Data Structure: PCB & TCB

上面说的state就是线程进程相关的信息, 分别在PCB (Process) 和TCB (Thread) 中, 

### 2.1 Process Control Block (PCB)

A process control block (PCB) contains information about the process, i.e. registers, PID, priority, etc. The process table is an array of PCBs, that means logically contains a PCB for all of the current processes in the system. 

这里列举一些基础的PCB的内容(省略了一些, 具体可以去维基百科查看):

- Process State – new, ready, running, waiting, dead;
- Process Number (PID) – unique identification number for each process (also known as Process ID);
- Program Counter (PC) – a pointer to the address of the next instruction to be executed for this process;
- CPU Registers – register set where process needs to be stored for execution for running state;

### 2.2 **Thread Control Block** (**TCB**)

An example of information contained within a TCB is:

- Thread Identifier: Unique id (tid) is assigned to every new thread
- Stack pointer: Points to thread's stack in the process
- Program counter (PC): Points to the current program instruction of the thread
- State of the thread (running, ready, waiting, start, done)
- Thread's register values
- Pointer to the Process control block (PCB) of the process that the thread lives on

## 3. Cost of Context Switch

Switching from one process to another requires a certain amount of time for doing the administration – saving and loading registers and memory maps, updating various tables and lists, etc. 

For example, in the Linux kernel, context switching involves ***loading the corresponding process control block (PCB)*** stored in the PCB table in the kernel stack to retrieve information about the state of the new process. ***CPU state information*** including the registers, stack pointer, and program counter as well as memory management information like segmentation tables and page tables (unless the old process shares the memory with the new) are loaded from the PCB for the new process. To avoid incorrect address translation in the case of the previous and current processes using different memory, ***the translation lookaside buffer (TLB)*** must be flushed. This negatively affects performance because every memory reference to the TLB will be a miss because it is empty after most context switches. 

Furthermore, analogous context switching happens between [user threads](https://en.wikipedia.org/wiki/User_thread), notably [green threads](https://en.wikipedia.org/wiki/Green_thread), and is often very lightweight, saving and restoring minimal context. In extreme cases, such as switching between goroutines in [Go](https://en.wikipedia.org/wiki/Go_(programming_language)), a context switch is equivalent to a [coroutine](https://en.wikipedia.org/wiki/Coroutine) yield, which is only marginally more expensive than a [subroutine](https://en.wikipedia.org/wiki/Subroutine) call.

## 4. When Context Switch Happens

### 4.1. System Calls

 When a process makes any system calls, the OS switches the mode of the kernel and saves that process in context, and executes the system call.

### 4.2. Interrupt Handling

Modern architectures are [interrupt](https://en.wikipedia.org/wiki/Interrupt) driven. This means that if the CPU requests data from a disk, for example, it does not need to [busy-wait](https://en.wikipedia.org/wiki/Busy-wait) until the read is over; it can issue the request (to the I/O device) and continue with some other task. When the read is over, the CPU can be *interrupted* (by a hardware in this case, which sends interrupt request to [PIC](https://en.wikipedia.org/wiki/Programmable_interrupt_controller)) and presented with the read. For interrupts, a program called an *[interrupt handler](https://en.wikipedia.org/wiki/Interrupt_handler)* is installed, and it is the interrupt handler that handles the interrupt from the disk.

### 4.3. User and Kernel Mode Switching

This trigger is used when the OS needed to switch between the user mode and kernel mode.

## 5. Performance

Context switching itself has a cost in performance, due to running the task scheduler, **TLB flushes**, and indirectly due to sharing the CPU cache between multiple tasks. **Switching between threads of a single process can be faster than between two separate processes, because threads share the same virtual memory maps, so a TLB flush is not necessary**.

The time to switch between two separate processes is called the process switching latency. The time to switch between two threads of the same process is called the thread switching latency. The time from when a hardware interrupt is generated to when the interrupt is serviced is called the interrupt latency. 

Considering a general arithmetic addition operation A = B+1. The instruction is stored in the [instruction register](https://en.wikipedia.org/wiki/Instruction_register) and the [program counter](https://en.wikipedia.org/wiki/Program_counter) is incremented. A and B are read from memory and are stored in registers R1, R2 respectively. In this case, B+1 is calculated and written in R1 as the final answer. This operation as there are sequential reads and writes and there's no waits for [function calls](https://en.wikipedia.org/wiki/Subroutine) used, hence no context switch/wait takes place in this case.

However, certain special instructions require [system calls](https://en.wikipedia.org/wiki/System_call) that require context switch to wait/sleep processes.  A system call handler is used for context switch to kernel mode. A display(data x) function may require data x from the Disk and a device driver in kernel mode, hence the display() function goes to sleep and waits on the READ operation to get the value of x from the disk, causing the program to wait and a wait for function call to the released setting the current statement to go to sleep and wait for the syscall to wake it up. 

## 6. Conclusion 

- program counter (PC): processor register, stores the address of next instruction to be executed.
- context switch: store state, restore state
- cause context siwtch
  - system call
  -  interrupt handling: CPU requests data from a disk

参考:

- [Context switch](https://en.wikipedia.org/wiki/Context_switch)
- [Process control block](https://en.wikipedia.org/wiki/Process_control_block)
- [Thread control block](https://en.wikipedia.org/wiki/Thread_control_block)
- [Program counter](https://en.wikipedia.org/wiki/Program_counter)
- [Context Switch in Operating System - GeeksforGeeks](https://www.geeksforgeeks.org/context-switch-in-operating-system/)
- [Scheduling In Go : Part I - OS Scheduler](https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part1.html)

