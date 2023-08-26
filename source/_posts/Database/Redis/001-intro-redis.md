---
title: Introduce Redis
date: 2023-08-18 10:40:58
categories:
 - Database
tags:
 - Database
---

## 1. Install & Run Redis Server

Install:

```shell
$ brew install redis
```

Run Redis in the foreground:

```shell
$ redis-server
```

As an alternative to running Redis in the foreground, you can also start the process in the background:

```shell
$ brew services start redis

$ brew services stop redis
```

## 2. Connect to Redis Server

Once Redis is running, you can connect it by running *Redis Command Line Interface* - `redis-cli`:

```shell
# run a client at terminal to connect Redis server
$ redis-cli
```

By default, `redis-cli` connects to the server at the address 127.0.0.1 with port 6379. To specify a different host name or an IP address:

```shell
$ redis-cli -h redis15.localnet.org -p 6390
```

By default, `redis-cli` uses a plain TCP connection to connect to Redis. You may enable SSL/TLS using the `--tls` option, along with `--cacert` or `--cacertdir` to configure a trusted root certificate bundle or directory.

If the target server requires authentication using a client side certificate, you can specify a certificate and a corresponding private key using `--cert` and `--key`.

### 2.1. Common Commands

```shell
$ redis-cli
127.0.0.1:6379> set name "john"
OK
127.0.0.1:6379> get name
"john"
127.0.0.1:6379> set id "001"
OK
127.0.0.1:6379> del name
(integer) 1
127.0.0.1:6379> get name
(nil)
127.0.0.1:6379> set age 10
OK
127.0.0.1:6379> keys *
1) "age"
2) "id"
```

>Redis is an open-source in-memory storage, used as a distributed, in-memory **key–value database**, cache and message broker, with optional durability. [Wikipedia](https://en.wikipedia.org/wiki/Redis)

### 2.2. Monitoring commands executed in Redis Server

All commands received by the active Redis instance will be printed to the standard output:

```shell
$ redis-cli MONITOR
OK
1692367745.525689 [0 127.0.0.1:49963] "set" "name" "jack"
1692368601.032173 [0 127.0.0.1:49963] "set" "name" "john"
1692368645.284030 [0 127.0.0.1:49963] "get" "name"
```

This means you will get all the commands that your redis server received from clients, recall that `redis-cli` will connects to the server at the address 127.0.0.1 with port 6379. 

And if your application `C1` use a Redis server `S` to save data, your another application `C2` that connects to server `S` can get that data too. When you run `redis-cli`, it start a client, and you can input `keys *` to query all key saved on your Redis server. 

## 3. Use Redis from your application

Of course using Redis just from the command line interface(*`redis-cli`*) is not enough as the goal is to use it from your application. In order to do so you need to download and install a Redis client library for your programming language. You'll find a [full list of clients for different languages in this page](https://redis.io/clients).

## 4. Use Cases for Redis

### 4.1. Session Store

There are many ways to save sessions, in-memory, file, database and Redis, if you don't know about session, please refer to: [Cookie & Session | 橘猫小八的鱼](https://davidzhu.xyz/2023/08/17/CS-Basics/005-session-cookie/)

### 4.2. Caching

For data that is frequently needed or retrieved by app users, a [cache](https://redislabs.com/redis-enterprise/use-cases/) would serve as a temporary data store for quick and fast retrieval without the need for extra database round trips. 

- **Cache-Aside Pattern** 

Here is the explanation of the Cache-Aside Pattern:

1. Cache hit. The service read data from cache. If there is the data wanted, it will return the data and the process stops here.
2. Cache miss. If the data is not stored in the cache, the service will read the data from the database.
3. Once the data is obtained, the service then stores the data to cache for future request.

![1](1.png)

- **Read/Write Through Pattern,**

- **Write Behind Caching Pattern**

References: 

- [Install Redis on macOS | Redis](https://redis.io/docs/getting-started/installation/install-redis-on-mac-os/)
- [Redis CLI | Redis](https://redis.io/docs/ui/cli/)
- [Redis: In-memory database. How it works and Why you should use it | The Home of Redis Developers](https://developer.redis.com/explore/what-is-redis/)
- [Redis - Cache-Aside Pattern](https://medium.com/bliblidotcom-techblog/redis-cache-aside-pattern-72fff2e4f927)
- [全网最详细Redis教程之缓存原理&设计 - 掘金](https://juejin.cn/post/7044366350654898207)





