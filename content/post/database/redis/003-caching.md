---
title: Caching in Go with Redis - Reading Notes
date: 2023-10-01 17:56:58
categories:
 - database
tags:
 - database
 - redis
 - go
typora-root-url: ../../../../static
---

Source: [Go-Redis Caching: Strategies, Best Practices & Common Pitfalls](https://voskan.host/2023/08/14/golang-redis-caching/)

## 1. What is Caching?

At its core, caching is the practice of storing a copy of data temporarily in a location for faster access upon subsequent requests. Imagine reading a thick encyclopedia. Instead of going through the entire book every time you need to reference a specific topic, you might keep a note or bookmark on pages of interest. Caching in the world of web applications follows a similar principle. Instead of fetching data from the main database, which can be time-consuming, a cached version of the data is fetched, which is significantly faster.

## 2. What is Redis?

Redis, an acronym for **Remote Dictionary Server**, is an open-source, in-memory data structure store. It can be employed as a database, cache, and even a message broker. Unlike traditional databases that read and write data to disk, Redis operates primarily in memory, which is one of the key reasons behind its lightning-fast data retrieval capabilities.

## 3. Basic Caching Strategies and Implementation in Go

To maximize the advantages of the **Go-Redis connection**, it’s imperative to employ the right caching strategy. Each strategy has its own set of merits and potential pitfalls, making the choice critical based on specific application needs. Let’s deep-dive into some basic caching strategies and their respective implementation in Go.

### 3.1. Cache-aside **(Lazy Loading)**

Cache-aside, often termed lazy loading, is a caching pattern where the application code is responsible for loading data into the cache, updating, and invalidating cache entries.

#### 3.1.1. Implementation:

1. Check the Cache:
   - Initially, the application checks the cache to determine if the desired data is present.
2. Database Call:
   - If not present in the cache, the application fetches the data from the primary data store (e.g., a database) and then places it in the cache.
3. Go Code:
   ```go
   value, err := client.Get(ctx, "key").Result()
   if err == redis.Nil { // Cache miss
       // Fetch data from database
       data := fetchDataFromDB("key")
       client.Set(ctx, "key", data, time.Hour) // Store in cache
   } else if err != nil {
       panic(err)
   } else {
       fmt.Println("Data from cache:", value)
   }
   ```

#### 3.1.2. Advantages **& Disadvantages**:

- Advantages:
  - **Minimal Initial Load**: Since data is loaded on-demand, the initial loading time is reduced.
  - **Always Updated**: Data in the cache is guaranteed to be current since it’s fetched only when needed.
- Disadvantages:
  - **Latency**: The first-time data is fetched (cache miss) has an additional latency since it requires a database call.
  - **Stale Data**: If not managed correctly, there can be periods where stale data remains in the cache.

### 3.2. Write-through **Cache**

In a write-through caching strategy, every write to the application data also writes to the cache. The cache is always updated with fresh data.

#### 3.2.1. **Implementation**:

1. Write Operation:

   - Every time there’s a write operation to the primary data store, the same data is written to the cache.

2. **Go Code**:

   ```go
   // Data update function
   func updateData(key string, value string) {
       updateDatabase(key, value)  // Update primary data store
       client.Set(ctx, key, value, time.Hour)  // Update cache
   }
   ```

#### 3.2.2 Advantages **& Disadvantages**:

- Advantages:
  - **Data Consistency**: The cache always contains the latest data.
  - **Read Speed**: Read operations are fast as data is always available in the cache.
- Disadvantages:
  - **Write Penalty**: Every write operation comes with an overhead of updating the cache.
  - **Resource Intensive**: It can be resource-intensive for write-heavy applications.

### 3.3. Write-behind **(or Write-back) Cache**

Here, the application writes directly to the cache, which then periodically updates the primary data store. This reduces the latency associated with every write operation.

#### 3.3.1. Implementation:

1. Buffered Writes:

   - Writes are buffered in the cache and are periodically flushed to the primary data store.

2. **Go Code**:

   ```go
   // Buffered data update function
   func bufferedUpdate(key string, value string) {
       client.Set(ctx, key, value, time.Hour)  // Update cache
       // A separate routine or process will flush the cache to the primary data store
   }
   ```

#### 3.3.2. Advantages **& Disadvantages**:

- Advantages:
  - **Fast Writes**: Write operations are speedy since they only update the cache initially.
  - **Batch Processing**: Periodic flushing can leverage batch processing for efficiency.
- Disadvantages:
  - **Data Loss**: If the cache fails before a flush, data can be lost.
  - **Complexity**: Implementing a reliable flushing mechanism adds complexity.

### 4. **Eviction** Policies: **Keeping Your Cache Optimized**

Redis provides several eviction policies, ensuring optimal use of memory:

1. No Eviction:
   - Redis returns errors when the memory limit is reached.
2. AllKeys LRU:
   - Evicts least recently used keys first.
3. AllKeys Random:
   - Evicts random keys.
4. Volatile LRU:
   - Evicts least recently used keys, but only among those set to expire.
5. Volatile Random:
   - Random eviction, but only among keys with an expiration set.
6. Volatile TTL:
   - Evicts the keys with the nearest expiration time first.

In Go, you can set the desired eviction policy using:

```go
client.ConfigSet(ctx, "maxmemory-policy", "allkeys-lru")
```

## 5. **Best Practices for Go-Redis Caching**

### 5.1. **Cache** key naming conventions

Choosing an appropriate naming convention for your cache keys can significantly improve cache manageability, readability, and prevent key collisions.

1. Descriptive Names: A key should provide hints about the data it holds.

   - *Bad*: `k1234`
   - *Good*: `user:profile:1234`

2. Namespacing: Use colons `:` for separating different parts of your keys to simulate namespaces.

   - Example: `post:comments:4567`

3. Versioning: When your data structure changes, you can use versioning in your keys to avoid conflicts.

   - Example: `v2:user:profile:1234`

4. Keep It Concise: While descriptiveness is essential, long keys take more memory.

   - Example in Go:

     ```go
     key := fmt.Sprintf("post:%d:comments", postID)
     ```

### 5.2. **Handling** Cache **Misses Efficiently**

Cache misses can be expensive. Here’s how to manage them wisely:

1. Implementing a Loading Strategy:
   - On a cache miss, fetch the data from the primary data source and load it into the cache for future requests. This can be implemented with the Cache-aside (Lazy Loading) pattern we discussed earlier.
2. Avoid Cache Stampede:
   - This occurs when multiple clients try to read a key that’s missing from the cache, causing them all to hit the database simultaneously. One way to avoid this is by using a mutex or a semaphore to ensure only one client fetches from the database.
3. Set Reasonable TTLs (Time-To-Live):
   - For infrequently changed data, longer TTLs are apt, while frequently changed data benefits from shorter TTLs.

## 6. Common Pitfalls in Go-Redis Caching and How to Avoid Them

### 6.1. Not Considering Serialization Costs

1. **The Pitfall**: Overlooking the time and CPU overhead of serializing and deserializing data when caching complex data structures.
2. **The Solution**: Choose efficient serialization libraries and formats. In Go, libraries like `encoding/gob` or third-party solutions like `msgpack` can be considered. Test serialization strategies to see which works best for your specific data types and access patterns.

e.g., 

[Serialization of cache items (encoding/gob?)](https://www.reddit.com/r/golang/comments/9krlqv/serialization_of_cache_items_encodinggob/)

I switched our in-memory caching to Redis and used `encoding/gob` to serialize the cache items. It seemed nice considering it carries type info and gave my "generic" caches a nice api (as I could just keep the redis store as an interchangeable `Store` interface, easily switched out for an in-memory cache without serialization or whatever), and benchmarked quite well as compared to json. But now I'm seeing a pretty massive CPU usage on our servers, and having read a bit more it might not have been a great use case for gob, which apparently is better suited for streams of data where one encoder instance is "paired" to one decoder instance. I end up having to initialize `GobEncoder` and `GobDecoder` on every ser/deser, and I suspect it's taking a pretty heavy toll on CPU.

Is there any way around this while still using gob? I tried keeping an encoder/decoder alive with a buffer along with a mutex, and clearing the buffer with `buffer.Reset()` on every ser/deser, but that fails. There seems to be more internal state to gob than that.

What other serialization formats do people normally use for storing stuff in redis or equivalent?

**Comments:**

**OP:** The thing I'm unsure about is whether gob is a viable solution for these "one off" ser/deserializations? Since it's primarily meant for streams of data, and I end up using something like:

```go
func Serialize(item Item) ([]byte, error) {
	b := new(bytes.Buffer)
	if err := gob.NewEncoder(b).Encode(item); err != nil {
		return nil, err
	}
	return b.Bytes(), nil
}

func Deserialize(data []byte) (*Item, error) {
	b := bytes.NewBuffer(data)
	var item Item
	return &item, gob.NewDecoder(b).Decode(&item)
}
```

**Someone:** Yeah, gob isn't the best fit for storing singular values.

https://golang.org/pkg/encoding/gob/#Encoder.Encode

> ... guaranteeing that all necessary type information has been transmitted first.

This could be the gotcha you're facing, https://golang.org/src/encoding/gob/decoder.go#L153 will likely end up running for every single value (as each stored value is in effect a complete stream with a single element).

edit: https://github.com/alecthomas/go_serialization_benchmarks may be helpful

**Someone:** You'll also find that gob uses more space than many other encodings when storing singular values - it's just not suited to this task.

**OP:** Ended up using msgpack as it performed way, way better for this single value scenario. Gob is just meant for streaming I suppose.

### 6.2. Cache Invalidation Woes

1. **The Pitfall**: Not invalidating or updating the cache when the underlying data changes, leading to stale data being served.
2. **The Solution**: Implement a robust cache invalidation strategy. This might include setting appropriate TTLs, using write-through caching, or manually invalidating keys when data changes.

### 6.3. Not Preparing for Redis Failures

1. **The Pitfall**: Failing to consider scenarios where the Redis server might become unavailable.
2. **The Solution**: Implement redundancy using Redis Sentinel or Redis Cluster. On the application side, ensure that your Go application can handle Redis downtimes gracefully, potentially serving stale data or reverting to the primary data source.

Learn more: 

- [Complete Guide to Redis in Go - From Installation to Advanced Features | Master Redis with Golang](https://voskan.host/2023/08/10/redis-and-golang-complete-guide/)
- [Go-Redis Caching: Strategies, Best Practices & Common Pitfalls](https://voskan.host/2023/08/14/golang-redis-caching/)
