---
title: Golang线程和Channel
date: 2023-05-20 19:55:8
categories:
 - Golang
 - Basics
tags:
 - Golang
---



不仅疑问,  `ch := make(chan string, 6)`是啥? 一些教程也没说, 困惑

```go
func main() {
 ch := make(chan string, 6)
 go func() {
  for {
   v, ok := <-ch
   if !ok {
    fmt.Println("Finish")
    return
   }
   fmt.Println(v)
  }
 }()

 ch <- "hello"
 ch <- "world"
 close(ch)
 time.Sleep(time.Second)
}
```

