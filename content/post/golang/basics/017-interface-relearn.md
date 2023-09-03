---
title: Type and Interface Value - Golang
date: 2023-09-02 18:57:04
categories:
 - golang
 - basics
tags:
 - golang
---

## 1. Types and interfaces

### 1.1. Types

Because reflection builds on the type system, let’s start with a refresher about types in Go.

Go is statically typed. Every variable has a static type, that is, exactly one type known and fixed at compile time: `int`, `float32`, `*MyType`, `[]byte`, and so on. If we declare

```go
type MyInt int

var i int
var j MyInt
```

then `i` has type `int` and `j` has type `MyInt`. The variables `i` and `j` have distinct static types and, although they have the same underlying type, they cannot be assigned to one another without a conversion.

### 1.2. Interfaces

One important category of type is interface types, which represent fixed sets of methods. An interface variable can store any concrete (non-interface) value as long as that value implements the interface’s methods. A well-known pair of examples is `io.Reader` and `io.Writer`, the types `Reader` and `Writer` from the [io package](https://go.dev/pkg/io/):

```go
// Reader is the interface that wraps the basic Read method.
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Writer is the interface that wraps the basic Write method.
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

Any type that implements a `Read` (or `Write`) method with this signature is said to implement `io.Reader` (or `io.Writer`). For the purposes of this discussion, that means that a variable of type `io.Reader` can hold any value whose type has a `Read` method:

```go
var r io.Reader
r = os.Stdin
r = bufio.NewReader(r)
r = new(bytes.Buffer)
// and so on
```

> It’s important to be clear that whatever concrete value `r` may hold, `r`’s type is always `io.Reader`: Go is statically typed and the static type of `r` is `io.Reader`.

We have talked this in [other posts](https://shaowenzhu.top/post/golang/basics/006-interfaces/#3-first-try---type-admin-isnt-adimin):

```go
var user1 User
user1 = &Admin{name:"user1"}
fmt.Printf("User1's name: %s\n", user1.Name())
var user2 User
user2 = *user1 // error: Invalid indirect of 'user1' (type 'User')
// which means cannot dereference a User type, you can dereference a *User type
```

`user1` is an interface, it holds an pointer value: `&Admin{name:"user1"}`, however, its type is still a `User` neither `*User` nor `*Admin`. 

Some people say that Go’s interfaces are dynamically typed, but that is misleading. They are statically typed: a variable of interface type always has the same static type, and even though at run time the value stored in the interface variable may change type, that value will always satisfy the interface.

## 2. The representation of an interface

A variable of interface type stores a pair: the concrete value assigned to the variable, and that value’s type descriptor. To be more precise, the value is the underlying concrete data item that implements the interface and the type describes the full type of that item. For instance, after

```go
var r io.Reader
// func OpenFile(name string, flag int, perm FileMode) (*File, error)
tty, err := os.OpenFile("/dev/tty", os.O_RDWR, 0)
if err != nil {
    return nil, err
}
r = tty
```

`r` contains, schematically, the (value, type) pair, (`tty`, `*os.File`). Notice that the type `*os.File` implements methods other than `Read` (other than: 除...之外); even though the interface value provides access only to the `Read` method, the value inside carries all the type information about that value. That’s why we can do things like this:

```go
var w io.Writer
w = r.(io.Writer)
```

The expression in this assignment is a type assertion; what it asserts is that the item inside `r` also implements `io.Writer`, and so we can assign it to `w`. After the assignment, `w` will contain the pair (`tty`, `*os.File`). That’s the same pair as was held in `r`. The static type of the interface determines what methods may be invoked with an interface variable, even though the concrete value inside may have a larger set of methods.

Continuing, we can do this:

```go
var empty interface{}
empty = w
```

and our empty interface value `empty` will again contain that same pair, (`tty`, `*os.File`). That’s handy: an empty interface can hold any value and contains all the information we could ever need about that value.

(We don’t need a type assertion here because it’s known statically that `w` satisfies the empty interface. In the example where we moved a value from a `Reader` to a `Writer`, we needed to be explicit and use a type assertion because `Writer`’s methods are not a subset of `Reader`’s.)

One important detail is that the pair inside an interface variable always has the form (value, concrete type) and cannot have the form (value, interface type). Interfaces do not hold interface values.

Sources: https://go.dev/blog/laws-of-reflection

## 3. Pointers to Interfaces

Pointer to an interface is rarely used, mostly because an interface is in fact a pointer itself. (Not just a pointer, but consists of it). If you want modify the value that an interface variable holds, you can pass a pinter to it. Here I mean, let an interface variable holds a pointer of a struct value , just like: `user1 = &Admin{name:"Coco"}`. I'll explain to you in code:

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

func main() {
	var user1, user2 User
  // let interface varibale user1 holds a pinter, then we can change Admin{name:"Coco"} with user1
  // so we don't need a pinter to an interface variable
  // an interface variable acts like a pointer already
	user1 = &Admin{name:"Coco"}
	user2 = Admin{name: "Bella"}
	fmt.Printf("[%T] %+v\n", user1, user1)
	fmt.Printf("[%T] %+v\n", user2, user2)
}
```

Output:

```
[*main.Admin] &{name:Coco}
[main.Admin] {name:Bella}
```

And don't get confused with two concepts here. A pointer to a struct and a pointer to an interface are not the same. **An interface can store either a struct directly *or* a pointer to a struct**. In the latter case, you **still** can use the interface directly, *not* a pointer to the interface. 

In both cases, the variable `user1`, and `user2` are just an interface whose type is `User`, *not* a pointer to an interface. However, when `user2` storing `&Admin{name:"Coco"}`, the interface *holds* a pointer to a `Admin` structure.

Wonder why can assign `&Admin{name:"Coco"}` to an interface `User` type? We have taked this in [other posts](https://shaowenzhu.top/post/golang/basics/006-interfaces/#3-first-try---type-admin-isnt-adimin). 

## 4. Copy Interface

As in all languages in the C family, everything in Go is passed by value. That is, a function always gets a copy of the thing being passed, as if there were an assignment statement assigning the value to the parameter. For instance, passing an `int` value to a function makes a copy of the `int`, and passing a pointer value makes a copy of the pointer, but not the data it points to. (See a [later section](https://go.dev/doc/faq#methods_on_values_or_pointers) for a discussion of how this affects method receivers.)

Map and slice values behave like pointers: they are descriptors that contain pointers to the underlying map or slice data. Copying a map or slice value doesn't copy the data it points to. Copying an interface value makes a copy of the thing stored in the interface value. If the interface value holds a struct, copying the interface value makes a copy of the struct. If the interface value holds a pointer, copying the interface value makes a copy of the pointer, but again not the data it points to.

Note that this discussion is about the semantics of the operations. Actual implementations may apply optimizations to avoid copying as long as the optimizations do not change the semantics.

Source: https://go.dev/doc/faq