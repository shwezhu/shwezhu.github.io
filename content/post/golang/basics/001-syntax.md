---
title: Golang Basics ‼️
date: 2023-05-12 10:00:20
categories:
 - golang
 - basics
tags:
 - golang
---

## 1. Variable Declarations

- The ***`:=`*** can **only** be used in inside a function, which is called **short variable declarations**. 

- A ***`var`*** statement can be at package or function level, which is called **regular variable declarations**. 

Variables declared without an explicit initial value are given their zero value. The zero value is:

- `0` for numeric types,
- `false` for the boolean type, and
- `""` (the empty string) for strings.
- `nil` for pointer
- `nil` for map and slice

```go

func main() {
	var i int
	var f float64
	var b bool
	var s string
	var p *string
	var sl []int
	var m map[string]string
	fmt.Printf("%v %v %v %q %v %v %v \n", i, f, b, s, p, sl==nil, m==nil)
}
// 0 0 false "" <nil> true true 
```

Dereferencing a nil pinter will cause panic, don't do that.

```go
kitten := Cat{Name: "Coco"}
var cat *Cat
*cat = kitten  // runtime error: invalid memory address or nil pointer dereference
```

## 2. Variable Redeclaration 

Unlike regular variable declarations, a short variable declaration may *redeclare* variables provided they were originally declared earlier in the same block **with the same type**, and **at least one of the non-[blank](https://go.dev/ref/spec#Blank_identifier) variables is new**. As a consequence, redeclaration can only appear in a multi-variable short declaration. Redeclaration does not introduce a new variable; it just assigns a new value to the original. 

```go
func main() {
	y, x := 1, 2
	z, x := 2, 3 // z must be new
	fmt.Println(x, y, z)
}
```

This is useful when handle error, 

```go
// func (s *memoryStore) generateID(n int) (string, error)
id, err := s.generateID(32) 
if err != nil {
	return nil, err
}
// func (r *Request) Cookie(name string) (*Cookie, error)
c, err := r.Cookie(name) // redeclare err 
...
```

## 3. Go does not have Reference Variables

This all is very easy once you stop using inappropriate terms while thinking of it. It is not helpful to ask about the hair color or the accent of a bacterium. These are categories applicable to humans. Same in Go: there are no references in Go and there are no "shallow" copies (and no "deep" copy, all there is are copies of values).

Putting & before a variable does not produce a reference, simply because there are no references in Go. It produces a value of totally different type:

```go
var i int = 3     // create variable of type int and store 3 in this variable
var p *int = &i   // create variable of type *int and store memory location of i init
```

Note that `p` is not a "reference to i". It is not. Forget that now and forever. `p` is a pointer to an `int` and nothing else.

The same applies to `:=`. This operator creates a new variable and assigns a value to it. The type is inferred for your convenience from the right hand side. So your

```go
copy1 := someStruct.listofStruct[0]
copy2 := &someStruct.listofStruct[0]
```

is basically (writing out the type interference)

```go
var copy1 someOtherStruct = someStruct.listofStruct[0]
var copy2 *someOtherStruct = &someStruct.listofStruct[0]
```

And now you see that `copy1` and `copy2` are totally unrelated. The have completely different types. `copy1` really is a copy of someStruct.listofStruct[0]: It has the same type and was assigned via = so a copy was made. On the other hand `copy2` is **not** a "copy". You asked the compile the "give me the memory address of someStruct.listofStruct[0] and store this value in copy2 (make this an appropriate pointer type)". Absolutely no copying here.

Pointers are totally normal values. Making a copy of a pointer value makes a copy of a pointer value. No magic here. No deep or shallow copy, no references. Same like making a copy of an int or a complex256.

By dereferencing a pointer you can "get back to the object pointed too". This is the only "reference" like step. In your case you can modify what copy2 points to by `*copy2 = ...`. Note the * which dereferences copy2 (if copy2!=nil).

What everybody irritates at first is that some Go types use pointers internally: especially Maps and Slices. E.g. a slice is a view into an underlying backing array and two slices may look at the same backing array and each slice may modify what the other sees (as the see the same backing array). Such types have reference semantics.

> I think is true in Go/C++/C :
> A variable is just an adress location. When assignments happens `str="hello world"` : Instead of telling the computer store this series of bits in 0x015c5c15c1c5, you tell him to store it in `str`. `str` is just a nicer name of a memory adress location.
>
>  The computer doesn't care and will replace them when compiling, `str` won't exists, it's all 0x015c5c15c1c5.

Source: [Does operator := always cause a new copy to be created if assign without reference?](https://www.reddit.com/r/golang/comments/6v0aka/comment/dlwwvgn/?utm_source=share&utm_medium=web2x&context=3) 

> A variable is a **storage location** for holding a value. The set of permissible values is determined by the variable's type. 

Source: [The Go Programming Language Specification ](https://go.dev/ref/spec#Variables)

Learn more: [There is no pass-by-reference in Go | Dave Cheney](https://dave.cheney.net/2017/04/29/there-is-no-pass-by-reference-in-go)

## 3. Assignment Always Makes a Copy

> Similar to C++, a variable is just an adress location. But unlike C++, each variable defined in a Go program occupies a unique memory location. 

```go
func main() {
    kitten := Cat{Name: "Coco"}
    // do not think bella and kitten is a reference which points to a same object, this is java and python
    bella := kitten // makes a copy
    bella.Name = "Bella"
    fmt.Printf("kitten.Name:%v, bella.Name:%v\n", kitten.Name, bella.Name)
}
// kitten.Name:Coco, bella.Name:Bella
```

> For a mental model, you can treat variable names as references, which exists till their scope exists.
>
> For implementation, Go's variables are NOT references - for reference, use a pointer.
>
> These variables can be allocated on the stack, or on the heap. Both have pros and cons, the compiler decides. For correctness, it does not make any difference. "You don't have to know". 
>
> [source](https://www.reddit.com/r/golang/comments/s0m2h9/comment/hs2kvyo/?utm_source=share&utm_medium=web2x&context=3) 

```golang
type temp struct{
   val int
}

variable1 := temp{val:5}  // 1 makes a copy
variable2 := &temp{val:6} // 2
```

`temp{val:5}` is a [composite literal](https://go.dev/ref/spec#Composite_literals), it creates a value of type `temp`.

In the first example you used a [short variable declaration](https://go.dev/ref/spec#Short_variable_declarations), which is equivalent to

```golang
var variable1 = temp{val: 5}
```

There is a single variable created here (`variable1`) which is initialized with the value `temp{val: 5}`.

In the second example you take the address of a composite literal. That does create a variable, initialized with the literal's value, and the address of this variable will be the result of the expression. This pointer value will be assigned to the variable `variable2`.

## 4. Function

```go
defer func() {
		err := keyboard.Close()
		if err != nil {
			return
		}
	}()
// -------------------------------
go func() {
  ....
}()
```

You can treat the code above like this:

```go
var b = func a() { ... }
b() //call that function
```

## 5. Basic Type

```go
bool

string

int  int8  int16  int32  int64
uint uint8 uint16 uint32 uint64 uintptr

byte // alias for uint8

rune // alias for int32
     // represents a Unicode code point

float32 float64

complex64 complex128
```

## 6. Type Conversions

The expression `T(v)` converts the value `v` to the type `T`. Some numeric conversions:

```go
var i int = 42
var f float64 = float64(i)
var u uint = uint(f)
```

Or, put more simply:

```go
i := 42
f := float64(i)
u := uint(f)
```

Unlike in C, in Go assignment between items of different type requires an explicit conversion, 这增加了golang的type safety, 了解更多: [Type Safety from Why Rusy ](https://davidzhu.xyz/2023/08/05/Other/type-safety)

## 7. Type Assertions

A *type assertion* provides access to an **interface value's** underlying concrete value. 

```go
str := value.(string)
```

But if it turns out that the value does not contain a string, the program will crash with a run-time error. To guard against that, use the "comma, ok" idiom to test, safely, whether the value is a string:

```go
str, ok := value.(string)
if ok {
    fmt.Printf("string value is: %q\n", str)
} else {
    fmt.Printf("value is not a string\n")
}
```

similar syntax - 1:

```go
users := make(map[string]int)
users["jack"] = 13
users["john"] = 15

user, ok := users["milo"]
if ok {
	fmt.Println(user)
} else {
	fmt.Println("no such user")
}
```

similar syntax - 2:

```go
ele, ok:= <-channel_name
```

If the value of `ok` is true, this indicates that the channel is open and read operations can be done. 

### 7.1. Type Assertion Use Case

Type assertion only can be used when value's type is interface, 

```go
var m map[interface{}]interface{}
_, isMap := m.(map[interface{}]interface{}) 
```

The snippet above will cause error: `Invalid type assertion: m.(map[interface{}]interface{}) (non-interface type map[interface{}]interface{} on the left`. 

The code below works fine:

```go
var m map[interface{}]interface{}
var t interface{}
t = m
_, isMap := t.(map[interface{}]interface{})
fmt.Println(isMap)
// print: true
```

## 8. Conclusion

- `ele, ok:= <-channel_name`, `user, ok := users["milo"]`, `str, ok := value.(string)` 
-  type assertions only can be used by interface type.
- assignment, pass as an arguments and function return always makes a copy.
