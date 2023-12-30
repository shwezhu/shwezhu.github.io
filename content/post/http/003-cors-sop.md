---
title: Cross-origin Request HTTP
date: 2023-10-06 20:28:50
categories:
 - http
tags:
 - http
---

## 1. CORS policy error

> Access to fetch at 'http://127.0.0.1:8080/upload' from origin 'http://localhost:8080' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource. If an opaque response serves your needs, set the request's mode to 'no-cors' to fetch the resource with CORS disabled.

- One way is to enable `no-cors` mode in `fetch`

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

- Another way is to enable cors on the server side by setting the response header: 

  - **It's a bad practice to allow `CORS *`**

  ```js
  function handler(w http.ResponseWriter, r *http.Request) {
    ...
    w.Header().Set("Access-Control-Allow-Origin", "*")
  	_, _ = fmt.Fprintf(w, "upload successful")
  }
  ```

Enabling `no-cors` mode in `fetch` will prevent from accessing the response, which you don't want. 

Adding `Access-Control-Allow-Origin: *` header in http response on web server side is not safe. When the "Access-Control-Allow-Origin" header is set to "*", it means that any website, regardless of its origin, can make **cross-origin** requests to the server and access its resources. This opens up the server to potential attacks, including cross-site scripting (XSS) and cross-site request forgery (CSRF). 

## 2. Why need `Access-Control-Allow-Origin` header

假设您有一个运行在 `https://api.myserver.com` 上的后端 API，和两个前端应用，分别运行在 `https://myapp.com` 和 `https://anotherapp.com` 上。您希望 `https://myapp.com` 能够访问您的后端 API，但不希望 `https://anotherapp.com` 或其他任何网站能够这样做。

**不使用 CORS 的情况**

如果不实施任何 CORS 策略，那么浏览器的同源策略（SOP）默认会阻止来自 `https://myapp.com` 的前端应用调用 `https://api.myserver.com` 上的 API。这是因为这两个 URL 有不同的源（不同的域名），所以浏览器会出于安全考虑阻止这样的请求。

**使用 `Access-Control-Allow-Origin: *` 的情况**

如果在您的后端服务器上设置 `Access-Control-Allow-Origin` 为 `*`，那么任何网站都可以请求您的 API。在这种情况下，`https://myapp.com` 和 `https://anotherapp.com` 以及任何其他网站都能够访问您的 API。虽然这样做方便了跨域访问，但同时也增加了安全风险，因为恶意网站也可以访问您的 API。

**使用具体域名的情况**

理想的做法是在后端服务器上设置 `Access-Control-Allow-Origin` 为 `https://myapp.com`。这样，只有来自 `https://myapp.com` 的请求被允许访问您的 API，而来自 `https://anotherapp.com` 或任何其他网站的请求都会被浏览器阻止。这种方式既允许了您需要的跨域访问，又保证了较高的安全性。

## 3. Why `Access-Control-Allow-Origin: *` could be insecure 

## 3.1. Reasons

Suppose there is a user who is logged into their banking website, which is hosted on https://bank.example.com. This means there is authentication cookie (probably a session_id) stored on the user's browser. 

Now, suppose an attacker creates a malicious website called https://evil.com and manages to trick a user into visiting it. 

The attacker's JavaScript code running on https://evil.com could make a **cross-origin request** to the banking website's API (https://bank.example.com/api/userdata) **on behalf of the user's browser**. If the user's browser does not enforce strict same-origin policy, or the server set header `Access-Control-Allow-Origin: *` in response, which mean the browser will allow this request to be sent. 

> If the user has an authentication cookie for the legitimate site, the cookies will be sent along with the request. So the malicious site can perform transactions in the legitimate site on behalf of the user, **despite not having direct access** to the authentication cookie. 

### 3.2. Questions

**How does the server know where does the http request come from**, e.g.,  [https://evil.com](https://evil.com/) or https://bank.example.com:

Through the **`Origin` header** included in the request's headers, the **`Origin` header** will be added by the web browser automatically:

```http
Origin: https://evil.com
```

**Could the hacker spoof the `Origin` header** from `Origin: https://evil.com` to `Origin: https://bank.example.com`?

Browsers are in control of setting the `Origin` header, and **users can't override this value.** So you won't see the `Origin` header spoofed from a browser. A malicious user could craft a curl request that manually sets the `Origin` header, but this request would come from outside a browser, and may not have browser-specific info (such as cookies).

> Remember: The `Access-Control-Allow-Origin` header in CORS only dictates which origins should be allowed to make cross-origin requests. Don't rely on it for anything more. [source ](https://stackoverflow.com/a/21058346/16317008) 

## 4. CORS vs SOP

The Same-Origin Policy (SOP) is a security feature **enforced by web browsers** that restricts web pages (javascript) from interacting with resources (such as making requests or accessing data) from different origins. 

**CORS allows servers** to specify which origins are allowed to access their resources, even if they are from different origins. It provides a set of HTTP headers that the server includes in its responses to explicitly permit cross-origin requests from specific origins. 

## 5. Same-origin policy

### 5.1. 同源策略的关键点

1. **限制数据读取**：同源策略主要限制一个网页从不同源的服务器读取数据。这意味着一个网页上的脚本不能读取或操作另一个源的网页内容或响应数据。

2. **不阻止发送请求**：尽管同源策略阻止读取不同源的数据，但它并不阻止向不同源发送请求。这意味着，脚本可以向任何源发送请求，例如提交表单或发起 AJAX 请求。

3. **安全和隐私**：这种策略的目的是保护用户数据的安全和隐私，防止恶意网站访问或操作用户在其他网站上的敏感数据。

### 5.2. 例子
假设 Alice 在 `https://www.alicebank.com` 上登录了她的银行账户。然后，她访问了一个恶意网站 `https://www.badguy.com`。这个恶意网站包含一个脚本，尝试通过 AJAX 向 `https://www.alicebank.com` 发送请求。

- **发送请求是允许的**：恶意脚本可以向 `https://www.alicebank.com` 发送请求，这不违反同源策略。

- **读取响应受限**：虽然恶意脚本发送了请求，但由于同源策略，它不能读取来自 `https://www.alicebank.com` 的响应数据。因此，Alice 的银行数据（如账户余额和交易信息）对于 `https://www.badguy.com` 来说是不可见的，从而保护了其安全。

总的来说，同源策略是一种安全机制，它允许向任何源发送请求，但限制了从其他源读取数据，从而保护用户免受跨源读取攻击的威胁。
