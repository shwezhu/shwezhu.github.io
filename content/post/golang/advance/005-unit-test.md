---
title: Go Tests Basics - Go
date: 2023-09-05 15:10:18
categories:
 - golang
 - advance
tags:
 - golang
 - unit test
---

## 1. `go test` 

`go test` recompiles each package along with any files with names matching the file pattern `*_test.go`. These additional files can contain **test functions**, **benchmark functions**, **fuzz tests** and **example functions**. 

Therefore there four types of functions:

```go
// A test function is one named TestXxx (where Xxx does not start with a
// lower case letter) and should have the signature,
func TestXxx(t *testing.T) { ... }

// A benchmark function is one named BenchmarkXxx and should have the signature,
func BenchmarkXxx(b *testing.B) { ... }

// A fuzz test is one named FuzzXxx and should have the signature,
func FuzzXxx(f *testing.F) { ... }

// An example function is similar to a test function but, instead of using
// *testing.T to report success or failure, it prints output to os.Stdout.
func ExampleXxx() {...}
```

And only one type of file which is `*_text.go`. 

If you want do a **example test** and benchmark test for a file let's say `session.go`, you should have only one test file named `session_test.go`, and in this file you can have two functions one for example test another for benchmark. 

```go
// session_test.go

func BenchmarkSession(b *testing.B) {
  ...
}

func ExampleSession() {
	...
}
```

## 2. Run a specific function

`go test` will run all the test functions in all your test files default, 

```shell
# -v: verbose
$ go test -v         
=== RUN   TestSession
--- PASS: TestSession (4.00s)
=== RUN   TestDeepCopyMap
--- PASS: TestDeepCopyMap (0.00s)
PASS
ok      sessions        4.325s
```

`TestSession`, `TestDeepCopyMap` are two differnent **test functions** that I wrote in different test files, you can see two of them have been executed. 

But sometimes we just want it run a specifc function:

```shell
# "ExampleSession" is the function name you want to execute.
# You don't need to provid which test file does this function loacted,
# go test will look for all test files. 
$ go test -run ExampleSession -v
=== RUN   ExampleSession
...
```

## 3. Run a specific test file

Don't specify a test file to run, specify multiple test functions:

```shell
$ go test session_test.go -v     
# command-line-arguments [command-line-arguments.test]
./session_test.go:18:15: undefined: Session
./session_test.go:20:11: undefined: NewMemoryStore
```

As you see, you have to sepcify all related source files. You can run multiple test function with:

```shell
$ go test -run "ExampleSession|TestSession" -v
```

> Note that the `-run` flag is used for specifying **test functions**, not **benchmarks**, not **fuzz test**. Because **example test** is similar to **test function**, you can specify both example and test function with `-run` flag. 

If you want to specify benchmarks, use `-bench` flag. 

```shell
-bench regexp
	Run only those benchmarks matching a regular expression.
	By default, no benchmarks are run.
-fuzz regexp
	Run the fuzz test matching the regular expression.
-run regexp
	Run only those tests, examples, and fuzz tests matching the regular
	expression.
-skip regexp
	Run only those tests, examples, fuzz tests, and benchmarks that
	do not match the regular expression.
# Flags below can be used with flags above.
-race
 enable data race detection.
-cover
	enable code coverage instrumentation.
```

Learn more: [go command - cmd/go - Go Packages](https://pkg.go.dev/cmd/go#hdr-Testing_flags)