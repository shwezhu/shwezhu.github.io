---
title: Cross-origin Request HTTP
date: 2023-10-06 20:28:50
categories:
 - http
tags:
 - http
---

## 1. Upload file to web server with HTTP request

The html code:

```html
<input id="upload-file" type="file" />
<input id="upload-file-btn" type="submit" value="upload" />
```

I fInd the [docs about fetch](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch) and write code like this to upload file to the server with http request:

```javascript
document.getElementById("upload-file-btn").addEventListener("click", uploadFile)
async function uploadFile() {
  const url = "http://127.0.0.1:8080/upload"
  const fileInput = document.getElementById("upload-file")
  const formData = new FormData()
  formData.append("uploaded_file", fileInput.files[0])
  let response = await fetch(url, {
      method: "POST",
      headers: {"Content-Type": "multipart/form-data"},
      body: formData
  }) 
  if (!response.ok) {...}
}
```

Then I got an error at my web server:

```
no multipart boundary param in Content-Type
```

I found an explanation on [stack overflow](https://stackoverflow.com/a/42985029/16317008), says that form boundary is the delimiter for the form data, and added boundary to the header:

```javascript
...
let response = await fetch(url, {
    method: "POST",
    headers: {"Content-Type": "multipart/form-data; boundary=----WebKitFormBoundaryyEmKNDsBKjB7QEqu"},
    body: formData
})
```

Then got another error at server side:

```
multipart: NextPart: bufio: buffer full
```

And continue doing research on stackoverflow, find [a solution](https://stackoverflow.com/a/39281156/16317008): the solution to the problem is to explicitly set `Content-Type` to `undefined` so that your browser or whatever client you're using can set it and add that boundary value in there for you. 

I removed the headers settings:

```js
let response = await fetch(url, {
    method: "POST",
    body: formData
})
```

Then I got another error at the client side javascript console, so frustrated :(

```
Access to fetch at 'http://127.0.0.1:8080/upload' from origin 'http://localhost:8080' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource. If an opaque response serves your needs, set the request's mode to 'no-cors' to fetch the resource with CORS disabled.
```

Three ways to solve this problem:

- This is because the **target origin** is different from the [**origin**](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Origin), then I make the `fetch` function send request to `http://localhost:8080/upload` rather than `http://127.0.0.1:8080/upload`. Then the http request was sent successfully. 

- Another way is to enable `no-cors` mode in `fetch`

  ```js
  let response = await fetch(url, {
      method: "POST",
      body: formData,
      mode: "no-cors",
  })
  ```

  - This will work fine but you should note that when the request is made with "no-cors" mode, the response's status code property is always 0. This is because `no-cors` mode restricts the information available in the response, including the status code. 
  - `mode: 'no-cors'` won’t magically make things work. In fact it makes things worse, because one effect it has is to tell browsers, *“Block my frontend JavaScript code from seeing contents of the response body and headers under all circumstances.”* Of course you never want that. 
  - What happens with cross-origin requests from frontend JavaScript is that browsers by default block frontend code from accessing resources **cross-origin**. (If you know what [origin](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Origin) is, you will understand the term "cross-origin" easily). If `Access-Control-Allow-Origin` header is specified in a response, then browser relax that blocking and allow your code to access the response. Source: https://stackoverflow.com/a/43268098/16317008

- The last way is to enable cors on the server side by setting the response header: 

  - **It's a bad practice to allow `CORS *`**

  ```js
  function handler(w http.ResponseWriter, r *http.Request) {
    ...
    w.Header().Set("Access-Control-Allow-Origin", "*")
  	_, _ = fmt.Fprintf(w, "upload successful")
  }
  ```

> The first way is the correct way to solve this issue in this scenario. 
>
> Enabling `no-cors` mode in `fetch` will prevent from accessing the response, which you don't want. 
>
> Adding `Access-Control-Allow-Origin: *` header in http response on web server side is not safe. When the "Access-Control-Allow-Origin" header is set to "*", it means that any website, regardless of its origin, can make **cross-origin** requests to the server and access its resources. This opens up the server to potential attacks, including cross-site scripting (XSS) and cross-site request forgery (CSRF). 

## 2. Why cross-origin requests could be insecure 

Suppose there is a user who is logged into their banking website, which is hosted on https://bank.example.com. This means there is authentication cookie (probably a session_id) stored on the user's browser. 

Now, suppose an attacker creates a malicious website called https://evil.com and manages to trick a user into visiting it. 

The attacker's JavaScript code running on https://evil.com could make a **cross-origin request** to the banking website's API (https://bank.example.com/api/userdata) **on behalf of the user's browser**. If the user's browser does not enforce strict same-origin policy, or the server set header `Access-Control-Allow-Origin: *` in response, which mean the browser will allow this request to be sent. 

> If the user has an authentication cookie for the legitimate site, the cookies will be sent along with the request. So the malicious site can perform transactions in the legitimate site on behalf of the user, **despite not having direct access** to the authentication cookie. 

You probably wonder how does the server know where does the http request come from, e.g.,  [https://evil.com](https://evil.com/) or https://bank.example.com:

The server can determine the origin of an HTTP request through the `Origin` header included in the request's headers. The `Origin` header will be added by the web browser automatically.

```http
Origin: https://evil.com
```

You may wonder could the hacker spoof the `Origin` header from `Origin: https://evil.com` to `Origin: https://bank.example.com`:

Browsers are in control of setting the `Origin` header, and users can't override this value. So you won't see the `Origin` header spoofed from a browser. A malicious user could craft a curl request that manually sets the `Origin` header, but this request would come from outside a browser, and may not have browser-specific info (such as cookies).

Remember: CORS is not security. Do not rely on CORS to secure your site. If you are serving protected data, use cookies or OAuth tokens or something other than the `Origin` header to secure that data. The `Access-Control-Allow-Origin` header in CORS only dictates which origins should be allowed to make cross-origin requests. Don't rely on it for anything more. Source: https://stackoverflow.com/a/21058346/16317008

A **forbidden header name** is the name of any [HTTP header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers) that cannot be modified programmatically; specifically, an HTTP **request** header name . Learn more: https://developer.mozilla.org/en-US/docs/Glossary/Forbidden_header_name

## 3. Same-origin policy

The same-origin policy is a fundamental security feature **implemented by web browsers**. It is designed to prevent JavaScript code from making requests to a different origin (domain, scheme, or port) than the one from which it was originally loaded. 

Normally, web browsers enforce a same-origin policy, which means that JavaScript code running in a web page can only make requests to the same origin from which the page was served. In simpler terms, when a web page is loaded from a particular origin (e.g., [https://example.com](https://example.com/)), the same-origin policy ensures that any JavaScript code running within that page can only interact with resources (such as making HTTP requests or accessing data) from the same origin ([https://example.com](https://example.com/)). It restricts the ability of JavaScript code to access resources from other origins. Learn more: [Disable same origin policy in Chrome - Stack Overflow](https://stackoverflow.com/questions/3102819/disable-same-origin-policy-in-chrome) 

## 4. CORS 

Cross-origin resource sharing (CORS) can be understood as a controlled relaxation of the same-origin policy. 

**Cross-Origin Resource Sharing** ([CORS](https://developer.mozilla.org/en-US/docs/Glossary/CORS)) is an **HTTP-header based mechanism that allows a server** to indicate any [origins](https://developer.mozilla.org/en-US/docs/Glossary/Origin) (domain, scheme, or port) other than its own from which a browser should permit loading resources. 

### 4.1. Origins

These are same origin because they have the same scheme (`http`) and hostname (`example.com`), and the different file path does not matter:

- `http://example.com/app1/index.html`
- `http://example.com/app2/index.html`

These are not same origin because they use different schemes:

- `http://example.com/app1`
- `https://example.com/app2`

Now you know what is origin, then you should understand why CORS called **Cross-Origin** Resource Sharing. 

Source: [Origin - MDN Web Docs Glossary: Definitions of Web-related terms | MDN](https://developer.mozilla.org/en-US/docs/Glossary/Origin)

### 4.2. Example

An example of a cross-origin request: the front-end JavaScript code served from `https://domain-a.com` uses [`XMLHttpRequest`](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) to make a request for `https://domain-b.com/data.json`.

For security reasons, browsers restrict cross-origin HTTP requests initiated from scripts. For example, `XMLHttpRequest` and the [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) follow the [same-origin policy](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy). This means that a web application using those APIs can only request resources from the same origin the application was loaded from unless the response from other origins includes the right CORS headers.

Suppose web content at `https://foo.example` wishes to invoke content on domain `https://bar.other`. Code of this sort might be used in JavaScript deployed on `foo.example`:

```js
const xhr = new XMLHttpRequest();
const url = "https://bar.other/resources/public-data/";
xhr.open("GET", url);
xhr.onreadystatechange = someHandler;
xhr.send();
```

Let's look at what the browser will send to the server in this case:

```http
GET /resources/public-data/ HTTP/1.1
Host: bar.other
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:71.0) Gecko/20100101 Firefox/71.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Origin: https://foo.example
```

The request header of note is [`Origin`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Origin), which shows that the invocation is coming from `https://foo.example`.

```	http
HTTP/1.1 200 OK
Date: Mon, 01 Dec 2008 00:23:53 GMT
Server: Apache/2
Access-Control-Allow-Origin: *
Content-Type: application/xml

[…XML Data…]
```

In response, the server returns a [`Access-Control-Allow-Origin`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) header with `Access-Control-Allow-Origin: *`, which means that the resource can be accessed by **any** origin. `*` acts as a wildcard here in header for any origin. 

Source: [Cross-Origin Resource Sharing (CORS) - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

Set the `Access-Control-Allow-Origin` header for response in Go:

```go
...
w.Header().Set("Access-Control-Allow-Origin", "*")
_, _ = fmt.Fprintf(w, "upload successful")
```

## 5. CORS vs SOP

The Same-Origin Policy (SOP) is a security feature **enforced by web browsers** that restricts web pages (javascript) from interacting with resources (such as making requests or accessing data) from different origins. 

**CORS allows servers** to specify which origins are allowed to access their resources, even if they are from different origins. It provides a set of HTTP headers that the server includes in its responses to explicitly permit cross-origin requests from specific origins. 













