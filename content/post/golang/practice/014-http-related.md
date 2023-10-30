---
title: Some HTTP Issues with Go
date: 2023-10-29 11:130:50
categories:
 - golang
 - practice
tags:
 - golang
 - http
---

## 1. Parse raw query string 

```go
func (s *server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// handle asset.
	const assetPrefix = "asset="
	if strings.HasPrefix(r.URL.RawQuery, assetPrefix) {
		r.URL.RawQuery[len(assetPrefix):]
		s.asset(w, r, assetName)
		return
	}
  ...
}
```

If there are whitespaces in query string, the [whitespace will be encoded](https://stackoverflow.com/a/1211256/16317008) to `%20` or `+` automatically, 

js code:

```javascript
async function getUrl(filepath) {
    const filename = "back ground.png"
    const url = "?asset=" + filename
    let response = await fetch(url)
    ...
}
```

The request URL will be: `http://localhost:8080?filepath=back%20ground.png`. 

Therefore, if you use `r.URL.RawQuery` in Go:

```go
log.Println(r.URL.RawQuery)
log.Println(r.URL.Query())
```

This will print:

```
2023/10/29 12:19:36 filepath=back%20ground.png
2023/10/29 12:19:36 map[filepath:[back ground.png]]
```

As you can see, `r.URL.RawQuer` isn't friendly to string with whitespace, you should try to use `r.URL.Query()` to emliminate the `%20` characters. 

So the recommended way is as below:

```go
func (s *server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// handle asset.
	const assetPrefix = "asset="
	if strings.HasPrefix(r.URL.RawQuery, assetPrefix) {
    // r.URL.Query() returns a map[string][]string
		assetName := r.URL.Query()[strings.TrimSuffix(assetPrefix, "=")][0]
		s.asset(w, r, assetName)
		return
	}
  ...
}
```

### 2. Relative path

You can write relative path directly for the endpoint, because the browser know the **Origin**, when you make HTTP request, it knows where should go.

```html
<form method="post" action="/login">
  ...
</form>
```

And it's ok to write relative path when redirect in Go code:

```html
// Redirect to login page.
http.Redirect(w, r, "/login", http.StatusFound)
```

### 3. Redirection

#### 3.1. Redirect at front end

For redirection, you can use js code to redirect based on the status code passed from server:

```js
const response = await fetch("/login", {
  method: "POST",
  body: data,
})

if (!response.ok) {
  ...
  return
}
// If login successfully, redirect to /home
window.location = "/home"
```

#### 3.2. Redirect at server with `Location` header

Learn more: [HTTP Headers - David's Blog](https://davidzhu.xyz/post/http/001-http-headers/)

#### 3.3. Redirect at server with `http.Redirect()` method

See above **Relative path** section.

### 4. Parse form and query string

```go
func (r *Request) ParseForm() error
```

For all requests, `ParseForm()` parses the **raw query** from the URL and updates r.Form. For POST, PUT, and PATCH requests, **it also reads the request body**, parses it as a form and puts the results into both r.PostForm and r.Form. Request body parameters take precedence over URL query string values in r.Form. For other HTTP methods, **or when the Content-Type is not application/x-www-form-urlencoded, the request Body is not read**. 

Therefore, you can pass data in the query string or in the request body at front end, when you want 

Learn more: [http package - net/http - Go Packages](https://pkg.go.dev/net/http#Request.ParseForm)