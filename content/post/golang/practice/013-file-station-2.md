---
title: A File Station (2) - Go 
date: 2023-10-08 22:14:50
categories:
 - golang
 - practice
tags:
 - golang
 - http
---

## 1. Redirect status code

When redirect a web page, the code looks like this in Go handler:

```go
// Have not logged in, redirect to login page.
if session.IsNew() {
  http.Redirect(w, r, "http://localhost:8080/login", http.StatusTemporaryRedirect)
  return
}
...
```

But when I refresh my browser which makes `session.IsNew(` is always `true`, then the web page didn't redirect, I don't know why, until I change the status code to `http.StatusFound` or `http.StatusMovedPermanently` then when I refresh the web page, the redirect woks fine. 

This is because the status code `http.StatusPermanentRedirect`, `307` whicih tells clients making subsequent requests for this resource should use the old URI. Whereas `301` tells cilents making subsequent requests for this resource should use the new URI. I learn this in [an good explanation](https://stackoverflow.com/a/4764456/16317008):

- **301**: Permanent redirect. Clients making subsequent requests for this resource should use the new URI. Clients should **not** follow the redirect automatically for POST/PUT/DELETE requests.
- **302**: Redirect for undefined reason. Clients making subsequent requests for this resource should **not** use the new URI. Clients should **not** follow the redirect automatically for POST/PUT/DELETE requests.
- **303**: Redirect for undefined reason. Typically, 'Operation has completed, continue elsewhere.' Clients making subsequent requests for this resource should **not** use the new URI. Clients **should** follow the redirect for POST/PUT/DELETE requests, but **use GET for the follow-up request**.
- **307**: Temporary redirect. Resource may return to this location at a later point. Clients making subsequent requests for this resource should use the old URI. Clients should **not** follow the redirect automatically for POST/PUT/DELETE requests.

Status code constant in Go:

```go
StatusMovedPermanently  = 301 // RFC 9110, 15.4.2
StatusFound             = 302 // RFC 9110, 15.4.3
StatusTemporaryRedirect = 307 // RFC 9110, 15.4.8
StatusPermanentRedirect = 308 // RFC 9110, 15.4.9
```

## 2. `fetch()` in javascript

One of my router looks like this in Go:

```go
s.router.HandleFunc("/logout", s.authenticatedOnly(s.handleLogout))
```

and the `s.authenticatedOnly()` method looks like this:

```go
// Acts as a filter which only allow the logged in request to pass.
func (s *Server) authenticatedOnly(f func(http.ResponseWriter, *http.Request, *sessions.Session)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Check if user has logged in.
		session, err := s.store.Get(r, "session_id")
    ...
		f(w, r, session)
	}
}
```

The JavaScript code looks like this:

```javascript
document.getElementById("logout-btn").addEventListener("click", logout)
async function logout() {
    const url = "http://localhost:8080/logout"
    // fetch sends GET method by default 
    let response = await fetch(url)
    if (!response.ok) {
      ...
    }
}
```

But when I clicked the logout button, the handler `authenticatedOnly()` never get called, but when I make a POST method with fetch, it works, I don't know why:

```js
let response = await fetch(
    url,
    {method: "POST"},
)
```

## 3. `preventDefault()`

**1.in what else situation we can use preventDefault()?**

Actually any type of event, you can stop its default behavior with the `preventDefault();` So not only submit buttons, but keypresses, scrolling events, you name it and you can prevent it from happening. Or if you'd like add your own logic to the default behavior, think of logging an event or anything of your choice.

**2.how could I find out all the browsers default behaviour? e.g. if I click a button, what is the browsers default behaviour?**

What do you mean with this? Mostly the default behavior is kind of implied. When you click a button, the onclick event fires. When you click the submit button, the form is submitted. When the windows scrolls, the onscroll event fires.

Source: https://stackoverflow.com/a/17401436/16317008

`event.preventDefault()` basically prevents event to fire. In the case of `submit` event. `event.preventDefault()` will prevent your form to submit. We normally prevent `submit` behaviour to check some validation before submitting the form or we need to change values of our input fields or we want to submit using `ajax` calls. For this purpose, we prevent form to be submitted by using `event.preventDefault()`. 

## 4. Relative path

You can write relative path directly for the endpoint, because the browser know the `Origin`, when you make POST or GET request, it will know where should go.

```html
{{range .}}
    <div>
        <a href="/download?filename={{.Name}}">{{.Name}} ({{.Size}})</a>
    </div>
{{end}}

<form class="mx-1 mx-md-4" method="post" action="/login">
  ...
</form>
```

And it's ok to write relative path when redirect in Go code:

```html
// Redirect to login page.
http.Redirect(w, r, "/login", http.StatusPermanentRedirect)
```

## 5. Don't use `FormData` to send username and password

The parse form code in Go:

```go
if e := r.ParseForm(); err != nil {
  err = fmt.Errorf("failed to parse username and password: %v", e)
  return
}
username = r.Form.Get("username")
password = r.Form.Get("password")
```

According to [Golang docs](https://pkg.go.dev/net/http#Request.ParseForm) for `ParseForm() `: 

For other HTTP methods, or when the Content-Type **is not** application/x-www-form-urlencoded, the request Body is not read, and `r.PostForm` is initialized to a non-nil, empty value. I have talked this at [Parse Form Data in Go Server - David's Blog](https://davidzhu.xyz/post/golang/practice/010-go-web-2/). 

When you use fetch to send form data by this way:

```js
// don't use new FormData to send username and password
let data = new FormData(document.getElementById("login-form"))
let response = await fetch("/login", {
  method: "POST",
  headers:{"Content-Type":"application/x-www-form-urlencoded"},
  body: data,
})
```

Then the actual request body sent by browser will be:

```
"username"

david
------WebKitFormBoundaryGx7UioRfdfhdT5U5
Content-Disposition: form-data; name="password"

778899sS
------WebKitFormBoundaryGx7UioRfdfhdT5U5--
```

This is not correct, the suggestion to get a correct request body is to not set header explictly:

```js
let response = await fetch("/login", {
  method: "POST",
  //headers:{"Content-Type":"application/x-www-form-urlencoded"},
  body: data,
})
```

Then the correct form data will be sent:

``` 
username: david
password: 778899s
```

However, if you don't set `Content-Type` header explicitly, then the browser will make it to this automatically:

``` go
// received on server
Content-Type:[multipart/form-data; boundary=----WebKitFormBoundaryBcoBib8rzQP0rq2W] 
```

But this will make golang `ParseForm ` method ignore the request body, so you cannot get the username and password. The correct way to send form data with fetch is like this:

```js
const data = new URLSearchParams()
for (const pair of new FormData(document.getElementById("login-form"))) {
  data.append(pair[0], String(pair[1]))
}
let response = await fetch("/login", {
  method: "POST",
  //headers:{"Content-Type":"application/x-www-form-urlencoded"},
  body: data,
})
```

I find this solution on [an answer at Stackoverflow](https://stackoverflow.com/a/46642899/16317008), the problem caused by `new FormData()`:

To quote [MDN on `FormData`](https://developer.mozilla.org/en-US/docs/Web/API/FormData) (emphasis mine):

> The **`FormData`** interface provides a way to easily construct a set of key/value pairs representing form fields and their values, which can then be easily sent using the `XMLHttpRequest.send()` method. **It uses the same format a form would use if the encoding type were set to `"multipart/form-data"`**.

So when using `FormData` you are locking yourself into `multipart/form-data`. There is no way to send a `FormData` object as the body and *not* sending data in the `multipart/form-data` format.

If you want to send the data as `application/x-www-form-urlencoded` you will either have to specify the body as an URL-encoded string, or pass a [`URLSearchParams`](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams) object. 





