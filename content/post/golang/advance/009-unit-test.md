---
title: Unit Test - Go
date: 2023-09-30 09:58:56
categories:
 - golang
 - practice
tags:
 - golang
 - unit test
---

## 1. Benchmark 

### 1.1. `b.N` loop

Functions of the form

```
func BenchmarkXxx(*testing.B)
```

are considered benchmarks, and are executed by the `go test` command when its `-bench` flag is provided. Benchmarks are run sequentially. 

A sample benchmark function looks like this:

```go
func BenchmarkRandInt(b *testing.B) {
    for i := 0; i < b.N; i++ {
        rand.Int()
    }
}
```

The benchmark function must run the target code b.N times. During benchmark execution, **b.N is adjusted until the benchmark function lasts long enough to be timed reliably**. The output

```
BenchmarkRandInt-8   	68453040	        17.8 ns/op
```

means that the loop ran 68453040 times at a speed of 17.8 ns per loop.

### 1.2. set up

If a benchmark needs some **expensive setup before running**, the timer may be reset:

```go
func BenchmarkBigLen(b *testing.B) {
    big := NewBig()
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        big.Len()
    }
}
```

### 1.3. `RunParallel()`

If a benchmark needs to test performance in a parallel setting, it may use the `RunParallel` helper function; such benchmarks are intended to be used with the `go test -cpu` flag:

```go
func main() {
	testing.Benchmark(func(b *testing.B) {
		templ := template.Must(template.New("test").Parse("Hello, {{.}}!"))
		b.RunParallel(func(pb *testing.PB) {
			// Each goroutine has its own bytes.Buffer.
			var buf bytes.Buffer
			for pb.Next() {
				// The loop body is executed b.N times total across all goroutines.
				buf.Reset()
				templ.Execute(&buf, "World")
			}
		})
	})
}

```

The body function will be run in each goroutine. It should set up any goroutine-local state and then iterate until pb.Next returns false. It should not use the StartTimer, StopTimer, or ResetTimer functions, because they have global effect. It should also not call Run. 

References:

- https://pkg.go.dev/testing#hdr-Benchmarks
- https://pkg.go.dev/testing#B.RunParallel

