---
title: Common Attacks
date: 2023-10-30 22:44:57
categories:
 - network
tags:
 - cybersecurity
 - http
 - network
---

### 1. Man-in-the-middle attack

Learn more: 

https://davidzhu.xyz/post/cs-basics/002-ssh/

[HTTPS SSL TLS - David's Blog](https://davidzhu.xyz/post/cs-basics/003-ssl-secure-communication/#4-details-in-tls-handshake---avoid-man-in-middle-attack)

### 2. DDoS attack

Learn more: [DDoS Attack - David's Blog](https://davidzhu.xyz/post/cs-basics/012-ddos-attack/)

### 3. CSRF attack

Learn more: [CSRF Attack and CORS - David's Blog](https://davidzhu.xyz/post/http/007-csrf-attack/)

### 4. SSL stripping 

SSL stripping attacks, also known as SSL strip, SSL downgrade, or HTTP downgrade attacks, strip the encryption offered by HTTPS, reducing the connection to the less-secure HTTP. 

### 5. DNS poisoning 
DNS hijacking, DNS poisoning, or DNS redirection is the practice of subverting the resolution of Domain Name System (DNS) queries. This can be achieved by malware that **overrides a computer's TCP/IP configuration** to point at a rogue DNS server under the control of an attacker, or through modifying the behaviour of a trusted DNS server so that it does not comply with internet standards.

These modifications may be made for malicious purposes such as [phishing](https://en.wikipedia.org/wiki/Phishing), for self-serving purposes by [Internet service providers](https://en.wikipedia.org/wiki/Internet_service_providers) (ISPs), by the [Great Firewall of China](https://en.wikipedia.org/wiki/Great_firewall_of_China) and public/router-based online [DNS server providers](https://en.wikipedia.org/wiki/Name_server) to direct users' web traffic to the ISP's own [web servers](https://en.wikipedia.org/wiki/Web_server) where advertisements can be served, statistics collected, or other purposes of the ISP; and by DNS service providers to block access to selected domains as a form of [censorship](https://en.wikipedia.org/wiki/Internet_censorship#Technical_censorship).

[DNS hijacking](https://en.wikipedia.org/wiki/DNS_hijacking)

> Confusing thing: ...overrides a computer's TCP/IP configuration...
>
> When a computer connects to a network, it obtains network settings, including TCP/IP configuration parameters, from various sources such as DHCP (Dynamic Host Configuration Protocol) servers or manually configured settings. These TCP/IP configuration parameters include the IP address of the DNS server that the computer should use for DNS resolution. 
>
> Learn more: 