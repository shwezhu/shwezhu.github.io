---
title: Is HTTPS Secure Enough?
date: 2023-09-10 09:27:59
categories:
 - cs basics
tags:
 - cs basics
 - cryptography
 - http
 - cybersecurity
---

## 1. Is HTTPS Secure Enough?

Does an established HTTPS connection mean the line is really secure?

It's important to understand what SSL does and does not do, especially since this is a very common source of misunderstanding.

- It encrypts the channel
- It applies integrity checking
- It provides authentication

So, the quick answer should be: "yes, it is secure enough to transmit sensitive data". However, things are not that simple. There are a few issues here, **the major one being authentication**. Both ends need to be sure they are talking to the right person or institution and no man-in-the-middle attacks. 

## 2. What's the process of establishing a HTTPS connection?

I have talked man-in-middle attack in other [post](https://davidzhu.xyz/post/cs-basics/002-ssh/), when a ssh connection is being established at the first time, it will notify us the fingerprint of the server which enables us can go to the our server to check it's fingerprint so that we can make sure to we are connecting the right server. But it's a little diffenent in HTTPS:

When we click a link on our browser which will send a http requet, but before making a http request there are other things have been done under the hood (I have talked this in other [post](https://davidzhu.xyz/post/cs-basics/003-ssl-secure-communication/)):

- A tcp connection established (envolves three way handshake). 
- Make a [TLS handshake](https://www.cloudflare.com/learning/ssl/what-happens-in-a-tls-handshake/). 
- After TLS handshake,  the secure communication begins (client makes http request, server makes response). 

During the TLS handshake process, there is authenciation:

The client verifies the server's SSL certificate with the certificate authority that issued it. This confirms that the server is who it says it is, and that the client is interacting with the actual owner of the domain. 

## 3. Issues in HTTPS

SSL is only as secure as the DNS infrastructure that directed clitens to that server, and any corporate proxies in the communication path. If the DNS infrastructure is hacked (cache poisoning, etc) then the attacker could subject clients to many attacks. 

As a last note it should be mentioned that during the [SSL handshake](https://www.cloudflare.com/learning/ssl/what-happens-in-a-tls-handshake/) client and server agree on a [Cipher suite](http://en.wikipedia.org/wiki/Cipher_suite) and the client could pretend to only do "null encryption", i.e., not encrypt any of the data. If your server agrees to that option, the connection uses SSL, but data is still not encrypted. This is not an issue in practice since server implementations usually do not offer the null cipher as an option. 

## 4. Conclusion

HTTPS is secure in encryption. HTTPS is secure itself but if we can totally trust HTTPS connection when exhcange privacy data is another thing. Although no one can decrept the data without the session key, there probably have man-in-the-middle attck. If you can make sure the client is really that people you want talk as a server or you can make sure the server is the correct server you want to get, then https is safe. 

And can you make sure the server itself is a bad company? Which will sell your personal data to other perople. But this is another topic, haha, 

In the last I'll share a [answer](https://stackoverflow.com/a/5310027/16317008) here which is very comprehensive:

**Question:** Consider a scenario, where user authentication (username and password) is entered by the user in the page's form element, which is then submitted. The POST data is sent via HTTPS to a new page (where the php code will check for the credentials). If a hacker sits in the network, and say has access to all the traffic, is the Application layer security (HTTPS) enough in this case ?

**[Answer 1](https://stackoverflow.com/a/5310032/16317008):** Yes. In an HTTPS only the handshake is done unencrypted, but even the HTTP GET/POST query's are done encrypted.

It is however impossible to hide to what server you are connecting, since he can see your packets he can see the IP address to where your packets go. If you want to hide this too you can use a proxy (though the hacker would know that you are sending to a proxy, but not where your packets go afterwards).

**[Answer 2](https://stackoverflow.com/a/5310288/16317008):** HTTPS is sufficient "if" the client is secure. Otherwise someone can install a custom certificate and play man-in-the-middle. 

References:

- [Does an established HTTPS connection mean a line is really secure? - Information Security Stack Exchange](https://security.stackexchange.com/questions/5/does-an-established-https-connection-mean-a-line-is-really-secure)
- [php - POST data encryption - Is HTTPS enough? - Stack Overflow](https://stackoverflow.com/questions/5309997/post-data-encryption-is-https-enough)

