---
title: Function Closures - Go
date: 2023-09-18 23:32:55
categories:
 - golang
 - practice
tags:
 - golang
---

## 1. What is closure

> Go functions may be closures. A closure is a function value that references variables from outside its body. The function may access and assign to the referenced variables; in this sense the function is "bound" to the variables.
>
> [Closures - A Tour of Go](https://go.dev/tour/moretypes/25)

```go
func adder() func(int) (int, *int) {
	sum := 0
	return func(x int) (int, *int) {
		sum += x
		return sum, &sum
	}
}

func main() {
	pos, neg := adder(), adder()
	for i := 1; i <= 3; i++ {
		sum, addr := pos(i)
		fmt.Println("pos:  ", sum, " ", addr)
		sum, addr = neg(-i)
		fmt.Println("neg: ", sum, " ", addr)
	}
}

//--------------------------
pos:   1   0x140000b0018
neg:  -1   0x140000b0020
pos:   3   0x140000b0018
neg:  -3   0x140000b0020
pos:   6   0x140000b0018
neg:  -6   0x140000b0020
```

As we see above,  when the anonymous function defined in the `adder()` access `sum`, it looks like accessing a global variable, because even the function `adder()` has returned we still can access variable `sum`. However, there are "two" `sum` actually, they are isolated and each has its own address. 

You should note that we return an anonymous function here, function is first-class citizen in golang just like javascript, it's a gift don't fear it. 

## 2. Use cases

## 2.1. Pass behaviour

```go
type Mux struct {
	mu    sync.Mutex
	conns map[net.Addr]net.Conn
}

func (m *Mux) Add(conn net.Conn) {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.conns[conn.RemoteAddr()] = conn
}

func (m *Mux) Remove(addr net.Addr) {
	m.mu.Lock()
	defer m.mu.Unlock()
	delete(m.conns, addr)
}

func (m *Mux) SendMsg(msg string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, conn := range m.conns {
		_, err := io.WriteString(conn, msg)
		if err != nil {
			return err
		}
	}
	return nil
}
```

Is this what we call idiomatic in Go? Maybe. This is our first proverb **don't mediate the access to shared memory with locks and mutexes** instead share that memory by communicating. 

```go
type Mux struct {
	add     chan net.Conn
	remove  chan net.Addr
	sendMsg chan string
}

func (m *Mux) Add(conn net.Conn) {
	m.add <- conn
}

func (m *Mux) Remove(addr net.Addr) {
	m.remove <- addr
}

func (m *Mux) SendMsg(msg string) error {
	m.sendMsg <- msg
	return nil
}

func (m *Mux) loop() {
  // only one goroutine can access this map, 
  // don't need lock
	conns := make(map[net.Addr]net.Conn)
	for {
		select {
		case conn := <-m.add:
			conns[conn.RemoteAddr()] = conn
		case addr := <-m.remove:
			delete(conns, addr)
		case msg := <-m.sendMsg:
			for _, conn := range conns {
				_, _ = io.WriteString(conn, msg)
			}
		}
	}
}
```

We don't need the mutex anymore because the shared sate this `conns` map is now local to the `loop()` function, it can't be mutated by anybody else. There cannot be a (data) race because it only exists within the scope of that function. 

But there's still a lot of hard-coded logic in here, `loop()` only knows how to do three things, it only knows how to `add`, `remove` and `sendMsg`. If we wanted to extend our `Mux`,  it would involve three things

- adding a channel
- adding a helper (function) to send data over that channel
- and then opening up the `select` logic inside loop and adding the knowledge of how to process  that data

But we can rewrite our `Mux` to use first-class functions **to pass the behavior we want to be executed** not the data to interpret. 

```go
type Mux struct {
	ops chan func(map[net.Addr]net.Conn)
}

func (m *Mux) Add(conn net.Conn) {
	m.ops <- func(m map[net.Addr]net.Conn) {
		m[conn.RemoteAddr()] = conn
	}
}

func (m *Mux) Remove(addr net.Addr) {
	m.ops <- func(m map[net.Addr]net.Conn) {
		delete(m, addr)
	}
}

func (m *Mux) SendMsg(msg string) error {
	m.ops <- func(m map[net.Addr]net.Conn) {
		for _, conn := range m {
			_, _ = io.WriteString(conn, msg)
		}
	}
	return nil
}

func (m *Mux) loop() {
	conns := make(map[net.Addr]net.Conn)
	for op := range m.ops {
		op(conns)
	}
}
```

But there are a few little problems to fix, the lack of error handling inside `sendMsg`,  if there's an error of writing to one of the connections that's just going to be discarded. To handle the error generated inside the anonymous function that we pass into loop we need to create a channel to communicate with the result of the operation. 

```go
func (m *Mux) SendMsg(msg string) error {
	result := make(chan error, 1)
	m.ops <- func(m map[net.Addr]net.Conn) {
		for _, conn := range m {
			_, err := io.WriteString(conn, msg)
			if err != nil {
				result <- err
				return
			}
		}
		result <- nil
	}
	return <-result
}

func (m *Mux) PrivateMsg(addr net.Addr, msg string) (int, error) {
	result := make(chan net.Conn, 1)
	m.ops <- func(m map[net.Addr]net.Conn) {
		result <- m[addr]
	}
	conn := <-result
	if conn == nil {
		return 0, fmt.Errorf("client %v not registered", addr)
	}
	return io.WriteString(conn, msg)
}
```

- First class functions let you pass around behaviour, not just dead data that must be interpreted.
- First class functions aren't new or novel.
- Like the other features, first class functions should be used with restraint.
- First class functions are something that every Go programmer should have in their toolbox.
- First class functions aren't hard, just a little unfamiliar, and that is something that can be overcome with practice.

> Next time you define an API it has just one method I want you to ask yourself: should this really just be a function.

Source: [dotGo 2016 - Dave Cheney - Do not fear first class functions](https://www.youtube.com/watch?v=5buaPyJ0XeQ&list=WL&index=1) 

{{% youtube "5buaPyJ0XeQ" %}}

References:

- [Function Closures - A Tour of Go](https://go.dev/tour/moretypes/25)
-  [First-Class Functions in Golang](https://levelup.gitconnected.com/first-class-functions-in-golang-ef2a5001bb4f) 