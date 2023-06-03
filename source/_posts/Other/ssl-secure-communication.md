---
title: Openssl和安全通信
date: 2023-06-03 11:51:26
categories:
  - Others
tags:
  - Python
  - Practice
  - Cryptography
  - Build Website
---

最近使用python的 `urllib3` 发送http请求, 看到了一些基础概念, 想着还是记录一下, 

### 1. HTTP vs HTTPS

先看看这两个啥区别:

> [HTTPS](https://www.cloudflare.com/learning/ssl/what-is-https/) is [HTTP](https://www.cloudflare.com/learning/ddos/glossary/hypertext-transfer-protocol-http/) with [encryption](https://www.cloudflare.com/learning/ssl/what-is-encryption/) and verification. The only difference between the two protocols is that HTTPS uses [TLS](https://www.cloudflare.com/learning/ssl/transport-layer-security-tls/) ([SSL](https://www.cloudflare.com/learning/ssl/what-is-ssl/)) to encrypt normal HTTP requests and responses, and to digitally sign those requests and responses. As a result, HTTPS is far more secure than HTTP. A website that uses HTTP has `http://` in its URL, while a website that uses HTTPS has `https://`.

另外: HTTP commonly uses standard port 80, while HTTPS uses port 443.

### 2. TLS vs SSL

上面提到了HTTPS使用TLS和SSL进行加密以及数字签名认证, 那先看看这俩是啥:

> TLS evolved from a previous encryption protocol called Secure Sockets Layer ([SSL](https://www.cloudflare.com/learning/ssl/what-is-ssl/)), which was developed by Netscape. TLS version 1.0 actually began development as SSL version 3.1, but the name of the protocol was changed before publication in order to indicate that it was no longer associated with Netscape. Because of this history, the terms TLS and SSL are sometimes used interchangeably.

所以可以认为TLS就是一个新的SSL, 只是改了个名字, 

HTTPS, HTTP, TLS 都是协议, 只不过 HTTPS 利用了 TLS 协议提供的加密数据和数字认证功能, 至于加密又分为两种:

- symmetric cryptography
- asymmetric cryptography 又叫 public key cryptography

我们使用 SSH 生成公私钥的时候会有看到 RSA 的身影, RSA 就是个非对称加密的算法, 用来产生公私钥的算法, 除了 RSA, 还有其它非对称加密算法, 如 Diffie-Hellman, ECC (Elliptic Curve Cryptography), 

参考:

- [Why is HTTP not secure? | HTTP vs. HTTPS | Cloudflare](https://www.cloudflare.com/learning/ssl/why-is-http-not-secure/)
- [Difference Between SSL & TLS | Baeldung on Computer Science](https://www.baeldung.com/cs/ssl-vs-tls)
- [What is Transport Layer Security (TLS)? | Cloudflare](https://www.cloudflare.com/learning/ssl/transport-layer-security-tls/)