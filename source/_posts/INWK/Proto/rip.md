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

## RIP 工作过程

RIP uses a distance vector algorithm to decide which path to put a packet on to get to its destination. Each RIP router maintains a [routing table](https://www.techtarget.com/searchnetworking/definition/routing-table), which is a list of all the destinations the router knows how to reach. Each router broadcasts its entire routing table to its closest neighbors every 30 seconds. In this context, *neighbors* are the other routers to which a router is connected directly -- that is, the other routers on the same network segments as the selected router. The neighbors, in turn, pass the information on to their nearest neighbors, and so on, until all RIP hosts within the network have the same knowledge of routing paths. This shared knowledge is known as *convergence*.

If a router receives an update on a route, and the new path is shorter, it will update its table entry with the length and next-hop address of the shorter path. If the new path is longer, it will wait through a "hold-down" period to see if later updates reflect the higher value as well. It will only update the table entry if the new, longer path has been determined to be stable.

If a router crashes or a network connection is severed, the network discovers this because that router stops sending updates to its neighbors, or stops sending and receiving updates along the severed connection. If a given route in the routing table isn't updated across six successive update cycles (that is, for 180 seconds) a RIP router will drop that route and let the rest of the network know about the problem through its own periodic updates.

RIP supports only 15 hops in a path. If a packet can't reach a destination in 15 hops, the destination is considered unreachable. Paths can be assigned a higher cost (as if they involved extra hops) if the enterprise wants to limit or discourage their use. For example, a satellite backup link might be assigned a cost of 10 to force traffic to follow other routes when available.

## RIP timers

- **Update timer** -- Frequency of routing updates. Every 30 seconds IP RIP sends a complete copy of its routing table, subject to [split horizon](https://www.techtarget.com/searchnetworking/definition/split-horizon). (Internetwork packet exchange RIP does this every 60 seconds.)
- **Invalid timer** -- Absence of refreshed content in a routing update. RIP waits 180 seconds to mark a route as invalid and immediately puts it into hold-down.
- **Hold-down timers and triggered updates** -- Assist with stability of routes in a Cisco environment. Hold-downs ensure that regular update messages do not inappropriately cause a routing loop. The router doesn't act on non-superior new information for a certain period of time. RIP's hold-down time is 180 seconds.
- **Flush timer** -- RIP waits an additional 240 seconds after hold-down before it actually removes the route from the table.

参考:

- [What is Routing Information Protocol (RIP) and How Does It Work?](https://www.techtarget.com/searchnetworking/definition/Routing-Information-Protocol)
- [What is a Routing Table? – A Definition from TechTarget.com](https://www.techtarget.com/searchnetworking/definition/routing-table)
- [Routing Information Protocol](https://en.wikipedia.org/wiki/Routing_Information_Protocol)
