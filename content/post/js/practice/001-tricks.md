---
title: Tricks in Javascript
date: 2023-10-28 22:54:02
categories:
  - javascript
  - practice
tags:
  - javascript
---

### 1. click copy

```html
<p id="url-text" style="display: none">{{.SharedUrl}}</p>
<button onclick="copyText()">share</button>

<script>
    function copyText() {
        const copyText = document.getElementById("url-text");
        navigator.clipboard.writeText(copyText.textContent)
            .then(() => {
                alert("successfully copied");
            })
            .catch(() => {
                alert("something went wrong");
            });
    }
</script>
```

### 2. `preventDefault()`

`event.preventDefault()` basically prevents event to fire. In the case of `submit` event. `event.preventDefault()` will prevent your form to submit. We normally prevent `submit` behaviour to check some validation before submitting the form or we need to change values of our input fields or we want to submit using `ajax` calls. For this purpose, we prevent form to be submitted by using `event.preventDefault()`. 

Learn more: [preventDefault() Event Method](https://www.w3schools.com/jsref/event_preventdefault.asp)

### 3. Relative path

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

### 4. Send username and password form

Traditional way to submit a form:

```html
<form action="/login">
  <input type="text" name="name">
  <input type="password" name="psaaword">
  <input type="submit" value="Submit">
</form> 
```

The form data will be sent to `/login` page of the server automatically. 

However, sometimes we need get the status code from the server or validate the legality of the input, which means we cannot use the form directly, **we need to make a ajax request** with js code.

After check the input, you may make ajax with `fetch()` to send form data:

```js
let data = new FormData(document.getElementById("login-form"))
...
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

This is not correct, and you will get error on the server side, the suggestion to get a correct request body is to not set header explictly:

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

> Note that if you don't set `Content-Type` header explicitly, the browser will set Content-Type header to `multipart/form-data` automatically. 

#### 4.1. Special situation in Go

If your server written in Go, you may parse form like this:

```go
if e := r.ParseForm(); err != nil {
  err = fmt.Errorf("failed to parse username and password: %v", e)
  return
}
username = r.Form.Get("username")
password = r.Form.Get("password")
```

According to [Golang docs](https://pkg.go.dev/net/http#Request.ParseForm) for `ParseForm() `: 

> For other HTTP methods, or when the Content-Type **is not** application/x-www-form-urlencoded, the request Body is not read. 

Therefore, `ParseForm()` method will ignore the request body, which means you cannot get the username and password. The `URLSearchParams()` in JS can help:

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

> The **`FormData`** interface provides a way to easily construct a set of key/value pairs representing form fields and their values, which can then be easily sent using the `XMLHttpRequest.send()` method. **It uses the same format a form would use if the encoding type were set to `"multipart/form-data"`**.

So when using `FormData` you are locking yourself into `multipart/form-data`. There is no way to send a `FormData` object as the body and *not* sending data in the `multipart/form-data` format.

If you want to send the data as `application/x-www-form-urlencoded` you will either have to specify the body as an URL-encoded string, or pass a [`URLSearchParams`](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams) object. 