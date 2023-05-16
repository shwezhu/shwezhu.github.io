---
title: Golang Methods实践中的一些用法
date: 2023-05-16 18:03:05
categories:
 - Golang
tags:
 - Golang
---

Java里有个`Object`类, 是所有类的父类, 那关于go里没有类似的东西呢? 当然, 其实就是一个空的interface, 与Java的类`Object`比起来, 一个空的interface更像个wildcard, 

The interface type that specifies zero methods is known as the *empty interface*:

```go
interface{}
```

An empty interface may hold values of any type. **Empty interfaces are used by code that handles values of unknown type**. For example, `fmt.Print` takes any number of arguments of type `interface{}`.

---

通过实现接口`fmt.Stringer`来自定义打印一个自定类型的行为, 

One of the most ubiquitous interfaces is [`Stringer`](https://go.dev/pkg/fmt/#Stringer) defined by the [`fmt`](https://go.dev/pkg/fmt/) package. A `Stringer` is a type that can describe itself as a string. The `fmt` package (and many others) look for this interface to print values.

```go
type Stringer interface {
    String() string
}
```

```go
package main

import "fmt"

type IPAddr [4]byte

// TODO: Add a "String() string" method to IPAddr.
func (ip IPAddr) String() string {
  // 注意, Go里, 我们可以这么拼接字符串然后返回, 
  // func Sprintf(format string, a ...interface{}) string
	return fmt.Sprintf("%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3])
}

func main() {
	hosts := map[string]IPAddr{
		"loopback":  {127, 0, 0, 1},
		"googleDNS": {8, 8, 8, 8},
	}
	for name, ip := range hosts {
		fmt.Printf("%v: %v\n", name, ip)
	}
}
```

----

