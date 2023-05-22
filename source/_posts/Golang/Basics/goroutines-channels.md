---
title: Golang Goroutine和Channel
date: 2023-05-21 20:06:10
categories:
 - Golang
 - Basics
tags:
 - Golang
 - Concurrency
---

## 1. Declaring channels

A channel is a built-in data structure used for communication and synchronization between goroutines (concurrently executing functions or methods). It provides a way for goroutines to send and receive values. **Each channel has a type associated with it.** This type is the type of data that the channel is allowed to transport. No other type is allowed to be transported using the channel. 

The zero value of a channel is `nil`. `nil` channels are not of any use and hence the channel has to be defined using `make` similar to `maps` and `slices`:

```go
package main
import "fmt"

func main() {  
    var a chan int
    if a == nil {
        fmt.Println("channel a is nil, going to define it")
        // 也可以是 a = make(chan string), 即这个channel只允许通过字符串
        a = make(chan int)
        fmt.Printf("Type of a is %T", a)
    }
}
```

这个例子只是为了解释`nil ` channel是无法使用的, 实际使用我们可以直接`ch := make(chan int)`, 

## 2. Sending and receiving from a channel

channel 是两个线程用来通信的, 那怎么往channel里投放或读取信息呢?

```go
data := <- a // read from channel a  
a <- data // write to channel a  
```

## 3. Sends and receives are blocking by default

Sends and receives to a channel are blocking by default. What does this mean? When data is sent to a channel, the control is blocked in the send statement until some other Goroutine reads from that channel. Similarly, when data is read from a channel, the read is blocked until some Goroutine writes data to that channel.

This property of channels is what helps Goroutines communicate effectively without the use of explicit locks or conditional variables that are quite common in other programming languages.

## 4. Example Program

没有channel的话, 如果我们想让主程序等待子线程执行完毕再执行, 需要像下面这么写:

```go
package main

import (  
    "fmt"
    "time"
)

func hello() {  
    fmt.Println("Hello world goroutine")
}

func main() {  
    go hello()
    time.Sleep(1 * time.Second)
    fmt.Println("main function")
}
```

感觉有点笨, 这时候我们就可以利用channel的默认block特性来实现:

```go
package main

import (
	"fmt"
)

func hello(done chan bool) {
	fmt.Println("Hello world goroutine")
	done <- true
}

func main() {
	done := make(chan bool)
	go hello(done)
	// sends and receives are blocking by default
  // 只读, 也不读入某个变量即利用block特性, 阻止程序在有数据写入done之前运行
	<- done
	fmt.Println("main function")
}
```

## 5. Deadlock

One important factor to consider while using channels is deadlock. If a Goroutine is sending data on a channel, then it is expected that some other Goroutine should be receiving the data. If this does not happen, then the program will panic at runtime with `Deadlock`.

Similarly, if a Goroutine is waiting to receive data from a channel, then some other Goroutine is expected to write data on that channel, else the program will panic.

下面这个程序就会一直等待别的goroutine从`ch`读取数据, 如果没人读取, 那就会一直卡住, 

```go
package main

func main() {  
    ch := make(chan int)
    ch <- 5
}
```

## 6. Unidirectional Channels

All the channels we discussed so far are bidirectional channels, that is data can be both sent and received on them. It is also possible to create unidirectional channels, that is channels that only send or receive data. 

It is possible to convert a bidirectional channel to a send only or receive only channel but not the vice versa.

## 7. Closing channels and for range loops on channels

Senders have the ability to close the channel to notify receivers that no more data will be sent on the channel.

Receivers can use an additional variable while receiving data from the channel to check whether the channel has been closed.

```go
v, ok := <- ch  
```

In the above statement `ok` is `true` if the value was received by a successful send operation to a channel. If `ok` is `false` it means that we are reading from a closed channel. 

```go
package main

import (  
    "fmt"
)

func producer(chnl chan int) {  
    for i := 0; i < 10; i++ {
        chnl <- i
    }
    close(chnl)
}
func main() {  
    ch := make(chan int)
    go producer(ch)
    for {
        v, ok := <-ch
        if ok == false {
            break
        }
        fmt.Println("Received ", v, ok)
    }
}
```

原文: [Go (Golang) Channels Tutorial with Examples | golangbot.com](https://golangbot.com/channels/)
