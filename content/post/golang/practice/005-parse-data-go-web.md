---
title: Parse Form Data in Go Server
date: 2023-09-23 18:08:55
categories:
 - golang
 - practice
tags:
 - golang
 - http
---

## 1. Parse query string and `x-www-form-urlencoded` data

```go
if e := r.ParseForm(); err != nil {
  err = fmt.Errorf("failed to parse username and password: %v", e)
  return
}
username = r.Form.Get("username")
password = r.Form.Get("password")
```

According to  [Golang docs](https://pkg.go.dev/net/http#Request.ParseForm), `r.ParseForm()` will try to parse both query string and request body in Go, but there is a condition: the `Content-Type` header of the reuqest must be `application/x-www-form-urlencoded`. Otherwise, the request body will be ignored by `r.ParseForm()`, it just tries to parse query string resides in the URL. 

> If you don't know query string or `application/x-www-form-urlencoded`: 

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

And the request below will get same result:

```shell
$ curl -X POST "localhost:8080/postform?username=david&password=778899a"
$ curl -X POST localhost:8080/postform -d "username=davidzhu&password=778899a"
```

But the code below won't work, because the `Content-Type` header is not `application/x-www-form-urlencoded`:

```shell
$ curl -X POST localhost:8080/postform 
	-d "username=davidzhu&password=778899a" 
	-H "Content-Type: application/json"
	
failed to parse username and password: no username or password
```

## 3. Parse json data from request body

The handler should be like this:

```go
func handlePostBody(w http.ResponseWriter, r *http.Request) {
	// Parse username and password in form.
	type info struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}
	user := info{}
  // note that r.Body is an io.Reader
  // which means decoder.Decode() method will consume data stroed in r.Body
  // you cannot read same data twice
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&user)
	if err != nil {
		http.Error(w, fmt.Sprintf("failed to decode post body:%v", err),
			http.StatusMethodNotAllowed)
	}
	_, _ = fmt.Fprint(w, fmt.Sprintf("username:%v password:%v\n", user.Username, user.Password))
}
```

The command below won't work:

```shell
$ curl -X POST localhost:8080/postbody 
	-d "username=davidzhu&password=778899a" 
	-H "Content-Type: application/json"
failed to decode post body:invalid character 'u' looking for beginning of value
username: password:
```

Because the data format isn't correct, this will work:

```shell
$ curl localhost:8080/postbody -d '{"username":"davidzhu", "password":"778899a"}' 
```

### 4. Notes



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
