---
title: Golang 基础语法之函数变量声明及基础数据类型
date: 2023-05-12 10:00:20
categories:
 - Golang
 - Basics
tags:
 - Golang
---

# 1. 函数声明与使用

先来看看函数相关的东西, 

```go
// declear a basic func
func add(x int, y int) int {
	return x + y
}
// If parameter type same, you can omit the type from all but the last
func add(x, y int) int {
	return x + y
}
// Multiple results, the swap function returns two strings.
func swap(x, y string) (string, string) {
	return y, x
}
func main() {
	a, b := swap("hello", "world")
	fmt.Println(a, b)
}
```

除了上面的基础的声明, 在声明function的时候还可以声明返回值的名字: 

Go's return values may be named. If so, they are treated as variables defined at the top of the function.

```go
// 注意哦, 这里的返回值有名字, 然后他们可以直接在函数体使用了, 如上所说, 
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return
}

func main() {
	fmt.Println(split(17))
}
```

A `return` statement without arguments returns the named return values. This is known as a "naked" return.

> **Naked return** statements should be used only in short functions, as with the example shown here. They can harm readability in longer functions.

# 2. 变量

The `var` statement declares a list of variables; as in function argument lists, the type is last. **A `var` statement can be at package or function level.**

```go
var c, python, java bool

func main() {
	var i int
	fmt.Println(i, c, python, java)
}
```

另外声明变量时, 可以不用指定类型, 

A `var` declaration can include initializers, one per variable.If an initializer is present, the type can be omitted; the variable will take the type of the initializer.

```go
var i, j int = 1, 2

func main() {
	var c, python, java = true, false, "no!"
	fmt.Println(i, j, c, python, java)
}
```

还有个声明符号`:=`需要注意一下, 

Inside a function, the `:=` short assignment statement can be used in place of a `var` declaration with implicit type. Outside a function, every statement begins with a keyword (`var`, `func`, and so on) and so the `:=` construct is not available. 所以在函数体里, 就用`:=`来定义变量, 在函数外就用`var`比较好, 当然你也可以都用`var`,  你看你看到了`var`来定义变量, 那怎么定义只读呢? 答案是`const`

```go
func main() {
	var i, j int = 1, 2
	k := 3
	c, python, java := true, false, "no!"

	fmt.Println(i, j, k, c, python, java)
}
```

# 3. 基础数据类型

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

注意定义多个变量和导入多个包的写法习惯, 

```go
package main

import (
	"fmt"
	"math/cmplx"
)

var (
	ToBe   bool       = false
	MaxInt uint64     = 1<<64 - 1
	z      complex128 = cmplx.Sqrt(-5 + 12i)
)

func main() {
	fmt.Printf("Type: %T Value: %v\n", ToBe, ToBe)
	fmt.Printf("Type: %T Value: %v\n", MaxInt, MaxInt)
	fmt.Printf("Type: %T Value: %v\n", z, z)
}

//Type: bool Value: false
//Type: uint64 Value: 18446744073709551615
//Type: complex128 Value: (2+3i)
```

Variables declared without an explicit initial value are given their ***zero value***.

The zero value is:

- `0` for numeric types,
- `false` for the boolean type, and
- `""` (the empty string) for strings.

```go
func main() {
	var i int
	var f float64
	var b bool
	var s string
	fmt.Printf("%v %v %v %q\n", i, f, b, s)
}
//0 0 false ""
```

# 4. Type Conversions

The expression `T(v)` converts the value `v` to the type `T`.

Some numeric conversions:

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

Unlike in C, in Go assignment between items of different type requires an explicit conversion (想想这是不是增加了golang的type safety). 然后go的类型转换与c不一样的还有, 比如int完整无法表示float, 那你就没办法强制转换成int,  

```go
func main() {
  x := 9
	x = 3.6 // 报错, '3.6' (type untyped float) cannot be represented by the type int
  x = int(3.6) // 依然报错 Cannot convert an expression of the type 'float64' to the type 'int'
  
  y := 2.7
	x := 2 
  y = 2 // 注意这样不会报错, 为啥, 因为2也可以是2.0啊, 但x就是int,值是2 不是2.0
  y = x // 报错, Cannot use 'x' (type int) as the type float64
	y = float64(x) // 成功, 因为float可以完整表示int, 所以可以直接强制转换
}
```

那上面的报错的应该怎么解决呢? 

```go
func main() {
	floatNum := 3.14
	intNum := int(floatNum)
	fmt.Println(intNum) // Output: 3
}

func main() {
	var x float32 = 3.14
	var y int = 6
	y = int(x)
	fmt.Println(y) // Output: 3
}
```

即, 如上你应该先定义再转换, 而不是直接转换一个值(constant), 这其实也没意义, 如果都知道值了, 直接使用`:=`不就行了吗.  

另外补充创建比较大的数字或者其它, 要想到用移位操作, 如下:

```go
const (
	// Create a huge number by shifting a 1 bit left 100 places.
	// In other words, the binary number that is 1 followed by 100 zeroes.
	Big = 1 << 100
	// Shift it right again 99 places, so we end up with 1<<1, or 2.
	Small = Big >> 99
)
```

# 5. 总结

- 三个常用关键字`var`, `const`, `func`, 
- 在函数中可以用`:=`来定义变量, 可以自动推断类型, 类似cpp里的`auto`
- go里没有implicit conversion, int->float也不行, 
- 函数声明可以对返回值命名, 相当于在函数体的顶部定义两个local variables
- 常用移位操作, `Big = 1 << 100`, `Small = Big >> 99`

拓展阅读, 

- Exported names: [A Tour of Go](https://go.dev/tour/basics/3)

- Go的声明很奇怪, [这篇文章](https://go.dev/blog/declaration-syntax)解释了为啥Go选择“奇怪”的声明方式

