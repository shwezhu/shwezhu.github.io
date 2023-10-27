---
title: HTTP Headers
date: 2023-10-26 09:58:10
categories:
 - http
tags:
 - http
typora-root-url: ../../../static
---

### 0. Header types

Headers can be grouped according to their contexts:

- [Request headers](https://developer.mozilla.org/en-US/docs/Glossary/Request_header) contain more information about the resource to be fetched, or about the client requesting the resource.
- [Response headers](https://developer.mozilla.org/en-US/docs/Glossary/Response_header) hold additional information about the response, like its location or about the server providing it.
- [Representation headers](https://developer.mozilla.org/en-US/docs/Glossary/Representation_header) contain information about the body of the resource, like its [MIME type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types), or encoding/compression applied.
- [Payload headers](https://developer.mozilla.org/en-US/docs/Glossary/Payload_header) contain representation-independent information about payload data, including content length and the encoding used for transport.

Learn more: [HTTP headers - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers)

### 1. `Content-Type` 

The `Content-Type` header can be `application/json`, `application/x-www-form-urlencoded`, `multipart/form-data`, the first two is usually used with posting form data to server, the third is used to upload file to the server.

- The format of `application/json` is `'{"username":"davidzhu", "password":"778899a"}'`. 

- The format of `application/x-www-form-urlencoded` is `"username=davidzhu&password=778899a" `. 

Post file to server:

```html
<form method="POST" action="{{.CurrentPath}}?upload" enctype="multipart/form-data">
    <input type="file" name="file" required/>
    <button type="submit">upload</button>
</form>
```

> HTML provides no way to generate JSON from *form data*. You'd probably be better off sticking to `application/x-www-form-urlencoded` data and processing that on the server instead of JSON. Your form doesn't have any complicated hierarchy that would benefit from a JSON data structure. Source: https://stackoverflow.com/a/22195153/16317008
>

If you really want to handle it from the client, then you would have to resort to using JavaScript to: 

1. gather your data from the form via DOM
2. organise it in an object or array
3. generate JSON with [JSON.stringify](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify)
4. POST it with XMLHttpRequest

Learn more: [Curl Basics - David's Blog](https://davidzhu.xyz/post/cs-basics/017-curl/)

### 2. `Access-Control-Allow-Origin`

Adding `Access-Control-Allow-Origin: *` header in http response on web server side is not safe. When the "Access-Control-Allow-Origin" header is set to "*", it means that any website, regardless of its origin, can make **cross-origin** requests to the server and access its resources. This opens up the server to potential attacks, including cross-site scripting (XSS) and cross-site request forgery (CSRF). 

The Same-Origin Policy (SOP) is a security feature **enforced by web browsers** that restricts web pages (javascript) from interacting with resources (such as making requests or accessing data) from different origins. 

**CORS allows servers** to specify which origins are allowed to access their resources, even if they are from different origins. It provides a set of HTTP headers that the server includes in its responses to explicitly permit cross-origin requests from specific origins. 

Learn more: [A File Station (1) - Go - David's Blog](https://davidzhu.xyz/post/golang/practice/012-file-station-1/)

### 3. `Location`

The **`Location`** response header indicates the URL to redirect a page to. It only provides a meaning when served with a `3xx` (redirection) or `201` (created) status response.

```go
func (s *server) handleMkdir(w http.ResponseWriter, r *http.Request, currentPath string) error {
	// Parse form.
	if err := r.ParseForm(); err != nil {
		err = fmt.Errorf("failed to parse folder name: %v", err)
		return err
	}
  ...

	// clean url and redirect
	r.URL.RawQuery = ""
	w.Header().Set("Location", r.URL.String())
	w.WriteHeader(http.StatusSeeOther)

	return nil
}
```

> Note that `Location` is a response header. 

Status code 303: [HTTP Status Codes - David's Blog](https://davidzhu.xyz/post/http/002-http-status-codes/)

### 4. `Cache-Control`

`cache-control: no-cache`: This directive means that cached versions of **the requested resource** cannot be used without first checking to see if there is an updated version. `max-age=0` is *a workaround for no-cache* , because many old (HTTP/1.0) cache implementations don't support no-cache. 

`cache-control: private`: A response with a `private` directive can only be cached by the client and never by an intermediary agent, such as a [CDN](https://www.cloudflare.com/learning/cdn/what-is-a-cdn/) or a proxy. These are often resources containing private data, such as a website displaying a user’s personal information. 

`cache-control: public`: Conversely, the `public` directive means the requested resource can be stored by any cache.

When we access a web page, there may have multiple http requests being made, such as `favicon.ico`, `xxx.js`, `xxx.json`, `xxx.png`, for each of these resources there is a http request needed to be sent, and indeed there is a corresponding http response. These resourses are called **the requested resources** above we mentioned. So each of the repsonse have their own http headers:

![a](/001-http-headers/a.png)

![b](/001-http-headers/b.png)

Browser caching is a great way to both preserve resources and improve user experience on the Internet, but without cache-control, it would be very brittle. Every resource on every site would be bound by the same caching rules, meaning that sensitive information would be cached the same way as public information, and **frequently-updated resources would be cached for the same amount of time as ones that rarely change**. 

The code below is written in Go which responsible for handle assets request from client, `favicon.ico` for example.

```go
func RenderAsset(w http.ResponseWriter, r *http.Request, assetPath string) {
	header := w.Header()
	header.Set("Cache-Control", "public, max-age=0")
	http.ServeFile(w, r, filename)
}
```

> **Browser caching** is when a web browser saves website resources so it doesn’t have to fetch them again from a server. For example, a background image on a website might be saved locally in cache so that when a user visits that page for the second time, the image will load from the user’s local files and the page will load much faster.

> **Cookies are HTTP Headers**. The header is called `Cookie:`, and it contains your cookie.

Learn more: [What is cache-control? | Cache explained | Cloudflare](https://www.cloudflare.com/learning/cdn/glossary/what-is-cache-control/)

### 5. `Authorization ` & `WWW-Authenticate`

The HTTP **`Authorization`** **request header** can be used to provide credentials that authenticate a user agent with a server, allowing access to a protected resource.

The HTTP **`WWW-Authenticate`** **response header** defines the [HTTP authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication) methods ("challenges") that might be used to gain access to a specific resource. 

> The **`Authorization`** header is usually, but not always, sent after the user agent first attempts to request a protected resource without credentials. The server responds with a [`401`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/401) `Unauthorized` message that includes at least one [`WWW-Authenticate`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate) header. This header indicates what authentication schemes can be used to access the resource (and any additional information needed by the client to use them). 

[RFC 7235](https://datatracker.ietf.org/doc/html/rfc7235) defines the HTTP authentication framework, which can be used by a server to [challenge](https://developer.mozilla.org/en-US/docs/Glossary/Challenge) a client request, and by a client to provide authentication information.

The challenge and response flow works like this:

1. The server responds to a client with a [`401`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/401) (Unauthorized) response status and provides information on how to authorize with a [`WWW-Authenticate`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate) response header containing at least one challenge.
2. A client that wants to authenticate itself with the server can then do so by including an [`Authorization`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization) request header with the credentials.
3. Usually a client will present a password prompt to the user and will then issue the request including the correct `Authorization` header.

> **Warning:** The "Basic" authentication scheme used in the diagram above sends the credentials **encoded but not encrypted**. This would be completely insecure unless the exchange was over a secure connection (HTTPS/TLS).

```go
func(w http.ResponseWriter, r *http.Request) {
  
  username, password, ok := r.BasicAuth()
  if ok {
    usernameMatch := subtle.ConstantTimeCompare(usernameHash[:], expectedUsernameHash[:]) == 1
    passwordMatch := subtle.ConstantTimeCompare(passwordHash[:], expectedPasswordHash[:]) == 1
    if usernameMatch && passwordMatch {
      ...
      return
    }
  }
  w.Header().Set("WWW-Authenticate", `Basic realm="restricted", charset="UTF-8"`)
  http.Error(w, "Unauthorized", http.StatusUnauthorized)
}
```

Code credit to: [Go BasicAuth](https://www.alexedwards.net/blog/basic-authentication-in-go)

HTTP authentication framework: [HTTP authentication - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication)

Learn more: [Authorization - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization)

