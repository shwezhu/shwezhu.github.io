---
title: Common Network Attacks
date: 2023-10-30 22:44:57
categories:
 - networking
tags:
 - cybersecurity
 - http
 - networking
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
DNS hijacking, DNS poisoning, or DNS redirection is the practice of subverting the resolution of Domain Name System (DNS) queries. This can be achieved by malware that **overrides a computer's TCP/IP configuration** to point at a **rogue DNS server** under the control of an attacker, or through modifying the behaviour of a trusted DNS server so that it does not comply with internet standards.

These modifications may be made for malicious purposes such as phishing, for self-serving purposes by Internet service providers (ISPs), by the Great Firewall of China and public/router-based online DNS server providers to direct users' web traffic to the ISP's own web servers where advertisements can be served, statistics collected, or other purposes of the ISP; and by DNS service providers to block access to selected domains as a form of censorship.

>  ...overrides a computer's TCP/IP configuration...point at a **rogue DNS server** 
>
> When a computer connects to a network, **it obtains network settings**, including TCP/IP configuration parameters, **from**  [DHCP servers](https://davidzhu.xyz/post/network/003-dhcp/) or manually configured settings. These TCP/IP configuration parameters include the IP address of the DNS server that the computer should use for DNS resolution. So ***a computer's TCP/IP configuration*** mentioned above, are the informations it gets from a DHCP server, whcih includes its ip address, subnet mask, DNS server, gateway, etc. 

**Malware can modify these TCP/IP configuration settings** on an infected computer to point to a **rogue DNS server** controlled by an attacker. This can be done in a few ways:

1. **Modifying DNS settings**: The malware can directly modify the DNS server IP address in the computer's network settings. By changing the DNS server address to that of a rogue server under the attacker's control, the malware ensures that all DNS queries from the infected computer are sent to the malicious DNS server.
2. **Modifying the hosts file**: The malware can also alter the hosts file, which is a local file on a computer that maps hostnames to IP addresses. By adding entries to the hosts file, the malware can redirect specific domain names to IP addresses controlled by the attacker. This effectively bypasses the DNS resolution process and directs the computer to connect to the attacker's desired IP addresses.

> **Rogue DNS server**: A rogue DNS server translates domain names of desirable websites (search engines, banks, brokers, etc.) into IP addresses of sites with unintended content, even malicious websites. Most users depend on DNS servers automatically assigned by their [ISPs](https://en.wikipedia.org/wiki/ISP). A router's assigned DNS servers can also be altered through the remote exploitation of a vulnerability within the router's firmware.[[2\]](https://en.wikipedia.org/wiki/DNS_hijacking#cite_note-2) When users try to visit websites, they are instead sent to a bogus website. This attack is termed [pharming](https://en.wikipedia.org/wiki/Pharming). If the site they are redirected to is a malicious website, masquerading as a legitimate website, in order to fraudulently obtain sensitive information, it is called [phishing](https://en.wikipedia.org/wiki/Phishing). From [Wikipeida](https://en.wikipedia.org/wiki/DNS_hijacking)

Learn more: [DHCP Basics - David's Blog](https://davidzhu.xyz/post/network/003-dhcp/)

Reference: [DNS hijacking](https://en.wikipedia.org/wiki/DNS_hijacking)

### 6. DNS cache poisoning























