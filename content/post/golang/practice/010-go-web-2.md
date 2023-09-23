---
title: Parse Form Data in Go Server
date: 2023-09-23 18:08:55
categories:
 - golang
 - practice
tags:
 - golang
---

## 1. `Content-Type` header

The `Content-Type` header can be `application/json`, `application/x-www-form-urlencoded`, `multipart/form-data`, the first two is usually used with posting form data to server, the third is used to upload file to the server.

- The format of `application/json` is `'{"username":"davidzhu", "password":"778899a"}'`. 

- The format of `application/x-www-form-urlencoded` is `"username=davidzhu&password=778899a" `. 

## 2. Parse query string and `x-www-form-urlencoded` data

In [previous post......................]() I have talked that query string and form data is treated as same thing when you call `r.ParseForm()` in Go, but there is a condition: the `Content-Type` header of the reuqest must be `application/x-www-form-urlencoded` and you have the correct format data in the request body. Otherwise, the request body will be ignored by `r.ParseForm()`, it just tries to parse query string resides in the URL. Talk is cheap let's show the codes, 

First, there is a simple handler which parses form data or query string:

```go
func handlePostForm(w http.ResponseWriter, r *http.Request) {
	// r.ParseForm() parses username and password in form or query string.
  // And puts the parsed data into r.Form which is a map value.
	if err := r.ParseForm(); err != nil {
		http.Error(w, fmt.Sprintf("failed to parse username and password: %v", err),
			http.StatusMethodNotAllowed)
		return
	}
	username := r.Form.Get("username")
	password := r.Form.Get("password")
	if username == "" || password == "" {
		http.Error(w, "failed to parse username and password: no username or password",
			http.StatusMethodNotAllowed)
		return
	}
	_, _ = fmt.Fprint(w, fmt.Sprintf("username:%v password:%v\n", username, password))
}

func main() {
	mux := http.NewServeMux()
  // Add pattern and its handdler into mux
	mux.HandleFunc("/postform", handlePostForm)
  // http.ListenAndServe will call mux.ServerHTTP(w, r)
	_ = http.ListenAndServe(":8080", mux)
}
```

And I 