---
title: Network Programming - Go
date: 2023-09-13 20:06:55
categories:
 - golang
 - practice
tags:
 - golang
 - networking
typora-root-url: ../../../../static
---

## 1. Analyze with Wireshark 

Client:

```go
func main() {
	// Three-way handshake included this step
	// Note that we're connecting to port 9000 on the server,
	// not use port 9000 to connect the server.
	conn, err := net.Dial("tcp", ":9000")
	if err != nil {
		log.Fatalf("couldn't connect to the server: %v", err)
	}
	buf := make([]byte, 15)
	// send data to server, the data will be copied into kernel space
	// and encapsulated into tcp segment -> ip packet -> ethernet frame
	if _, err := conn.Write([]byte("Hi, I am Coco\n")); err != nil {
		log.Fatalf("couldn't send request: %v", err)
	} else {
		// Read data from server, the data are copied from kernel space
		// what happens in kernel space (network stack):
		// ethernet frame -> ip packet -> tcp segment
		// the data will be forwarded to this program.
		// If the connection is closed, return error: io.EOF
		_, err = conn.Read(buf)
		if err != nil {
			log.Fatalf("couldn't read server response: %v", err)
		}
		fmt.Println(string(buf))
	}
	_ = conn.Close()
}
```

Server:

```go
func main() {
	// Obtain the port
	port := fmt.Sprintf(":%s", os.Args[1])
	// Create a tcp listener on the given port
	listener, err := net.Listen("tcp", port)
	if err != nil {
		fmt.Println("failed to create listener, err:", err)
		os.Exit(1)
	}
	fmt.Printf("listening on %s\n", listener.Addr())
	// listen for new connections
	for {
		// Three-way handshake included
		// this connection will be assigned a new port (different from the port this server is listening)
		// for sending and receiving data
		conn, err := listener.Accept()
		if err != nil {
			fmt.Println("failed to accept connection, err:", err)
			continue
		}
		// Pass an accepted connection to a handler goroutine
		go handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	defer conn.Close()
	buf := make([]byte, 15)
	for {
		// read client request data, same as client side
		// if the connection is closed, return error: io.EOF
		_, err := conn.Read(buf)
		if err != nil {
			if err != io.EOF {
				log.Println("failed to read data, err:", err)
			}
			fmt.Println("connection closed by client:", conn.RemoteAddr())
			return
		}
		fmt.Printf("request: %s", buf)
		line := fmt.Sprintf("%s", buf)
		// Same as on client side
		_, _ = conn.Write([]byte(line))
	}
}
```

Run server and client:

```shell
# server
$ go run main.go 9000
# client
$ go run main.go
```

Wireshark (check about usage of Wireshark: ):

![a](/009-network-programming-go/a.png)