---
title: Golang函数变量以及基础数据类型
date: 2023-05-12 10:00:20
categories:
 - Golang
 - Basics
tags:
 - Golang
---

## 1. Function Declearation

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

```go
// 返回值在函数签名中已确认 故返回时可不用标注 return x, y
// 这也叫 "naked" return
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return
}

func main() {
	fmt.Println(split(17))
}
```

> **Naked return** statements should be used only in short functions, as with the example shown here. They can harm readability in longer functions. 

当函数是匿名函数的时候, 可以直接在函数体后加`()`进行调用该函数, 

```go
defer func() {
		err := keyboard.Close()
		if err != nil {
			return
		}
	}()
```

上面等于直接调用匿名函数, 可以这么理解:

```go
var b = func a() { ... }
b() //调用函数
```

## 2. Varibale

### 2.1. `var`

A `var` statement can be at package or function level.

```go
// package level
var c, python, java bool

func main() {
  // funcition level
	var i int
	fmt.Println(i, c, python, java)
}
```

声明变量时, 如果有 initializer 便可以省略数据类型:

```go
func main() {
  var j = 1
	fmt.Println(j)
}
```

### 2.2. `:=`

```go
func main() {
	var i, j int = 1, 2
	k := 3
	c, python, java := true, false, "no!"

	fmt.Println(i, j, k, c, python, java)
}
```

The `:=` short assignment statement can **only** be used in inside a function, outside a function, every statement begins with `var`, `func`, and so on. 

## 3. Basic Type

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

### 3.1. Default Value

Variables declared without an explicit initial value are given their ***zero value***. The zero value is:

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
// 0 0 false ""
```

## 4. Type Conversions

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

## 5. Type Assertions

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

类似的语法还有 map 通过 key 获取值, 

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

channel 值读取也可用类似语法判断是否状态为 closed, 

```go
ele, ok:= <-channel_name
```

If the value of `ok` is true, this indicates that the channel is open and read operations can be done. 

### 5.1. Type Assertion Use Case

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

## 6. Conclusion

- ‼️ `ele, ok:= <-channel_name`, `user, ok := users["milo"]`, `str, ok := value.(string)` 
- ‼️ type assertions only can be used by interface type
- 三个常用关键字 `var`, `const`, `func`, 
- 在函数中可以用 `:=` 来定义变量, 可以自动推断类型, 类似cpp里的`auto`
- 声明变量时, 如果有 initializer 便也可以省略数据类型
- go 没有 implicit conversion, int->float 也不行, 
- 函数声明可以对返回值命名, 相当于在函数体的顶部定义两个local variables
- 常用移位操作, `Big = 1 << 100`, `Small = Big >> 99`
- 调用匿名函数可以直接在函数体后加`()`

拓展阅读, 

- Exported names: [A Tour of Go](https://go.dev/tour/basics/3)

- Go的声明很奇怪, [这篇文章](https://go.dev/blog/declaration-syntax) 解释了为啥Go选择“奇怪”的声明方式

