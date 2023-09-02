---
title: little tricks in golang
date: 2023-08-27 17:12:55
categories:
 - Golang
 - Practice
tags:
 - Golang
 - Practice
---

## 1. `map[string]int` 

```go
// Dup1 prints the text of each line that appears more than
// once in the standard input, preceded by its count.
counts := make(map[string]int)
input := bufio.NewScanner(os.Stdin)
for input.Scan() {
	counts[input.Text()]++
}
```

