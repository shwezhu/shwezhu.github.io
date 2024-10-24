---
title: Go Modules and Environment
date: 2024-01-18 22:12:20
categories:
 - golang
 - basics
tags:
 - golang
---

## `go build` vs `go install`

The `go install` command **builds and installs** the packages named by the paths on the command line. Executables (main packages) are installed to the directory named by the GOBIN environment variable, which defaults to `$GOPATH/bin` or `$HOME/go/bin` if the `GOPATH` environment variable is not set.

The `go install` command behaves almost identically to `go build`, but instead of leaving the executable in the current directory, or a directory specified by the `-o` flag, it places the executable into the `$GOPATH/bin` directory.

```shell
# check the $GOPATH
❯ go env GOPATH
/Users/David/go
```

> Since `go install` will place generated executables into `$GOPATH/bin`, this directory must be added to the `$PATH` environment variable so that you can run the executables from the command line anywhere.

## Commands commonly used in Go Modules

- **go mod init github.com/your-username/your-repo-name** (enabling dependency tracking in your code)

To track and manage the dependencies you add, you begin by putting your code in its own module. This creates a `go.mod` file at the root of your source tree. Dependencies you add will be listed in that file.

- **go get** (adding a dependency)

The following describes a few examples.

To add all dependencies for a package in your module, run a command like the one below ("." refers to the package in the current directory):
```shell
$go get .
```

To add a specific dependency, specify its module path as an argument to the command:

```shell
$ go get github.com/example/xxmodule
```

> The package installed by `go get` will be downloaded into the `$GOPATH/pkg/mod/cache` directory.

- **go mod tidy**

go mod tidy ensures that the go.mod file matches the source code in the module. It adds any missing module requirements necessary to build the current module’s packages and dependencies, and it removes requirements on modules that don’t provide any relevant packages. It also adds any missing entries to go.sum and removes unnecessary entries.

References: 

- [Go Modules Reference - The Go Programming Language](https://go.dev/ref/mod#go-mod-init)
- [Managing dependencies - The Go Programming Language](https://go.dev/doc/modules/managing-dependencies#naming_module)
