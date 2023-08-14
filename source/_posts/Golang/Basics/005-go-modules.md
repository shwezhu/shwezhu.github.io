---
title: Golang模块module和包package的使用之导入自定义包
date: 2023-05-21 14:32:10
categories:
 - Golang
 - Basics
tags:
 - Golang
---

昨天做贪吃蛇的时候想用个第三方的库来读取键盘输入, 很小, 就直接创建一个go文件把内容复制了进去, 但import的时候却找不到包, 查了一下是Go的包管理机制和Java, Python的不太一样, 于是就有了这篇文章, 

## 1. `main` function and `main` package

Go类似C, 即程序的入口是个`main`函数, 没有它, 你的程序是无法运行的, 但与C还有不同, 如果某个源文件`hello_world.go`你想直接运行它, 那它的第一行必须是`package main`, 所以一个可执行go源文件有两个要求

- 在源文件声明属于 main package
- 具有 main 函数

如下:

```go
package main

func main() {
	println("hello world")
}
```

下面的都会报错:

```go
import "fmt"
package main

func main() {
	fmt.Printf("hello world")
}
// error: package expected, got 'import'
```

```go
package hello_world

func main() {
	println("hello world")
}
// $ go run hello_world.go
// error: package command-line-arguments is not a main package
```

> `package main` specifies that this file belongs to the `main` package. The `import "package_name"` statement is used to import an existing package. `package_name.FunctionName()` is the syntax to call a function in a package. 

这句话总结的很好, 如:

```go
package main
// 导入fmt package
import "fmt"

func main() {
  // 调用fmt package里的Printf()函数
	fmt.Printf("hello world")
}
```

> 注意区分package和module: A Go Module is nothing but a collection of Go packages. `fmt`是package, 不是module, 

## 2. Compile

编写好`hello_world.go`, 怎么运行它? 来捋一捋:

```shell
$ mkdir my_project && cd my_project 
$ vi hello_world.go
$ cat hello_world.go 
package main

import "fmt"

func main() {
	fmt.Printf("hello world")
}
```

然后我们来编译这个源文件, 

```go
$ go install  
go: go.mod file not found in current directory or any parent directory; see 'go help modules'
```

报错了, 原因是我们没有初始化 在项目根目录执行:

```shell
$ go mod init my_project
go: creating new go.mod: module my_project
go: to add module requirements and sums:
	go mod tidy

$ tree -L 2
.
├── go.mod
└── hello_world.go
```

项目文件夹是 `my_project`, 创建的module名也叫`my_project`, 一般他俩设置同名, `go mod init my_project` :

```go
$ cat go.mod 
module my_project

go 1.20
```

第一行就是上面指定的 module name, 初始化之后, 我们便可以编译go了:

```shell
$ go install      
```

编译好的可执行文件在`~/go/bin`目录下, 

## 3. Go Modules 

看完上面的你肯定有疑惑, `go mod init my_project` 是干嘛的, 为什么编译一个小小的源代码, 还需要"初始化"? 

其实也可以不用“初始化”, 上面的例子不使用 `go install` 进行编译, 直接运行源代码就可以了:

```shell
$ go run hello_world.go 
hello world
```

所以这个 `go install` 绝对不仅仅是编译, 

- The [`go build` command](https://go.dev/cmd/go/#hdr-Compile_packages_and_dependencies) compiles the packages, along with their dependencies, but it doesn't install the results.
- The [`go install` command](https://go.dev/ref/mod#go-install) compiles and installs the packages.
- The command [`go run`](https://www.digitalocean.com/community/tutorials/how-to-write-your-first-program-in-go#step-2-—-running-a-go-program) to automatically compile your source code and run the resulting executable.

什么时候我们需要用到 `go mod init my_project` “初始化” 项目呢? 

答案是当我们用到 **custom package** 的时候, 这就会到了文章开头遇到的问题, 现在我演示一下如何导入 **custom package**, 

创建个空文件夹`my_project`, 并在里面编写两个go源文件,一个是`hello_world.go`, `tools/math.go`然后让前者为`main` package用于执行, 后者为`tools` package用于被`hello_world.go`调用,  项目结构如下如下:

```shell
my_project
├── hello_world.go
└── tools
    └── math.go
```

文件内容如下:

```go
// math.go
package tools
// 注意名字开头要大写属于exported names, 否则是私, 即外部无法访问, 变量也是
func Calculate(a, b int) int {
	return a+b, 
}
```

```go
// hello_world.go
package main

import "fmt"
import "my_project/tools"

func main() {
	fmt.Printf("hello world\n")
	fmt.Printf("%v\n", tools.Calculate(3, 2))
}
```

此时还无法运行`hello_world.go`, 若运行, 则报错:

```shell
$ go run hello_world.go
hello_world.go:4:8: package my_project/tools is not in GOROOT (/Users/David/sdk/go1.20.4/src/my_project/tools)
```

此时在项目根目录创建go module, module的名字与项目文件夹名字`my_project`相同, 

```shell
$ go mod init my_project
go: creating new go.mod: module my_project
```

此时再运`hello_world.go`:

```go
$ go run hello_world.go 
hello world
5
```

`tools/` 是自定义的 package, `tools/math.go` 通过其第一行代码 `package tools` 声明其属于 package `tools`, 我们在 `hello_world.go` 调用package里的函数的语法是`import module_name/package_name`, 所以我们`hello_world.go`的第一行是`import "my_project/tools"`, 

现在看看下面这段话, 是不是觉得很多概念都清晰了呢:

> **A Go Module is nothing but a collection of Go packages.** Now this question might come to your mind. Why do we need Go modules to create a custom package? The answer is **the import path for the custom package we create is derived from the name of the go module**. In addition to this, all the other third-party packages(such as source code from github) which our application uses will be present in the `go.mod` file along with the version. This `go.mod` file is created when we create a new module. Another question might popup in our minds. How come we got away without creating a [Go module](https://golangbot.com/books/) till now? The answer is, we never created our own custom package till now in this [tutorial series](https://golangbot.com/learn-golang-series/) and hence no Go module was needed. 

## 4. A bit more on `go install`

Now that we understand how packages work, it's time to talk a little bit more about `go install`. Go tools like `go install` work in the context of the current directory. Let's understand what that means. Till now we have been running `go install` from the directory `~/Documents/learnpackage/`. If we try to run it from any other directory, it will fail.

Try cding into `cd ~/Documents/` and then running `go install learnpackage`. It will fail with the following error.

```
can't load package: package learnpackage: cannot find package "learnpackage" in any of:  
    /usr/local/Cellar/go/1.13.7/libexec/src/learnpackage (from $GOROOT)
    /Users/nramanathan/go/src/learnpackage (from $GOPATH)
```

Let's understand the reason behind this error. `go install` takes an optional package name as a parameter(in our case the package name is `learnpackage`) and it tries to compile the main function if the package exists in the current directory from which it is run or in the parent directory or it's parent directory and so on.

We are in `Documents` directory and there is no `go.mod` file there and hence `go install` complains that it cannot find the package `learnpackage`.

When we move to `~/Documents/learnpackage/`, there is a `go.mod` file there and our module name is `learnpackage` in that `go.mod` file.

so `go install learnpackage` will work from inside the `~/Documents/learnpackage/` directory.

But so far we have just been using `go install` and we did not specify the package name. If no package name is specified, `go install` will default to the module name in the current working directory. That's why when `go install` is run without any package name from `~/Documents/learnpackage/` it worked. So the following 3 commands are equivalent when run from `~/Documents/learnpackage/`

```
go install

go install .

go install learnpackage  
```

即`go install`后面还有个参数及module name, 如果我们没加, `go insatll`就会根据`go.mod`里的module name自动加上, 所以如果我把上面例子中的`go.mod`的内容改成, 注意项目文件夹为`my_project`:

```go
module my_module_name
go 1.20
```

那此时我们执行`go install`需要使用

```shell
$ go install  
$ go install my_module_name
```

可以成功, 但是若使用`go install my_project`则会报错:

```shell
package my_project is not in GOROOT (/Users/David/sdk/go1.20.4/src/my_project)
```

## 5. GOPATH vs Go Modules

> Go 1.11 introduces a new dependency mangement system, *Go modules* (That’s why Go uses the environment variable name `GO111MODULE`: indicating to use Go 1.11 module). Google introduced *Go module* as an alternative to *GOPATH* for versioning and dependency management to the Go ecosystem. 

```shell
$ echo $GOPATH
/Users/David/sdk
```

Go Modules 是 Golang 新的依赖管理方法, 之前用的都是 GOPATH, 他们两个不能同时存在, Goland 默认设置了 GOPATH, 如果你使用了Go Modules 即 `go mod init xxx`, 那你需要删除 Goland 上面的 Project GOPATH, 如下:

![a](a.png)

了解 GOPATH: https://golangr.com/what-is-gopath

 ## 6. 总结

- `go install`, `go run` 要区分开, 平时常用的是`go run`
- `go install`运行前需要执行`go mod init my_project`
- 需要使用custom package的时候, 要使用go module, 即`go mod init your_module_name`, module name往往和我们项目名相同, 但你也可以使用其他的名字, 
- 创建自定义package即在项目根目录下创建一个文件夹, 然后在里面写go源代码, 注意package里面的源文件的第一行必须声明其属于该package: `package xxx`
- 创建自定义package的时候, 里面的函数变量必须要首字母大写, 否则那个函数就属于私有了, 具体参考: [A Tour of Go](https://go.dev/tour/basics/3)
- 注意区分package和module的概念, 他们是不同的: A Go Module is nothing but a collection of Go packages. 
- `go install` 后面的参数是当前的模块名

参考:

- [Learn to create and use Go packages - golangbot.com](https://golangbot.com/go-packages/)
- [Go (Golang) Hello World Tutorial Updated for Go 1.17 | golangbot.com](https://golangbot.com/hello-world-gomod/)
- [A Tour of Go](https://go.dev/tour/basics/3)
