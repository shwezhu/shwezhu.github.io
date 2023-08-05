---
title: Spring Security (2), Spring学习(五)
date: 2023-08-05 09:06:50
categories:
 - Java
 - Backend
tags:
 - Java
 - Spring Boot
---







## 几个重要的类

AuthenticationManager

```java
public interface AuthenticationManager {
  Authentication authenticate(Authentication authentication) throws AuthenticationException;
}
```

- ProviderManager
- AuthenticationProviders



本文主要参考: https://youtu.be/iJ2muJniikY