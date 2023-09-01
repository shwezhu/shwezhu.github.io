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

## 1. `select` will block if none of its case cannot run

A `select` blocks until one of its cases can run, then it executes that case. It chooses one at random if multiple are ready.

```go
// This goroutine will sleep forever
s := make(chan int)
select {
// write to an unbuffered channel operation 
// will block unitl the value stored in the channel get read 
case s<- 1:
	fmt.Println("write 1 to s")
case <-s:
	fmt.Println("read from s")
}

// This goroutine won't sleep
s := make(chan int, 1)
select {
case s<- 1:
	fmt.Println("write 1 to s")
case <-s:
	fmt.Println("read from s")
}
```

## 2. Default case

The `default` case in a `select` statement is executed when none of the other cases is ready. **This is generally used to prevent the select statement from blocking**. 

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

## 3. Practice

实现贪吃蛇的时候用一个 goroutine 监听键盘输入, 另一个 goroutine 打印每一帧, 

```go
func monitorInput() {
	for {
    // monitor input, turn left, right and set gameOver=true if user input 'q'/'Q'
    ...
  }
}

// 'quitSignal' is global variable
func main() {
  go monitorInput()
	for !gameOver {
		update()
		time.Sleep(refreshRate)
	}
}
```

想在退出游戏的时候让线程函数 `monitorInput()` 也结束运行而不是一直 for 循环:

```go
func monitorInput() {
	for {
		select {
		case <-quitSignal:
			close(quitSignal)
			return
		default:
      // monitor input, turn left, right and set gameOver = true if user input 'q'/'Q'
      ...
  }
}

// 'gameOver' and 'quitSignal' are global variables
func main() {
  go monitorInput()
	for !gameOver {
		update()
		time.Sleep(refreshRate)
	}
	quitSignal <- struct{}{}
}
```

