---
title: A File Station - Go
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

#### 4. Relative path

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

