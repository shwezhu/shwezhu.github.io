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

购买域名后, 肯定要在域名设置页面为自己的域名添加`A`, `CNAME`或其他类型的DNS Records, 这一步就是为了把你购买的域名绑定到指定的ip地址, 

把域名和服务器IP关联就需要为域名添加 `A` 记录, 需要指定 HOSTNAME 和 IP, 其中 `HOSTNAME` 可以填`@`或者`www`, 或者不填, `@`代表空即不填或者填`@`都是一个意思 (还有个概念叫wildcard, 即`*.example.com`) 

![a](/001-domain-name-dns-records/a-8733304.png)

添加 `CNAME记录` 需要指定**HOSTNAME**和**target hostname**, 

![b](/001-domain-name-dns-records/b-8733375.png)

下图是添加 `CNAME` 记录的例子:

![](/001-domain-name-dns-records/a.png)

添加之后, 等大概半小时就会生效, 可以使用 `dig` 命令查看:

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

添加 `A` 记录时, 相同 IP 可以有不同的 `HOSTNAME`:

![c](/001-domain-name-dns-records/c-8734697.png)

一个域名也可以拥有多个 ip 地址不同的 `A` 记录, 如下: 

```shell
HOSTNAME: @, IP: 1.2.3.4
HOSTNAME: www, IP: 6.7.8.5
```

一般我们的域名会自带默认的 DNS Records, 如下图, 

![](/001-domain-name-dns-records/init_dns.png)

所以我们买了域名之后做的第一件事就应该删除这些默认记录(你可以不删用于测试), 不然等你又添加了一个A记录, 这时候你的域名就会被解析到多个IP(默认的和你刚添加的), 那浏览器访问你域名的时候, 选择哪个呢? 我查了一下论坛, 有人说是choose randomly, 所以如果你不删除域名所有的默认DNS Records, 那浏览器访问你域名的时候就有可能选择“错误”的ip, 

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

## 4. 阅读实践

其实我们完整度以下[Github这篇文档](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages)即如何为GitHub pages设置自定义域名, 你就懂了, 学了知识要实践的嘛, 我复制一部分到下面了, 

### 4.1. About custom domains and GitHub Pages

GitHub Pages supports using custom domains, or changing the root of your site's URL from the default, like octocat.github.io, to any domain you own. 

GitHub Pages works with two types of domains: **subdomains** and **apex domains**. For a list of unsupported custom domains, see "[Troubleshooting custom domains and GitHub Pages](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/troubleshooting-custom-domains-and-github-pages#custom-domain-names-that-are-unsupported)."

| Supported custom domain type | Example            |
| :--------------------------- | :----------------- |
| `www` subdomain              | `www.example.com`  |
| Custom subdomain             | `blog.example.com` |
| Apex domain                  | `example.com`      |

You can set up either or both of apex and `www` subdomain configurations for your site. For more information on apex domains, see "[Using an apex domain for your GitHub Pages site](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages#using-an-apex-domain-for-your-github-pages-site)."

We recommend always using a `www` subdomain, even if you also use an apex domain. When you create a new site with an apex domain, we automatically attempt to secure the `www` subdomain for use when serving your site's content, but you need to make the DNS changes to use the `www` subdomain. If you configure a `www` subdomain, we automatically attempt to secure the associated apex domain. For more information, see "[Managing a custom domain for your GitHub Pages site](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)."

After you configure a custom domain for a user or organization site, the custom domain will replace the `<user>.github.io` or `<organization>.github.io` portion of the URL for any project sites owned by the account that do not have a custom domain configured. For example, if the custom domain for your user site is `www.octocat.com`, and you have a project site with no custom domain configured that is published from a repository called `octo-project`, the GitHub Pages site for that repository will be available at `www.octocat.com/octo-project`. For more information about each type of site and handling custom domains, see "[About GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages#types-of-github-pages-sites)."

### 4.2. Using a subdomain for your GitHub Pages site

A subdomain is the part of a URL before the root domain. You can configure your subdomain as `www` or as a distinct section of your site, like `blog.example.com`.

Subdomains are configured with a `CNAME` record through your DNS provider. For more information, see "[Managing a custom domain for your GitHub Pages site](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site#configuring-a-subdomain)."

#### 4.2.1. `www` subdomains

A `www` subdomain is the most commonly used type of subdomain. For example, `www.example.com` includes a `www` subdomain.

`www` subdomains are the most stable type of custom domain because `www` subdomains are not affected by changes to the IP addresses of GitHub's servers.

#### 4.2.2. Custom subdomains

A custom subdomain is a type of subdomain that doesn't use the standard `www` variant. Custom subdomains are mostly used when you want two distinct sections of your site. For example, you can create a site called `blog.example.com` and customize that section independently from `www.example.com`.

https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages

https://docs.github.com/zh/pages/configuring-a-custom-domain-for-your-github-pages-site/troubleshooting-custom-domains-and-github-pages