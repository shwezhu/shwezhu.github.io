---
title: CSRF Attack and CORS
date: 2023-10-06 18:29:57
categories:
 - http
tags:
 - cybersecurity
 - http
---

## 1. Cross-Origin Resource Sharing (CORS)

Cross-origin resource sharing (CORS) can be understood as a controlled relaxation of the same-origin policy. 

### 1.1. How does cross-origin resource sharing work?

In standard internet communication, your browser sends an HTTP request to the application server, receives data as an HTTP response, and displays it. In browser terminology, the current browser URL is called the *current origin* and the third-party URL is *cross-origin*.

When you make a cross-origin request, this is the request-response process:

1. The browser adds an origin header to the request with information about the current origin's protocol, host, and port
2. The server checks the current origin header and responds with the requested data and an Access-Control-Allow-Origin header
3. The browser sees the access control request headers and shares the returned data with the client application

Alternatively, if the server doesn’t want to allow cross-origin access, it responds with an error message.

### 1.2. **Cross-origin resource sharing example**

For example, consider a site called *https://news.example.com. This site* wants to access resources from an API at *partner-api.com*.

Developers at *https://partner-api.com* first configure the cross-origin resource sharing (CORS) headers on their server by adding *new.example.com* to the allowed origins list. 

*Access-Control-Allow-Origin: https://news.example.com*

Once CORS access is configured, *news.example.com* can request resources from *partner-api.com*. For every request, *partner-api.com* will respond with *Access-Control-Allow-Credentials : "true."* The browser then knows the communication is authorized and permits cross-origin access.

If you want grant access to multiple origins, use a comma-separated list or wildcard characters like * that grant access to everyone.

## 2. What is a CORS preflight request?

If a web app needs a complex HTTP request, the browser adds a **[preflight request](https://developer.mozilla.org/docs/Web/HTTP/CORS#preflighted_requests)** to the front of the request chain.

The CORS specification defines a **complex request** as

- A request that uses methods other than GET, POST, or HEAD
- A request that includes headers other than `Accept`, `Accept-Language` or `Content-Language`
- A request that has a `Content-Type` header other than `application/x-www-form-urlencoded`, `multipart/form-data`, or `text/plain`

Browsers create a preflight request if it is needed. It's an `OPTIONS` request like below and is sent before the actual request message.

```text
OPTIONS /data HTTP/1.1
Origin: https://example.com
Access-Control-Request-Method: DELETE
```

On the server side, an application needs to respond to the preflight request with information about the methods the application accepts from this origin.

```text
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: GET, DELETE, HEAD, OPTIONS
```

The server response can also include an `Access-Control-Max-Age` header to specify the duration (in seconds) to cache preflight results so the client does not need to make a preflight request every time it sends a complex request.

References: 

- [Cross-Origin Resource Sharing (CORS)](https://web.dev/cross-origin-resource-sharing/)
- [What is CORS? - Cross-Origin Resource Sharing Explained - AWS](https://aws.amazon.com/what-is/cross-origin-resource-sharing/#:~:text=Cross%2Dorigin%20resource%20sharing%20(CORS,resources%20in%20a%20different%20domain.)

## 3. CSRF

[Cross-Site Request Forgery (CSRF)](https://owasp.org/www-community/attacks/csrf) is a type of attack that occurs when a malicious web site, email, blog, instant message, or program causes a user's web browser to perform an unwanted action on a trusted site when the user is authenticated. A CSRF attack works because **browser requests automatically include all cookies including session cookies.** Therefore, if the user is authenticated to the site, the site cannot distinguish between legitimate authorized requests and forged authenticated requests. This attack is thwarted when proper Authorization is used, which implies that a challenge-response mechanism is required that verifies the identity and authority of the requester. Source: https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#synchronizer-token-pattern

{{% youtube "eWEgUcHPle0" %}}

Video: https://www.youtube.com/watch?v=eWEgUcHPle0

## 4. Cross-site request forgery prevention

- **For stateful software use the [synchronizer token pattern](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#synchronizer-token-pattern)**
- **For stateless software use [double submit cookies](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#double-submit-cookie)**
- **For API-driven sites that don't use `<form>` tags, consider [using custom request headers](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#custom-request-headers)**

### 4.1. Synchronizer token pattern

CSRF tokens should be generated on the server-side. They can be generated once per user session or for each request. Per-request tokens are more secure than per-session tokens as the time range for an attacker to exploit the stolen tokens is minimal. However, this may result in usability concerns. For example, the "Back" button browser capability is often hindered as the previous page may contain a token that is no longer valid. Interaction with this previous page will result in a CSRF false positive security event on the server. In per-session token implementations after the initial generation of a token, the value is stored in the session and is used for each subsequent request until the session expires.

When a request is issued by the client, the server-side component must verify the existence and validity of the token in the request compared to the token found in the user session. If the token was not found within the request, or the value provided does not match the value within the user session, then the request should be rejected. Additional actions such as logging the event as a potential CSRF attack in progress should also be considered.

CSRF tokens should be:

- Unique per user session.
- Secret
- Unpredictable (large random value generated by a [secure method](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html#rule---use-cryptographically-secure-pseudo-random-number-generators-csprng)).

CSRF tokens prevent CSRF because without a token, an attacker cannot create valid requests to the backend server.

**For the Synchronised Token Pattern, CSRF tokens should not be transmitted using cookies.**

The CSRF token can be transmitted to the client as part of a response payload, such as a HTML or JSON response. It can then be transmitted back to the server as a hidden field on a form submission, or via an AJAX request as a custom header value or part of a JSON payload. Make sure that the token is not leaked in the server logs, or in the URL. CSRF tokens in GET requests are potentially leaked at several locations, such as the browser history, log files, network utilities that log the first line of a HTTP request, and Referer headers if the protected site links to an external site.

For example:

```
<form action="/transfer.do" method="post">
<input type="hidden" name="CSRFToken" value="OWY4NmQwODE4ODRjN2Q2NTlhMmZlYWEwYzU1YWQwMTVhM2JmNGYxYjJiMGI4MjJjZDE1ZDZMGYwMGEwOA==">
[...]
</form>
```

Inserting the CSRF token in a custom HTTP request header via JavaScript is considered more secure than adding the token in the hidden field form parameter because requests with custom headers are automatically subject to the **same-origin policy**. 

### 4.2. Custom Request Headers

Both the **synchronizer token** and the **double submit cookie** are used to prevent forgery of form data, but they can be tricky to implement and degrade usability. Many modern web applications do not use `<form>` tags. A user-friendly defense that is particularly well suited for AJAX or API endpoints is the use of a **custom request header**. No token is needed for this approach.

In this pattern, the client appends a custom header to requests that require CSRF protection. The header can be any arbitrary key-value pair, as long as it does not conflict with existing headers.

```
X-YOURSITE-CSRF-PROTECTION=1
```

When handling the request, the API checks for the existence of this header. I**f the header does not exist, the backend rejects the request as potential forgery.** This approach has several advantages:

- UI changes are not required
- no server state is introduced to track tokens

If you use `<form>` tags anywhere in your client, you will still need to protect them with alternate approaches described in this document such as tokens.

This defense relies on the browser's [same-origin policy (SOP)](https://en.wikipedia.org/wiki/Same-origin_policy) restriction that only JavaScript can be used to add a custom header, and only within its origin. By default, browsers do not allow JavaScript to make cross origin requests with custom headers. Only JavaScript that you serve from your origin can add these headers. 

By default, web browsers enforce the same-origin policy, which restricts JavaScript from making cross-origin requests with custom headers. 

```js
let response = await fetch("http:127.0.0.1:8080", {
    method: "POST",
    body: formData,
    // cosutm header
    headers: {"abc": "123"},
})
```

Some **headers in this request**:

```
Origin:http://localhost:8080
```

And `Request URL: http://127.0.0.1:8080/upload`, as you can see this is a cross-origin request, because the origin is different from the target origin. 

We have **header in response**:

```
Access-Control-Allow-Origin: *
```

But this request will still be blocked by the browser, because web browsers enforce the same-origin policy, which restricts JavaScript from making cross-origin requests with custom headers. 

### 4.3. SameSite Attribute

An emerging way to protect against [CSRF Attacks](https://docs.spring.io/spring-security/reference/features/exploits/csrf.html#csrf) is to specify the [SameSite Attribute](https://tools.ietf.org/html/draft-west-first-party-cookies) on cookies. A server can specify the `SameSite` attribute when setting a cookie to indicate that the cookie should not be sent when coming from external sites.

References:

- [Cross-Site Request Forgery Prevention - OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html#synchronizer-token-pattern)
- [Cross Site Request Forgery (CSRF) :: Spring Security](https://docs.spring.io/spring-security/reference/features/exploits/csrf.html)

