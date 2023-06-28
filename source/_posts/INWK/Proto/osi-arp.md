---
title: OSI Model & ARP Format
date: 2023-06-27 19:39:36
categories:
 - INWK
 - Proto
---

## OSI 和 TCP/IP 模型

ARP 是 Data Link layer 的协议, 先看一下 **OSI 模型**:

- Physical layer
  - WiFi (802.11) operates at the first two layers of the OSI model, in other words, the physical layer and the data link layer. 
- Data Link layer
  - WiFi (802.11) 
  - ARP (Address Resolution Protocol)
- Network layer
  - IP (Internet Protocol)
  - ICMP (Internet Control Message Protocol)
- Transport layer
  - TCP (Transmission Control Protocol) 
  - UDP (User Datagram Protocol)
- Session layer
- Presentation layer
- Application layer 
  - HTTP - for web applications
  - FTP - for file transfer
  - DNS - converts hostnames to IP addresses
  - SMTP - for email

**TCP 模型**:

- Network Access layer, combines the physical and data link layers of the OSI model.
- Internet layer
- Transport layer
- Application layer, combines the session, presentation and application layers in OSI.

了解了每一层都是什么, 以及每个协议工作在哪一层, 有便于对协议的信息格式有个整体的把握, 比如知道 ARP 协议工作在 data link 层, 而 IP 协议在 data link 之上, 所以 ARP 信息肯定包括 IP 地址等信息, 

## ARP

The Address Resolution Protocol is a data link layer protocol used to map MAC addresses to IP addresses. All hosts on a network are located by their IP address, but NICs do not have IP addresses, they have MAC addresses.

![b](b.png)

**Hardware type:** This is 16 bits field defining the type of the network on which ARP is running. Ethernet is given type 1. 

**Protocol type:** This is 16 bits field defining the protocol. The value of this field for the IPv4 protocol is 0800H.

**Hardware length:** This is an 8 bits field defining the length of the physical address in bytes. Ethernet is the value 6.

**Protocol length:** This is an 8 bits field defining the length of the logical address in bytes. For the IPv4 protocol, the value is 4.

**Operation** (**request or reply):** This is a 16 bits field defining the type of packet. Packet types are ARP request (1), and ARP reply (2).

**Sender hardware address:** This is a variable length field defining the physical address of the sender. For example, for Ethernet, this field is 6 bytes long.

**Sender protocol address:** This is also a variable length field defining the logical address of the sender For the IP protocol, this field is 4 bytes long.

**Target hardware address:** This is a variable length field defining the physical address of the target. For Ethernet, this field is 6 bytes long. For the ARP request messages, this field is all Os because the sender does not know the physical address of the target.

**Target protocol address:** This is also a variable length field defining the logical address of the target. For the IPv4 protocol, this field is 4 bytes long.

课本给的 Ethernet 类型的 ARP 格式:

![a](a.png)

参考:

- [Address Resolution Protocol (ARP) - IBM Documentation](https://www.ibm.com/docs/en/zos-basic-skills?topic=3-address-resolution-protocol-arp)
- [ARP Protocol Packet Format - GeeksforGeeks](https://www.geeksforgeeks.org/arp-protocol-packet-format/)