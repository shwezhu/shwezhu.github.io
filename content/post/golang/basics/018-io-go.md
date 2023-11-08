---
title: IO in Go
date: 2023-09-14 21:57:04
categories:
 - golang
 - basics
tags:
 - golang
---

## 1. Open and read file

```go
file, err := os.Open(filepath)
if err != nil {
  ...
}

buf := make([]byte, 512)
n, err := file.Read(buf)
if err != nil {
  ...
}
```



bytes, bufio, io, 

The main difference between buffered I/O and normal I/O is that buffered I/O reads or writes data in chunks rather than one byte at a time. While on the other side normal I/O reads or writes data one byte at a time. In a case where you are reading or writing a lot of data, buffered I/O can be much faster than normal I/O.  

[Golang Bufio (A Complete Guide)](https://www.kelche.co/blog/go/golang-bufio/)