---
title: HTTP Headers (2)
date: 2023-10-30 22:06:07
categories:
 - http
tags:
 - http
typora-root-url: ../../../static
---

### 1. Strict-Transport-Security

Q: Disable HTTP access to the domain, don’t even redirect or link it to SSL. Just inform the users this website is not accessible over HTTP and they have to access it over SSL. 

A: I can't see any technical reason why HTTP needs to be completely blocked either, and **many sites do forward HTTP to HTTPS. When doing this** it is highly advisable to implement HTTP Strict Transport Security (HSTS) which is a web security mechanism which declares that browsers are to only use HTTPS connections.

An HTTP request that includes a session ID cookie is subject to session hijacking attacks. It is important that if you do allow HTTP and redirect to HTTPS, that cookies are marked as secure.

HSTS is implemented by specifying a response header such as `Strict-Transport-Security: max-age=31536000`. Complying user agents will automatically turn insecure links into secure links, thereby reducing the risk of man-in-the-middle attacks. Additionally, if there is a risk that the certificate isn't secure, e.g. the root authority isn't recognised, then an error message is displayed and the response is not shown.

Source: [security - Is redirecting http to https a bad idea? - Stack Overflow](https://stackoverflow.com/questions/4365294/is-redirecting-http-to-https-a-bad-idea)