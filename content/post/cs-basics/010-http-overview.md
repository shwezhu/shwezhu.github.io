---
title: An overview of HTTP
date: 2023-08-28 16:03:59
categories:
 - cs basics
tags:
 - cs basics
---

## Process of HTTP Connection Establishment

How a browser uses HTTP to display a simple HTML resource that resides on a distant server:

- The browser extracts the server’s hostname from the URL.
- The browser converts the server’s hostname into the server’s IP address.
- The browser extracts the port number (if any) from the URL.
- The browser establishes a TCP connection with the web server.
- The browser sends an HTTP request message to the server.
- The server sends an HTTP response back to the browser.
- The connection is closed, and the browser displays the document.

## HTTP is stateless, but not sessionless

HTTP is stateless: there is no link between two requests being successively carried out on the same connection. This immediately has the prospect of being problematic for users attempting to interact with certain pages coherently, for example, using e-commerce shopping baskets. But while the core of HTTP itself is stateless, HTTP cookies allow the use of stateful sessions. Using header extensibility, **HTTP Cookies allows session creation on each HTTP request to share the same state**.

## HTTP and Connections

A connection is controlled at the transport layer, and therefore fundamentally out of scope for HTTP. HTTP doesn't require the underlying transport protocol to be connection-based; it only requires it to be *reliable*, or not lose messages (at minimum, presenting an error in such cases). Among the two most common transport protocols on the Internet, TCP is reliable and UDP isn't. HTTP therefore relies on the TCP standard, which is ***connection-based***.

Before a client and server can exchange an HTTP request/response pair, they must establish a TCP connection, a process which requires several round-trips. The default behavior of ***HTTP/1.0*** is to open a separate TCP connection for each HTTP request/response pair. This is less efficient than sharing a single TCP connection when multiple requests are sent in close succession.

In order to mitigate this flaw, ***HTTP/1.1*** introduced *pipelining* (which proved difficult to implement) and *persistent connections*: the underlying TCP connection can be partially controlled using the [`Connection`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Connection) header. ***HTTP/2*** went a step further by multiplexing messages over a single connection, helping keep the connection warm and more efficient.

## HTTP/2

**Multiplexing:** HTTP/1.1 loads resources one after the other, so if one resource cannot be loaded, it blocks all the other resources behind it. In contrast, HTTP/2 is able to use a single [TCP](https://www.cloudflare.com/learning/ddos/glossary/tcp-ip/) connection to send multiple streams of data at once so that no one resource blocks any other resource. HTTP/2 does this by splitting data into binary-code messages and numbering these messages so that the client knows which stream each binary message belongs to.

**Server push:** Typically, a server only serves content to a client device if the client asks for it. However, this approach is not always practical for modern webpages, which often involve several dozen separate resources that the client must request. HTTP/2 solves this problem by allowing a server to "push" content to a client before the client asks for it. 

## HTTP/3

HTTP/3 is the next proposed version of the HTTP protocol. [HTTP/3](https://www.cloudflare.com/learning/performance/what-is-http3/) does not have wide adoption on the web yet, but it is growing in usage. The key difference between HTTP/3 and previous versions of the protocol is that HTTP/3 runs over [QUIC](https://www.cloudflare.com/learning/ddos/what-is-a-quic-flood/) instead of TCP. QUIC is a faster and more secure transport layer protocol that is designed for the needs of the modern Internet.

References:

- [1.6. Connections | HTTP: The Definitive Guide](https://learning.oreilly.com/library/view/http-the-definitive/1565925092/ch01s06.html)
- [An overview of HTTP - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview)
- [HTTP/2 vs. HTTP/1.1 | Cloudflare](https://www.cloudflare.com/learning/performance/http2-vs-http1.1/)