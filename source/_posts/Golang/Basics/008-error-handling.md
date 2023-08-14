---
title: Golang错误处理
date: 2023-05-17 17:20:06
categories:
 - Golang
 - Basics
tags:
 - Golang
---

第一次接触Golang这种语法, 很容易就绕进圈子里, 刚开始竟然愣是没看懂错误处理是怎么搞的, 最迷惑的是奇怪的接口实现方式, 然后导致每次看定义的时候就总是忽略了 function, 总是觉得所有的都是 method, 

进入正题, 首先Go有个包叫 errors, 里面的内容很简单, 

```go
package errors

func New(text string) error {
	return &errorString{text}
}

// errorString is a trivial implementation of error.
type errorString struct {
	s string
}

func (e *errorString) Error() string {
	return e.s
}
```

errors 包的内容很简单, 主要就是用于我们不想自定义错误类型的时候, 即 *"errorString is a trivial implementation of error."* 最常见的使用例子: 

```go
func Sqrt(f float64) (float64, error) {
	if f < 0 {
		return 0, errors.New("math: square root of negative number")
	}
	return math.Sqrt(f), nil
}

func main() {
	res, err := Sqrt(-64.0)
	fmt.Printf("res: %v, err: %v", res, err)
}
```

那如果我们不想使用 `errorString` 呢? 那我们就要自定义一个 type 然后实现接口 `error`, 刚开始学习, 我们也不知道是什么标准, 不妨借鉴一下 Go 官方是怎么处理错误的, 

下面 TCP 连接相关的代码:

```go
func main() {
...
	sock, err := net.Listen("tcp", addr)
	if err != nil {
		panic(err)
	}
	fmt.Println("Listening on", addr)

	for {
		conn, err := sock.Accept()
		if err != nil {
			panic(err)
		}
		go handle(conn, args.Cmd)
	}
}
```

我们看看Go是怎么使用error的, 比如`net.Listen("tcp", addr)`返回了err, 我们看看一些相关实现, 顺着这个函数查找, 嵌套了好多函数, 终于找到了下面这个直接返回err的函数(为了方便看, 我删除了很多代码, 只保留了部分):

```go
func setDefaultSockopts(s, family, sotype int, ipv6only bool) error {
  if (sotype == syscall.SOCK_DGRAM || sotype == syscall.SOCK_RAW) && family != syscall.AF_UNIX {
		// Allow broadcast.
		return os.NewSyscallError(...)
	}
	return nil
}
```

这个函数的返回值类型是`error`, 就是Go的内置接口`error`, 在IDE里面按下cmd然后点击该函数的返回值`error`, 便可看到error在一个叫`builtin.go`的package里:

```go
// The error built-in interface type is the conventional interface for
// representing an error condition, with the nil value representing no error.
type error interface {
	Error() string
}
```

没错error就这么简单, 它就是个接口, 上面的代码返回的是`os.NewSyscallError(...)`, 然后我们来看看`os.NewSyscallError(...)`具体的实现:

```go
func NewSyscallError(syscall string, err error) error {
	if err == nil {
		return nil
	}
	return &SyscallError{syscall, err}
}
```

终于找到源头, `os.NewSyscallError(...)`返回值是`error`类型, 然后它返回的是`&SyscallError{syscall, err}`, 这个语法你可以简单理解为该函数返回了一个匿名对象的引用(Go里没有对象的概念哦, 这样说是方便理解), 然后Go有GC, 所以这个匿名对象并不会在函数返回的时候被清理掉, 具体原因可以看[关于Golang函数返回局部变量的地址的问题](https://davidzhu.xyz/2023/05/15/Golang/Basics/lifetime-of-variables/), 

显然`SyscallError`也实现了接口`error`, 这样它才能属于`error`, 就像我们最开始介绍的那个`errors`包里的`errorString`, 然后我们来看看`SyscallError`, 

```go
type SyscallError struct {
	Syscall string
	Err     error
}

// 这里也可以发现, 自定义一个错误类型必须实现接口 `Error() string`, 
// 直接打印该错误的一个实例, 就是打印该错误在实现 `Error() string` 时返回的内容, 
// 即 SyscallError sError, println(sError) 就是打印的 return e.Syscall + ": " + e.Err.Error()
func (e *SyscallError) Error() string { return e.Syscall + ": " + e.Err.Error() }
```

唔~, 终于找到你了, 再来看看上面那个“简单的”`errorString`的实现:

```go
// errors.go
// errorString is a trivial implementation of error.
type errorString struct {
	s string
}

func (e *errorString) Error() string {
	return e.s
}
```

ummm, 如果`errorString`是注释中所说的那样, 那难道`SyscallError`不是一个trivial implementation of error吗?

到了这, 相信对于Go的错误处理机制也有个简单的概念, 你可以使用简单的`errors`里面的人家预先帮你实现好的`error`, 你也可以自己定一个自己的error, 就像`SyscallError`那样, 

如果我们想自己实现一个呢, 请参考: [Learn how to handle errors in Go (Golang) | golangbot.com](https://golangbot.com/error-handling/)

----

在知乎看到[一个回答](https://www.zhihu.com/question/330263279/answer/726217922), 总结的很好, 摘一段在这当个笔记:

Golang 中的错误处理的哲学和 C 语言一样, 函数通过返回错误类型 `error` 或者 `bool` 类型(不需要区分多种错误状态时) 表明函数的执行结果, 调用检查返回的错误类型值是否是 `nil` 来判断调用结果, 

这个设计一直被吐槽太繁琐, 作为主要用GO的攻城狮, 经常写 `if err!=nil`, 但是如果想偷懒, 少带了上下文信息, 直接写 `if err != nil { return err }`了 或者 `fmt.Errorf` 携带的上下文信息太少了的话, 看到错误日志也会一脸懵逼, 难以定位问题

官方在 2011 年就发过[一篇博客](https://go.dev/blog/error-handling-and-go)教大家如何在Go中处理error, error 是一个内建的 interface， 鼓励大家用好自定义错误类型，常用的范式有三种：

- ﻿一是用 `errors.New(str string)` 定义错误常量Q, 让调用方去判断返回的err 是否等于这个常量, 来进行区分处理
- ﻿二是用 `fmt.Errorf(fmt string, args. .. interface{})`增加一些上下文信息, 用文字的方式告诉调用方哪里出错了, 让调用方打错误日志出来
- ﻿三是自定义 struct type, 实现 error 接口, 调用方用类型断言转成特定的 struct type, 拿到更结构化的错误信息