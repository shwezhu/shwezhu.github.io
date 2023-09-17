---
title: Concurrency Programming - Go
date: 2023-09-04 21:35:55
categories:
 - golang
 - practice
tags:
 - golang
 - practice
 - concurrency
---

## 1. Channel





## 2. Map

**First version:**

```go
func (s *memoryStore) monitorExpiredSessions() {
	for {
    // detect every seconds
		time.Sleep(time.Second)
		memoryMutex.Lock()
		if len(s.sessions) == 0 {
			memoryMutex.Unlock()
			continue
		}
		for k, info := range s.sessions {
			if info.expiresTimestamp <= time.Now().Unix() {
				delete(s.sessions, k)
			}
		}
		memoryMutex.Unlock()
	}
}

// in other place will run this method
go s.monitorExpiredSessions()
```

**Second version:**

```go
func (s *memoryStore) monitorExpiredSessions() {
	ticker := time.NewTicker(time.Second)
  defer ticker.Stop()
	for range ticker.C {
		if s.isEmpty() {
			continue
		}
		for k, info := range s.sessions {
			if info.expiresTimestamp <= time.Now().Unix() {
				s.delete(k)
			}
		}
	}
}

func (s *memoryStore) delete(k string) {
	memoryMutex.Lock()
	defer memoryMutex.Unlock()
	delete(s.sessions, k)
}

func (s *memoryStore) isEmpty() bool {
	memoryMutex.RLock()
	defer memoryMutex.RUnlock()
	return len(s.sessions) == 0
}
```

This is not good because there is no lock when ranging map `s.sessions`, we cannot require a RLock or Lock before range, if we do that, in `s.delete()` function will `memoryMutex.Lock()` will block forever. Because we have require a lock before the range and haven't release it unitl the for loop ends. 

And I think the design of my program is not correct, I don't need to iterate the map for expirations things, I received a very good advice from [Reddit](https://www.reddit.com/r/golang/comments/169cy30/comment/jz3d914/?utm_source=share&utm_medium=web2x&context=3), and quote here:

> One other thought that might be helpful if you want to reduce the locking time. You could build this like an LRU cache, where you'd keep 2 data structures for the different operations:
>
> 1. a map, for O(1) lookups of single keys
> 2. a slice of keys to expiration times, sorted by expirations.
>
> For inserts, you'd add to the map and append to the slice, so that the slice remains sorted and the map always has all valid keys.
>
> For expiration, you'd iterate the slice until you find an unexpired key, deleting each entry from the map.
>
> There's also the concurrency-safe `sync.Map` which supports ranging.

Btw, I came across [another suggestion on Reddit](https://www.reddit.com/r/golang/comments/169cy30/comment/jz4n8fa/?utm_source=share&utm_medium=web2x&context=3), share it here:

> Also, you will probably want to use [sync.Map](https://pkg.go.dev/sync#Map) instead of standard map. The default map is not concurrent safe. 

**Third version:**

I found it's a little bit to implement because we have to keep it sorted and it's time consuming, and when iterate the slice we have to acquire another lock, because there are many requests that need create a new session which will be inserted into the slice. 

Prbably if there are enormous numbers of session, this approch would be a good choice or not, but I'm not going to implement this. But this is a very smart way especially the concept of LRU cache which I didn't know before. 

And I find [fiber memory storage](https://github.com/gofiber/storage/blob/main/memory/memory.go) on github which suits my condition provided by a [gopher](https://www.reddit.com/r/golang/comments/169cy30/comment/jz18tzh/?utm_source=share&utm_medium=web2x&context=3). 

I'll share the code here:

```go
// Adopted from: https://github.com/gofiber/storage/blob/main/memory/memory.go
func (s *cookieStore) gc() {
	ticker := time.NewTicker(s.gcInterval)
	defer ticker.Stop()
	var expired []string
	for range ticker.C {
		if s.isEmpty() {
			continue
		}
		mutex.RLock()
		for k, session := range s.sessions {
			if session.expiry <= time.Now().Unix() {
				expired = append(expired, k)
			}
		}
		mutex.RUnlock()
		mutex.Lock()
		// Double-checked locking.
		// User might have reset the max age of the session in the meantime.
		for i := range expired {
			v := s.sessions[expired[i]]
			if v.expiry <= time.Now().Unix() {
				delete(s.sessions, expired[i])
			}
		}
		mutex.Unlock()
	}
}

func (s *cookieStore) isEmpty() bool {
	mutex.RLock()
	defer mutex.RUnlock()
	return len(s.sessions) == 0
}
```

When I test this, this gets panic sometimes:

```go
panic: runtime error: invalid memory address or nil pointer dereference
```

At `v.expiry <= time.Now().Unix() `:

```go
v := s.sessions[expired[i]]
if v.expiry <= time.Now().Unix() {
  delete(s.sessions, expired[i])
}
```

This means we get a nil session from `s.sessions[expired[i]]`, which mean there is a problem with slice `expired`, I was thinking if its length is 0, the range still iterate it. Turns out the `range` won't iterate an empty slice, just do nothing. 

Then I realize that I did't update the slice, woops, we need drop the useless element in last round:

```go
...
for range ticker.C {
  // Drop useless elements in last round.
  expired = expired[:0]
  .....
}
```







