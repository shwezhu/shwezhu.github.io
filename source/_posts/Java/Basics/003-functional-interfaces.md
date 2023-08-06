---
title: Functional Interfaces & Anonymous Classes & Lambda Expressions - Java
date: 2023-08-06 12:03:53
categories:
 - Java
 - Basics
tags:
 - Java
---

## 1. Anonymous Classes

- Anonymous Class Extending a Class
- Anonymous Class Implementing an Interface

如何理解呢, 如 `Cat cat = new Cat() {...}`, 若 Cat 是个类, 那对象 ` cat` 就是个类型为匿名的类, 只不过这个类继承了 ` Cat` , 同理若 ` Cat` 是个接口 interface, 那对象 ` cat` 的类型就是 a class that implements the interface ` Cat` , 具体可参考下面[这个视频](https://www.youtube.com/watch?v=DwtPWZn6T1A), 讲得很好:

{% youtube DwtPWZn6T1A %}

## 2. Functional Interfaces & Lambda Expressions 

- 若想定义一个方法, 且这个方法的参数也是一个方法, 就可以考虑使用 functional interface
- All a Lambda is, is a shorcut to define an implementation of a functional interface. 
- Functional interface 只可以有一个 abstract method, 最好使用注解` @FunctionalInterface` , 它告诉编译器相关信息, 若接口有多个 abstract methods, 那编译器就会报错, 
- 常见的 functional interface 有: Runnable, ActionListener, and Comparable, 

举个例子, Java 创建线程一般如下:

```java
public class Main {
    public static void main(String[] args) {
        // Creating and starting a thread using lambda expression
        Thread myThread = new Thread(() -> {
            // Code to be executed in the thread
            System.out.println("Thread is running");
        });

        myThread.start();
    }
}
```

你看 ` Thread() ` 的构造方法可以接受一个 lambda 表达式, 我们去看看其函数原型, 

```java
public Thread(Runnable task) {
        ...
}
```

此时不用看, `Runnable` 肯定是个 functional interface, 不然是没办法接受 lambda的, 

```java
/**
 * Represents an operation that does not return a result.
 *
 * <p> This is a {@linkplain java.util.function functional interface}
 * whose functional method is {@link #run()}.
 *
 * @author  Arthur van Hoff
 * @see     java.util.concurrent.Callable
 * @since   1.0
 */
@FunctionalInterface
public interface Runnable {
    /**
     * Runs this operation.
     */
    void run();
}
```

具体参考[下面这个视频](https://youtu.be/), 讲的很好:

{% youtube tj5sLSFjVj4 %}
