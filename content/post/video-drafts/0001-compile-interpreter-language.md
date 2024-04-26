---
title: Compiled and Interpreted Languages - Video Draft
date: 2024-04-25 21:30:17
categories:
 - video draft
tags:
 - video draft
---

## 1. Computers only know binary code

Two ways to convert human-readable code to binary code:
- **Compilation:** The code is converted to binary code before it is executed.
- **Interpretation:** The code is converted to binary code as it is executed.

## Why a compiled binary code cannot be run on a different OS?

### ISA (Instruction Set Architecture)

> **ISA:** The CPU has a set of predefined actions called the instruction set or ISA (instruction set architecture). [source](https://arc.net/l/quote/ildxcafd)

Popular ISAs:
- x86: Intel and AMD processors, high performance. 
  - Not the case in nowadays, ARM is also used in high-performance devices.
  - One reason os that some powerful GPUs, such as NVIDIA works better with x86 processors.
- ARM: Often used in the devices with small battery, such as smartphones, embedded systems, such as snapdragon, and Apple's A-series chips, and Raspberry Pi, STM32. M-series chips. 
- MIPS: used in switches and routers, and some embedded systems. 

### OS (Operating System)

Different OSs have different system calls. We use standard libraries to make system calls, such as `printf` in C. 

## Cross-compilation

Cross-compilation is the process of compiling code for a platform different from the one on which the compiler is running. 

### Why cross-compilation?

Some machines are not powerful enough to compile the code. For example, compiling code for a micro-controller on a Raspberry Pi.

### How to cross-compile?

## Cross platform

Java - Write once, run anywhere. Benefits from the JVM. 

Python - Benefits from the Python interpreter. 

C, C++ - Cross-compile the code.

## References

> For many years, the typical answer to the "ARM CPU vs. x86?" question was that x86es are better suited to desktop and high-performance computing, while ARM chips were better suited for mobile devices. That perception changed when Apple released its ARM-based M1 chips in 2020, followed by the powerful M2 series in 2022. [source](https://arc.net/l/quote/pmsoload)

> x86 processors typically operate independently of peripheral components, such as RAM and GPUs. But ARM processors were designed to package these additional components into a central unit. That's why ARM processors operate as part of a System on Chip (SOC). [source](https://arc.net/l/quote/zvffhkyc)

> When you communicate with GPUs, you typically use graphics libraries such as OpenGL, Vulkan, or DirectX. The company that sold you the **graphics card** also provides a graphics driver that translates commands from these graphics libraries into instructions that the GPU can understand. The instructions that your graphics driver generate are in a proprietary protocol known only to a few wizards at NVIDIA and AMD who actually understand how GPUs work on a low level. Us mere mortals don't get to look under the hood at these instructions.
> Interestingly, many modern CPUs operate the same way. They take your x86 code and internally translate it into something better, faster, and chip specific. Adopted from [source](https://arc.net/l/quote/zvuupchl)

