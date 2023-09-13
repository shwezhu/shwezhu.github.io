---
title: Octopus - Go
date: 2023-09-08 21:43:55
categories:
 - golang
 - practice
tags:
 - golang
 - practice
---

## 1. Simple test

### 1.1. Install Go

```shell
# choose your version
$ wget https://go.dev/dl/go1.21.1.linux-amd64.tar.gz
$ sudo tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz
```

Add environment variable, edit `.zshrc` file:

```
export PATH=$PATH:/usr/local/go/bin
```

Learn more: https://go.dev/doc/install

### 1.2. Run server & client code

An echo server for test: https://github.com/venilnoronha/tcp-echo-server/blob/master/main_test.go

```shell
$ go run main.go 9000 hello
```

> You need configure the firewall of you server, enable the tcp connection for port 9000. 

Run the code below on you loacl machine:

```go
func main() {
  server_public_ip := "xx.xx.xx.xx:9000"
	conn, err := net.Dial("tcp", server_public_ip)
	if err != nil {
		log.Fatalf("couldn't connect to the server: %v", err)
	}
	defer conn.Close()
	if _, err := conn.Write([]byte("world" + "\n")); err != nil {
		log.Fatalf("couldn't send request: %v", err)
	} else {
		reader := bufio.NewReader(conn)
		response, err := reader.ReadBytes(byte('\n'))
		if err != nil {
			log.Fatalf("couldn't read server response: %v", err)
		}
		fmt.Println(string(response))
	}
}
```

## 2. Set up TUN on vpn client

```shell
go get -u github.com/songgao/water
```

```go
func main() {
	ifce, err := water.New(water.Config{DeviceType: water.TUN})
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("Interface Name: %s\n", ifce.Name())

	packet := make([]byte, 1500)
	for {
		n, err := ifce.Read(packet)
		if err != nil {
			log.Fatal(err)
		}
		log.Printf("Packet Received: % x\n", packet[:n])
	}
}

```

```shell
# NOTE: replace utunx with the name printed on your go code above
$ sudo ifconfig utun5 10.1.0.10 10.1.0.20 up
```

Then test:

```shell
ping 10.1.0.20
```

If no data printed on your go codes, restart your go codes and change a pair of ip addresses for utun interface.

Learn more: 

- [songgao/water: A simple TUN/TAP library written in native Go.](https://github.com/songgao/water)
- [TUN Device & utun Interface](https://davidzhu.xyz/post/cs-basics/011-tun-device/)

