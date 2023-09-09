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

## 1. Set up

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
