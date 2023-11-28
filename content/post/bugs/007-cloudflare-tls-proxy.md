---
title: Coudflare TLS encryption 520 Error Code & too Many Redirections
date: 2023-11-15 20:09:22
categories:
 - bugs
tags:
 - bugs
 - docker
 - golang
typora-root-url: ../../../static
---

## 1. Enable end-to-end encryption with Cloudflare

Getting a official TLS certificate is too expensive, so I decide to use Cloudflare TLS proxy to enable TLS connection between the client and my server. 

There are two steps to enable end-to-end encryption with Cloudflare.:

- Add your domain to Cloudflare
- Create and install TLS certificate to your server

### 1.1. Add your domain to Cloudflare

Go to this website: https://dash.cloudflare.com/

![aa](/007-cloudflare-tls-proxy/aa.png)

And you will get instructions for updating your nameserver of your domain. After change your nameserver, waite about one hour, your site will be **active** on Cloudflare. Then you can choose the TLS encryption mode:

![b](/007-cloudflare-tls-proxy/b.png)

> **Note:** choose `full mode`, don't use `flexbile mode`, otherwise you **probably would** get [ERR_TOO_MANY_REDIRECTS](https://developers.cloudflare.com/ssl/troubleshooting/too-many-redirects/) when access your website. 

### 2.2. Install TLS certificate

![c](/007-cloudflare-tls-proxy/c.png)

Create `cert.pem` and `cert.key` on your server and copy the corresponding file into these two files. Then you can use them. 

```
client <----tls-1----> cloudflare <----tls-2----> your server
```

> So you cannot login your server with `ssh user@your_domain` any more.

The generated two files `cert.pem` and `cert.key` is used for encryption between your server and Cloudflare. 

You can use these two file like this:

```go
... 
func main() {
    http.HandleFunc("/hello", HelloServer)
    err := http.ListenAndServeTLS(":443", "./conf/cert.pem", "./conf/cert.key", nil)
    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }
}
```

> **Note**: don't add the keep-alive header when handle request on your server, otherwise you may get a 520 error when you access your website on browser: `Error 520: Web server is returning an unknown error` 
>
> ```go
> w.Header().Set("Connection", "Keep-Alive")
> w.Header().Set("Keep-Alive", "timeout=2, max=1000")
> ```

Learn more: https://luyuhuang.tech/2020/06/03/cloudflare-free-https.html

> After config this, the DNS needs time to take effect (you change the nameservers of your domain to Cloudfalre from the defatult nameservers, this needs time to take effect) 
>
> If there still no HTTPS connection but the cloudflare displays your website **is active** on their service, you may try to check if your server is listening on 443 port and try to flush the DNS cache of your client computer (chrome + system DNS cache). Learn more: [DNS Concepts (NameServer(NS), DNS Records and Caching) - David's Blog](https://davidzhu.xyz/post/networking/002-dns-basics/)

BTW, you can check if your domain is proxied by the Cloudflare with nslookup command, which will get the `A Record` by default (IPv4) address of your domain, but in this case, with Cloudfalre proxy, you should get the ip of Cloudfalre Name Server. 

```shell
❯ nslookup shaowenzhu.top
Non-authoritative answer:
Name:	shaowenzhu.top
Address: 172.67.171.207 # not my domain's real ip, it's Cloudfalre
Name:	shaowenzhu.top
Address: 104.21.47.185 # not my domain's real ip, it's Cloudfalre

❯ nslookup -type=soa davidzhu.xyz
Authoritative answers can be found from:
davidzhu.xyz	nameserver = ns1.dnsowl.com.
davidzhu.xyz	nameserver = ns2.dnsowl.com.
davidzhu.xyz	nameserver = ns3.dnsowl.com.

# your domain's real ip
❯ nslookup davidzhu.xyz ns1.dnsowl.com
Name:	davidzhu.xyz
Address: 185.199.108.153
```

