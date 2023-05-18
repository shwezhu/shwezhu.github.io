---
title: 启动Cloudflare代理导致无法通过域名解析出A记录中的IP
date: 2023-04-26 17:30:22
categories:
 - Bugs
tags:
 - Bugs
---

这几天弄服务器, 用ssh通过域名连接的时候总是出现超时(域名只有一个A记录即服务器IP), 问题下面是分析思路, 

I'm trying to use `ssh` to connect my server with my domain name `ssh root@www.davidzhu.xyz`, but I always get timeout. However I can connect my server when use my server ip directly `ssh root@144.202.12.32`, so I was trying to use `tcpdump` to check what has happened, and I found when I use `ssh root@www.davidzhu.xyz`, there are two different target ip addresses like this:

```shell
16:31:01.116901 IP 192.168.2.15.51247 > 172.67.210.8.22: Flags [S], seq 712140576, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 2121803756 ecr 0,sackOK,eol], length 0
16:31:01.860841 IP 192.168.2.15.51244 > 104.21.50.195.22: Flags [S], seq 3164612131, win 65535, options [mss 1460,nop,wscale 6,nop,nop,TS val 1521852758 ecr 0,sackOK,eol], length 0
```

So I use `dig` to check the ip address of my domain on DNS, the output is:

```shell
dig davidzhu.xyz  +short       
172.67.210.8
104.21.50.195

dig www.davidzhu.xyz  +short
172.67.210.8
104.21.50.195
```

But I only have one A record on my domain, this is the DNS Record of my domain name (the third one is about the google search console):

![](a.png)

惊不惊讶, **`dig`返回的两个IP地址竟然都与我域名的A记录不同**!

And I use cloudflare as my NS, cz I use it for free ssl. My two NS:

```shell
$ dig chin.ns.cloudflare.com +short 
172.64.32.84
173.245.58.84
108.162.192.84

$ dig noel.ns.cloudflare.com +short
108.162.193.216
172.64.33.216
173.245.59.216
```

And I saw [another guy](https://superuser.com/a/1780483/1689666) use `dig` command to check the ip of my domain name `www.davidzhu.xyz`, 

```shell
dig davidzhu.xyz +short
144.202.12.32

dig www.davidzhu.xyz +short
144.202.12.32
```

Is this about DNS cache on my mac? I tried to use something like this `sudo killall -HUP mDNSResponder`, but no help. 

----

在[Stack Exchange](https://stackexchange.com/)上的大佬帮助下, 研究明白了返回两个与我A记录不同IP的原因, 

首先这并不是因为我本地电脑DNS缓存问题, 而是因为我在Cloudflare上启动了代理traffic, 即开启免费SSL证书, 我没证书, 他们有, 所有通过`http://www.davidzhu.xyz`访问我的流量会转发给他们然后变成`https`, 问题描述里的另一个人可以“正常”显示我的IP是因为当时我在Cloudflare的修改(启动Proxy, SSL)还没生效. 

当时猜测是因为我的域名使用了Cloudflare的NS, 因为我想的是NS存储的就是map(我域名和其对应的IP地址), 如果是我域名指定的NS出了问题那就是访问不到我的IP地址或者因为缓存问题多返回了一个错误的IP地址(即我购买域名的时候默认的IP, 虽然我早删掉了), 但其实并不是因缓存问题, 而是我在Cloudflare开启了Proxy, 

然后[大佬](https://superuser.com/a/1781034/1689666)就想到了代理, 之前就是没想到代理也有IP地址, 即代理本质也是把所有请求都转发到另一台服务器(之前搞梯子竟然把这给忘了, 真是可恶). 

> The reason that the domain has two IP addresses is that the domain was put under Cloudflare, and the way Cloudflare works is by proxying all your traffic through them (they have the SSL on their system, so it can't go directly to you.) 

然后我把Cloudflare上的代理关了, 之后就得到了正确的IP地址:

![](b.png)

```shell
$ dig davidzhu.xyz +trace 
...
...
...
davidzhu.xyz.       3600    IN  NS  chin.ns.cloudflare.com.
davidzhu.xyz.       3600    IN  NS  noel.ns.cloudflare.com.
;; Received 581 bytes from 212.18.249.42#53(generationxyz.nic.xyz) in 26 ms

davidzhu.xyz.       300 IN  A   144.202.12.32
;; Received 57 bytes from 173.245.58.84#53(chin.ns.cloudflare.com) in 34 ms
```

所以这也知道了为啥通过域名使用ssh连接服务器总是超时了, 吗的, target ip都不是对的, 怎么可能连接的上
