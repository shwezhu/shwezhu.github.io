---
title: RIP - 课堂笔记
date: 2023-06-28 22:58:37
categories:
 - INWK
 - Proto
---

## Split Horizon

Split horizon is a method used by distance vector protocols to prevent network routing loops. The basic principle is simple: Never send routing information back in the direction from which it was received.

RIP implements the **split horizon**, **route poisoning**, and **holddown** mechanisms to prevent incorrect routing information from being propagated.

## RIP Intro

In RIPv1 routers broadcast updates with their **routing table** every 30 seconds.

RIP uses the User Datagram Protocol (UDP) as its transport protocol, and is assigned the reserved port number 520.

In most networking environments, RIP is not the preferred choice of routing protocol, as its time to converge and scalability are poor compared to EIGRP, **OSPF**, or IS-IS. However, it is easy to configure, because RIP does not require any parameters, unlike other protocols.

The routing metric used by RIP counts the number of routers that need to be passed to reach a destination IP network. The hop count 0 denotes a network that is directly connected to the router. 16 hops denote a network that is unreachable, according to the RIP hop limit.

In the enterprise, Open Shortest Path First ([OSPF](https://www.techtarget.com/searchnetworking/definition/OSPF-Open-Shortest-Path-First)) routing has largely replaced RIP as the most widely used Interior Gateway Protocol. RIP has been supplanted mainly due to its simplicity and inability to scale to very large and complex networks. Border Gateway Protocol ([BGP](https://www.techtarget.com/searchnetworking/definition/BGP-Border-Gateway-Protocol)) is another distance vector protocol that is now used to transfer routing information across autonomous systems on the internet. 注意 OSPF 是 IGP 与 RIP 类别相同, 与 BGP 是不同的, BGP 是在用在多个 autonomous systems 间, 而前者是用在 autonomous systems 内部, 

## RIP messages between routers
RIP messages use the User Datagram Protocol on port 520 and all RIP messages exchanged between routers are encapsulated in a UDP datagram. 

RIPv1 defined two types of messages:

- Request Message: Asking a neighbouring RIPv1 enabled router to send its routing table.
- Response Message: Carries the routing table of a router.

## RIP 工作过程

![a](a.png)

1. 初始状态:路由器开启RIP进程，宣告相应接口，则设备就会从相关接口发送和接收RIP报文。
2. 构建路由表：路由器依据收到的RIP报文构建自己的路由表项
3. 维护路由表：路由器每隔30秒发送更新报文，同时接收相邻路由器发送的更新报文以维护路由表项。
4. 老化路由表项：路由器为将自己构建的路由表项启动180秒的定时器。180秒内，如果路由器收到更新报文，则重置自己的更新定时器和老化定时器。
5. 垃圾收集表项：如果180秒过后，路由器没有收到相应路由表项的更新，则启动时长为120秒的垃圾收集定时器，同时将该路由表项的度量置为16。
6. 删除路由表项：如果120秒之后，路由器仍然没有收到相应路由表项的更新，则路由器将该表项删除。

## RIP路由表的形成

RIP 启动时的初始路由表仅包含本设备的一些直连接口路由, 通过相邻设备互相学习路由表项, 才能实现各网段路由互通, RIP路由表形成过程:

- RIP协议启动之后，RouterA会向相邻的路由器广播一个Request报文。
- 当RouterB从接口接收到RouterA发送的Request报文后，把自己的RIP路由表封装在Response报文内，然后向该接口对应的网络广播。(RIP传送的是 network address 以及 metric, 并不是路由器每个interface的ip地址)
- RouterA根据RouterB发送的Response报文，形成自己的路由表。

![b](b.png)

## RIP的更新与维护：

RIP协议在更新和维护路由信息时主要使用四个定时器：

- 更新定时器（Update timer）：当此定时器超时时，立即发送更新报文。
- 老化定时器（Age timer）：RIP设备如果在老化时间内没有收到邻居发来的路由更新报文，则认为该路由不可达。
- 垃圾收集定时器（Garbage-collect timer）：如果在垃圾收集时间内不可达路由没有收到来自同一邻居的更新，则该路由将被从RIP路由表中彻底删除。
- 抑制定时器（Suppress timer）：当RIP设备收到对端的路由更新，其cost为16，对应路由进入抑制状态，并启动抑制定时器。为了防止路由震荡，在抑制定时器超时之前，即使再收到对端路由cost小于16的更新，也不接受。当抑制定时器超时后，就重新允许接受对端发送的路由更新报文。

RIP的更新信息发布是由更新定时器控制的，**默认为每30秒**发送一次。

每一条路由表项对应两个定时器：老化定时器和垃圾收集定时器。当学到一条路由并添加到RIP路由表中时，老化定时器启动。如果老化定时器超时，设备仍没有收到邻居发来的更新报文，则把该路由的度量值置为16（表示路由不可达），并启动垃圾收集定时器。如果垃圾收集定时器超时，设备仍然没有收到更新报文，则在RIP路由表中删除该路由。

注意事项：

如果设备不具有触发更新功能，一个路由表项最多需要300秒才能被删除（老化时间+垃圾收集时间）。

如果存在触发更新，那么一个路由条目最多需要120秒才能被删除（即为垃圾收集时间）。

## 如何选路

  (1)当一个[主机](https://blog.csdn.net/pcbase/j614797010.html)试图与另一个主机通信时，IP首先决定目的主机是一个内网还是[外网](https://blog.csdn.net/surfing/s291444.html)，怎么确定？当然使用网络号。
  (2)如果是是同一[内网](https://blog.csdn.net/safe-tech/v366061.html)，那就就是直接发送了，这个最简答不过了。
  (3)如果目的主机是和发送主机不在同一个内网，也就是在[外网](https://blog.csdn.net/web-special/x461913.html)了，^_^很啰嗦，IP将查询路由表来为外网主机或外网选择一个[路由](https://blog.csdn.net/linux/2008/07/s419030.html)，所以一般情况下有可能为某个外网指定特定的路由，具体问题稍后[分析](https://blog.csdn.net/net-manage/d688124081.html)。
  (4)若未找到明确的[路由](https://blog.csdn.net/z/specia/router.html)，此时在路由表中还会有默认网关，也可称为缺省网关，IP用缺省的[网关](https://blog.csdn.net/other-devtool/f218154.html)地址将一个数据传送给下一个指定的路由器，所以网关也可能是[路由器](https://blog.csdn.net/route/f801344008.html)，也可能只是内网向特定路由器传输数据的网关。
  (4)在该[路由器](https://blog.csdn.net/win98/2009/12/f485537.html)收到数据后，它再次为远程主机或网络查询路由，若还未找到路由，该[数据包](https://blog.csdn.net/net-manage/d264176081.html)将发送到该路由器的缺省网关地址。

## RIP timers

- **Update timer** -- Frequency of routing updates. Every 30 seconds IP RIP sends a complete copy of its routing table, subject to [split horizon](https://www.techtarget.com/searchnetworking/definition/split-horizon). (Internetwork packet exchange RIP does this every 60 seconds.)
- **Invalid timer** -- Absence of refreshed content in a routing update. RIP waits 180 seconds to mark a route as invalid and immediately puts it into hold-down.
- **Hold-down timers and triggered updates** -- Assist with stability of routes in a Cisco environment. Hold-downs ensure that regular update messages do not inappropriately cause a routing loop. The router doesn't act on non-superior new information for a certain period of time. RIP's hold-down time is 180 seconds.
- **Flush timer** -- RIP waits an additional 240 seconds after hold-down before it actually removes the route from the table.

参考:

- [What is Routing Information Protocol (RIP) and How Does It Work?](https://www.techtarget.com/searchnetworking/definition/Routing-Information-Protocol)
- [What is a Routing Table? – A Definition from TechTarget.com](https://www.techtarget.com/searchnetworking/definition/routing-table)
- [Routing Information Protocol](https://en.wikipedia.org/wiki/Routing_Information_Protocol)
- [RIP基础知识 | 曹世宏的博客](https://cshihong.github.io/2018/03/23/RIP%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86/)
- [如何理解ip路由和操作linux的路由表_blueman2012的博客-CSDN博客](https://blog.csdn.net/blueman2012/article/details/6699364)
