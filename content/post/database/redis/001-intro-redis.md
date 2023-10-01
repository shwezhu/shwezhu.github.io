---
title: Introduce Redis - In-memory Database
date: 2023-08-18 10:40:58
categories:
 - database
tags:
 - database
 - redis
typora-root-url: ../../../../static
---

## 1. Redis data types

### 1.1. String

Redis Strings is one of the most versatile of Redis’ building blocks, a **binary-safe** data structure, binary-safe means the strings in Redis can be any binary data. In Redis, strings are multipurpose. They can store data as simple as an integer or as complex as a JPEG image file.

**Strings is an array data structure of bytes** (or words) that stores a sequence of elements, typically characters, using some character encoding. It can store any data-a string, integer, floating point value, JPEG image, serialized Ruby object, or anything else you want it to carry. 

```shell
redis> set mykey "This is a string"
OK
redis> get mykey
"This is a string"
```

### 1.2. Hash

A Redis hash is a data type that represents a **mapping between** **a string field and a string value**. There is no integer or float value in hash, just string. 

```shell
> hset bike:1 model Deimos type 'Enduro bikes' price 4972
(integer) 3
> hget bike:1 model
"Deimos"
> hget bike:1 price
"4972"
> hgetall bike:1
1) "model"
2) "Deimos"
3) "type"
4) "Enduro bikes"
5) "price"
6) "4972"
```

Note that the output of `> hget bike:1 price` is `"4972"` not `4972`, which is a string. 

On the surface, think of a hash data type as an enclosed set of key/value pairs inside the value of another key. The embedded keys are called **fields**. So a string is stored inside a **key** and inside a particular **field** within that key. 

Figure 3 shows the basics of how a hash is stored. The key is associated with a hash object. That hash object can have multiple fields (i.e., subkeys) associated with individual strings. This allows you to store more complex data types.

![a](/001-intro-redis/a.png)



{{% youtube "-KdITaRkQ-U" %}}

Source: 

- https://thenewstack.io/redis-data-types-the-basics/

- https://youtu.be/-KdITaRkQ-U?si=aAQDQfZvUhqGn800

Learn more: 

[Redis Data Types: The Basics - The New Stack](https://thenewstack.io/redis-data-types-the-basics/)

[Data Structures | Redis](https://redis.com/redis-enterprise/data-structures/)

[Redis data types | Redis](https://redis.io/docs/data-types/)

## 2. Key-value database

All data in Redis are stored as key-value pairs, **Redis keys** are always strings, **Redis values** can be strings, hashes, lists, sets or sorted sets. 

> A good practice for naming keys is to create and stick to a particular schema. For example, a common scheme for identifying objects is to use an `object-type:id` schema. So an object representing user id#1000 would be attached to the key name `user:1000`. An object representing a purchase order with an order number of 1234 might be attached to a key named `order:1234`.
>
> Additionally, keys related to the base object can use suffixes on the key. For example, while the user id#1000 can use the key `user:1000`, a queue associated with that user could use the key `user:1000:queue`.
>
> Source: https://thenewstack.io/redis-data-types-the-basics/

### 2.1. Key is always string

When you store a hash object in Redis, the key is still a string, and the value is a hash data structure:

```shell
127.0.0.1:6379> hset user:1 name Alice age 6
(integer) 2
127.0.0.1:6379> set os Ubuntu
OK
127.0.0.1:6379> keys *
1) "user:1"
2) "os"
```

As you can see there we created two key-value data above, the first one's value is a hash and second one's value is a string, that's the only difference. You may think the first key `"user:1"` a littler strange, but it's just a string, you can name it as `user-1`, `user1` or other form,  `"user:1"` is just a hash's key naming convention in Redis. 

And we use key to retrieve data:

```shell
127.0.0.1:6379> get os
"Ubuntu"
127.0.0.1:6379> hget user:1 age
"6"
127.0.0.1:6379> hgetall user:1 
1) "name"
2) "Alice"
3) "age"
4) "6"
```

Retrieving hash value in Redis is a little complited, as you can see, we use string `"user:1"` to retrieve the hash value `{"name":"Alice", "age", "6"}`, then we use the string `"age"` to get the string value `"6"`. 

### 2.2. Don't forget all is string

Note that we are in the Redis command line, therefore we don't need make the key or value string explicitly, what I mean is that the both codes belwo is fine:

```shell
127.0.0.1:6379> set "greeting" "helloworld"
OK
127.0.0.1:6379> set greeting helloworld
OK
127.0.0.1:6379> hset user:1 name Alice age 12
127.0.0.1:6379> hset "user:1" "name" "Alice" "age" "12"
```

Bu you should know that they are string!

> In Redis, a key-value pair is a fundamental data structure used for storing and retrieving data. The "key" is a unique identifier that is used to access the associated "value".
>
> A Redis hash is a data type that represents a mapping between a string field and a string value. 

## 3. Use Cases

### 3.1. Session Store

There are many ways to save sessions, in-memory, file, database and Redis, if you don't know session, please refer to: [Cookie & Session](https://davidzhu.xyz/post/cs-basics/005-session-cookie/)

### 3.2. Caching

- Cache-Aside Pattern

- Read/Write Through Pattern

- Write Behind Caching Pattern

For data that is frequently needed or retrieved by app users, a [cache](https://redislabs.com/redis-enterprise/use-cases/) would serve as a temporary data store for quick and fast retrieval without the need for extra database round trips. 

<img src="/001-intro-redis/1.png" alt="1" style="zoom:50%;" />

learn more:

- [Redis Tutorial: Exploring Data Types, Architecture, and Key Features](https://www.atatus.com/blog/redis-tutorial-exploring-data-types-architecture-and-key-features/)

- [Cache vs. Session Store | Redis](https://redis.com/blog/cache-vs-session-store/)

References: 

- [Install Redis on macOS | Redis](https://redis.io/docs/getting-started/installation/install-redis-on-mac-os/)
- [Redis CLI | Redis](https://redis.io/docs/ui/cli/)
- [Redis: In-memory database. How it works and Why you should use it | The Home of Redis Developers](https://developer.redis.com/explore/what-is-redis/)
- [Redis - Cache-Aside Pattern](https://medium.com/bliblidotcom-techblog/redis-cache-aside-pattern-72fff2e4f927)
- [全网最详细Redis教程之缓存原理&设计 - 掘金](https://juejin.cn/post/7044366350654898207)

