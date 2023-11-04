---
title: HTTP Messages
date: 2023-09-23 09:51:30
categories:
 - http
tags:
 - http
typora-root-url: ../../../static
---

## 1. Intro of HTTP messages

There are two types of messages: ***requests*** sent by the client to trigger an action on the server, and ***responses***, the answer from the server.

HTTP requests, and responses, share similar structure and are composed of:

1. A `start-line` describing the requests to be implemented, or its status of whether successful or a failure. This start-line is always a single line.
2. An optional set of `HTTP headers` specifying the request, or describing the body included in the message.
3. A `blank line` indicating all meta-information for the request has been sent.
4. An optional `body` containing data associated with the request (like content of an HTML form), or the document associated with a response. The presence of the body and its size is specified by the start-line and HTTP headers.

![aa](/004-http-messages/aa.png)

The `start-line` and `HTTP headers` of the HTTP message are collectively known as the ***head*** of the requests, whereas its `payload` is known as the ***body***.

## 2. HTTP Requests

### 2.1. Start line

A start line contains three parts:

- Their *start-line* contain three elements:
  - An HTTP method, a verb (like `GET`, `PUT` or `POST`) or a noun (like HEAD or OPTIONS), that describes the action to be performed. 

- The *request target* 
  - Usually a URL
  - Sometimes url followed by a `'?'` and **query string**: `http://example.com/?bar1=a&bar2=b`

- The *HTTP version*

```
POST www.example.com/test.html?username=alibaba HTTP/1.1
```

### 2.2. Headers

An HTTP header consists of its case-insensitive name followed by a colon (`:`), then by its value. Whitespace before the value is ignored. This is an HTTP header:

```
Content-Type: text/html; charset=utf-8
```

Usually, a request or response consist of many headers:

```
GET /home.html HTTP/1.1
Host: developer.mozilla.org
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:50.0) Gecko/20100101 Firefox/50.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Referer: https://developer.mozilla.org/testpage.html
Connection: keep-alive
```

As you can see above, there are 7 headers in this request, a header like a key-value string, **different header usually has different syntax and its own type**. For example:

The type of [`Accept header`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept) is a [ Request header](https://developer.mozilla.org/en-US/docs/Glossary/Request_header), and its syntax is below:

``` 
Accept: <MIME_type>/<MIME_subtype>
Accept: <MIME_type>/*
Accept: */*

// Multiple types, weighted with the quality value syntax:
Accept: text/html, application/xhtml+xml, application/xml;q=0.9, image/webp, */*;q=0.8
```

The type of  [`Content-Type header`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type) is [Representation header](https://developer.mozilla.org/en-US/docs/Glossary/Representation_header), and its syntax:

```
Content-Type: text/html; charset=utf-8
Content-Type: multipart/form-data; boundary=something
```

The offcial way to indicate aobve is:

Many different headers can appear in an HTTP request. They can be divided in several groups:

- [General headers](https://developer.mozilla.org/en-US/docs/Glossary/General_header), like [`Via`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Via), apply to the message as a whole.
- [Request headers](https://developer.mozilla.org/en-US/docs/Glossary/Request_header), like [`User-Agent`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent) or [`Accept`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept), modify the request by specifying it further (like [`Accept-Language`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Language)), by giving context (like [`Referer`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referer)), or by conditionally restricting it (like [`If-None`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None)).
- [Representation headers](https://developer.mozilla.org/en-US/docs/Glossary/Representation_header) like [`Content-Type`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type) that describe the original format of the message data and any encoding applied (only present if the message has a body).

![a](/004-http-messages/a1.png)

### 2.3. Body

The final part of the request is its body. Not all requests have one: requests fetching resources, like `GET`, `HEAD`, `DELETE`, or `OPTIONS`, usually don't need one. Some requests send data to the server in order to update it: as often the case with `POST` requests (containing HTML form data).

Bodies can be broadly divided into two categories:

- Single-resource bodies, consisting of one single file, defined by the two headers: [`Content-Type`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type) and [`Content-Length`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Length).
- [Multiple-resource bodies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#multipartform-data), consisting of a multipart body, each containing a different bit of information. This is typically associated with [HTML Forms](https://developer.mozilla.org/en-US/docs/Learn/Forms).

## 3. HTTP Responses

HTTP Reponse also contains three parts:

- Status line
  -  Three part:  *protocol version*, a *status code*, a *status text* (A brief, purely informational, textual description of the status code to help a human understand the HTTP message.)
  - `HTTP/1.1 404 Not Found`

- Headers
  - Same as http request.

- Body
  - Same as http request.

Reference: [HTTP Messages - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages)

## 2. Form data vs query string

### 2.1. Client side

Query string resides in the url:

```
http://www.blabla.com?a=1&b=2
```

Form data is sent with the request body. Therefore, when there is sensitive data, we usually put data in the form not the query string. Because the requested URL might show up in **Web server logs** and **browser history/bookmarks** which is not a good thing. [source](https://stackoverflow.com/a/830092/16317008)

### 2.2. Server side

#### 2.2.1. Go web

For all requests, `ParseForm()` parses the **raw query** from the URL and updates r.Form. For POST, PUT, and PATCH requests, **it also reads the request body**, parses it as a form and puts the results into both r.PostForm and r.Form. When the `Content-Type` is not application/x-www-form-urlencoded, the request Body is not read. 

Learn more: [Some HTTP Issues with Go - David's Blog](https://davidzhu.xyz/post/golang/practice/012-http-related/#4-parse-form-and-query-string)

#### 2.2.2. Spring web

If your server is wiritten in Java Spring, and you need to POST form data to the server, you need to set your `Content-Type` header of your request to `application/json`. 

When we write test we usually use `curl` command, looks like this:

```shell
$ curl localhost:8080/hello -d '{"username":"davidzhu", "password":"778899a"}'
```

However, this command with `-d` option will set `Content-Type` header to `application/x-www-form-urlencoded`  by default, which is not accepted on Spring's side.

Therefore you have to set `Content-Type` explicitly:

```shell
$ curl localhost:8080/postbody 
		-d '{"username":"davidzhu", "password":"778899a"}' 
		-H "Content-Type: application/json"
```

Note the format of the `-d` is josn format not url query string format: `"username=davidzhu&password=778899a"`, this format is `application/x-www-form-urlencoded`, not `application/json`. 

Source: https://stackoverflow.com/a/7173011/16317008

Learn more about curl post: https://reqbin.com/req/c-dwjszac0/curl-post-json-example

## 3. POST data

The **HTTP `POST` method** sends data to the server. The type of the body of the request is indicated by the [`Content-Type`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type) header.

A `POST` request is typically sent via an [HTML form](https://developer.mozilla.org/en-US/docs/Learn/Forms) and results in a change on the server. In this case, the content type is selected by putting the adequate string in the [`enctype`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form#enctype) attribute of the [`form`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form)  element or the [`formenctype`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#formenctype) attribute of the [`input`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input) or [`button`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button) elements:

- `application/x-www-form-urlencoded`: the keys and values are encoded in key-value tuples separated by `'&'`, with a `'='` between the key and the value. 
- `multipart/form-data`: each value is sent as a block of data ("body part"), with a user agent-defined delimiter ("boundary") separating each part. The keys are given in the `Content-Disposition` header of each part.
- `text/plain`

![a](/004-http-messages/a.png)

Source: https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST

### 3.1. Example in real code

Let's say I have a html code like this:

```html
<form action="http://localhost:8080/postform" method="post" class="form-example">
    <div class="form-example">
        <label for="username">username</label>
        <input type="text" name="usernam" id="username" required />
    </div>
    <div class="form-example">
        <label for="password">password</label>
        <input type="password" name="passwor" id="password" required />
    </div>
    <div class="form-example">
        <input type="submit" value="register" />
    </div>
</form>
```

And when I push the regiser buttion to submit the form, the http request looks like this:

![c](/004-http-messages/c.png)

![d](/004-http-messages/d.png)

As you can see the form data resides in the request body, not in the URL.  

Sometimes when you put data in the URL as a query string **or** put data in the form, and make a POST request, these two cases may result same thing (the server will get same data), which gives you a wrong impression that form data wil be put into URL too. 

Looks like this:

```shell
$ curl -X POST localhost:8080/postform -d "username=davidzhu&password=778899a" 
$ curl -X POST "localhost:8080/postform?username=david&password=778899a"
```

The server may get same data for these two command, this is because the server may try to parse the query string and form data at the same time, we have talked this above in Go web. 

## 4. Form data restriction

As we talk above, form data can only be these three type by by default:`application/x-www-form-urlencoded`, `multipart/form-data`, `text/plain`, and you have to set the `Content-Type` to the corresponding type with correct format. 

If you want `application/json` type, you need encode the form data into josn at client and decode the request body at server side. Besides, don't forget to set the `Content-Type` header to `application/json` which will tell the server the data format resides in the request body. 

[An answer](https://stackoverflow.com/a/22195153/16317008) from stackoverflow, hope it will help:

HTML provides no way to generate JSON from form data. If you really want to handle it from the client, then you would have to resort to using JavaScript to:

1. gather your data from the form via DOM
2. organise it in an object or array
3. generate JSON with [JSON.stringify](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify)
4. POST it with [XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Using_XMLHttpRequest)

You'd probably be better off sticking to `application/x-www-form-urlencoded` data and processing that on the server instead of JSON. Your form doesn't have any complicated hierarchy that would benefit from a JSON data structure.

This is same in Go, if you want send json data in the request body, you should encode it into bytes and decode request body at server:

client:

```go
// string in back quote is raw string which means
// the double quote here will lose its special meaning
// decode the json string into 
reader_json := strings.NewReader(`{"username": "david", "password": "my_password"}`)
r, _ := http.NewRequest(http.MethodPost, "/postbody", reader_json)
r.Header.Set("Content-Type", "application/json")
...
```

server:

```go
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
print(user.password)
print(user.username)
```
