---
title: Java 8 Optional
date: 2023-08-06 15:44:52
categories:
 - Java
 - Basics
tags:
 - Java
---

定义, 

```java
public final class Optional<T>
extends Object
```

A container object which may or may not contain a non-null value. If a value is present, `isPresent()` will return `true` and `get()` will return the value. 

之前讨论的 [`java.lang.Class`](https://davidzhu.xyz/2023/08/05/Java/Basics/002-reflection-object-class/), 也是一个类包装器, 若一个函数的返回值为 ` Optional<?>` 则就是返回` Optional<?>` 的对象, 这很容易看出来, 不要加个泛型就迷了, 如一个方法的签名为 ` public Cat foo();`  则该方法返回的一定是 Cat 的对象, 

---

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
public Optional<T> filter(Predicate<? super T> predicate)
```

基(根)本看不懂, 恶补了一下: 
