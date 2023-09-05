---
title: little tricks in golang
date: 2023-08-27 17:12:55
categories:
 - golang
 - practice
tags:
 - golang
 - practice
---

### 1. `map[string]int` 

```go
// Dup1 prints the text of each line that appears more than
// once in the standard input, preceded by its count.
counts := make(map[string]int)
input := bufio.NewScanner(os.Stdin)
for input.Scan() {
	counts[input.Text()]++
}
```

### 2. slice

```go
func (s *MemoryStore) gc() {
	ticker := time.NewTicker(s.gcInterval)
	defer ticker.Stop()
	var expired []string
	for range ticker.C {
    // create a new enpty slice whose capacity has not been changed.
		expired = expired[:0]
    // add elements to expired
    ...
    // after use the elements in expired, the elments is useless now, we can drop them
    // which is expired = expired[:0] above
		for i := range expired {
			...
		}
	}
}
```

