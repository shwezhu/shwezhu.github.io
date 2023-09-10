---
title: byte slice vs string - Go
date: 2023-08-19 19:38:59
categories:
 - golang
 - basics
tags:
 - golang
---

Before read this: [Relearn slice in Golang](https://davidzhu.xyz/2023/08/19/Golang/Basics/016-slice-relearning/)

## `byte` type

A `byte` in Go is an unsigned 8-bit integer. It has type `uint8`. A `byte` has a limit of 0 – 255 in numerical range. It can represent an ASCII character.

Go uses `rune`, which has type `int32`, to deal with multibyte characters.

## `byte` slice vs string

A `byte` is just a `char` in C language, so a `byte` slice just a list of ASCII characters, and don't forget a `byte` is just a number - an unsigned 8-bit integer. 

```go
func main() {
  // this is a slice not an array!!!
  // find more: https://davidzhu.xyz/2023/05/13/Golang/Basics/003-collections/
	data := []byte{102, 97, 108, 99, 111, 110}

	fmt.Println(data)
  // convert byte slice to string
	fmt.Println(string(data))
  // string to byte slice
  fmt.Println([]byte("falcon"))
}
----------------------------------------
[102 97 108 99 111 110]
falcon
[102 97 108 99 111 110]
```

The compiler will allocate a new piece of memory and copy the data over when you convet string to bytes or bytes to string. The reason is that `[]byte` is not immutable.  You can change the bytes within a slice. You can grow the slice by appending bytes to the end. But a string is immutable. You cannot change it and you cannot grow it without creating a whole new string. If a string and a `[]byte` were backed by the same memory, then the string would change when the `[]byte` was changed, and that might not be what you expect. 

So, each time you do `[]byte(“fred”)` or `string([]byte{0x40, 0x040})`, there’s an allocation and a copy. This is done by https://golang.org/pkg/runtime/?m=all#stringtoslicebyte and https://golang.org/pkg/runtime/?m=all#slicebytetostring. And this is normally the right thing to do and normally has no significant consequences. 

## string is immutable

```go
func EchoCommandArgs() {
	var s string
	// The variable os.Args is a slice of strings.
	// range produces a pair of values: the index and the value of the element at that index.
	// we ignore index with _ marker here
	for _, arg := range os.Args[1:]{
		// s += ... will make a new string everytime, because string is immutable
		// The += statement makes a new string by concatenating the old string,
		// a space character, and the next argument, then assigns the new string to s.
		// The old contents of s are no longer in use, so they will be garbage-collected in due course.
		// If the amount of data involved is large, this could be costly.
		// A simpler and more efficient solution would be to use the Join function from the strings package
		s += arg
		s += " "
	}
	fmt.Println(s)
	fmt.Println(os.Args[1:])
	fmt.Println(strings.Join(os.Args[1:], " "))
}
---------------------------------------
$ go run main.go hello hi hi
hello hi hi 
[hello hi hi]
hello hi hi
```

References:

- [Go byte - working with bytes in Golang](https://zetcode.com/golang/byte/)
- [[]byte vs string in Go](https://syslog.ravelin.com/byte-vs-string-in-go-d645b67ca7ff)