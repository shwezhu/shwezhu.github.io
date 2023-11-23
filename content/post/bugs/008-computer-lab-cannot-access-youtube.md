---
title: 排查实验室电脑无法访问一些网站
date: 2023-11-22 21:43:22
categories:
 - bugs
tags:
 - bugs
 - networking
typora-root-url: ../../../static
---

首先可以联网, 谷歌和微软邮箱等其他的一些网站都可访问, 但是访问油管的时候总是会超时, 

首先想到了是 DNS 服务器的问题, 尝试把电脑的 DNS server 改为 8.8.8.8, 可惜需要管理员权限, 失败

后来无聊想着看看解析出来youtube.com的实际ip是什么, 使用 nklookup 查了一下, (大概这样, 没在实验室)

```shell
❯ nslookup youtube.com
Server:		192.168.2.1
Address:	192.168.100.1#53

Non-authoritative answer:
Name:	youtube.com
Address: 142.251.40.206
```

于是访问 `142.251.40.206` 

```shell
❯ wget -O- 142.251.40.206
--2023-11-22 22:23:53--  http://142.251.40.206/
Connecting to 142.251.40.206:80... connected.
HTTP request sent, awaiting response... 301 Moved Permanently
Location: http://www.google.com/ [following]
--2023-11-22 22:23:53--  http://www.google.com/
Resolving www.google.com (www.google.com)... 142.250.80.36
```

可以看到被重定向到了谷歌页面, 当时在实验室也是这种情况, 查了一下, 这确实是正确的地址, 只是[谷歌给重定向](https://stackoverflow.com/questions/5142030/why-does-the-resolved-ip-of-youtube-com-direct-to-google-com)了, 所以不是DNS的问题, 那应该就是防火墙的问题, 下次去实验室再看看, 

另外上面 nskookup 返回的是 [Non-authoritative answer](https://davidzhu.xyz/post/networking/006-commands-in-network/), 意思是 ip 地址不是由该域名的 NS 服务器返回的, 而是从 DNS cache获取的, 所以 Non-authoritative answer 并不是代表不安全或者不可靠, 但可能不是最新的, 比如你的域名刚更新了 NS server, 加了层 Cloudflare 的 https 加密代理, 即 `your_domain->proxy-ip->your_ip`, 而学校的 DNS cache 里缓存的却是你之前的 ip, 即 `your_domain -> your_ip`, 那代理就不会生效, 

