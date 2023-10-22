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

Different redirect status code can **cause browser behave differently**. 

```go
StatusMovedPermanently  = 301 // RFC 9110, 15.4.2
StatusFound             = 302 // RFC 9110, 15.4.3
StatusTemporaryRedirect = 307 // RFC 9110, 15.4.8
StatusPermanentRedirect = 308 // RFC 9110, 15.4.9
```

An unauthorized user make a request to `/home ` which needs authorized state to access, because he has not authorized, so he will be redirect to `/login`, if you respond a 308 code from server, then the unauthorized user will be redirect to `/login`, this woks fine. But 308 tell the brower all following http requests for `/home` need be redirected to `/login` even the user login successfully, you can clear the browser cache to reset, make sure don't repond a wrong status code. 

## 2. `preventDefault()`

**1.in what else situation we can use preventDefault()?**

Actually any type of event, you can stop its default behavior with the `preventDefault();` So not only submit buttons, but keypresses, scrolling events, you name it and you can prevent it from happening. Or if you'd like add your own logic to the default behavior, think of logging an event or anything of your choice.

**2.how could I find out all the browsers default behaviour? e.g. if I click a button, what is the browsers default behaviour?**

What do you mean with this? Mostly the default behavior is kind of implied. When you click a button, the onclick event fires. When you click the submit button, the form is submitted. When the windows scrolls, the onscroll event fires.

Source: https://stackoverflow.com/a/17401436/16317008

`event.preventDefault()` basically prevents event to fire. In the case of `submit` event. `event.preventDefault()` will prevent your form to submit. We normally prevent `submit` behaviour to check some validation before submitting the form or we need to change values of our input fields or we want to submit using `ajax` calls. For this purpose, we prevent form to be submitted by using `event.preventDefault()`. 

## 3. Relative path

You can write relative path directly for the endpoint, because the browser know the `Origin`, when you make POST or GET request, it knows where should go.

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

## 4. Don't use `new FormData()` to send username and password

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

> For other HTTP methods, or when the Content-Type **is not** application/x-www-form-urlencoded, the request Body is not read, and `r.PostForm` is initialized to a non-nil, empty value. I have talked this at [Parse Form Data in Go Server - David's Blog](https://davidzhu.xyz/post/golang/practice/010-go-web-2/). 

When you use fetch to send form data by this way:

```js
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

However, if you don't set `Content-Type` header explicitly, the browser will set Content-Type header to `multipart/form-data` automatically:

``` go
// received on server
Content-Type:[multipart/form-data; boundary=----WebKitFormBoundaryBcoBib8rzQP0rq2W] 
```

Golang's `ParseForm()` method will ignore the request body, so you cannot get the username and password. The correct way to send form data with fetch is like this:

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
