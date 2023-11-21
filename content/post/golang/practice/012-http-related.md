---
title: Some HTTP Issues with Go
date: 2023-10-29 11:30:50
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

## 2. `r.URL.Path` vs `r.URL.RawPath`

```go
func main() {
	u, err := url.Parse("http://example.com/x/xx%20a")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Path:", u.Path)
	fmt.Println("RawPath:", u.RawPath)
	fmt.Println("EscapedPath:", u.EscapedPath())
}
```

```go
Path: /x/xx a
RawPath: 
EscapedPath: /x/xx%20a
```

If url changes to "http://example.com/x/xx%2Fa", then will print:

```
Path: /x/xx/a
RawPath: /x/xx%2Fa
EscapedPath: /x/xx%2Fa
```

In general, code should call `EscapedPath()` instead of reading `u.RawPath` directly. 

Learn more: 

https://pkg.go.dev/net/url#URL.EscapedPath

## 3. Relative path

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

## 4. Redirection

### 4.1. Redirect at front end

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

### 4.2. Redirect at server with `Location` header

Learn more: [HTTP Headers - David's Blog](https://davidzhu.xyz/post/http/001-http-headers/)

### 4.3. Redirect at server with `http.Redirect()` method

See above **Relative path** section.

## 5. Parse form and query string

```go
func (r *Request) ParseForm() error
```

For all requests, `ParseForm()` parses the **raw query** from the URL and updates r.Form. For POST, PUT, and PATCH requests, **it also reads the request body**, parses it as a form and puts the results into both r.PostForm and r.Form. Request body parameters take precedence over URL query string values in r.Form. For other HTTP methods, **or when the Content-Type is not application/x-www-form-urlencoded, the request Body is not read**. 

Therefore, you can pass data in query string or in the request body. When you pass data with request body and the `Content-Type` header is `application/x-www-form-urlencoded`, it will be same to sending data with query stirng. 

The `Content-Type` header can be `application/json`, `application/x-www-form-urlencoded`, `multipart/form-data`, learn more: [Curl Basics - David's Blog](https://davidzhu.xyz/post/cs-basics/017-curl/) 

How to send form data in `application/x-www-form-urlencoded` format: [Tricks in Javascript - David's Blog](https://davidzhu.xyz/post/js/practice/001-tricks/#4-send-username-and-password-form)

Learn more: [http package - net/http - Go Packages](https://pkg.go.dev/net/http#Request.ParseForm)

## 6. Check the type of the request

When You are starting a HTTP/s server You use either `ListenAndServe` or `ListenAndServeTLS` or both together on different ports. If You are using just one of them, then from `Listen..` it's obvious which scheme request is using and You don't need a way to check and set it. But if You are serving on both HTTP and HTTP/s then You can use `request.TLS` state. if its `nil` it means it's HTTP.

```golang
// TLS allows HTTP servers and other software to record
// information about the TLS connection on which the request
// was received. This field is not filled in by ReadRequest.
// The HTTP server in this package sets the field for
// TLS-enabled connections before invoking a handler;
// otherwise it leaves the field nil.
// This field is ignored by the HTTP client.
TLS *tls.ConnectionState
```

an example:

```go
func index(w http.ResponseWriter, r *http.Request) {
    scheme := "http"
    if r.TLS != nil {
        scheme = "https"
    }
    w.Write([]byte(fmt.Sprintf("%v://%v%v", scheme, r.Host, r.RequestURI)))
}
```

Source: https://stackoverflow.com/a/76143800/16317008
