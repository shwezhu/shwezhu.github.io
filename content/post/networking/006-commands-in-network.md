---
title: Tools Commonly Used in Networking
date: 2023-10-31 15:23:08
categories:
 - networking
tags:
 - networking
---

## 1. `nslookup`

**Nslookup** (stands for “Name Server Lookup”) is a useful command for getting information from the DNS server. It is a network administration tool for querying the Domain Name System (DNS) to obtain domain name or IP address mapping or any other specific DNS record. 

`nslookup` followed by the domain name will display the **“A Record”** (IP Address) of the domain:

```shell
# basic DNS lookup
$ nslookup google.com                             
Server:		192.168.2.1
Address:	192.168.2.1#53

Non-authoritative answer:
Name:	google.com
Address: 142.250.81.238
```

**Lookup for NS record of domain**:

```shell
$ nslookup -type=ns google.com
Server:		192.168.2.1
Address:	192.168.2.1#53

Non-authoritative answer:
google.com	nameserver = ns1.google.com.
google.com	nameserver = ns3.google.com.
....
```

You can also do the **reverse DNS look-up** by providing the IP Address as an argument to nslookup:

```shell
$ nslookup 18.219.46.189                          
Server:		192.168.2.1
Address:	192.168.2.1#53

Non-authoritative answer:
189.46.219.18.in-addr.arpa	name = ec2-18-219-46-189.us-east-2.compute.amazonaws.com.

Authoritative answers can be found from:
46.219.18.in-addr.arpa	nameserver = ns1-24-us-east-2.ec2-rdns.amazonaws.com.
```

> *“**Non-authoritative answer**” is the expected output from nslookup in 99.9% of cases, so this warning can be safely ignored. Your ISP’s DNS server is what your computer (and nslookup) uses to get answers to DNS queries. Every website and domain has different authoritative DNS servers, and your ISP’s DNS server queries these authoritative DNS servers on your behalf. Because you got the answer indirectly via your ISP’s DNS server, nslookup tells you the answer is not authoritative.* [Source](https://ioflood.com/blog/what-is-the-meaning-of-non-authoritative-answer-given-by-nslookup-dns-demystified/)

When using the nslookup utility to query Domain Name System (DNS) servers, you could see the message “Non-authoritative answer.” This tells you that the DNS server you’re asking can’t ensure that it has the official, up-to-date information for the domain name or IP address you’re seeking up and is instead giving you a cached response that it got from another DNS server. 

Please note that getting non-authoritative answers doesn't mean incorrect or unreliable. However, if you need the **most accurate and up-to-date information**, it is recommended to use authoritative DNS servers for queries. 

Reference: 

[Nslookup Command in Linux with Examples - GeeksforGeeks](https://www.geeksforgeeks.org/nslookup-command-in-linux-with-examples/)

[Why is “Non-authoritative answer” given by nslookup? DNS Explained](https://ioflood.com/blog/what-is-the-meaning-of-non-authoritative-answer-given-by-nslookup-dns-demystified/)

## 2. Get authoritative answer

1. Use the `nslookup` command to query the SOA (Start of Authority) record of the domain name. The SOA record contains information about the authoritative name servers for the domain. 

```bash
❯ nslookup -type=soa davidzhu.xyz
Non-authoritative answer:
...

Authoritative answers can be found from:
davidzhu.xyz	nameserver = ns1.dnsowl.com.
davidzhu.xyz	nameserver = ns2.dnsowl.com.
davidzhu.xyz	nameserver = ns3.dnsowl.com.
```

2. Identify the primary name server from previous response:

```shell
❯ nslookup davidzhu.xyz ns1.dnsowl.com
Server:		ns1.dnsowl.com
Address:	162.159.27.173#53

Name:	davidzhu.xyz
Address: 185.199.108.153
```

## 3. `dig`

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
