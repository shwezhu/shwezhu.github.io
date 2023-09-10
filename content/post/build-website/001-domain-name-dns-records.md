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

购买域名后给域名指定的ip地址, 则要为其添加 `A` 类型的 DNS Record,  把域名和服务器IP关联就需要为域名添加 `A` 记录, 需要指定 HOSTNAME 和 IP, 其中 `HOSTNAME` 可以填`@`或者`www`, 或者不填, `@`代表空即不填或者填`@`都是一个意思 (还有个概念叫wildcard, 即`*.example.com`) 

![a](/001-domain-name-dns-records/a-8733304.png)

添加 `CNAME记录` 需要指定 **HOSTNAME**和 **target hostname**, 前者可以不填或者其他`blog`, ` www`  与上面相同, 后者填另一个域名, 比如github 自定义域名, target hostname 则填 ` your-username.github.io` 

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

## 2. www是干什么的

上面我们添加DNS记录的时候有时候(根据自己的需求)需要把hostname的值填为www, 那这个是干嘛的呢, 填与不填? 是不是说, hostname空着不填,我们只能通过`exapmle.com`来访问服务器, 填了之后, 我们就可以通过`www.example.com`来访问服务器. 

然后之前我的域名绑定的是我服务器的ip, url是`http://shaowenzhu.top/`, 看着好奇怪, 不是好多网站都是`www.`开头的吗, 为啥我的是`http://shaowenzhu.top/`,

### 2.1. DNS Hierarchy

先了解一下DNS hierarchy, 你就懂上面的`www`是什么了, 

DNS服务器怎么会知道每个域名的IP地址呢？答案是分级查询, 仔细看下面DNS解析过程，每个域名的尾部都多了一个点`.`

![](/001-domain-name-dns-records/c.png)

多出的那个`.`是Root Level Domain, 比如`www.example.com`真正的名字是`www.example.com.root`然后上图就简写为`www.example.com.` 因为根域名`.root`对于所有域名都是一样的，所以平时是省略的。

**Root Level Domain**(`.root`)的下一级叫**top-level domain**(TLD)，比如`.com`, `.net`

再下一级叫**second-level domain**SLD，比如`www.example.com`里面的`.example`, 有人直接把`example.com`这种叫做SLD

再下一级是**HOSTNAME**，比如`www.example.com`里面的`www`，这是我们可以任意分配的。那具体怎么分配呢? 就是在域名管理页面, 有添加DNS Records选项, 比如你打算添加个A类记录, 这时候要求你填HOSTNAME和IP地址, 这时候HOSTNAME你可以填`www`, `@`, `blog`等等, 然后IP就是你的服务器的IP地址, 可以参考上面的添加A记录和CNAME的图. 

总结一下，域名的层级结构如下:

```
HOSTNAME.SLD.TLD.root
```

![](/001-domain-name-dns-records/d.png)

### 2.2. Subdomain 和 Apex Domain

然后还有个subdomain 和 apex domain, 其实subdomain就是HOSTNAME, 看一下Github上的解释:

> An **apex domain** is a custom domain that does not contain a **subdomain**, such as `example.com`. Apex domains are also known as base, bare, naked, root apex, or zone apex domains. 

## 3. DNS 查询过程

> DNS 中的域名都是用**句点**来分隔的，比如 `www.server.com`，这里的句点代表了不同层次之间的**界限**。在域名中，**越靠右**的位置表示其层级**越高**。毕竟域名是外国人发明，所以思维和中国人相反，比如说一个城市地点的时候，外国喜欢从小到大的方式顺序说起（如 XX 街道 XX 区 XX 市 XX 省），而中国则喜欢从大到小的顺序（如 XX 省 XX 市 XX 区 XX 街道）。根域是在最顶层，它的下一层就是 com 顶级域，再下面是 server.com。

浏览器首先看一下自己的缓存里有没有，如果没有就向操作系统的缓存要，还没有就检查本机域名解析文件 `hosts`，如果还是没有，就会 DNS 服务器进行查询，查询的过程如下：

1. 客户端首先会发出一个 DNS 请求，问 www.server.com 的 IP 是啥，并发给本地 DNS 服务器（也就是客户端的 TCP/IP 设置中填写的 DNS 服务器地址）。
2. 本地域名服务器收到客户端的请求后，如果缓存里的表格能找到 www.server.com，则它直接返回 IP 地址。如果没有，本地 DNS 会去问它的根域名服务器：“老大， 能告诉我 www.server.com 的 IP 地址吗？” 根域名服务器是最高层次的，它不直接用于域名解析，但能指明一条道路。
3. 根 DNS 收到来自本地 DNS 的请求后，发现后置是 .com，说：“www.server.com 这个域名归 .com 区域管理”，我给你 .com 顶级域名服务器地址给你，你去问问它吧。”
4. 本地 DNS 收到顶级域名服务器的地址后，发起请求问“老二， 你能告诉我 www.server.com 的 IP 地址吗？”
5. 顶级域名服务器说：“我给你负责 www.server.com 区域的权威 DNS 服务器的地址，你去问它应该能问到”。
6. 本地 DNS 于是转向问权威 DNS 服务器：“老三，www.server.com对应的IP是啥呀？” server.com 的权威 DNS 服务器，它是域名解析结果的原出处。为啥叫权威呢？就是我的域名我做主。
7. 权威 DNS 服务器查询后将对应的 IP 地址 X.X.X.X 告诉本地 DNS。
8. 本地 DNS 再将 IP 地址返回客户端，客户端和目标建立连接。

至此，我们完成了 DNS 的解析过程。现在总结一下，整个过程我画成了一个图。

![33](/001-domain-name-dns-records/33.webp)

