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

> **Note:** choose full mode, otherwise you may get [ERR_TOO_MANY_REDIRECTS](https://developers.cloudflare.com/ssl/troubleshooting/too-many-redirects/) when access your website on your browser. 

### 2.2. Install TLS certificate

![c](/007-cloudflare-tls-proxy/c.png)

Create `cert.pem` and `cert.key` on your server and copy the corresponding file into these two files. Then you can use them. 

```
client <----tls-1----> cloudflare <----tls-2----> your server
```

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

> After you config this, the DNS needs time to take effect (you change the nameservers of your domain to Cloudfalre from the defatult nameservers, this needs time to take effect) 
>
> If you still cannot have https or always cannot access your website with https and the cloudflare displays your website is active on their server, then you may try if your server listening 443 port and try to clear the DNS cache of your client computer (chrome + system DNS cache). Learn more: [DNS Concepts (NameServer(NS), DNS Records and Caching) - David's Blog](https://davidzhu.xyz/post/networking/002-dns-basics/)
