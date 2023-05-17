---
title: Golang错误处理
date: 2023-05-17 17:20:06
categories:
 - Golang
 - Basics
tags:
 - Golang
---

第一次接触Golang这种语法, 很容易就绕进圈子里, 刚开始竟然愣是没看懂错误处理是怎么搞的, 最迷惑的是奇怪的接口实现方式, 然后导致每次看定义的时候就总是忽略了function, 总是觉得所有的都是method, 看来以后需要多多练习实践,  不能只是看单纯的教程博客, 现在基础语法看的差不多还差泛型和线程以及网络相关的, 可这又是Go主要用到的东西, ummm, 之后看看用这些单纯的小语法能写个什么, 

好了不说了, 进入正题, 首先Go有个包叫errors, 里面的内容很简单, 

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

就这些东西, 里面有个函数`New()`用来返回一个`errorString`value的引用, 然后就是一个自定义类型`errorString`和它的一个method`Error()`, 当然这个`Error()`就是Go内置的`error`接口的函数, 所以`errorString`属于`error`, 我们看到一个函数应该注意它有没有receiver, 如果有里面的type就是这个函数的归属类, 没有, 那么这个函数就属于所在的包, 

errors包的内容很简单, 主要就是用于我们不想定义自己的错误类型了那就用它, errors里也说了, "errorString is a trivial implementation of error." 最常见的就是下面这样使用:

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

那如果我们不想使用`errorString`呢? 那我们就要自定义一个type然后实现接口`error`, 刚开始学习, 我们也不知道是什么标准, 不妨借鉴一下Go官方是怎么处理错误的, 

下面TCP连接相关的代码:

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

终于找到源头, `os.NewSyscallError(...)`返回值是`error`类型, 然后它返回的是`&SyscallError{syscall, err}`, 这个语法你可以简单理解为该函数返回了一个匿名对象的引用(Go里没有对象的概念哦, 这样说是方便理解), 然后Go有GC, 所以这个匿名对象并不会在函数返回的时候被清理掉, 具体原因可以看



显然`SyscallError`也实现了接口`error`, 这样它才能属于`error`, 就像我们最开始介绍的那个`errors`包里的`errorString`, 

