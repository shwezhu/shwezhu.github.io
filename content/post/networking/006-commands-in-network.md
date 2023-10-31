---
title: Commands Commonly Used in Networking
date: 2023-10-31 15:23:08
categories:
 - networking
tags:
 - networking
---

## 1. `nslookup`

**Nslookup** (stands for “Name Server Lookup”) is a useful command for getting information from the DNS server. It is a network administration tool for querying the Domain Name System (DNS) to obtain domain name or IP address mapping or any other specific DNS record. 

`nslookup` followed by the domain name will display the “A Record” (IP Address) of the domain:

```shell
# basic DNS lookup
$ nslookup google.com                             
Server:		192.168.2.1
Address:	192.168.2.1#53

Non-authoritative answer:
Name:	google.com
Address: 142.250.81.238
```

You can also do the reverse DNS look-up by providing the IP Address as an argument to nslookup:

```shell
$ nslookup 18.219.46.189                          
Server:		192.168.2.1
Address:	192.168.2.1#53

Non-authoritative answer:
189.46.219.18.in-addr.arpa	name = ec2-18-219-46-189.us-east-2.compute.amazonaws.com.

Authoritative answers can be found from:
46.219.18.in-addr.arpa	nameserver = ns1-24-us-east-2.ec2-rdns.amazonaws.com.
```

Lookup for an ns record of domain:

```shell
$ nslookup -type=ns google.com
Server:		192.168.2.1
Address:	192.168.2.1#53

Non-authoritative answer:
google.com	nameserver = ns1.google.com.
google.com	nameserver = ns3.google.com.
....
```

Source: [Nslookup Command in Linux with Examples - GeeksforGeeks](https://www.geeksforgeeks.org/nslookup-command-in-linux-with-examples/)

## 2. `dig`

**dig** command stands for ***Domain Information Groper***. It is used for retrieving information about DNS name servers. Dig command replaces older tools such as [nslooku](https://www.geeksforgeeks.org/nslookup-command-in-linux-with-examples/)p and the [host](https://www.geeksforgeeks.org/host-command-in-linux-with-examples/).

To query domain “A” record:

```shell
$ dig geeksforgeeks.org
```

This command causes dig to look up the “A” record for the domain name “geeksforgeeks.org”. A record refers to IPV4 IP. Similarly, if record type is set as “AAAA”, this would return IPV6 IP.  

To query domain “A” record with **+short**

```shell
$ dig geeksforgeeks.org +short
34.218.62.116
```

Specifying name servers:

```shell
$ dig geeksforgeeks.org @8.8.8.8
```

> By default, dig command will query the name servers listed in “/etc/resolv.conf” to perform a DNS lookup. We can change it by using @ symbol followed by a hostname or IP address of the name server. 
