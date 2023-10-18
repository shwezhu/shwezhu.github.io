---
title: Statically Compiling Go Programs
date: 2023-10-10 12:09:35
categories:
 - golang
 - advance
tags:
 - golang
 - c
---

## 1. Compilation process in C

C/C++ programs are built in two main phases (ignore the preprocess, assemble):

1. Compilation - produces object code (`.obj`, `.o`)
   ```shell
   # Compile source code into an object file without linking:
   gcc -c path/to/source.c
   ```
   - The extension of the ***object file*** in DOS is `.obj`, and in UNIX, the extension is `.o`. 

2. Linking - produces executable code (.exe or .dll)

   - ***executable file*** with an extension of `exe` in DOS and `.out` in UNIX OSL

## 2. Static linking and dynamic linking

### 2.1. Static linking - portable, fast

Mainly, all the programs written in C use library functions. These library functions are pre-compiled, and the object code of these library files is stored with `.lib` (or `.a`) extension. **The main working of the linker** is to combine the ***object code*** of library files with the ***object code*** of our program. The output of the linker is the executable file. So the **static Linking creates larger binary files**.  Note that this is the process of static linking, and `.lib` and `.a` is static library in windows and linux respectively. 

In static linking, everything is bundled into your application, you don’t have to worry that the client will have the right library (and version) available on their system. Since all library code have connected at compile time, the final executable has no dependencies on the library at run time. You have everything under your control and there is no dependency.

One major advantage of static libraries being preferred even now “is speed”. There will be no dynamic querying of symbols in static libraries.

One drawback of static libraries is, for any change(up-gradation) in the static libraries, you have to recompile the main program every time.

### 2.2. Dynamic linking - smaller binary 

Dynamic Linking doesn’t require the code to be copied, it is done by just placing name of the library in the binary file. The actual linking happens when the program is run, when both the binary file and the library are in memory. 

Source: [Static and Dynamic Libraries | Set 1 - GeeksforGeeks](https://www.geeksforgeeks.org/static-vs-dynamic-libraries/)

## 3. Static library vs dynamic library

- Static library: windows `.lib`,  linux `.a` 

- Dynamic library (shared library): windows `.dll`, linux `.so` 

Static library `.lib` is just a bundle of `.obj` files and therefore isn't a complete program. It hasn't undergone the second (linking) phase of building a program. Dlls, on the other hand, are like exe's and therefore are complete programs.

**If you build a static library**, it isn't linked yet and therefore consumers of your static library will have to use the same compiler that you used (if you used g++, they will have to use g++). If the static library uses C++ library, such as `#include <iostream>`. 

If instead you built a dll (and built it [correctly](http://www.codeproject.com/Articles/28969/HowTo-Export-C-classes-from-a-DLL)), you have built a complete program that all consumers can use, no matter which compiler they are using. There are several restrictions though, on exporting from a dll, if cross compiler compatibility is desired.

Source: https://stackoverflow.com/a/25209275/16317008

## 4. Example in practice

Dynamic linking means the use of shared libraries. Shared libraries usually end with `.so` (short for "shared object") or `.dylib` on MacOS.

Another thing to note is that when a bug is fixed in a shared library, every application that references this library will profit from it. This also means that if the bug remains undetected, each referencing application will suffer from it (if the application uses the affected parts).

It can be very hard for beginners **when an application requires a specific version of the library, but the linker only knows the location of an incompatible versio**n. In this case, you must help the linker find the path to the correct version.

Although this is not an everyday issue, understanding dynamic linking will surely help you in fixing such problems.

Fortunately, the mechanics for this are quite straightforward. To detect which libraries are required for an application to start, you can use `ldd`, which will print out the shared libraries used by a given file. 

```
$ ldd my_app 
	linux-vdso.so.1 (0x00007ffd1299c000)
	libmy_shared.so => not found
	libc.so.6 => /lib64/libc.so.6 (0x00007f56b869b000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f56b8881000)
```

Note that the library `libmy_shared.so` is part of the repository but is not found. This is because the **dynamic linker**, which is responsible for loading all dependencies into memory before executing the application, cannot find this library in the standard locations it searches.

Errors associated with linkers finding incompatible versions of common libraries (like `bzip2`, for example) can be quite confusing for a new user. One way around this is to add the repository folder to the environment variable `LD_LIBRARY_PATH` to tell the linker where to look for the correct version. In this case, the right version is in this folder, so you can export it:

```bash
$ LD_LIBRARY_PATH=$(pwd):$LD_LIBRARY_PATH
$ export LD_LIBRARY_PATH
```

Now the dynamic linker knows where to find the library, and the application can be executed. You can rerun `ldd` to invoke the dynamic linker, which inspects the application's dependencies and loads them into memory. The memory address is shown after the object path:

```bash
$ ldd my_app 
	linux-vdso.so.1 (0x00007ffd385f7000)
	libmy_shared.so => /home/stephan/library_sample/libmy_shared.so (0x00007f3fad401000)
	libc.so.6 => /lib64/libc.so.6 (0x00007f3fad21d000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f3fad408000)
```

To find out which linker is invoked, you can use `file`:

```bash
$ file my_app 
my_app: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=26c677b771122b4c99f0fd9ee001e6c743550fa6, for GNU/Linux 3.2.0, not stripped
```

The linker `/lib64/ld-linux-x86–64.so.2` is a symbolic link to `ld-2.30.so`, which is the default linker for my Linux distribution:

```bash
$ file /lib64/ld-linux-x86-64.so.2 
/lib64/ld-linux-x86-64.so.2: symbolic link to ld-2.31.so
```

Looking back to the output of `ldd`, you can also see (next to `libmy_shared.so`) that each dependency ends with a number (e.g., `/lib64/libc.so.6`). The usual naming scheme of shared objects is:

```text
**lib** XYZ.so **.<MAJOR>** . **<MINOR>**
```

On my system, `libc.so.6` is also a symbolic link to the shared object `libc-2.30.so` in the same folder:

```bash
$ file /lib64/libc.so.6 
/lib64/libc.so.6: symbolic link to libc-2.31.so
```

If you are facing the issue that an application will not start because the loaded library has the wrong version, it is very likely that you can fix this issue by inspecting and rearranging the symbolic links or specifying the correct search path (see "The dynamic loader: ld.so" below).

For more information, look on the [`ldd` man page](https://www.man7.org/linux/man-pages/man1/ldd.1.html).

Source: [How to handle dynamic and static libraries in Linux | Opensource.com](https://opensource.com/article/20/6/linux-libraries)

> Note that the dynamic linker on MacOS is called `dyld`, try `man dyld` to check the details. Learn more: https://stackoverflow.com/a/34905091/16317008

```go
func main() {
	fmt.Println("hello")
}
// go build -o server main.go
```

Then check the shared libraries this executable file `server` required:

```shell
# otool -L: print shared libraries used
$ otool -L server           
server:
	/usr/lib/libSystem.B.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libresolv.9.dylib (compatibility version 0.0.0, current version 0.0.0)
```

> `ldd` is on linux, on MaxOS you should use `otool`

## 5. Static linking in Go 

### 5.1. On linux

Go creates **static binaries** by default unless you use cgo to call C code, in which case it will create a dynamically linked binary. The easiest way to check if your program is statically compiled is to run `file` on it. 

standard packages `os/user` and `net`  use cgo, so importing either (directly or indirectly) will result in a dynamic binary. 

> Note that `net` use cgo does't mean that all its implementation is cgo, cgo is just used for Name Resolution and some teivial features. https://pkg.go.dev/net#section-documentation

I do this test on my Ubuntu server firstly without cgo:

```go
package main

import "fmt"

func main() {
	fmt.Println("hello")
}
```

```shell
# ubuntu @ ip-172-31-12-228 in ~/codes [19:40:23] 
$ go build -o server main.go

# ubuntu @ ip-172-31-12-228 in ~/codes [19:40:31] 
$ file server 
server: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, Go BuildID=hjbIteBvAg_rZ86av_gy/k1xYD8duMhRTtrThDrrX/5yBtTaOBDsf4F2IOwADX/U1b5vnivY9rWcRUWpC_A, with debug_info, not stripped

# ubuntu @ ip-172-31-12-228 in ~/codes [19:40:36] 
$ ldd server 
	not a dynamic executable
```

As you can see, I just use `fmt` package, and the executable file is statically linked. 

And then I change the go code to:

```go
package main

import (
	"fmt"
	"net/http"
)

func main() {
	srv := http.NewServeMux()
	srv.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		_, _ = fmt.Fprintln(w, "hello world")
	})
	fmt.Println("running...")
	_ = http.ListenAndServe(":8080", srv)
}
```

Then build it on Ubtutu machine:

```shell
# ubuntu @ ip-172-31-12-228 in ~/codes [19:47:06]
$ go build -o server main.go

# ubuntu @ ip-172-31-12-228 in ~/codes [19:47:31] 
$ file server 
server: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, Go BuildID=KCFaacb5_zSot7hqkTv8/oYQa-0nbl_Gq2_YxF6JO/BnF2hmfFNgVx-UHRKxMt/Oj91sMcK9_or35yi4Xd0, with debug_info, not stripped

# ubuntu @ ip-172-31-12-228 in ~/codes [19:47:39] 
$ ldd server 
	linux-vdso.so.1 (0x00007fff10cfb000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f4cd6200000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f4cd6612000)
```

As you can see, the binary file is dynamically linked. 

#### 5.1.1. Disable dynamically linking with ` CGO_ENABLED=0` 

```shell
# ubuntu @ ip-172-31-12-228 in ~/codes [19:48:57] 
$ CGO_ENABLED=0 go build -o server main.go

# ubuntu @ ip-172-31-12-228 in ~/codes [20:11:01] 
$ file server 
server: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, Go BuildID=wGRY1RH-HeASVOwzThcj/lQNxgqzqGUe1P8n_WjN7/cEcN362GspK8XKl2L0AG/F7hVHMJfVIyYcLM6Jhz1, with debug_info, not stripped
```

> Note that the `CGO_ENABLED=0` is to disable cgo. It is disabled by default when cross-compiling. You can control this by setting the CGO_ENABLED environment variable when running the go tool: set it to 1 to enable the use of cgo, and to 0 to disable it. 
>
> If CGO_ENABLED=0 is set, the Go net package will not use cgo, and instead, it will use a pure Go implementation for its networking functionality. 
>
> Learn more: https://go-review.googlesource.com/c/go/+/12603/2/src/cmd/cgo/doc.go

### 5.2. On MacOS

On Mac, the behavior is totoally different, even don't use cgo the final executable will be dynamically linked.

```go
package main

import "fmt"

func main() {
	fmt.Println("hello")
}
```

Build on **MacOS machine**:

```shell
$ go build -o server main.go

$ file server 
server: Mach-O 64-bit executable arm64

# otool is similar to 'ldd' on linux
# -L print shared libraries used
$ otool -L server
server:
	/usr/lib/libSystem.B.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libresolv.9.dylib (compatibility version 0.0.0, current version 0.0.0)
```

**`CGO_ENABLED=0` won't help on MaxOS**. And I found something could be explain this:

> I think this won't work on macOS, where **fully static builds are not allowed/supported by Apple**. Binaries should always go through libSystem, which is also why we changed the way Go calls the kernel in Go 1.12. So, pure Go binaries are already as static as they can be, as far as I can tell.
>
> I propose that on macOS `go build -static` simply tries to statically link cgo libraries, so that the final binary doesn't depend on third-party. So but just on system libraries. To do this, unfortunately, it looks like it's not sufficient to add the output of `pkg-config --static --libs` to `LDFLAGS` because that output still refers to each library as `-L/path/to -lfoo` (as this is the correct syntax when `--static` is passed to the linker, which we are not going to do in macOS). So, the output of `pkg-config` should be rewritten as `/path/to/libfoo.a` (using a similar library path search algorithm that the linker does).
>
> Source: https://github.com/golang/go/issues/26492#issuecomment-525527016

> Yes, I agree with Volker's comment that some systems don't really allow static binaries.
>
> Source: https://stackoverflow.com/a/61324538/16317008

Note that fully static builds are not allowed/supported by Apple doesn't mean we cannot create statically linked binaries on Mac, we can build the binary executable on other platforms, linux, for example. 

```go
package main

import (
	"fmt"
	"net/http"
)

func main() {
	srv := http.NewServeMux()
	srv.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		_, _ = fmt.Fprintln(w, "hello world")
	})
	fmt.Println("running...")
	_ = http.ListenAndServe(":8080", srv)
}
```

Build on MacOS machine with some flags:

```shell
$ GOOS=linux go build -o server main.go

$ file server                          
server: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, Go BuildID=qAraNfnU-cYn-2KsoFx7/rrJYFJTR911CeHr08Y4E/uoFKsYV1LH9as_7QdMc7/fJ71_ARZOiNg7b4tLPIt, with debug_info, not stripped
```

As you can see, even we use the `net` package which uses cgo, it still can be statically with `GOOS=linux` flag, this is called cross compilation, learn more: [Cross Compilation - Go - David's Blog](https://davidzhu.xyz/post/golang/advance/011-cross-compilation/)

But the arch is arm64, not amd64, if you want build binary gonna runs on amd64, you should add `GOARCH=amd64` : 

```shell
$ GOOS=linux GOARCH=amd64 go build -o server main.go
```

### 5.3. `"-extldflags=-static"`

In previous part, we know that `CGO_ENABLED=0` will disable cgo, if we use `net` and we want statically linking, it's fine we just pass `CGO_ENABLED=0` to go build, then we will use pure go implementation of `net`. But what if we use a third party package that only implemented by cgo, [mattn/go-sqlite3](https://github.com/mattn/go-sqlite3) for example, and we want make it linked statically, apparently we can't use `CGO_ENABLED=0` to disable cgo. 

A simle cgo:

```go
package main

// typedef int (*intFunc) ();
//
// int
// bridge_int_func(intFunc f)
// {
//		return f();
// }
//
// int fortytwo()
// {
//	    return 42;
// }
import "C"
import "fmt"

func main() {
	f := C.intFunc(C.fortytwo)
	fmt.Println(int(C.bridge_int_func(f)))
	// Output: 42
}
```

Then compile it with `CGO_ENABLED=0` on Ubuntu machine:

```shell
$ CGO_ENABLED=0 go build -o server main.go
go: no Go source files

# ubuntu @ ip-172-31-12-228 in ~/codes [20:58:50] C:1
$ go build -o server main.go 

# ubuntu @ ip-172-31-12-228 in ~/codes [21:00:15] 
$ file server 
server: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=da0674602632e4f540cfe58f0be1ffa261f2eefe, for GNU/Linux 3.2.0, with debug_info, not stripped
```

Then we can use `-ldflags` to tell the C linker to statically link with `-extldflags`:

```go
-ldflags="-extldflags=-static"
```

```shell
# ubuntu @ ip-172-31-12-228 in ~/codes [21:00:18] 
$ go build -ldflags="-extldflags=-static" -o server main.go

# ubuntu @ ip-172-31-12-228 in ~/codes [21:01:41] 
$ file server 
server: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, BuildID[sha1]=4031763b8f09ffcd1455840afe89c4644eca0088, for GNU/Linux 3.2.0, with debug_info, not stripped
```

Now it's statically linked. 

I hope you can understand the difference between `CGO_ENABLED=0` and `-ldflags="-extldflags=-static"` flag, and when you should use which one. Besides, you should know the different behavior on MacOS and Linux for statically linking in Go. And the two common command `ldd`,  `otool`, `file` will help you. 

Learn more: 

- [Statically compiling Go programs](https://www.arp242.net/static-go.html)
- [#!bash blog/2014/04/linking-golang-statically/](https://blog.hashbangbash.com/2014/04/linking-golang-statically/)
- [cgo | Dave Cheney](https://dave.cheney.net/tag/cgo)
- [Matt Turner - Statically Linking Go in 2022](https://mt165.co.uk/blog/static-link-go/index.html)
