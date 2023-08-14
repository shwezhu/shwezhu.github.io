---
title: Golang Methods实践中的一些用法
date: 2023-05-16 18:03:05
categories:
 - Golang
 - Basics
tags:
 - Golang
---

## 1. Empty Interface - Wildercard

Java 中的 `Object `类是所有类的父类, 可以作为一个 Wildcard, Go 里与之对应的是个空的 interface, 

The interface type that specifies zero methods is known as the *empty interface*:

```go
interface {}
```

An empty interface may hold values of any type. **Empty interfaces are used by code that handles values of unknown type**. For example, `fmt.Print` takes any number of arguments of type `interface{}`.

## 2. 实现 Stringer 接口 自定义打印

通过实现接口 `fmt.Stringer` 实现打印自定类型, One of the most ubiquitous interfaces is [`Stringer`](https://go.dev/pkg/fmt/#Stringer) defined by the [`fmt`](https://go.dev/pkg/fmt/) package. A `Stringer` is a type that can describe itself as a string. The `fmt` package (and many others) look for this interface to print values.

```go
// print.go
type Stringer interface {
    String() string
}
```

```go
type Employee struct {
	name string
	salary float32
}

func (e Employee) String()  string {
	return fmt.Sprintf("Salary of %s is %v", e.name, e.salary)
}

func main() {
	emp := Employee {
		name:     "Sam Adolf",
		salary:   5000,
	}
	fmt.Println(emp)
}
```

## 3. 错误处理

