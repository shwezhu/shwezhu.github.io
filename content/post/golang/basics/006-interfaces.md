---
title: Interfaces in Go (and Methods Receivers)
date: 2023-09-02 19:58:32
categories:
 - golang
 - basics
tags:
 - golang
---

## 1. An Interesting Question

I found an [interesting question](https://stackoverflow.com/questions/37851500/how-to-copy-an-interface-value-in-go/37851764#37851764) on stackoverflow, and find that interface in golang is different from other languages, I'll show you. This is the backgroud code:

```go
type User interface {
	Name() string
	SetName(name string)
}

type Admin struct {
	name string
}

func (a *Admin) Name() string {
	return a.name
}

func (a *Admin) SetName(name string) {
	a.name = name
}
```

OP tries to copy `user1`'s value below:

```go
func main() {
    var user1 User
    user1 = &Admin{name:"user1"}

    fmt.Printf("User1's name: %s\n", user1.Name())

    var user2 User
    user2 = user1
    user2.SetName("user2")

    fmt.Printf("User2's name: %s\n", user2.Name()) // print: "user2"
    fmt.Printf("User1's name: %s\n", user1.Name()) // print: "user2" too, How to make the user1 name does not change？
}
```

## 2. First Try - Type `Admin` isn't `*Adimin`

Because golang everything pass by value, even assignment will make a copy, therefore, at first I tried like this:

```go
var user1 User
user1 = &Admin{name:"user1"}
fmt.Printf("User1's name: %s\n", user1.Name())
var user2 User
user2 = *user1 // got an error: Invalid indirect of 'user1' (type 'User')
```

This erorr says that user's type is `User` not `*User`, so we cannot dereference it. This reminds me that why `user1 = &Admin{name:"user1"}` doesn't cause an error?

Shouldn't the code be `user1 = Admin{name:"user1"}`, because `Admin` implements interface `User`. But this cause an error aggin:

```go
var user1 User
user1 = Admin{name:"user1"} 
// error: Cannot use 'Admin{name:"user1"}' (type Admin) as the type User Type does not implement 'User' as the 'Name' method has a pointer receiver. 
```

This error is a little confusing, actually it says that type `Admin` doesn't implement interface `User`. You may wonder, you lied, `Admin` has implemented all methods of `User`, but wait, really?

In fact, it's not type `Admin` implementing interface `User` but type `*Admin`, check the definition of `Name()` and `SetName()` above, both of these two method have a pointer receiver, not a value receiver. This means **the `Name()` and `GetName()` method are in the [method set](https://golang.org/ref/spec#Method_sets) of the `*Admin` type, but not in that of `Admin`.**

Therefore, it's easy to understand why we can do:

```go
var user1 User
user1 = &Admin{name:"user1"}
```

we cannot do:

```go
var user1 User
user1 = Admin{name:"user1"} // error
```

If you change the receiver to value receiver in `Name()` and `GetName()`, then both `user1 = &Admin{name:"user1"}` and  `user1 = Admin{name:"user1"}` will work fine. 

This is strange we've talked that `*Admin` is not `Admin`, why `user1 = &Admin{name:"user1"}` works when we change method receiver to value receiver?

This is not the type problem, even above, the error is not above the type, it's all about the [method set](https://golang.org/ref/spec#Method_sets), **if a type's method set has all methods of a interface, we say that type implements that interface**:

- The method set of a [defined type](https://go.dev/ref/spec#Type_definitions) `T` consists of all [methods](https://go.dev/ref/spec#Method_declarations) declared with receiver type `T`.
- The method set of a pointer to a defined type `T` (where `T` is neither a pointer nor an interface) is the set of all methods declared with receiver `*T` or `T`.

You can see the second point, the method set of a ponter type `T` is the set of all methods declared with receiver `*T` and `T`. Therefore, when we make the method receiver of `Name()` and `SetName()` into value receiver,  `Name()` and `SetName()` are in the method set of `*Admin` too. 

enlightened by: 

[pointers - How to copy an interface value in Go? - Stack Overflow ](https://stackoverflow.com/questions/37851500/how-to-copy-an-interface-value-in-go/37851764#37851764)

[go - Pointer Receiver and Value Receiver on Interfaces in Golang - Stack Overflow](https://stackoverflow.com/questions/53701458/pointer-receiver-and-value-receiver-on-interfaces-in-golang) 

## 3. Answer

Now, we know what's happening here:

```go
var user1 User
user1 = &Admin{name:"user1"}
fmt.Printf("User1's name: %s\n", user1.Name())
var user2 User
user2 = *user1 // error: Invalid indirect of 'user1' (type 'User')
```

Then there is an [great explanation](https://stackoverflow.com/a/37851764/16317008):

The problem here is that your `user1` variable (which is of type `User`) holds a *pointer* to an `Admin` struct.

When you assign `user1` to another variable (of type `User`), the interface value which is a pair of the dynamic type and value `(value;type)` will be copied - so the pointer will be copied which will point to the same `Admin` struct. So you only have one `Admin` struct value, both `user1` and `user2` refer (point) to this. Changing it through any of the interface values changes the one and only value.

**To make `user1` and `user2` distinct, you need 2 "underlying" `Admin` structs.** (Because user1 and user2 have pair (value; type) in side, the value is a pointer to a struct value)

One way is to [type assert](https://golang.org/ref/spec#Type_assertions) the value in the `user1` interface value, and make a copy of that struct, and wrap its address in another `User` value:

```go
var user2 User
padmin := user1.(*Admin) // Obtain *Admin pointer
admin2 := *padmin        // Make a copy of the Admin struct
user2 = &admin2          // Wrap its address in another User
user2.SetName("user2")
```

***Using reflection:***

If we want a "general" solution (not just one that works with `*Admin`), we can use reflection ([`reflect`](https://golang.org/pkg/reflect/) package).

Learn more: https://stackoverflow.com/a/37851764/16317008

## 4. Polymorphism

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

In java we cam make Rect and Circle implement a same interface to achieve polymorphism:

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

In golang we can use Method Receiver to implement polymorphism, 

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

// this is value receiver
// echo method call will make a copy of rect value that is rect's "object"
// if you want modify the field of the value, you need a pinter receiver
// learn more: https://shaowenzhu.top/post/golang/basics/013-methods-receivers/
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

Here we saying type `rect` implements interface `Shape`  is not accurate, this is java things. We should say all methods of interface `Shape` are in the method set of type `rect`, and calling a method on an interface value executes the method of the same name on its underlying type. Therefore, we say type `rect` implements interface `Shape`. 

参考:

- [A Tour of Go](https://go.dev/tour/methods/14)
- [Go by Example: Interfaces](https://gobyexample.com/interfaces)
- [How to Iterate Over a Slice in Golang? - golangprograms.com](https://www.golangprograms.com/how-to-iterate-over-a-slice-in-golang.html)

