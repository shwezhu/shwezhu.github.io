---
title: Wireshark 抓包分析
date: 2023-06-24 10:02:35
categories:
 - INWK
 - Proto
---

## ICMP

启动 Wireshark 捕捉 ICMP 数据包, 在终端输入

```shell
ping -c1 google.ca
```

捕捉结果如下, 一个 request 一个 reply, 

![a](a.png)

根据输出可以看出, 应用层直接使用的是 ICMP 数据包装, 然后再加上 IP header, 之后是 ethernet, 中间并没有用到传输层的 TCP 或 UDP, 

ICMP 头部的第 1 字节是 type, 第二字节是 code, type+code 决定信息类型, 具体可以在维基百科查看, echo request 的 type = 8, code = 0, echo reply 的 type = 0, code = 0:

![b](b.png)

ICMP 信息格式如下:

![c](c.png)

在 Wireshark 打开数据包查看细节, 可以看到具体 header 里都是有什么内容:

![d](d.png)

然后接着协议栈往下看, 看 IP 包, 先看一下 IP 包的格式:

![e](e.png)

在 wireshark 展开刚 ICMP 上面的 IP 部分, 

![f](f.png)

这里注意一下, 根据上图 IP header 的长度为 20 bytes, 但是实际值是 0101, 大概是因为这个数字被编码成 32-bit words, 即值为 1, 则就是 4 byes, 这里放上一个解释, 供参考:

- The minimum length of an IPv4 header of a valid datagram is 20 bytes, when the value reads 5 and there are no options
- Since the field is 4 bits wide, the maximum value it can store is 15, thus the maximum length of the header is 60 bytes.

> Internet Header Length is **the length of the internet header in 32 bit words**, and thus points to the beginning of the data. Note that the minimum value for a correct header is 5.

Which means whatever value is stored in the IHL, it should be multiplied with 32 to get the **total number of bits**, or with 4 to get the total number of bytes.

再往下的是以太帧和链路层数据包, 不在此讨论范围, 







参考:

- [networking - How do I calculate IP-header length? - Stack Overflow](https://stackoverflow.com/questions/11668172/how-do-i-calculate-ip-header-length)
- 