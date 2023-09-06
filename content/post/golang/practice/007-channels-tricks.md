---
title: Go Channels Use Cases in Practice
date: 2023-09-06 14:05:55
categories:
 - golang
 - practice
tags:
 - golang
 - practice
 - concurrency
---

Previous post: [Goroutine & Channel - Go Basics - David's Blog](https://davidzhu.xyz/post/golang/basics/010-goroutine-channels/)

## 1. Pass a slice to channel

```go
func main() {
	ready := make(chan []string)
  
	go func() {
		var expired []string
		expired = append(expired, "Coco")
		expired = append(expired, "Bella")
		ready<- expired
	}()
  
	go func() {
    // this will block until there is data sent to cahnnel ready
		for s := range ready {
			for _, name := range s{
				fmt.Println(name)
			}
		}
	}()
  
	time.Sleep(time.Second)
}
```

Bacsuse a slice likes a pointer, the two goroutines above share a same underlying array. If you want make a copy, you can find it in my another post: [Everything Passed by Value - Go - David's Blog](https://davidzhu.xyz/post/golang/basics/009-everything-passed-by-value/) 

When use for loop you should note that the [iteration variable is re-used in each iteration](https://github.com/golang/go/wiki/CommonMistakes). 



