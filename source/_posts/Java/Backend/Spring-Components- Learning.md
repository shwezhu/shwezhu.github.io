---
title: Spring组件学习记录
date: 2023-04-25 22:26:22
categories:
 - Java
 - Backend
tags:
 - Java
 - Spring Boot
---

# 1. Spring Data JPA (Learn JPA & Hibernate)

- [Learn JPA & Hibernate | Baeldung](https://www.baeldung.com/learn-jpa-hibernate)

- [JPA Query Parameters Usage | Baeldung](https://www.baeldung.com/jpa-query-parameters)

补充Mybatis:

这两天启动了一个新项目因为项目组成员一直都使用的是 Mybatis，虽然个人比较喜欢 Jpa 这种极简的模式，但是为了项目保持统一性技术选型还是定了 Mybatis 。到网上找了一下关于 Spring Boot 和 Mybatis 组合的相关资料，各种各样的形式都有，看的人心累，结合了 Mybatis 的官方 Demo 和文档终于找到了最简的两种模式，花了一天时间总结后分享出来。

Orm 框架的本质是简化编程中操作数据库的编码，发展到现在基本上就剩两家了，一个是宣称可以不用写一句 Sql 的 Hibernate，一个是可以灵活调试动态 Sql 的 Mybatis ,两者各有特点，在企业级系统开发中可以根据需求灵活使用。发现一个有趣的现象：传统企业大都喜欢使用 Hibernate ,互联网行业通常使用 Mybatis 。

Hibernate 特点就是所有的 Sql 都用 Java 代码来生成，不用跳出程序去写（看） Sql ，有着编程的完整性，发展到最顶端就是 Spring Data Jpa 这种模式了，基本上根据方法名就可以生成对应的 Sql 了. 

Mybatis 初期使用比较麻烦，需要各种配置文件、实体类、Dao 层映射关联、还有一大推其它配置。当然 Mybatis 也发现了这种弊端，初期开发了[generator](https://github.com/mybatis/generator)可以根据表结果自动生产实体类、配置文件和 Dao 层代码，可以减轻一部分开发量；后期也进行了大量的优化可以使用注解了，自动管理 Dao 层和配置文件等，发展到最顶端就是今天要讲的这种模式了，`mybatis-spring-boot-starter` 就是 Spring Boot+ Mybatis 可以完全注解不用配置文件，也可以简单配置轻松上手。

现在想想 Spring Boot 就是牛逼呀，任何东西只要关联到 Spring Boot 都是化繁为简。

了解更多(原文):

- [Spring Boot(六)：如何优雅的使用 Mybatis - 纯洁的微笑博客](http://www.ityouknow.com/springboot/2016/11/06/spring-boot-mybatis.html)

- [Spring Boot3.0(七)：Mybatis 多数据源最简解决方案 - 纯洁的微笑博客](http://www.ityouknow.com/springboot/2023/01/07/spring-boot-multi-mybatis.html)

# 2. 
