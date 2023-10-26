---
title: HTTP Headers
date: 2023-10-26 09:58:10
categories:
 - http
tags:
 - http
---

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

Status Code 303: 
