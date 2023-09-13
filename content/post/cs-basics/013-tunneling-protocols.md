---
title: Tunneling Protocols
date: 2023-09-10 08:27:59
categories:
 - cs basics
tags:
 - cs basics
 - networking
---

## 1. Tunneling

In [previous post](https://davidzhu.xyz/post/cs-basics/011-tun-device/), we know that ***TUN*** and ***TAP*** are two different kernel virtual network devices, which are used for **tunneling** purposes. In this post, we'll discuss what is tunneling and coomon tunneling protocols. 

In the physical world, tunneling is a way to cross terrain or boundaries that could not normally be crossed. Similarly, in networking, tunnels are a method for transporting data across a network using protocols that are not supported by that network. **Tunneling works by encapsulating packets: wrapping packets inside of other packets.** 

> Encapsulating packets within other packets is called "tunneling." 

Because tunneling involves repackaging the traffic data into a different form, perhaps with encryption as standard, it can hide the nature of the traffic that is run through a tunnel. 

> Encapsulation:
>
> Data traveling over a network is divided into packets. A typical packet has two parts: the **header**, which indicates the packet's destination and which protocol it uses, and the **payload**, which is the packet's actual contents. 
>
> **An encapsulated packet is essentially a packet inside another packet**. In an encapsulated packet, the header and payload of the first packet goes inside the payload section of the surrounding packet. **The original packet itself becomes the payload.** 

> A VPN just uses one of the tunneling protocols, therefore, when you know how each tunneling protocol works, you will know the essence of VPN of that type. 

## 2. Types of Tunneling protocol

In addition to GRE, IPsec, IP-in-IP, and SSH, other tunneling protocols include:

- Point-to-Point Tunneling Protocol (PPTP)
- Secure Socket Tunneling Protocol (SSTP)
- Layer 2 Tunneling Protocol (L2TP)
- Virtual Extensible Local Area Network (VXLAN)

## 3. IPsec - Network layer

The IPsec protocol suite operates at the **network layer** of the OSI model. Within the term "IPsec," "IP" stands for "**Internet Protocol**" and "sec" for "secure."  IPsec usually uses port 500.

The Internet Protocol is the main routing protocol used on the Internet; it designates where data will go using [IP addresses](https://www.cloudflare.com/learning/dns/glossary/what-is-my-ip-address/). IPsec is secure because it **adds encryption and authentication** to this process. 

### 3.1. Why IPSec is important?

Security protocols like IPsec are necessary because networking methods are not encrypted by default. When sending mail through a postal service, a person typically would not write their message on the outside of the envelope. Instead, they enclose their message inside the envelope so that no one who handles the mail between sender and recipient can read their message. However, networking protocol suites like **TCP/IP are only concerned with connection and delivery**, and messages sent are not concealed. Anyone in the middle can read them. IPsec, and other protocols that encrypt data, essentially put an envelope around data as it traverses networks, keeping it secure. 

### 3.2. How does IPsec work?

IPsec connections include the following steps:

**Key exchange:** [Keys](https://www.cloudflare.com/learning/ssl/what-is-a-cryptographic-key/) are necessary for encryption; a key is a string of random characters that can be used to "lock" (encrypt) and "unlock" (decrypt) messages.

**Packet headers and trailers:** All data that is sent over a network is broken down into smaller pieces called packets. Packets contain both a payload and a header. IPsec adds several headers to data packets containing authentication and encryption information. IPsec also adds trailers, which go after each packet's payload instead of before.

Learn more: [What is IPsec? | How IPsec VPNs work | Cloudflare](https://www.cloudflare.com/learning/network-layer/what-is-ipsec/)

### 3.3. IPsec tunnel and IPsec transport mode

**IPsec tunnel mode** is used between two dedicated routers, with each router acting as one end of a virtual "tunnel" through a public network. In IPsec tunnel mode, **both** the original IP header (containing the final destination of the packet) **and** the packet payload is encrypted. To tell intermediary routers where to forward the packets, IPsec adds a new IP header. At each end of the tunnel, the routers decrypt the IP headers to deliver the packets to their destinations.

**In transport mode**, the payload of each packet is encrypted, but the original IP header is not. Intermediary routers are thus able to view the final destination of each packet — unless a separate tunneling protocol (such as [GRE](https://www.cloudflare.com/learning/network-layer/what-is-gre-tunneling/)) is used.

### 3.4. What protocols are used in IPsec?

In [networking](https://www.cloudflare.com/learning/network-layer/what-is-the-network-layer/), a protocol is a specified way of formatting data so that any networked computer can interpret the data. **IPsec is not one protocol, but a suite of protocols**. The following protocols make up the IPsec suite:

**Authentication Header (AH):** The AH protocol ensures that data packets are from a trusted source and that the data has not been tampered with, like a tamper-proof seal on a consumer product. These headers do not provide any encryption; they do not help conceal the data from attackers.

**Encapsulating Security Protocol (ESP):** ESP encrypts the IP header and the payload for each packet — unless transport mode is used, in which case it only encrypts the payload. ESP adds its own header and a trailer to each data packet.

**Security Association (SA):** SA refers to a number of protocols used for negotiating encryption keys and algorithms. One of the most common SA protocols is Internet Key Exchange (IKE).

Finally, while the **Internet Protocol (IP)** is not part of the IPsec suite, IPsec runs directly on top of IP.

### 3.5. How does IPsec impact MSS and MTU?

[MSS](https://www.cloudflare.com/learning/network-layer/what-is-mss/) and [MTU](https://www.cloudflare.com/learning/network-layer/what-is-mtu/) are two measurements of packet size. Packets can only reach a certain size (measured in bytes) before computers, routers, and [switches](https://www.cloudflare.com/learning/network-layer/what-is-a-network-switch/) cannot handle them. MSS measures the size of each packet's payload, while MTU measures the entire packet, including headers. Packets that exceed a network's MTU may be fragmented, meaning broken up into smaller packets and then reassembled. Packets that exceed the MSS are simply dropped.

IPsec protocols add several headers and trailers to packets, all of which take up several bytes. For networks that use IPsec, either the MSS and MTU have to be adjusted accordingly, or packets will be fragmented and slightly delayed. Usually, the MTU for a network is 1,500 bytes. A normal IP header is 20 bytes long, and a TCP header is also 20 bytes long, meaning each packet can contain 1,460 bytes of payload. However, IPsec adds an Authentication Header, an ESP header, and associated trailers. These add 50-60 bytes to a packet, or more.

## 4. GRE - Network Layer

Encapsulating packets within other packets is called "tunneling." GRE tunnels are usually configured between two routers, with each router acting like one end of the tunnel. The routers are set up to send and receive GRE packets directly to each other. **Any routers in between those two routers** will not open the encapsulated packets; they only reference the headers surrounding the encapsulated packets in order to forward them.

GRE enables the usage of protocols that are not normally supported by a network, because the packets are wrapped within other packets that do use supported protocols. To understand how this works, think about the difference between a **car** and a **ferry**. A **car** travels over roads on land, while a **ferry** travels over **water**. A **car** cannot normally travel on **water** — however, a **car** can be loaded onto a **ferry** in order to do so. 

For instance, suppose a company needs to set up a connection between the [local area networks (LANs)](https://www.cloudflare.com/learning/network-layer/what-is-a-lan/) in their two different offices. Both LANs use the latest version of the [Internet Protocol](https://www.cloudflare.com/learning/network-layer/internet-protocol/), IPv6. But in order to get from one office network to another, traffic must pass through a network managed by a third party — which is somewhat outdated and only supports the older IPv4 protocol.

With GRE, the company could send traffic through this network by encapsulating IPv6 packets within IPv4 packets. Referring back to the analogy, the **IPv6 packets are the car**, the IPv4 packets are the ferry, and the **third-party network is the water**.

### 4.1. What goes in a GRE header?

GRE adds two headers to each packet: the GRE header, which is 4 bytes long, and an IP header, which is 20 bytes long. The GRE header indicates the protocol type used by the encapsulated packet. The IP header encapsulates the original packet's header and payload. This means that a GRE packet usually has two IP headers: one for the original packet, and one added by the GRE protocol. Only the routers at each end of the GRE tunnel will reference the original, non-GRE IP header.

### 4.2. How does the use of GRE impact MTU and MSS requirements?

Like any protocol, using GRE adds a few bytes to the size of data packets. This must be factored into the MSS and MTU settings for packets. If the MTU is 1,500 bytes and the MSS is 1,460 bytes (to account for the size of the necessary IP and [TCP](https://www.cloudflare.com/learning/ddos/glossary/tcp-ip/) headers), the addition of GRE 24-byte headers will cause the packets to exceed the MTU:

*1,460 bytes [payload] + 20 bytes [TCP header] + 20 bytes [IP header] + 24 bytes [GRE header + IP header] = 1,524 bytes*

As a result, the packets will be fragmented. Fragmentation slows down packet delivery times and increases how much compute power is used, because packets that exceed the MTU must be broken down and then reassembled.

This can be avoided by reducing the MSS to accommodate the GRE headers. If the MSS is set to 1,436 instead of 1,460, the GRE headers will be accounted for and the packets will not exceed the MTU of 1,500:

*1,436 bytes [payload] + 20 bytes [TCP header] + 20 bytes [IP header] + 24 bytes [GRE header + IP header] = 1,500 bytes*

While fragmentation is avoided, the result is that payloads are slightly smaller, meaning it will take extra packets to deliver data. For instance, if the goal is to deliver 150,000 bytes of content (or about 150 kB), and if the MTU is set to 1,500 and no other layer 3 protocols are used, compare how many packets are necessary when GRE is used versus when it is not used:

- Without GRE, MSS 1,460: **103** packets
- With GRE, MSS 1,436: **105** packets

The extra two packets add milliseconds of delay to the data transfer. However, the usage of GRE may allow these packets to take faster network paths than they could otherwise take, which can make up for the lost time.

## 5. SSH Tunneling  - Application layer

The Secure Shell (SSH) protocol sets up encrypted connections between client and server, and can also be used to set up a secure tunnel. SSH operates at layer 7 of the OSI model, the application layer. By contrast, IPsec, IP-in-IP, and GRE operate at the network layer.

A *[Secure Shell](https://en.wikipedia.org/wiki/Secure_Shell) (SSH) tunnel* consists of an encrypted tunnel created through an [SSH protocol](https://en.wikipedia.org/wiki/Secure_Shell) connection. Users may set up SSH tunnels to transfer [unencrypted](https://en.wikipedia.org/wiki/Unencrypted) traffic over a network through an [encrypted](https://en.wikipedia.org/wiki/Encrypted) channel. It is a software-based approach to network security and the result is transparent encryption. 

References:

- [What is IPsec? | How IPsec VPNs work | Cloudflare](https://www.cloudflare.com/learning/network-layer/what-is-ipsec/)
- [What is tunneling? | Tunneling in networking | Cloudflare](https://www.cloudflare.com/learning/network-layer/what-is-tunneling/)
- [Tunneling protocol](https://en.wikipedia.org/wiki/Tunneling_protocol)
- [What is GRE tunneling? | How GRE protocol works | Cloudflare](https://www.cloudflare.com/learning/network-layer/what-is-gre-tunneling/)
