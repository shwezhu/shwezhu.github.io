---
title: Wireshark Basics 
date: 2023-09-13 16:52:30
categories:
 - networking
tags:
 - networking
typora-root-url: ../../../static
---

## 1. Structure

![a](/001-wireshark/a.png)

## 2. Capture filter

### 2.1. Selcet netowk interface

- `en0` 
  - Physical network interface
- utun0~4
  - VIrtual netwrok interface used for tunneling, learn more: [Working with TUN Device on MacOS - David's Blog](https://davidzhu.xyz/post/networking/007-tun-device-macos/)
- loopback interface: 127.0.0.1
  - When you run a echo server and client on your local machine, you should select the `loopback` interface, not the `en0` interface. 

### 2.2. Specify filter rules

Filter by port and protocol:

```shell
tcp port 9000
```

Learn more: [CaptureFilters](https://wiki.wireshark.org/CaptureFilters)

> Wireshark can only capture some specific ports that for HTTP package by default, so if you gonna capture HTTP package, make sure use the correct ports ir goto settings to change the default ports. If you ignore this, like to capture HTTP on port 9000, you probably jut get TCP package.  
>
> You can find the allowed HTTP port on Preferences->Protocols->HTTP

## 3. Display filter

[DisplayFilters](https://wiki.wireshark.org/DisplayFilters)

References:

- [CaptureFilters - Wireshark](https://wiki.wireshark.org/CaptureFilters)