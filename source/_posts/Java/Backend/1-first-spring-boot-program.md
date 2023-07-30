---
title: 第一个Spring Boot项目及踩坑总结 Spring学习(一)
date: 2023-07-29 16:47:46
categories:
 - Java
 - Backend
tags:
 - Java
 - Spring Boot
---

## 错误总结

**(1) 所有Java代码**都要在`java`目录下, 即不可删除`java`目录, 否则, 运行`./mvnw clean package`报错, 你可以自己试试

```shell
├── pom.xml
├── src
│   ├── main
│   │   ├── java
│   │   │   └── com
│   │   │       ├── MyAppApplication.java
│   │   │       └── restservice
│   │   │           ├── Greeting.java
│   │   │           └── GreetingController.java
```

**(2) controller** 等组件所在文件夹需要在主类的同级或者次级目录, 否则运行程序访问`http://localhost:8080/greeting`会出现错误:

```shell
Whitelabel Error Page 
This application has no explicit mapping for /error, so you are seeing this as a fallback. 
Tue Jun 30 17:24:02 CST 2023 There was an unexpected error (type=Not Found, status=404). No message available 
```

主类就是被`@SpringBootApplication`修饰的那个类, 

正确结构:

```shell
├── java
│   └── com
│       ├── MyAppApplication.java
│       └── restservice
│           ├── Greeting.java
│           └── GreetingController.java
# or
├── java
│   └── com
│       ├── MyAppApplication.java
│       ├── Greeting.java
│       └── GreetingController.java
```

错误结构: 

```shell
├── java
│   ├── com
│   │   └── MyAppApplication.java
│   └── restservice
│       ├── Greeting.java
│       └── GreetingController.java
```

具体可参考: [spring - This application has no explicit mapping for /error - Stack Overflow](https://stackoverflow.com/questions/31134333/this-application-has-no-explicit-mapping-for-error)

## 新概念 Record Class

`Greeting` 与传统的类不同, 没有构造函数, 更像是个函数, `Greeting.java`:

```java
package com.restservice;
public record Greeting(long id, String content) { }
```

这是Java14的新特性, 具体参考: [Java Records vs POJO](https://shixseyidrin.medium.com/java-records-vs-pojo-bb7dd26f43f0)

这里有个新概念叫 *POJO* Class: [What Is a Pojo Class? | Baeldung](https://www.baeldung.com/java-pojo-class)

## Jackson 

可能会好奇, 为什么没有用 json 库, 直接返回是一个Greeting对象,但得到的内容却是 json 格式的信息呢?  教程里给的解释:

> This application uses the Jackson JSON library to automatically marshal instances of type `Greeting` into JSON. Jackson is included by default by the web starter.

原来是 spring boot 集成了 Jackson, 代码里没有用相关的代码是因为Spring Boot 用了 *ObjectMapper* , 

>When using JSON format, Spring Boot will use an *ObjectMapper* instance to **serialize responses and deserialize requests**. [Spring Boot: Jackson ObjectMapper](https://www.baeldung.com/spring-boot-customize-jackson-objectmapper)

## 源码解释

 项目创建过程可参考: [Getting Started | Building a RESTful Web Service](https://spring.io/guides/gs/rest-service/)

```java
// MyApplicaiton.java
package com;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MyAppApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyAppApplication.class, args);
    }
}
```

 ```java
// Greeting.java
package com.restservice;
public record Greeting(long id, String content) { }
 ```

```java
// GreetingController.java
package com.restservice;

import java.util.concurrent.atomic.AtomicLong;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GreetingController {
    private static final String template = "Hello, %s!";
    private final AtomicLong counter = new AtomicLong();

    @GetMapping("/greeting")
    public Greeting greeting(@RequestParam(value = "name", defaultValue = "World") String name) {
        return new Greeting(counter.incrementAndGet(), String.format(template, name));
    }
}
```

- The `@GetMapping` annotation ensures that HTTP GET requests to `/greeting` are mapped to the `greeting()` method.
- There are companion annotations for other HTTP verbs (e.g. `@PostMapping` for POST). There is also a `@RequestMapping` annotation that they all derive from, and can serve as a synonym (e.g. `@RequestMapping(method=GET)`).
- `@RequestParam` binds the value of the query string parameter `name` into the `name` parameter of the `greeting()` method. If the `name` parameter is absent in the request, the `defaultValue` of `World` is used.
- This code uses Spring [`@RestController`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/bind/annotation/RestController.html) annotation, which marks the class as a controller where every method returns a domain object instead of a view. It is shorthand for including both `@Controller` and `@ResponseBody`.
- The `Greeting` object must be converted to JSON. Thanks to Spring’s HTTP message converter support, you need not do this conversion manually. Because [Jackson 2](https://github.com/FasterXML/jackson) is on the classpath, Spring’s [`MappingJackson2HttpMessageConverter`](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/http/converter/json/MappingJackson2HttpMessageConverter.html) is automatically chosen to convert the `Greeting` instance to JSON.
- `@SpringBootApplication` is a convenience annotation that adds all of the following:
  - `@Configuration`: Tags the class as a source of bean definitions for the application context.
  - `@EnableAutoConfiguration`: Tells Spring Boot to start adding beans based on classpath settings, other beans, and various property settings. For example, if `spring-webmvc` is on the classpath, this annotation flags the application as a web application and activates key behaviors, such as setting up a `DispatcherServlet`.
  - `@ComponentScan`: Tells Spring to look for other components, configurations, and services in the `com/example` package, letting it find the controllers.

最后一个没怎么看明白, 也不打算现在弄明白, 想着随着学习的深入, 慢慢的对 spring 有个更清晰的认识的时候, 就慢慢懂了, 

If you use Maven, you can run the application by using `./mvnw spring-boot:run`. Alternatively, you can build the JAR file with `./mvnw clean package` and then run the JAR file, as follows:

```
java -jar target/gs-rest-service-0.1.0.jar
```

Now that the service is up, visit `http://localhost:8080/greeting`
