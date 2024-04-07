---
title: 域名分级和DNS记录之何为www
date: 2023-04-23 00:15:30
categories:
 - build website
tags:
 - build website
typora-root-url: ../../../static
---

## 1. DNS Records: A & CNAME

购买域名后给域名指定的ip地址则要为其添加 `A` 类型的 DNS Record, 需要指定 HOSTNAME 和 IP, 其中 `HOSTNAME` 可以填`@`或者`www`或`blog`等自定义, `@`代表空即不填或者填`@`都是一个意思 (还有个概念叫wildcard, 即`*.example.com`) 

![a](/001-domain-name-dns-records/a-8733304.png)

添加 `CNAME记录` 需要指定 **HOSTNAME** 和 **target hostname**, 前者与上面相同, 后者填另一个域名, 比如 `your-username.github.io` 

![b](/001-domain-name-dns-records/b-8733375.png)

大概半小时会生效, 可以使用 `dig` 命令查看:

```shell
$ dig www.shaowenzhu.top +nostats +nocomments +nocmd
; <<>> DiG 9.10.6 <<>> www.shaowenzhu.top +nostats +nocomments +nocmd
;; global options: +cmd
;www.shaowenzhu.top.		IN	A
www.shaowenzhu.top.	7207	IN	CNAME	shwezhu.github.io.
shwezhu.github.io.	1937	IN	A	185.199.108.153
shwezhu.github.io.	1937	IN	A	185.199.109.153
shwezhu.github.io.	1937	IN	A	185.199.110.153
shwezhu.github.io.	1937	IN	A	185.199.111.153
```

添加 `A` 记录时, 相同 IP 可以有不同的 `HOSTNAME`, 即一个为空一个为 `www`:

![c](/001-domain-name-dns-records/c-8734697.png)

一般域名自带默认的 DNS Records:

![](/001-domain-name-dns-records/init_dns.png)

所以买了域名之后做的第一件事就应该删除这些默认记录, 不然等你又添加了一个A记录, 这时候你的域名就会被解析到多个IP(默认的和你刚添加的), 那浏览器访问你域名的时候, 选择哪个呢? 我查了一下论坛, 有人说是choose randomly, 所以如果你不删除域名所有的默认DNS Records, 那浏览器访问你域名的时候就有可能选择“错误”的ip, 

下面是回答个链接, 这个其实自己为域名添加俩不同的A记录用`dig`测试一下就行了, 但是我懒, 还得等半小时生效, 所以就不去验证了~

> Yes you can. It is called round-robin DNS, and the browser just chooses one of them randomly. It is a well used method of getting cheap load balancing, but if one host goes down, users will still try to access it. https://serverfault.com/q/528742/761923

一般我们想把域名绑定到服务器的时候, 为我们的域名添加两个A类DNS Records就行了, 不用改什么Name Server, 类似下面这个样子(注意TTL一般设置为3600s就可以啦):

![](/001-domain-name-dns-records/domain_to_server.png)

## 2. www 就是个 HOSTNAME

在上面截图中可以看出, 域名和ip就是一个映射关系, 添加 A Record 时若 HOSTNAME 空着则就是 `exapmle.com` -> ip address, 若填则为 `www.example.com`/`blog.example.com` -> ip address. 也就是说 `www` 就是个 HOSTNAME, 是用户随意分配的, 只是大部分网站使用 `www` 你也可以填成 `blog`, 

## 3. DNS Hierarchy

DNS服务器怎么会知道每个域名的IP地址呢？答案是分级查询, 仔细看下面DNS解析过程，每个域名的尾部都多了一个点`.`

![](/001-domain-name-dns-records/c.png)

多出的那个`.`是Root Level Domain, 比如`www.example.com`真正的名字是`www.example.com.root`然后上图就简写为`www.example.com.` 因为根域名`.root`对于所有域名都是一样的，所以平时是省略的。

- **Root Level Domain**(`.root`)的下一级叫**top-level domain**(TLD)，比如`.com`, `.net`

- 再下一级叫**second-level domain**SLD，比如`www.example.com`里面的`.example`, 有人直接把`example.com`这种叫做SLD

- 再下一级是**HOSTNAME**，比如`www.example.com`里面的`www`, 这是可以任意设置的, 你也可以让域名的 HOSTNAME 为 `blog`, 

域名的层级结构:

```
HOSTNAME.SLD.TLD.root
```

<img src="/001-domain-name-dns-records/d.png" style="zoom:33%;" />

## HOSTNAME vs SLD

HOSTNAME 和二级域名(SLD)是不一样的, 二级域名是指`example.com`里面的`example`, 而HOSTNAME是指`www.example.com`里面的`www`. 

HOSTNAME 的作用是为了区分同一个域名下的不同服务, 比如`www.example.com`和`blog.example.com`是同一个域名下的不同服务, 现在都是采用微服务分布式架构, 即每个服务通常不在一个主机, 这样用户访问`www.example.com`和`blog.example.com`时就会访问到不同的服务器, 从而提供不同的服务. 如下图可以看出一个 HOSTNAME 可以对应一个 IP:

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/001-domain-name-dns-records%2F01.jpg)