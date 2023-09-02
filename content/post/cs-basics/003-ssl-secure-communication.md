---
title: HTTPS 连接过程分析以及 SSL 证书和 OpenSSL 介绍
date: 2023-06-03 20:32:26
categories:
  - CS Basics
tags:
  - Python
  - Cryptography
  - Build Website
---

最近使用python的 `urllib3` 发送http请求, 看到了一些基础概念, 想着还是记录一下, 

## 1. HTTP vs HTTPS

HTTPS 并不是个新的协议, 它就是使用了 SSL/TLS 的 HTTP 协议: 

> Strictly speaking, HTTPS is not a separate protocol, but refers to use of ordinary HTTP over an encrypted SSL/TLS connection. [Wiki](https://en.wikipedia.org/wiki/HTTPS#Network_layers) 

 A website that uses HTTP has `http://` in its URL, while a website that uses HTTPS has `https://`. HTTP commonly uses standard port 80, while HTTPS uses port 443. 

## 2. TLS vs SSL

> SSL, more commonly called TLS, is a protocol for **encrypting Internet traffic and verifying server identity**. 
>
> TLS evolved from a previous encryption protocol called Secure Sockets Layer ([SSL](https://www.cloudflare.com/learning/ssl/what-is-ssl/)), which was developed by Netscape. TLS version 1.0 actually began development as SSL version 3.1, but the name of the protocol was changed before publication in order to indicate that it was no longer associated with Netscape. Because of this history, the terms TLS and SSL are sometimes used interchangeably. 

HTTPS, HTTP, TLS 都是协议,  HTTPS 利用了 SSL 提供的加密数据和数字认证功能, 而 SSL 利用 RSA 非对称算法生成公私钥实现加密, 加密又分为两种:

- symmetric cryptography
- asymmetric cryptography 又叫 public key cryptography

使用 SSH 生成公私钥的时候会有看到 RSA 的身影, RSA 就是个非对称加密的算法, 用来产生公私钥, 除了 RSA, 还有其它非对称加密算法, 如 Diffie-Hellman, ECC (Elliptic Curve Cryptography), 感兴趣可参考: [通过 SSH 实现免密登陆以及分析 SSH 如何验证真实性](https://davidzhu.xyz/2023/06/03/CS-Basics/002-ssh/)

## 3. HTTPS 建立链接的过程

HTTPS 利用 SSL 实现加密传输以及让客户端验证服务器的身份与[SSH 中间人攻击](https://davidzhu.xyz/2023/06/03/CS-Basics/002-ssh/)问题相似, 但却不能用那种办法来解决, 因为在电脑上存储每个网站的公钥或者每点一个链接🔗就人工比对公钥指纹很不现实, 而且公钥指纹在人家服务器上, 你也没办法比对... 

SSL 证书是需要放到服务器上的, 当客户端向服务器发送 HTTPS 请求时, 服务器会把自己的 SSL 证书传给客户端, 

有两个问题:

- 服务器(网站)怎么获得 SSL 证书, 
- 发送 HTTPS 请求后, 客户端拿到该服务器的 SSL 证书后, 如何验证该证书真伪: [浏览器如何验证HTTPS证书的合法性](https://www.zhihu.com/question/37370216)

### 3.1. What is SSL Certificates

SSL certificates include the following information in a single data file:

- The domain name that the certificate was issued for
- Associated subdomains
- Which person, organization, or device it was issued to
- The certificate authority's digital signature
- The public key (the private key is kept secret)

刚开始我的想法是客户端给服务器发送数据如密码等信息, 可以使用服务器的公钥进行加密 (服务器会把自己的 SSL 证书发给客户端, 而 SSL 证书就是个文件, 里面包含了服务器的公钥信息), 那服务器怎么发送加密数据, 然后客户端怎么解密的? 

其实我只猜对了一半, HTPPS 采用的是混合加密, 即从建立 HTTPS 连接到相互传递数据存在两个Key, 服务器的公钥和客户端服务器两者共享的密钥, 该密钥是对称加密里的密钥, 什么意思呢, 就是客户端不是拿到了服务器的 SSL 证书吗? 这个证书里包含了服务器的公钥, 这时候呢, 客户端生成一个密钥 (对称加密里的密钥, 不是公私钥里的私钥) 然后客户端用服务器的公钥加密这个密钥传给服务器, 服务器用它自己的私钥解密, 之后的他们就都使用这同一个密钥进行加密解密, 具体如下图:

![a](/003-ssl-secure-communication/a-5839840.png)

这里又有个问题, HTTPS 是 stateful 还是 stateless 的呢? 我们知道 http 是stateless的, 在文章第一节我们就提到 https 并不是什么新的协议, 就是 http 利用了 SSL 协议, 而 SSL 是 stateful 的, 所以在上图中的会话即session里, 客户端和服务器并不是只传递一次信息回话就结束了, 而是可传递多次,  

> **TLS/SSL is stateful.** The web server and the client (browser) cache the session including the cryptographic keys to improve performance and do **not** perform key exchange for every request. [Source](https://stackoverflow.com/a/33681674/16317008)

> 服务器会为每个浏览器（或客户端软件）维护一个session ID，在TLS握手阶段传给浏览器，浏览器生成好密钥传给服务器后，服务器会把该密钥存到相应的session ID下，之后浏览器每次请求都会携带session ID，服务器会根据session ID找到相应的密钥并进行解密加密操作，这样就不必要每次重新制作、传输密钥了！[Source](https://zhuanlan.zhihu.com/p/43789231)

## 4. 获取 SSL Certificate 的两种方式

现在来回答上面提出的两个问题, 好像扯的很远了 ummm, 篇幅有限我已经在第二个问题上附上了连接, 就说说第一个问题吧, 获取 SSL Certificate 的方式有两种, 一是从CA那里获得, 二是利用 OpenSSL 自己生成, 

我们先来看第一种, 从 CA 获得 SSL Certificate: 

For an SSL certificate to be valid, domains need to obtain it from a certificate authority (CA). A CA is an outside organization, a trusted third party, that generates and gives out SSL certificates. **The CA will also digitally sign the certificate with their own private key**, allowing client devices to verify it. Once the certificate is issued, it needs to be installed and activated on the website's origin server. 

再来看看第二种, 自己生成:

Technically, anyone can create their own SSL certificate by generating a public-private key pairing and including all the information mentioned above . Such certificates are called self-signed certificates because the digital signature used, instead of being from a CA, would be the website's own private key.

But with self-signed certificates, there's no outside authority to verify that the origin server is who it claims to be. **Browsers don't consider self-signed certificates trustworthy** and may still mark sites with one as "not secure," despite the `https://` URL. They may also terminate the connection altogether, blocking the website from loading.

## 5. OpenSSL vs LibreSSL

> OpenSSL is an all-around cryptography library that offers an open-source application of the TLS protocol. It allows users to perform various SSL-related tasks, including CSR (Certificate Signing Request) and private keys generation, and SSL certificate installation. You can use OpenSSL's commands to generate, install and manage SSL certificates on various servers.  [What Is OpenSSL and How Does It Work?](https://www.ssldragon.com/blog/what-is-openssl/) 

上面说 OpenSSL 是个库, 那应该有 API 接口吧, 但更常见的 OpenSSL 是作为命令行工具, 在电脑上输入:

在我电脑上输入:

```shell
$ openssl version   
LibreSSL 3.3.6
```

不仅好奇, 怎么多出来个 LibreSSL,  这是什么? LibreSSL 就是实现 SSL 的另一个版本, 和 OpenSSL 并列, 请参考: [Why You Should Use LibreSSL Instead of OpenSSL](https://www.youtube.com/watch?v=n1uaoJyBwHk) 

上面说 OpenSSL 是个库, HTTPS 的基础是 SSL, 用SSL建立安全连接的时候需要 SSL 握手等验证身份的操作, 比如我们写个程序发送 http 请求给服务器, 然后那个服务器使用的是 https 安全协议, 那此时像握手, 验证数字签名这些操作, 自己写显然不太行, OpenSSL 就是干这些事的, 有人说之前我发送 http 请求也没用 openssl 啊, 那是因为你使用的 http 协议 不是 https 你看看你的目的端口是不是80, 或者你使用的发送http的库在底层调用了 openssl 库, 帮你实现了那些繁杂的操作, 比如我最近用的 openai 发送 https 请求的包, 就是底层调用了 OpenSSL, 但我们只看这些代码是看不出来的, 

```python
import openai

openai.api_key = "Your Key"

response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[
        {"role": "user", "content": "Who won the 2018 FIFA world cup?"}
    ]
)

print(response['choices'][0]['message']['content'])
```

然后报错的时候, 我才发现SSL的存在, 

```shell
ImportError: urllib3 v2.0 only supports OpenSSL 1.1.1+, currently the 'ssl' module is compiled with LibreSSL 2.8.3. See: https://github.com/urllib3/urllib3/issues/2168
```

实际上面代码即openai利用了python的package, urllib3, 而 urllib3 就是用来发 http 请求的, urllib3 用到了python的内置库叫ssl, ssl里调用了openssl相关的接口, 进行创建会话, 验证证书等操作, 

However, from your Python code's perspective, you're just using the ssl module's high-level API. You don't have to interact directly with OpenSSL - it's an implementation detail hidden by the SSLContext and socket wrapping methods. So in short, the Python SSL library uses the OpenSSL library under the hood to actually perform SSL handshakes, key generation, encryption, etc. But from a Python programmer's point of view, you just import ssl and call its APIs to establish encrypted SSL connections.

![b](/003-ssl-secure-communication/b.png)

所以呢上面这个错误是在说, urllib3 2.0 仅支持 OpenSSL 1.1.1+, 但是电脑上的 ssl 库使用的是 LibreSSL 2.8.3., (别忘了上面我们输入`openssl version` 的时候输出的是LibreSSL), 在这 OpenSSL 和 LibreSSL等价, 既然 urllib3的2.0版本不支持我们电脑上的LibreSSL, 那我们就换个 urllib3 的版本咯, 

```shell
pip3 uninstall urllib3 
pip3 install 'urllib3<2.0' 
```

或者换我们电脑上的 LibreSSL 的版本, 

```python
$ brew install openssl@1.1
```

参考:

- [Why is HTTP not secure? | HTTP vs. HTTPS | Cloudflare](https://www.cloudflare.com/learning/ssl/why-is-http-not-secure/)
- [Difference Between SSL & TLS | Baeldung on Computer Science](https://www.baeldung.com/cs/ssl-vs-tls)
- [What is Transport Layer Security (TLS)? | Cloudflare](https://www.cloudflare.com/learning/ssl/transport-layer-security-tls/)
- [What is an SSL certificate? | Cloudflare](https://www.cloudflare.com/learning/ssl/what-is-an-ssl-certificate/)
- [Is HTTPS Stateful or Stateless? - Stack Overflow](https://stackoverflow.com/questions/11067500/is-https-stateful-or-stateless)
- [HTTPS 是如何进行加密的 - heptaluan's blog](https://heptaluan.github.io/2020/08/09/HTTP/09/)
- [彻底搞懂HTTPS的加密原理 - 知乎](https://zhuanlan.zhihu.com/p/43789231)
- [Why You Should Use LibreSSL Instead of OpenSSL](https://www.youtube.com/watch?v=n1uaoJyBwHk)
- https://youtu.be/wzbf9ldvBjM
- [Fixing ImportError: urllib3 v2.0 only supports OpenSSL 1.1.1+ | Level Up Coding](https://levelup.gitconnected.com/fixing-importerror-urllib3-v2-0-5fbfe8576957)