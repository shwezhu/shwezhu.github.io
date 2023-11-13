---
title: MPLS
date: 2023-09-10 08:27:59
categories:
 - networking
tags:
 - networking
typora-root-url: ../../../static
---

## 1. OSPF, BGP and MPLS

- OSPF: OSPF is an interior gateway protocol (IGP) used for routing within an autonomous system (AS). It determines the best paths for routing packets based on metrics such as bandwidth, delay, and cost.
- ﻿﻿BGP: BGP is an exterior gateway protocol (EGP) used for routing between autonomous systems. It enables the exchange of routing information between different networks and determines the best paths between ASes.
- ﻿﻿MPLS: MPLS is not a routing protocol but a forwarding mechanism that operates at the network layer. It uses labels to encapsulate packets, creating virtual paths called Label Switched Paths (LSPs). MPLS allows for efficient forwarding and traffic engineering by quickly switching packets based on labels instead of performing complex IP routing.

> **Routers** refer to internal **routing tables** to make decisions about how to route packets along network paths. A routing table records the paths that packets should take to reach every destination that the router is responsible for. 

## 2. MPLS

### 2.1. Basic concepts

In a network that uses MPLS, each packet is assigned to a class called a forwarding equivalence class (FEC). The network paths that packets can take are called label-switched paths (LSP). A packet's class (FEC) determines which path (LSP) the packet will be assigned to. Packets with the same FEC follow the same LSP.

Each packet has one or more **labels** attached, and all labels are contained in an **MPLS header**, which is added on top of all the other headers attached to a packet. **FECs** are listed within each packet's labels. Routers do not examine the packet's other headers; they can essentially ignore the IP header. Instead, they examine the packet's label and direct the packet to the right **LSP**.

Because MPLS-supporting routers only need to see the MPLS labels attached to a given packet, MPLS can work with almost any protocol (hence the name "multiprotocol"). It does not matter how the rest of the packet is formatted, as long as the router can read the MPLS labels at the front of the packet.

<img src="/008-mpls/aa.png" alt="aa" style="zoom:33%;" />

- Label value: the name says it all, this is where you will find the value of the label.
- EXP: these are the three experimental bits. These are used for QoS, normally the IP precedence value of the IP packet will be copied here.
- S: this is the “bottom of stack” bit. With MPLS it’s possible to add more than one label, you’ll see why in some of the MPLS VPN lessons. When this bit is set to one, it’s the last MPLS header. When it’s set to zero then there is one or more MPLS headers left.
- TTL: just like in the IP header, this is the time to live field. You can use this for traces in the MPLS network. Each hop decrements the TTL by one.

### 2.2. FECs

> FEC is a term used in MPLS networks to describe a set of incoming packets with similar characteristics, allowing those packets to be allocated the same label and forwarded down the same LSP (Label Switched Path). [FEC - Forwarding Equivalence Class](https://www.mpirical.com/glossary/fec-forwarding-equivalence-class.)

In previous part we said: **FECs** are listed within each packet's labels. But, wait, how?

An FEC is a set of packets that a single router:

(1) Forwards to the same next hop;

(2) Out the same interface; and

(3) With the same treatment (such as queuing).

First let’s look at how a packet is forwarded across a path toward a destination using regular IP processes. A packet arrives at R1, and its destination IP address is examined. A lookup is performed at R1, the packet’s FEC (next-hop, outgoing interface, and forwarding treatment) is determined, and with that information the packet is forwarded to the next hop router R2. R2 then repeats the process: The FEC is determined and the packet is forwarded to R3. R3 again determines the packet’s FEC and forwards it to R4.

When an unlabeled packet enters the ingress router and needs to be passed on to an MPLS [tunnel](https://en.wikipedia.org/wiki/Tunneling_protocol), the router first determines the FEC for the packet and then inserts one or more labels in the packet's newly created MPLS header. The packet is then passed on to the next hop router for this tunnel. In an MPLS network the FEC is determined only once, at the ingress to an LSP, rather than at every router hop along the path. 

When a packet reaches an MPLS router, the router examines the topmost label in the label stack. It looks up the label in its forwarding table to determine the associated FEC. 

References: 

- [What is MPLS (multiprotocol label switching)? | Cloudflare](https://www.cloudflare.com/learning/network-layer/what-is-mpls/)
- [MPLS Labels and Devices](https://networklessons.com/mpls/mpls-labels-and-devices)
- [Understanding the Role of FECs in MPLS | Network World](https://www.networkworld.com/article/2350449/understanding-the-role-of-fecs-in-mpls.html)

