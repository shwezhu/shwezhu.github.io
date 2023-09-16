---
title: IO in Go
date: 2023-09-14 21:57:04
categories:
 - golang
 - basics
tags:
 - golang
---





bytes, bufio, io, 

The main difference between buffered I/O and normal I/O is that buffered I/O reads or writes data in chunks rather than one byte at a time. While on the other side normal I/O reads or writes data one byte at a time. In a case where you are reading or writing a lot of data, buffered I/O can be much faster than normal I/O.  

[Golang Bufio (A Complete Guide)](https://www.kelche.co/blog/go/golang-bufio/)