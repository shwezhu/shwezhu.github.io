---
title: Golang基础语法之循环判断及defer
date: 2023-05-13 00:10:15
categories:
 - golang
 - basics
tags:
 - golang
---

## For

There are no **parentheses** surrounding the three components of the `for` statement and the braces `{ }` are always required.

```go
func main() {
	sum := 0
	for i := 0; i < 10; i++ {
		sum += i
	}
}
```

`for`在go里除了判断条件部分, 其它都可省略, 灵活度很高, 

```go
// while
func main() {
	sum := 1
	for sum < 1000 {
		sum += sum
	}
	fmt.Println(sum)
}
// Forever
func main() {
	for {
	}
}
```

## If

Like `for`, the `if` statement can start with a short statement to execute before the condition. Variables declared by the statement are only in scope until the end of the `if`. (Try using `v` in the last `return` statement.) 

```go
func pow(x, n, lim float64) float64 {
	if v := math.Pow(x, n); v < lim {
		return v
	} else {
		fmt.Printf("%g >= %g\n", v, lim)
	}
	// can't use v here, though
	return lim
}
```

## Switch

A `switch` statement is a shorter way to write a sequence of `if - else` statements. 

```go
func main() {
	fmt.Print("Go runs on ")
	switch os := runtime.GOOS; os {
		case "darwin":
			fmt.Println("OS X.")
		case "linux":
			fmt.Println("Linux.")
		default:
			// freebsd, openbsd,
			// plan9, windows...
			fmt.Printf("%s.\n", os)
	}
}
```

Switch cases evaluate cases from top to bottom, stopping when a case succeeds.

```go
switch i {
case 0:
case f():
// does not call f if i==0.)
```

## Defer

A defer statement defers the execution of a function until the surrounding function returns. 

```go
func main() {
	defer fmt.Println("world")
	fmt.Println("hello")
}
```

