---
title: Ping & ICMP 
date: 2023-06-21 19:49:33
categories:
 - INWK
 - Proto
---

## `ping` command

`ping` is used to test the reachability of a host on an Internet Protocol (IP) network. Ping uses the Internet Control Message Protocol (ICMP) packets for its operation. Pinging involves sending an ICMP echo request to the target host and waiting for an ICMP echo reply.  

## ICMP Message Format

上面说的 ICMP echo request, ICMP echo reply 是 ICMP Message 的不同类型, 不同类型的 ICMP Message 可以通过 ICMP header 里的 type 和 code field 来判断, 

首先整个协议栈 application 下的协议层的 package 结构都可以认为是 `header + payload`, 即整个协议栈也就是从上到下一直加不同的header, 比如应用层的数据到了加上运输层加上 TCP header 就成了 TCP segment, TCP segment 的结构即 `tcp header + payload`, payload 就是运输层的数据, 同理该 TCP segment 到了 IP 层加上 IP header 就成了 IP package, IP package = `IP header + payload`, 这里的 payload 就是上面的 TCP segment, 这一封装过程也叫 encapsulation, 

其次要知道 ICMP 是工作在 IP层的, 然后它的相关数据是在 IP datagram 里的, 可以理解为 ICMP 在 IP 层之上, TCP 之下, 具体格式如下:

![a](a.png)

可以看到 ICMP Message 的前两字节是 `type`, `code` field, 这两个区域就是判断 ICMP Message 类型的, 具体规则如下:

![b](b.png)

可以看到若一个 ICMP Message 的 `type` 和 `code` field 都为 0 的时候, 该 ICMP Message 的类型就是上面我们说的 ICMP echo reply, 

然后再看一下[维基百科](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol) ICMP Packet 的结构描述:

> The ICMP packet is encapsulated in an IPv4 packet. The packet consists of header and data sections. 即与上面我们说的其他层数据结构一样,  `ICMP Message =  header + payload`, 

> The ICMP header starts after the IPv4 header and is identified by IP protocol number. All ICMP packets have an 8-byte header and variable-sized data section. The first 4 bytes of the header have fixed format, while the last 4 bytes depend on the type/code of that ICMP packet. [Internet Control Message Protocol](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol)

## Results of Ping Command

```shell
# -c3 的意思是发送三次 ping request
$ ping -c3 google.ca
PING google.ca (142.250.80.35): 56 data bytes
64 bytes from 142.250.80.35: icmp_seq=0 ttl=118 time=25.531 ms
64 bytes from 142.250.80.35: icmp_seq=1 ttl=118 time=32.361 ms
64 bytes from 142.250.80.35: icmp_seq=2 ttl=118 time=23.043 ms

--- google.ca ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 23.043/26.978/32.361/3.939 ms
```

可以看到有 3 次回应, 

想用 tcpdump 监控一下 ping 数据包, 看看实际发送收到的什么, 然后就查了一下 ping 的端口号, 就像 ftp, http 应用层协议一般都有自己的默认端口, ping 也是工作在应用层的, 但是, 它没有端口号, 因为 ping 用的是 IP 层的 ICMP 协议, 而端口号和IP地址是属于 TCP层的, 

不仅会想, 应用层的每个应用接收信息都是监控的某个端口, 如一个应用推特只用监控手机上的某个特定端口所有的数据便可以收到信息, 但若 ping 没有端口号, 它是怎么知道来的数据包是属于它的呢? 

专业的话讲就是 有多个进程使用TCP, 那么当TCP接收到数据时, 根据端口号知道数据是属于哪个进程的, 但若有多个进程都使用ICMP, 然后 ICMP 又不使用端口号, 那么当ICMP接收到数据时, 怎么知道该数据是属于哪个进程的呢？下面这个图很好([来源](https://segmentfault.com/q/1010000006052215)): 

![c](c.png)

看到一个人的回答:

> 1. 对于 [ICMP 套接字](https://link.segmentfault.com/?enc=tQT0MRu1f7vLhFYgDdXJnQ%3D%3D.MMFeOwtRILf0oRjsnRPZQqmIEd%2B%2BIls6we5pRkCWObbaoNlRZIFF5sxPX6Bh9m6XoI8WkfZpcK5FNNYb9fUgC4hchL8U344MtmHVb73Qfu8%3D)，ICMP id 就是进程号。
> 2. 对于 raw 套接字，程序自己记住 id。比如 Linux 的 ping 命令就会判断收到的 ICMP 包是不是对应自己发出的。

这个回答的意思就是说, 虽然 ping 没有端口号, 但是操作系统协议栈过滤了 ICMP Packets之后, ping 可以通过 ICMP Packet 的 id来判断是不是属于该进程, 我们用 tcpdump 监控一下, 看看发生了什么, 

首先监控所有关于 icmp 的数据包, 

```shell
# -n: Don't convert addresses (i.e., host addresses, port numbers, etc.) to names.
$ sudo tcpdump -n icmp
```

然后 `ping -c2 google.ca`, 

之后 tcpdump 输出如下:

```shell
$ sudo tcpdump -n icmp  
tcpdump: data link type PKTAP
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on pktap, link-type PKTAP (Apple DLT_PKTAP), snapshot length 524288 bytes
00:18:45.390154 IP 192.168.2.15 > 142.250.80.35: ICMP echo request, id 55385, seq 0, length 64
00:18:45.413787 IP 142.250.80.35 > 192.168.2.15: ICMP echo reply, id 55385, seq 0, length 64
00:18:46.395331 IP 192.168.2.15 > 142.250.80.35: ICMP echo request, id 55385, seq 1, length 64
00:18:46.419453 IP 142.250.80.35 > 192.168.2.15: ICMP echo reply, id 55385, seq 1, length 64
```

可以看到有4个 icmp 数据包, 因为前面我们发送了两次 ping request, 然后得到了两次 echo reply, 所以是 4 个 ICMP 数据包, 很好理解, 然后前两个的 seq number 是0, 就是为了标注 icmp_seq 0的request对应的reply是 icmp_seq 0, 大概这个意思,  后两个是 1, 同理, 

然后你看 id 一直都是 55385 没有变, 看来和上面那个回答一样, 就是用 id来标注某个 ICMP  Message 属于那个进程的, 这样就不用端口号了, 至于`ICMP echo reply`, `ICMP echo request`, 你现在肯定知道是什么了, 

再看一下详细的报告, 

```shell
# -v: When parsing and printing, produce (slightly more) verbose output. 
# For example, the time to live, identification, total length and options in an IP packet are printed. 
# Also enables additional packet integrity checks such as verifying the IP and ICMP header checksum.
# -vvv: Even more verbose output. 
$ sudo tcpdump -vvv -n icmp
Password:
tcpdump: data link type PKTAP
tcpdump: listening on pktap, link-type PKTAP (Apple DLT_PKTAP), snapshot length 524288 bytes
00:31:08.303605 IP (tos 0x0, ttl 64, id 13722, offset 0, flags [none], proto ICMP (1), length 84)
    192.168.2.15 > 142.250.80.35: ICMP echo request, id 65113, seq 0, length 64
00:31:08.327043 IP (tos 0x60, ttl 118, id 0, offset 0, flags [none], proto ICMP (1), length 84)
    142.250.80.35 > 192.168.2.15: ICMP echo reply, id 65113, seq 0, length 64
00:31:09.308832 IP (tos 0x0, ttl 64, id 56957, offset 0, flags [none], proto ICMP (1), length 84)
    192.168.2.15 > 142.250.80.35: ICMP echo request, id 65113, seq 1, length 64
00:31:09.332058 IP (tos 0x60, ttl 118, id 0, offset 0, flags [none], proto ICMP (1), length 84)
    142.250.80.35 > 192.168.2.15: ICMP echo reply, id 65113, seq 1, length 64
```

这里有两个 id, 第一个 id 是 65113, 一直是不变的这个应该是分辨进程的那个, 但是括号里面的那个 id 是什么? 然后这些 id, ttl, 是存储在哪层数据包的header呢?

看下 **Claude-instant** 的回答, 

The id information in the round brackets (id 65113) is the **ICMP identifier**, which is used to identify this specific ICMP echo request/reply session. This ID is chosen by the system generating the ICMP echo request (in this case 192.168.2.15) and sent in each echo request. The responding system (142.250.80.35) then includes the same ID in the echo reply so the requestor knows which request it corresponds to.

The id information outside the round brackets (id 56957) is the **IP identifier**, which is used to reassemble fragmented IP packets. This is a separate identifier used at the IP layer, not specific to ICMP.

So in summary:

- (id 65113) - **ICMP identifier**, used to identify this specific ICMP echo session
- id 56957 - **IP identifier**, used for IP packet reassembly

These identifiers are stored and sent in the packet headers:

- The ICMP identifier is stored in the ICMP header
- The IP identifier is stored in the IP header

The information in the round brackets includes just the relevant ICMP fields:

- id - ICMP identifier 
- seq - ICMP sequence number
- length - ICMP payload length

然后关于 ping 不需要端口号就能正确获取 ICMP Message 的原因, 具体点的解释我也没查到, 只有上面那个简单的回答, 不过经过分析我们也知道了就是通过 ICMP id 来判断的, 看看 AI 咋说的, 

1. Who generates the ICMP echo reply packet?

The operating system of the target system will generate the ICMP echo reply packet, not a separate ping program. Most operating systems have built-in functionality to handle and respond to ICMP echo requests.

2. How does ping receive ICMP messages?

ICMP messages, including echo requests and replies, are received directly by the networking stack of the operating system. The ping program then uses APIs provided by the operating system to "listen" for incoming ICMP echo replies and correlate them to the requests it sent.

So in more detail:

- Ping sends an echo request packet using the operating system's ICMP APIs.

- That echo request packet is routed to the destination IP address using the IP protocol number of 1.

- The destination operating system receives the packet on its network interface. Its networking stack filters ICMP packets and recognizes the echo request. 

- The operating system then generates an echo reply packet in response, again using its built-in ICMP functionality.

- The echo reply packet is routed back to the ping program's system, again using the IP protocol 1.

- The ping program, running as a userspace application, is using the operating system's ICMP APIs. When an echo reply is received by the operating system, it notifies the ping program via those APIs.

- The ping program then correlates the received echo reply packet to the original echo request it sent based on the sequence number, and knows a response was received.

## Traceroute

Traceroute can use either UDP packets OR ICMP packets as the probes that it sends with incrementing TTL values.

- When traceroute uses UDP packets as probes:
  - When the UDP packet's TTL expires at a router, that router will send an ICMP Time Exceeded message back to the traceroute source.
  - Traceroute then observes this ICMP timeout message to detect that the UDP probe timed out, allowing it to identify the router at that hop.
- When traceroute uses ICMP packets as probes:
  - When the ICMP packet's TTL expires at a router, that router will send another ICMP Time Exceeded message back to the traceroute source.
  - Again, traceroute observes this ICMP timeout message to detect that the ICMP probe timed out, identifying the router at that hop.



1. **Routers decrement the TTL**, they do not increment it. When a router receives a packet, it decrements the TTL field by 1. If the TTL reaches 0 after decrementing, the router will drop the packet and send an ICMP Time Exceeded message.
2. **Traceroute itself increments the TTL** with each probe it sends. So for example:

- For the first probe, traceroute will set the TTL to 1
- It will send that probe, and the first router will decrement TTL to 0, drop the probe, and send an ICMP message.
- Traceroute then knows the first hop is that router.
- For the second probe, traceroute will set the TTL to 2
- The second router will decrement TTL to 1, then to 0, drop the probe, and send an ICMP message.
- Traceroute then knows the second hop is that router.



```shell
ping -c2 hostA1 # -c2 means send 2 ping requests
ping -R houstA # The -R flag with ping is used for record route
```

e.g., 

1. The ping command is executed in the terminal or command prompt. This is an application layer request.
2. The ping application creates an ICMP Echo Request packet. This is the ICMP message it wants to send.
3. The ICMP Echo Request packet is encapsulated in a UDP header, since ping typically uses the UDP transport protocol.
4. The ICMP/UDP packet is then encapsulated in an IP packet, with the IP header containing the source and destination IP addresses.
5. The ICMP/UDP/IP packet is given to the network interface card driver, which encapsulates it in a link layer frame. For ethernet, this would be an Ethernet frame with Ethernet header.
6. The Ethernet frame is transmitted over the physical medium, such as copper wire or fiber optic cable, using electrical signals for copper and optical signals for fiber.



One rule of UDP is that if it receives a UDP datagram and the destination port does not correspond to a port that some process has in use, UDP responds with an ICMP port unreachable. We can force a port unreachable using the TFTP client. 

The well-known UDP port for the TFTP server to be reading from is 69. But most TFTP client programs allow us to specify a different port using the connect command. We use this to specify a port of 8888:



Process of Sending UDP:

1. The application sends a UDP datagram to the IP layer, specifying the destination IP address.
2. The IP layer looks up the destination IP address in its ARP cache. There are 3 possibilities:

- The ARP cache has a mapping for that IP address. In this case, the IP layer can send the datagram directly using the cached MAC address, without needing to send an ARP request.
- The ARP cache has an expired mapping for that IP address. In this case, the IP layer will first send an ARP request to update the MAC address, and then send the datagram.
- The ARP cache has no mapping for that IP address. In this case, the IP layer will first send an ARP request, get the MAC address in the ARP reply, and then send the datagram.