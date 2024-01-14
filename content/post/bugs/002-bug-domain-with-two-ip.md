---
title: 启动Cloudflare代理导致无法通过域名解析出A记录中的IP
date: 2023-04-26 17:30:22
categories:
 - bugs
tags:
 - bugs
 - build website
typora-root-url: ../../../static
---

### 问题描述:

这几天弄服务器, 用ssh通过域名连接的时候总是出现超时(域名只有一个A记录即服务器IP), 问题下面是分析思路, 

I'm trying to use `ssh` to connect my server with my domain name `ssh root@www.davidzhu.xyz`, but I always get timeout. However I can connect my server when use my server ip directly `ssh root@144.202.12.32`, so I use `dig` to check the ip address of my domain on DNS, the output is:

```shell
dig davidzhu.xyz  +short       
172.67.210.8
104.21.50.195

dig www.davidzhu.xyz  +short
172.67.210.8
104.21.50.195
```

But I only have one A record on my domain, this is the DNS Record of my domain name (the third one is about the google search console):

![](/002-bug-domain-with-two-ip/a.png)

惊不惊讶, **`dig`返回的两个IP地址竟然都与我域名的A记录不同**!

----

### **更新:** 

原因是我的域名开启了 Cloudfalre 的 [reverse proxy](https://developers.cloudflare.com/fundamentals/concepts/how-cloudflare-works/), 通过域名获取到的是 Clouflare 的IP, 无法访问到我服务器真实IP:

> When you add your application to Cloudflare, we use this network to sit in between requests and your origin server. 
>
> Cloudflare does this by serving as a **reverse proxy** for your web traffic. All requests to and from your origin **flow through Cloudflare** and — as these requests pass through our network — we can apply various rules and optimizations to improve security, performance, and reliability.

关闭 Cloudflare 反向代理就可以通过域名获取到服务器真实IP了:

![cc](/002-bug-domain-with-two-ip/cc.png)

另外通过这个机制, 若更换域名的 DNS Record, 就不用在购买域名的服务商那修改了, 只需要在服务商那把你域名的 NS 服务器修改为 Clouflare 的 NS 服务器, 之后修改域名的 DNS Record, 比如你服务器IP换了, 直接到 Cloudflare 这修改一下域名的 A Record 就可以了, 如上图, 

了解更多: [Enable Coudflare Reverse Proxy - David's Blog](https://davidzhu.xyz/post/build-website/008-enable-cloudflare-reverse-proxy/)

---

另外如果使用了 cloudflare https 代理, 一般都是先修改域名的 NS 为 cloudfalre 指定的 NS, 但是有些电脑可能因为 DNS cache 问题, 通过 https 访问你的域名可能会失败, 此时应该尝试修改本地 DNS cache, 

注意, DNS cache 一般 chrome 保存了一份, 操作系统也会保存一份, 因此两个地方都要考虑进去, 

关于DNS: [DNS Concepts (NameServer(NS), DNS Records and Caching) - David's Blog](https://davidzhu.xyz/post/networking/002-dns-basics/)

了解更多: [HTTPS Works on some computers but not others? - Website, Application, Performance / Security - Cloudflare Community](https://community.cloudflare.com/t/https-works-on-some-computers-but-not-others/15922)

---

其实这样有个好处, 就是别人无法通过你的域名接触到你的服务器, 因为每次请求你的域名, 都要经过 Cloudfalre 中转才能到你的服务器, 另外通过nslookup, dig也无法查到你服务器的真实IP, 返回的都是 Cloudflare 的IP. 

> Because of [how Cloudflare works](https://developers.cloudflare.com/fundamentals/concepts/how-cloudflare-works/), all traffic to [proxied DNS records](https://developers.cloudflare.com/dns/manage-dns-records/reference/proxied-dns-records/) pass through Cloudflare before reaching your origin server. This means that your origin server will stop receiving traffic from individual visitor IP addresses and instead receive traffic from [Cloudflare IP addresses](https://www.cloudflare.com/ips), which are shared by all proxied hostnames.
>
> [Cloudflare IPs · Getting started · Learning paths](https://developers.cloudflare.com/learning-paths/get-started/concepts/cloudflare-ips/)
