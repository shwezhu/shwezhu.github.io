---
title: 计算网络地址和广播地址 - 课堂笔记
date: 2023-07-01 09:28:37
categories:
 - INWK
 - Proto
---

### 1. 确定用于划分子网的位数

用于划分子网的位数`n`, 由子网掩码决定: 

- 子网掩码若为 27 位, 即 `255.255.255.1110 0000`, 即 `255.255.255.224`, IP 地址共 32 位, 子网掩码为 27 位, 则划分子网位数为 3, 

- 常见的数字: 0=0，128=1，192=2，224=3，240=4，248=5，252=6，254=7，255=8。
- 子网掩码默认为 255.255.255.255, 表示没有子网

> The *limited broadcast address* is 255.255.255.255. A datagram destined for the limited broadcast address is *never* forwarded by a router under any circumstance. It only appears on the local cable.

### 2. 确定主机位数

主机位数等于 `32-子网掩码位数`, 知道了主机位数和子网位数都知道了那子网数和主机数就知道了 `2^n`, 

### 3. 计算广播地址

> 子网中的第一个地址是网络地址, 最后一个地址是广播地址

下面是例子, 可以参考

![a](a.png)

参考:

- [3种方法来计算网络地址和广播地址](https://zh.wikihow.com/%E8%AE%A1%E7%AE%97%E7%BD%91%E7%BB%9C%E5%9C%B0%E5%9D%80%E5%92%8C%E5%B9%BF%E6%92%AD%E5%9C%B0%E5%9D%80)