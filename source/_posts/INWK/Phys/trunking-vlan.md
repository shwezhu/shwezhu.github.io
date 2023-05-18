---
title: Trunk和Vlan - Lab笔记
date: 2023-05-18 00:49:07
categories:
 - INWK
 - Phys
---

## Switchport `Access Mode` vs `Trunk Mode`

As a general case, freshers in networking domain tend to come across **TRUNK** and **ACCESS** terminologies in Switching. 

**Trunk ports** are generally used in the switch to switch communication or switch to Router (Router on a stick). Trunks carry multiple Vlans across devices and maintain VLAN tags in Ethernet frames for receiving directly connected device differentiates between different [Vlans](https://ipwithease.com/what-is-vlan-virtual-lan/). 

**Access ports** are part of only one VLAN and normally used for terminating end devices likes PC, Laptop and printer.

Using the `Switchport mode access` command forces the port to be an access port while and any device plugged into this port will only be able to communicate with other devices that are in the same VLAN.

Using the `Switchport mode trunk` command forces the port to be trunk port.

## Terminologies

**DTP, Dynamic Trunking Protocol,** is a trunking protocol that is developed and proprietary to Cisco which is used to automatically negotiate trunks between Cisco switches. Trunk negotiations are managed by DTP only if the port is directly connected to each other.

`DTP`就是两个相连的Switch的端口用来协商port mode的, 然后还有两个协议, 是用来封装trucking link上的数据的, In trunking, there are two encapsulation types:`ISL` and `IEEE802.1Q`. 刚说DTP是用来协商mode的, 具体有什么mode, 如下:

**Switch port modes**

- Access — Puts the Ethernet port into permanent nontrunking mode and negotiates to convert the link into a nontrunk link. The Ethernet port becomes a nontrunk port even if the neighboring port does not agree to the change.
- Trunk — Puts the Ethernet port into permanent trunking mode and negotiates to convert the link into a trunk link. The port becomes a trunk port even if the neighboring port does not agree to the change.
- Dynamic Auto — Makes the Ethernet port willing to convert the link to a trunk link. The port becomes a trunk port if the neighboring port is set to trunk or dynamic desirable mode. This is the default mode for some switchports.
- Dynamic Desirable — Makes the port actively attempt to convert the link to a trunk link. The port becomes a trunk port if the neighboring Ethernet port is set to trunk, dynamic desirable or dynamic auto mode.
- No-negotiate — Disables DTP. The port will not send out DTP frames or be affected by any incoming DTP frames. If you want to set a trunk between two switches when DTP is disabled, you must manually configure trunking using the (switchport mode trunk) command on both sides.

The configured switch port mode setting is referred to as the port's trunking administrative mode. The current behavior of a given port after negotiating with the neighboring port is referred to as the port's trunking operational mode.

DTP允许交换机之间进行协商, 具体协商的什么呢, 看看:

1. Trunking Protocol: Switches need to determine which trunking protocol to use for establishing the trunk link. Different trunking protocols, such as IEEE 802.1Q or ISL (Inter-Switch Link), may be supported by switches. The negotiation process helps switches identify compatible protocols and agree on a common protocol to use for trunking.
2. Trunking Mode: Switches need to negotiate the trunking mode, which determines how the trunk link will be formed. There are different modes like desirable, auto, or on. The negotiation process helps switches agree on the appropriate mode to establish the trunk link successfully.
3. VLAN Configuration: The negotiation process involves comparing the VLAN configurations of both switches and reaching a consensus on which VLANs should be allowed over the trunk link. If there are VLANs that are not present or configured differently on both switches, the negotiation process helps reconcile these differences and establish a common set of VLANs that can traverse the trunk.

References:

- [Switchport Access Mode vs Trunk Mode - IP With Ease](https://ipwithease.com/switchport-trunk-mode-vs-access-mode/)
- [Dynamic Trunking Protocol](https://en.wikipedia.org/wiki/Dynamic_Trunking_Protocol)
- [Cisco Dynamic Trunking Protocol (DTP) Explained - Study CCNA](https://study-ccna.com/dynamic-trunking-protocol-dtp-cisco/)