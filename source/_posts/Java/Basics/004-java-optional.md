---
title: Java 8 Optional & Method Reference
date: 2023-08-06 15:44:52
categories:
 - Java
 - Basics
tags:
 - Java
---

## Optional Class

Optional 就是为了应对方法返回 null 的情况, 减少我们的 null check 代码, [下面这个视频](https://youtu.be/vKVzRbsMnTQ)讲的很好:

{% youtube vKVzRbsMnTQ %}

看完视频再啰嗦几句, 此文章看似是了解 Java 8 Optional, 其实涉及到了generics和functional interface, 了解后阅读源码也会容易很多, 因为很多都用到了这两个特性, 了解更多: 

- [Functional Interfaces & Anonymous Classes & Lambda Expressions - Java | 橘猫小八的鱼](https://davidzhu.xyz/2023/08/06/Java/Basics/003-functional-interfaces/)
- [java.lang.Object & java.lang.Class | 橘猫小八的鱼](https://davidzhu.xyz/2023/08/05/Java/Basics/002-reflection-object-class/)

Java 8 Optional 定义如下:

```java
// A container object which may or may not contain a non-null value. If a value is present, `isPresent()` will return `true` and `get()` will return the value. 
public final class Optional<T>
extends Object
```

之前讨论的 [`java.lang.Class`](https://davidzhu.xyz/2023/08/05/Java/Basics/002-reflection-object-class/), 也是一个类包装器, 若一个函数的返回值为 ` Optional<?>` 则就是返回` Optional<?>` 的对象, 这很容易看出来, 不要加个泛型就迷了, 如一个方法的签名为 ` public Cat foo();`  则该方法返回的一定是 ` Cat`  的对象, 

## Method Reference

学 Spring Security, 看到一段自定义代码, 用来获取通过 Open ID 登录用户的 email:

```java 
private static String getName(Authentication authentication) {
        return Optional.of(authentication.getPrincipal())
                .filter(OidcUser.class::isInstance)
                .map(OidcUser.class::cast)
                .map(OidcUser::getEmail)
                .orElseGet(authentication::getName);
}
```

首先是 `filter()`, 

```java
// If a value is present, and the value matches the given predicate, return an Optional describing the value, otherwise return an empty Optional.
public Optional<T> filter(Predicate<? super T> predicate);
```

该方法返回的是 ` Optional<T> ` 对象, 与 ` Optional.of()` 返回值相同, 参数类型是一个 functional interface, 即 ` Predicate<? super T>` , 可以看看其定义, 

``` java
@FunctionalInterface
public interface Predicate<T> {
    boolean test(T t);
    ...
}
```

如果你了解 functional interface, 不难发现对于这种参数类型我们可以直接传 lambda expression, 但是上面代码传的是 `OidcUser.class::isInstance` 这是什么鬼? 

> **Method references are a special type of lambda expressions**. They're often used to create simple lambda expressions by referencing existing methods. [Method References in Java](https://www.baeldung.com/java-method-references)

不得不说, Java 8 带来了很多的新的特性啊: Optional, Method Reference, Lambda, 







