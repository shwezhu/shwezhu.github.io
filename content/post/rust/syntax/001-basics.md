---
title: Rust Basics - Syntax, Types
date: 2024-05-03 23:30:17
categories:
 - rust
---

## Syntax

```rust
let mut x = 5;
let _x = 5;

// Destructuring Tuples
let (x, y, z) = (1, "hello", 3.5);
let abc = (0.1, 0.2, 0.3);

// Destructuring Structs
let Point { x: a, y: b } = Point { x: 10, y: 20 };

// Ignoring Values and Partial Destructuring
let (first, _, _, last) = (1, 2, 3, 4);
let Point { a, .. } = point;

let y: i32; // 未初始化, 不可以被使用
```

## Types

> #### [整型溢出](https://course.rs/basic/base-type/numbers.html#整型溢出)
>
> 假设有一个 `u8` ，它可以存放从 0 到 255 的值。那么当你将其修改为范围之外的值，比如 256，则会发生**整型溢出**。关于这一行为 Rust 有一些有趣的规则：当在 debug 模式编译时，Rust 会检查整型溢出，若存在这些问题，则使程序在编译时 *panic*(崩溃,Rust 使用这个术语来表明程序因错误而退出)。
>
> 在当使用 `--release` 参数进行 release 模式构建时，Rust **不**检测溢出。相反，当检测到整型溢出时，Rust 会按照补码循环溢出（*two’s complement wrapping*）的规则处理。简而言之，大于该类型最大值的数值会被补码转换成该类型能够支持的对应数字的最小值。比如在 `u8` 的情况下，256 变成 0，257 变成 1，依此类推。程序不会 *panic*，但是该变量的值可能不是你期望的值。依赖这种默认行为的代码都应该被认为是错误的代码。

> #### [浮点数陷阱](https://course.rs/basic/base-type/numbers.html#浮点数陷阱)
>
> ```rust
> fn main() {
>   // 断言0.1 + 0.2与0.3相等
>   assert!(0.1 + 0.2 == 0.3);
> }
> ```
>
> 你可能以为，这段代码没啥问题吧，实际上它会 *panic*(程序崩溃，抛出异常)，因为二进制精度问题，导致了 0.1 + 0.2 并不严格等于 0.3，它们可能在小数点 N 位后存在误差。
>
> 那如果非要进行比较呢？可以考虑用这种方式 `(0.1_f64 + 0.2 - 0.3).abs() < 0.00001` ，具体小于多少，取决于你对精度的需求。

> #### [statement & expression](https://course.rs/basic/base-type/statement-expression.html#语句和表达式)
>
> Rust 的函数体是由一系列语句组成
>
> ```tust
> fn add_with_extra(x: i32, y: i32) -> i32 {
>     let x = x + 1; // 语句
>     let y = y + 5; // 语句
>     x + y // 表达式
> }
> ```
>
> 最后由一个表达式来返回值. 语句会执行一些操作但是不会返回一个值，而表达式会在求值后返回一个值，因此在上述函数体的三行代码中，前两行是语句，最后一行是表达式。

## Ownership

在计算机语言不断演变过程中，出现了三种流派：

- **垃圾回收机制(GC)**，在程序运行时不断寻找不再使用的内存，典型代表：Java、Go
- **手动管理内存的分配和释放**, 在程序中，通过函数调用的方式来申请和释放内存，典型代表：C++
- **通过所有权来管理内存**，编译器在编译时会根据一系列规则进行检查

其中 Rust 选择了第三种，最妙的是，这种检查只发生在编译期，因此对于程序运行期，不会有任何性能上的损失。

### 一段不安全的代码

```c
int* foo() {
    int a;          // 变量a的作用域开始
    a = 100;
    char *c = "xyz";   // 变量c的作用域开始
    return &a;
}                   // 变量a和c的作用域结束
```

这段代码虽然可以编译通过，但是其实非常糟糕，变量 `a` 和 `c` 都是局部变量，函数结束后将局部变量 `a` 的地址返回，但局部变量 `a` 存在栈中，在离开作用域后，`a` 所申请的栈上内存都会被系统回收，从而造成了 `悬空指针(Dangling Pointer)` 的问题。这是一个非常典型的内存安全问题，虽然编译可以通过，但是运行的时候会出现错误, 很多编程语言都存在。

再来看变量 `c`，`c` 的值是常量字符串，存储于常量区，可能这个函数我们只调用了一次，也可能我们不再会使用这个字符串，但 `"xyz"` 只有当整个程序结束后系统才能回收这片内存。

所以内存安全问题，一直都是程序员非常头疼的问题，好在, 在 Rust 中这些问题即将成为历史，因为 Rust 在编译的时候就可以帮助我们发现内存不安全的问题. 

### Stack & Heap

因为**栈**的实现方式，栈中的所有数据都必须占用已知且固定大小的内存空间，假设数据大小是未知的，那么在取出数据时，你将无法取到你想要的数据。与栈不同，对于大小未知或者可能变化的数据，我们需要将它存储在**堆**上。当向堆上放入数据时，需要请求一定大小的内存空间。操作系统在堆的某处找到一块足够大的空位，把它标记为已使用，并返回一个表示该位置地址的**指针**, 该过程被称为**在堆上分配内存**，有时简称为 “分配”(allocating)。接着，该指针会被推入**栈**中，因为指针的大小是已知且固定的，在后续使用过程中，你将通过栈中的**指针**，来获取数据在堆上的实际内存位置，进而访问该数据。由上可知，堆是一种缺乏组织的数据结构。

在栈上分配内存比在堆上分配内存要快，因为入栈时操作系统无需进行函数调用（或更慢的系统调用）来分配新的空间，只需要将新数据放入栈顶即可。相比之下，在堆上分配内存则需要更多的工作，这是因为操作系统必须首先找到一块足够存放数据的内存空间，接着做一些记录为下一次分配做准备，如果当前进程分配的内存页不足时，还需要进行系统调用来申请更多内存。 因此，处理器在栈上分配数据会比在堆上分配数据更加高效。

### Owner Rule

1. Rust 中每一个值都被一个变量所拥有，该变量被称为值的所有者
2. 一个值同时只能被一个变量所拥有，或者说一个值只能拥有一个所有者
3. 当所有者(变量)离开作用域范围时，这个值将被丢弃(drop)

## References

[基本类型 - Rust语言圣经(Rust Course)](https://course.rs/basic/base-type/index.html)

[所有权和借用 - Rust语言圣经(Rust Course)](https://course.rs/basic/ownership/index.html)