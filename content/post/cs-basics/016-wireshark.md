---
title: Wireshark
date: 2023-09-13 16:52:30
categories:
 - cs basics
tags:
 - cs basics
typora-root-url: ../../../static
---

## 1. Structure

![a](/016-wireshark/a.png)

## 2. Capture filter

### 2.1. Selcet netowk interface

- `en0` 
  - Physical network interface
- utun0~4
  - VIrtual netwrok interface used for tunneling, learn more: [Working with TUN Device on MacOS - David's Blog](https://davidzhu.xyz/post/cs-basics/011-tun-device/)
- loopback interface: 127.0.0.1
  - When you learn network programming and run a echo server and client on your loacl machine, you should select the `loopback` interface, not the `en0` interface. 

### 2.2. Specify filter rules

Filter by port:

```shell
tcp port 9000
```

## 3. Display filter



References:

- [CaptureFilters - Wireshark](https://wiki.wireshark.org/CaptureFilters)
- 