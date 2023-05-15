---
title: Golang基础之设计Methods的原因
date: 2023-05-14 01:10:32
categories:
 - Golang
 - Basics
tags:
 - Golang
---

Go does not have classes, however, **you can define methods on types**. A method is a function with a special *receiver* argument.

```go
// displaySalary() method has Employee as the receiver type
func (e Employee) displaySalary() {  
    fmt.Printf("Salary of %s is %d", e.name, e.salary)
}

func main() {  
    emp1 := Employee {
        name:     "Sam Adolf",
        salary:   5000,
    }
	 // Calling displaySalary() method of Employee type
	 emp1.displaySalary()
}
```

Methods就是个函数, 只不过多定义了一个receiver, 我们可以用函数来实现相同效果, 

```go
func (e Employee) displaySalary() {  
    fmt.Printf("Salary of %s is %s%d", e.name, e.currency, e.salary)
}

func main() {  
    emp1 := Employee {
        name:     "Sam Adolf",
        salary:   5000,
    }
    emp1.displaySalary() //Calling displaySalary() method of Employee type
}
```

不仅会想Go设计Methods干嘛呢, 既然函数也可以实现, 那这不是多此一举吗? 

总的来说, 平时的面向对象语言如Java有重载的概念, 即相同方法名可以有不同的参数, 但是Go的function却不行, 比如我们想计算正方形和圆形的面积, 那我们就得设计两个不同的functions, 

```go
type Rectangle struct {
	length int
	width  int
}

type Circle struct {
	radius float64
}

func RectangleArea(r Rectangle) int {
	return r.length * r.width
}

func CircleArea(c Circle) float64 {
	return math.Pi * c.radius * c.radius
}
```

以上这样看着还好, 但是在Java里我们可以使这两个形状都继承一个Interface, 然后通过多态和方法重载来简单调用同一个方法`Area`来求两个形状的面积, 而不是分别调用不同的函数, 如下:

```java
import java.util.ArrayList;

interface Shape {
    double Area();
}

class Rectangle implements Shape {
    int length = 6;
    int width = 5;

    @Override
    public double Area() {
        return length * width;
    }
}

class Circle implements Shape {
    int radius = 5;
    @Override
    public double Area() {
        return 2 * Math.PI * radius;
    }
}

public class Main {
    public static void main(String []args) {
        ArrayList<Shape> shapes = new ArrayList<>();
        shapes.add(new Rectangle());
        shapes.add(new Circle());
        for (Shape shape : shapes) {
            System.out.println(shape.Area());
        }
    }
}
```

而Go就不能直接像上面这样, 但Go的Methods间接的解决了这个问题, 对于以上代码我们可以这么写:

```go
type Rectangle struct {  
    length int
    width  int
}

type Circle struct {  
    radius float64
}

func (r Rectangle) Area() int {  
    return r.length * r.width
}

func (c Circle) Area() float64 {  
    return math.Pi * c.radius * c.radius
}

func main() {  
    r := Rectangle{
        length: 10,
        width:  5,
    }
    fmt.Printf("Area of rectangle %d\n", r.Area())
    c := Circle{
        radius: 12,
    }
    fmt.Printf("Area of circle %f", c.Area())
}
```

还没有完成类似java那么省事的代码, 别急, 我们再来介绍Interface的概念, 通过Golang的Interface和Methods来实现上面OO里的多态, 

Go里实现一个接口并不需要Java那样显示`implement`, 你直接定义个同名的method, 然后在*receiver argument*指定对应类型, 就可以说这个类型实现了那个接口, 如下: 

```go
type Shape interface {
	area() float64
}

type Rect struct {
	width, height float64
}
// 这就是等于说Rect实现了interface Shape, 
// 我们不用显示地declare
func (r Rect) area() float64 {
	return r.width * r.height
}

func main() {
	r := rect{width: 3, height: 4}
	fmt.Println(r.area())
}
```

> **An *interface type* is defined as a set of method signatures.** A type implements an interface by implementing its methods. There is no explicit declaration of intent, no "implements" keyword. 

然后结合interface和methods, 我们就可以实现上面Java的代码啦:

```go
package main

import (
	"fmt"
	"math"
)

type Shape interface {
	area() float64
}

type rect struct {
	width, height float64
}
type circle struct {
	radius float64
}

func (r rect) area() float64 {
	return r.width * r.height
}

func (c circle) area() float64 {
	return math.Pi * c.radius * c.radius
}

func main() {
	var shapes []Shape
	shapes = append(shapes, rect{width: 3, height: 4}, circle{radius: 5})
	for _, shape := range shapes {
		fmt.Println(shape.area())
	}
}
```

----

最后还要补充一下, 因为go里面也有指针的概念, 所以关于method的*receiver argument*或者是function的参数, 我们就要考虑尽量传递指针, 

There are two reasons to use a pointer receiver. The first is so that the method can modify the value that its receiver points to. The second is to avoid copying the value on each method call. This can be more efficient if the receiver is a large struct, for example.  

---

另外, 像Java里又个`Object`类, 是所有类的父类, 那关于go里没有类似的东西呢? 当然有, 就是一个空的interface, 与Java的类`Object`比起来, 一个空的interface更像个wildcard, 

The interface type that specifies zero methods is known as the *empty interface*:

```go
interface{}
```

An empty interface may hold values of any type. **Empty interfaces are used by code that handles values of unknown type**. For example, `fmt.Print` takes any number of arguments of type `interface{}`.

---

这里再举个例子, 比如我们可以通过实现接口`fmt.Stringer`来自定义打印一个自定类型时的行为, 

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

参考:

- [A Tour of Go](https://go.dev/tour/methods/14)
- [Go by Example: Interfaces](https://gobyexample.com/interfaces)
- [How to Iterate Over a Slice in Golang? - golangprograms.com](https://www.golangprograms.com/how-to-iterate-over-a-slice-in-golang.html)

