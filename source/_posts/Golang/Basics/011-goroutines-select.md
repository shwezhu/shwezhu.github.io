---
title: Golang并发学习之Select
date: 2023-05-21 21:22:11
categories:
 - Golang
 - Basics
tags:
 - Golang
 - Concurrency
---

实现贪吃蛇的时候用一个单独的goroutine去监听键盘的输入, 另一个线程负责打印更新游戏的每一帧(让蛇动起来), 如果游戏退出想结束监听键盘的goroutine, 可能想到到的方法是这样:

```go
func handleInput(quit chan bool) {
	for {
		if _, ok := <- quit; !ok {
			return
		}
		...
}

func main() {
	quit := make(chan bool)
	go handleInput(quit)
	for !gameOver {
		...
	}
	close(quit)
}
```

可是在[Golang Goroutine和Channel](https://davidzhu.xyz/2023/05/21/Golang/Basics/010-goroutine-channels/)介绍了channel是阻塞的, 也就是说`handleInput(quit chan bool) `会卡在第一行即等待channel `quit`那头有数据发过来, 这样显然无法实现我们想要达到的目的, 

这个时候就要介绍一下select, 做linux网络编程可能会比较熟悉这个, select不是多路复用里面的概念吗, poll, epoll, 概念类似即阻塞轮训监听, 使用select的default case, 便可以实现我们想要的:

```go
func handleInput(quit chan bool) {
	for {
		select {
		case <- quit:
			close(quit)
			return
		default:
			// 监听键盘输入
	}
}

func main() {
  ...
	quit := make(chan bool)
	go handleInput(quit)

	for !gameOver {
		...
	}

	quit <- true
}
```

## 1. What is *select*?

The `select` statement is used to choose from multiple send/receive channel operations. **The select statement blocks until** one of the send/receive operations is ready. If multiple operations are ready, one of them is chosen at random. 

```go
func server1(ch chan string) {  
    time.Sleep(6 * time.Second)
    ch <- "from server1"
}
func server2(ch chan string) {  
    time.Sleep(3 * time.Second)
    ch <- "from server2"

}
func main() {  
    output1 := make(chan string)
    output2 := make(chan string)
    go server1(output1)
    go server2(output2)
    select {
    case s1 := <-output1:
        fmt.Println(s1)
    case s2 := <-output2:
        fmt.Println(s2)
    }
}
```

Let's assume we have a mission critical application and we need to return the output to the user as quickly as possible. The database for this application is replicated and stored in different servers across the world. Assume that the functions `server1` and `server2` are in fact communicating with 2 such servers. The response time of each server is dependant on the load on each and the network delay. We send the request to both the servers and then wait on the corresponding channels for the response using the `select` statement. The server which responds first is chosen by the select and the other response is ignored. This way we can send the same request to multiple servers and return the quickest response to the user :).

## 2. Default case

The default case in a `select` statement is executed when none of the other cases is ready. **This is generally used to prevent the select statement from blocking**.

```go
func main() {
  quit := make(chan bool)
  go func() {
    for {
        select {
        case <- quit:
            return
        default:
            // Do other stuff
        }
    }
  }()
  
  // Do other stuff
 // Quit goroutine
 quit <- true 
}
```

原文: [Go (Golang) Select Tutorial with Practical Examples | golangbot.com](https://golangbot.com/select/)