---
title: HTTP Status Codes
date: 2023-10-26 15:30:05
categories:
 - http
tags:
 - http
---

### 1. Redirect

- **301: permanent redirect: the URL is old and should be replaced.** Browsers will cache this.
  *Example usage:* URL moved from `/register-form.html` to `signup-form.html`.
  The method will change to GET, as per RFC 7231: "For historical reasons, a user agent MAY change the request method from POST to GET for the subsequent request."

- **303: temporary redirect, changing the method to GET.**
  *Example usage:* if the browser sent POST to `/register.php`, then now load (GET) `/success.html`.
- **307: temporary redirect, repeating the request identically.**
  *Example usage:* if the browser sent a POST to `/register.php`, then this tells it to redo the POST at `/signup.php`.
- **308: permanent redirect, repeating the request identically.** Where 307 is the "no method change" counterpart of 303, this 308 status is the "no method change" counterpart of 301.
- **302: temporary redirect. Only use for HTTP/1.0 clients.** This status code should not change the method, but browsers did it anyway. The RFC says: "Many pre-HTTP/1.1 user agents do not understand [303]. When interoperability with such clients is a concern, the 302 status code may be used instead, since most user agents react to a 302 response as described here for 303." Of course, some clients may implement it according to the spec, so if interoperability with such ancient clients is not a real concern, 303 is better for consistent results.

```
╔═══════════╦════════════════════════════════════════════════╗
║           ║                Switch to GET?                  ║
║           ╟────────────────────────┬───────────────────────╢
║ Temporary ║          No            │         Yes           ║
╠═══════════╬════════════════════════╪═══════════════════════╣
║ No        ║ 308 Permanent Redirect │ 301 Moved Permanently ║
╟───────────╟────────────────────────┼───────────────────────╢
║ Yes       ║ 307 Temporary Redirect │ 303 See Other         ║
║           ║ 302 Found (intended)   │ 302 Found (actual)    ║
╚═══════════╩════════════════════════╧═══════════════════════╝
```

The `307 Temporary Redirect` code indicates that the requested resource has been temporarily moved to a new URL. When a browser encounters a `307` response, it will redirect to the new URL specified in the response headers. The method and body of the original request are reused for the redirected request. This means that if the original request was a `POST` request, the redirected request will also be a `POST` request. However, if you want to change the method to `GET` for the redirected request, you can use the `303 See Other` status code instead.

learn more: 

- https://stackoverflow.com/a/55008140/16317008
- https://stackoverflow.com/a/58492986/16317008

### 2. Redirect in practice

Different redirect status code can **cause browser behave differently**. 

An unauthorized user make a request to `/home ` which needs authorized state to access, because he has not authorized, so he will be redirect to `/login`, if you respond a 308 code from server, then the unauthorized user will be redirect to `/login`, this woks fine. But 308 tell the brower all following http requests for `/home` need be redirected to `/login` even the user login successfully, you can clear the browser cache to reset, make sure don't repond a wrong status code. 