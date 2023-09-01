---
title: IGMP - 课堂笔记
date: 2023-06-29 22:43:36
categories:
 - INWK
 - Proto
---

## IGMP

The Internet Group Management Protocol (IGMP) is a protocol that allows several devices to share one IP address so they can all receive the same data. Specifically, IGMP allows devices to join a multicasting group. 

任意两个主机之间 可以通过 unicast 建立唯一的 session, 要想一对多, 那可以通过broadcast来实现, 可是broadcast会增加网络负担, 因为不是所有的主机都想接收那一个信息, 这时候就有了multicast, multicast 可以实现指定的一对多, 而 IGMP 就是利用 multicast来实现的, 例如一个主机向一个路由器说, hey 我想订阅 223.0.0.8, 之后该路由器会告诉其他路由器 只要有朝着223.0.0.8发送信息的, 就发给我, 之后该路由器会发给那个主机, 具体参考下面这个视频:

{% youtube W5oMvrMRM3Q %}

## How does IGMP work?

IGMP uses IP addresses that are set aside for multicasting. Multicast IP addresses are in the range between 224.0.0.0 and 239.255.255.255. When a router receives a series of packets directed at the shared IP address, it will duplicate those packets, sending copies to all members of the multicast group. 

IGMP multicast groups can change at any time. A device can send an IGMP "join group" or "leave group" message at any point. 

IGMP works directly on top of the Internet Protocol (IP). Each IGMP packet has both an IGMP header and an IP header. **Just like ICMP, IGMP does not use a transport layer protocol such as TCP or UDP**. 

![1](1.png)

## What types of IGMP messages are there?

- IGMP General Membership Query (MQ) messages are **sent by multicast routers** to its connected subnets to identify the [multicast groups](https://www.omnisecu.com/tcpip/what-is-multicast-group.php) which the multicast clients in the network are interested to subscribe. General Membership Query (MQ) messages are sent by multicast router to the computers on its subnet at link-local All systems multicast address 224.0.0.1. 

- IGMP Group-specific Multicast Query (MQ) messages are sent to a specific multicast groupaddress as the destination IPv4 address. Group-specific Multicast Query (MQ) messages are used to determine the members of a particular multicast group. 

- IGMP Membership Report messages are **sent by multicast clients** inside the subnet to the router to inform the intention to join a multicast group or in response to a Membership Query (MQ) message sent by the router.
- Leave Group (LG) messages are **sent by multicast clients** to local multicast routers to inform that they are no longer interested in traffic from a particular group.

> A **multicast group** is a group of computers (more specifically, network interfaces) interested in receiving a particular stream of data. Multicast groups does not require to be located in a local network segment. Multicast groups can be located in any different network segments connected together with routers those can forward multicast traffic. Computers can join a multicast group or leave a multicast group using a protocol called as IGMP (Internet Group Management Protocol).

![a](a.png)

看一下 IGMPV2 Message Format, 

![b](b-8156690.png)

该信息中的 Group Address Field 解释如下: 

![b](b.png)

注意上面提到的 IP destination address 并不是放到 IGMP Message 里的 Group Address Field 不是一个东西, 

## 分析

```scala
1. 15:56:54.770752 00:00:0a:01:00:16 > 01:00:5e:01:02:03, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 4351, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.1 > 225.1.2.3: igmp v2 report 225.1.2.3

2. 15:58:18.509915 00:00:0a:01:00:01 > 01:00:5e:00:00:01, ethertype IPv4 (0x0800), length 42: (tos 0xc0, ttl 1, id 9466, offset 0, flags [none], proto IGMP (2), length 28)
    10.1.1.254 > 224.0.0.1: igmp query v2

3. 15:58:19.261373 00:00:0a:01:00:01 > 01:00:5e:00:00:02, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 9474, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.254 > 224.0.0.2: igmp v2 report 224.0.0.2

4. 15:58:20.068186 00:00:0a:01:00:01 > 01:00:5e:00:00:09, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 9475, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.254 > 224.0.0.9: igmp v2 report 224.0.0.9

5. 15:58:23.694320 00:00:0a:01:00:16 > 01:00:5e:01:02:03, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 4352, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.1 > 225.1.2.3: igmp v2 report 225.1.2.3

6. 16:00:23.604641 00:00:0a:01:00:01 > 01:00:5e:00:00:01, ethertype IPv4 (0x0800), length 42: (tos 0xc0, ttl 1, id 9552, offset 0, flags [none], proto IGMP (2), length 28)
    10.1.1.254 > 224.0.0.1: igmp query v2

7. 16:00:29.148030 00:00:0a:01:00:01 > 01:00:5e:00:00:09, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 9566, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.254 > 224.0.0.9: igmp v2 report 224.0.0.9

8. 16:00:29.551118 00:00:0a:01:00:16 > 01:00:5e:01:02:03, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 4353, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.1 > 225.1.2.3: igmp v2 report 225.1.2.3

9. 16:00:32.982533 00:00:0a:01:00:01 > 01:00:5e:00:00:02, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 9570, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.254 > 224.0.0.2: igmp v2 report 224.0.0.2

10. 16:02:27.889220 00:00:0a:01:00:01 > 01:00:5e:00:00:01, ethertype IPv4 (0x0800), length 42: (tos 0xc0, ttl 1, id 9627, offset 0, flags [none], proto IGMP (2), length 28)
    10.1.1.254 > 224.0.0.1: igmp query v2

11. 16:02:29.382974 00:00:0a:01:00:16 > 01:00:5e:01:02:03, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 4354, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.1 > 225.1.2.3: igmp v2 report 225.1.2.3

12. 16:02:36.428404 00:00:0a:01:00:01 > 01:00:5e:00:00:09, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 9647, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.254 > 224.0.0.9: igmp v2 report 224.0.0.9

13. 16:02:36.630112 00:00:0a:01:00:01 > 01:00:5e:00:00:02, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 9648, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.254 > 224.0.0.2: igmp v2 report 224.0.0.2

14. 16:03:23.474672 00:00:0a:01:00:16 > 01:00:5e:00:00:02, ethertype IPv4 (0x0800), length 46: (tos 0x0, ttl 1, id 4355, offset 0, flags [none], proto IGMP (2), length 32, options (RA))
    10.1.1.1 > 224.0.0.2: igmp leave 225.1.2.3

15. 16:03:23.475077 00:00:0a:01:00:01 > 01:00:5e:01:02:03, ethertype IPv4 (0x0800), length 42: (tos 0xc0, ttl 1, id 9673, offset 0, flags [none], proto IGMP (2), length 28)
    10.1.1.254 > 225.1.2.3: igmp query v2 [max resp time 10] [gaddr 225.1.2.3]
    
16. 16:03:24.483108 00:00:0a:01:00:01 > 01:00:5e:01:02:03, ethertype IPv4 (0x0800), length 42: (tos 0xc0, ttl 1, id 9674, offset 0, flags [none], proto IGMP (2), length 28)
    10.1.1.254 > 225.1.2.3: igmp query v2 [max resp time 10] [gaddr 225.1.2.3]

Discussion:
Frame 1 is the IGMP join (report) from hostA1. IP destination =225.1.2.3, group address= 225.1.2.3.
Frame 2 is the IGMP general query from routerA. IP destination =224.0.0.1, group address =0.0.0.0.
Frame 3, 4 and 5 are the IGMP reports from the various hosts/routers in reponse to the query in frame 2.

In frame routerA sends a report (to himself and any other multicast router ) that it is a member of 224.0.0.2 ( all multicast routers)

In frame 4 routerA sends a report that it is a member of 224.0.0.9 (RIP routers).
In frame 5 hostA1 sends a report that it is a member if 225.1.2.3.
Frame 6 is another general query. The time interval is 15:58:18. - 16:00:23. = 2 minutes and 5 seconds.
Frame 10 is the ICMP leave message from hostC1. The IP destination is 224.0.0.2 ( all multicast routers) and the group address is 225.1.2.3 ( group leaving).
Frame 11 and 12 are special queries from routerA. The IP destination is 225.1.2.3 and the group address is 225.1.2.3. The maximum response time is 10 seconds. The purpose of these queries is to check if there are any remaining members of the group 225.1.2.3.
```

参考:

- [What is IGMP? | Internet Group Management Protocol | Cloudflare](https://www.cloudflare.com/learning/network-layer/what-is-igmp/)
- https://youtu.be/W5oMvrMRM3Q
- [IGMP基础 | 曹世宏的博客](https://cshihong.github.io/2018/02/12/IGMP%E5%9F%BA%E7%A1%80/)
- [What is multicast group](https://www.omnisecu.com/tcpip/what-is-multicast-group.php)
- [IGMP message types](https://www.omnisecu.com/tcpip/igmp-message-types.php)
- [Internet Group Management Protocol](https://en.wikipedia.org/wiki/Internet_Group_Management_Protocol)
- https://youtu.be/5-h5LNT6DqM