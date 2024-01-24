---
title: Common Network Attacks
date: 2023-10-30 22:44:57
categories:
 - networking
tags:
 - cybersecurity
 - http
 - networking
typora-root-url: ../../../static
---

### 1. Man-in-the-middle attack

Learn more: 

https://davidzhu.xyz/post/cs-basics/002-ssh/

[HTTPS SSL TLS - David's Blog](https://davidzhu.xyz/post/cs-basics/003-ssl-secure-communication/#4-details-in-tls-handshake---avoid-man-in-middle-attack)

### 2. DDoS attack

Learn more: [DDoS Attack - David's Blog](https://davidzhu.xyz/post/networking/004-ddos-attack/)

### 3. CSRF attack

Learn more: [CSRF Attack and CORS - David's Blog](https://davidzhu.xyz/post/http/007-csrf-attack/)

### 4. SSL stripping 

SSL stripping attacks, also known as SSL strip, SSL downgrade, or HTTP downgrade attacks, strip the encryption offered by HTTPS, reducing the connection to the less-secure HTTP. 

In order to [“strip” the SSL](https://avicoder.me/2016/02/22/SSLstrip-for-newbies/), an attacker intervenes in the redirection of the HTTP to the secure HTTPS protocol and intercepts a request from the user to the server. The attacker will then continue to establish an HTTPS connection between himself and the server, and an unsecured HTTP connection with the user, acting as a “bridge” between them.

<img src="/004-common-attacks/a.png" alt="a" style="zoom:50%;" />

How can the SSL strip trick both the browser and the website’s server? The SSL strip takes advantage of the way most users come to SSL websites. The majority of visitors connect to a website’s page that redirects through a 302 redirect, or they arrive on an SSL page via a link from a non-SSL site. If the victim wants, for instance, to buy a product and types the URL www.buyme.com in the address bar, the browser connects to the attacker's machine and waits for a response from the server. In an SSL strip, the attacker, in turn, forwards the victim’s request to the online shop’s server and receives the secure HTTPS payment page. For example https://www.buyme.com. At this point, the attacker has complete control over the secure payment page. He downgrades it from HTTPS to HTTP and sends it back to the victim’s browser. The browser is now redirected to http://www.buyme.com. From now onward, all the victim’s data will be transferred in plain text format, and the attacker will be able to intercept it. Meanwhile, the website’s server will think that it has successfully established the secure connection, which indeed it has—but with the attacker’s machine, not the victim’s.

#### 4.1. Enable SSL sitewide at all websites

To mitigate this threat, financial institutions and technology firms have [already enabled](https://venafi.com/blog/https-should-be-implemented-everywhereincluding-static-websites/) HTTPS on a site-wide basis. Enabling HTTPS encrypts the connection between a browser and the website, thereby securing sensitive data transmissions. Therefore it makes perfect sense for banks and high-profile technology firms to enable HTTPS on their dynamic websites because of the transaction of important and sensitive information.

#### 4.2. Why enable HSTS?

In addition to enabling HTTPS on a site-wide basis, corporations should weigh the benefits of enabling [HSTS](https://www.globalsign.com/en/blog/what-is-hsts-and-how-do-i-use-it/) (HTTP Strict Transport Security), which is a web security policy mechanism that helps to protect websites against SSL stripping attacks and cookie hijacking. **It allows** **web servers to declare that** web browsers should interact with them using only secure HTTPS connections, and never via the insecure HTTP protocol.

When a web application issues HSTS Policy to user browsers, conformant user browsers will [automatically redirect](https://www.owasp.org/index.php/HTTP_Strict_Transport_Security_Cheat_Sheet) any insecure HTTP requests to HTTPS for the target website. In addition, when a man-in-the-middle attacker attempts to intercept traffic from a victim using an invalid certificate, HSTS does not allow the user to override the invalid certificate warning message. By having a HSTS policy installed, it will be nearly impossible for the attackers to intercept any information at all!

Source: [What Are SSL Stripping Attacks? | Venafi](https://venafi.com/blog/what-are-ssl-stripping-attacks/)

### 5. DNS hijacking

To prevent DNS hijacking, first, you have to know the different kinds of attacks. DNS hijacking can take four different forms:

1. **Local DNS hijacking:** An attacker installs [Trojan software](https://www.fortinet.com/resources/cyberglossary/trojan-horse-virus) on a user's computer, then modifies the local DNS settings (cahnge its DNS server to a Rogue DNS server). 
2. **DNS hijacking using a router:** Many routers have weak firmware or use the default passwords they were shipped with. Attackers can take advantage of this to hack a router and change its DNS settings, which will affect everyone that uses that router.
3. **Man-in-the-middle (MITM) attacks:** Attackers use [man-in-the-middle attack techniques](https://www.fortinet.com/resources/cyberglossary/man-in-the-middle-attack) to intercept communications between users and a [DNS server](https://www.fortinet.com/resources/cyberglossary/dynamic-dns). They then direct the target to malicious websites.

DNS hijacking, DNS poisoning, or DNS redirection is the practice of subverting the resolution of Domain Name System (DNS) queries. This can be achieved by malware that **overrides a computer's TCP/IP configuration** to point at a **rogue DNS server** under the control of an attacker, or through modifying the behaviour of a trusted DNS server so that it does not comply with internet standards. 

>  ...overrides a computer's TCP/IP configuration...point at a **rogue DNS server** 
>
> When a computer connects to a network, **it obtains network settings**, including TCP/IP configuration parameters, **from**  [DHCP servers](https://davidzhu.xyz/post/network/003-dhcp/) or manually configured settings. These TCP/IP configuration parameters include the IP address of the DNS server that the computer should use for DNS resolution. So ***a computer's TCP/IP configuration*** mentioned above, are the informations it gets from a DHCP server, whcih includes its ip address, subnet mask, DNS server, gateway, etc. 

**Malware can modify these TCP/IP configuration settings** on an infected computer to point to a **rogue DNS server** controlled by an attacker. This can be done in a few ways:

1. **Modifying DNS settings**: The malware can directly modify the DNS server IP address in the computer's network settings. By changing the DNS server address to that of a rogue server under the attacker's control, the malware ensures that all DNS queries from the infected computer are sent to the malicious DNS server.
2. **Modifying the hosts file**: The malware can also alter the hosts file, which is a local file on a computer that maps hostnames to IP addresses. By adding entries to the hosts file, the malware can redirect specific domain names to IP addresses controlled by the attacker. This effectively bypasses the DNS resolution process and directs the computer to connect to the attacker's desired IP addresses.

> **Rogue DNS server**: A rogue DNS server translates domain names of desirable websites (search engines, banks, brokers, etc.) into IP addresses of sites with unintended content, even malicious websites. Most users depend on DNS servers automatically assigned by their [ISPs](https://en.wikipedia.org/wiki/ISP). A router's assigned DNS servers can also be altered through the remote exploitation of a vulnerability within the router's firmware.[[2\]](https://en.wikipedia.org/wiki/DNS_hijacking#cite_note-2) When users try to visit websites, they are instead sent to a bogus website. This attack is termed [pharming](https://en.wikipedia.org/wiki/Pharming). If the site they are redirected to is a malicious website, masquerading as a legitimate website, in order to fraudulently obtain sensitive information, it is called [phishing](https://en.wikipedia.org/wiki/Phishing). From [Wikipeida](https://en.wikipedia.org/wiki/DNS_hijacking)

Learn more: [DHCP Basics - David's Blog](https://davidzhu.xyz/post/network/003-dhcp/)

References: 

[DNS hijacking](https://en.wikipedia.org/wiki/DNS_hijacking)

[What Is DNS Hijacking? How to Detect & Prevent It | Fortinet](https://www.fortinet.com/resources/cyberglossary/dns-hijacking)

### 6. DNS spoofing vs DNS (cache) poisoning

- **DNS Poisoning**: 
   - **Definition**: This is a technique where the attacker targets the DNS server itself. The attacker inserts false address records into the DNS server's cache, causing the server to return incorrect IP addresses for domain names. This means anyone using the poisoned DNS server will be redirected to the wrong IP address.
   - **Target**: The attack is on the DNS server.
   - **Example**: If `www.example.com` is supposed to resolve to IP `1.2.3.4`, in a DNS poisoning attack, the DNS server might be tricked into resolving it to `5.6.7.8`.

- **DNS Spoofing**:
   - **Definition**: This involves tricking a client into believing that a response is coming from a legitimate DNS server, when it is actually coming from an attacker. The attacker intercepts and responds to DNS requests with false information, usually before the legitimate response is received.
   - **Example**: When a user tries to access `www.example.com`, an attacker might intercept this request and send a fake response directing the user to IP `5.6.7.8` instead of the real IP `1.2.3.4`.

Learn more: [GFW and DNS Poisoning - David's Blog](https://davidzhu.xyz/post/networking/005-gfw-dns/)

## Others

1. **DNS Poisoning vs DNS Spoofing**:
   - DNS Poisoning: Inject false DNS info to the real server
   - DNS Spoofing: Send false response back with a malicious DNS server

2. **Purpose of MAC Address Spoofing**:
   - To make a switch forward packets to an attacker's device by mimicking a legitimate MAC address.

3. **Use of ICMP Redirects in Man-in-the-Middle Attacks**:
   - An attacker sends forged "ICMP redirect messages" to mislead a host into changing its routing table, diverting traffic through the attacker's machine.

