---
title: There is no Reference Variable in Golang 
date: 2023-09-05 22:04:20
categories:
 - golang
 - basics
tags:
 - golang
---

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
> The computer doesn't care and will replace them when compiling, `str` won't exists, it's all 0x015c5c15c1c5.

Source: [Does operator := always cause a new copy to be created if assign without reference?](https://www.reddit.com/r/golang/comments/6v0aka/comment/dlwwvgn/?utm_source=share&utm_medium=web2x&context=3) 

Learn more: [There is no pass-by-reference in Go | Dave Cheney](https://dave.cheney.net/2017/04/29/there-is-no-pass-by-reference-in-go)