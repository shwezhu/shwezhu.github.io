---
title: 通过 Cookie 实现有状态的 HTTP Session
date: 2023-06-23 22:51:35
categories:
  - Python
tags:
  - Python
  - Practice
---

## 1. HTTP Cookie

> An **HTTP cookie** (web cookie, browser cookie) is a small piece of data that a server sends to a user's web browser. The browser may store the cookie and send it back to the same server with later requests. Typically, an HTTP cookie is used to tell if two requests come from the same browser—keeping a user logged in, for example. It remembers stateful information for the [stateless](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview#http_is_stateless_but_not_sessionless) HTTP protocol. [Using HTTP cookies - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies)

注意上面说的是浏览器可以自动发送 cookie, 即并不需要我们写 js代码手动发送, 一般作为服务器返回 cookie 的时候会加上一个 expires time, 浏览器发送 http 请求的时候会根据这个 expire time 判断是否 cookie 还有效, 无效的不会发送, 此时你在服务器端获取 cookie 则为空, 具体服务端获取和返回 cookie 代码如下: 

```python
@app.route("/")
def index():
    session = request.cookies.get('session')
    print(session)
    if session is None:
        ...
    resp = make_response(render_template('index.html'))
    resp.set_cookie('session', session,
                    max_age=datetime.timedelta(minutes=2),
                    httponly=True)
    return resp
```

服务器返回的 Cookie 信息在 Response Header 里, 注意后面两字段 `HttpOnly;`, `Path=/`, 接下来会分别解释, 如下: 

![a](a.png)

> 首先要知道 cookie 是有 attributes 的, 主要有: `expires`, `max-age`, `path`, `domain`, 

注意 `Expires=Fri, 23 Jun 2023 22:57:38 GMT;`, 在失效时间前, 浏览器向服务器发送 http request 的时候, 会自动带上该 cookie, 这些操作都是浏览器自动完成的, 

### 1.1. Path Attribute

The `Path` attribute indicates a URL path that must exist in the requested URL in order to send the `Cookie` header. 

For example, if you set `Path=/docs`, these request paths match:

- `/docs`
- `/docs/`
- `/docs/Web/`
- `/docs/Web/HTTP`

But these request paths don't:

- `/`
- `/docsets`
- `/fr/docs`

上面 Python 代码中我们没有设置 cookie 的 path 属性, 如图中所示, 默认为 `/`, 即作用域在整个网页, 即我们访问任何子目录时浏览器都会带上该cookie, 意思就是说客户端已经获得了 cookie, 该 cookie 的 ptah 为 `/`, 若接下来向着`/v1/completion` 发送 post 或 get 请求, 那浏览器依然会自动带上该 cookie, 我们可以直接在 python 服务端通过 `session = request.cookies.get('session')` 类似代码获得 cookie, 所以传递 cookie 只需要我们在服务端进行返回处理, 并不需要在客户端做任何事, 

> 刚开始一直尝试用 js 获取cookie, 然后想着在用`fetch()` 发送 http 请求的时候加上 cookie, 殊不知, 人家 browser 会自动发送回 cookie!!!

看到一个很好的例子, 

Path属性可以为服务器特定文档指定Cookie，这个属性设置的url且带有这个前缀的url路径都是有效的。

例如：[http://m.zhuanzhuan.58.com](https://link.zhihu.com/?target=http%3A//m.zhuanzhuan.58.com) 和 [http://m.zhaunzhuan.58.com/user/](https://link.zhihu.com/?target=http%3A//m.zhaunzhuan.58.com/user/)这两个url。 [http://m.zhuanzhuan.58.com](https://link.zhihu.com/?target=http%3A//m.zhuanzhuan.58.com) 设置cookie

```js
Set-cookie: id="123432";domain="m.zhuanzhuan.58.com"; 
```

[http://m.zhaunzhuan.58.com/user/](https://link.zhihu.com/?target=http%3A//m.zhaunzhuan.58.com/user/) 设置cookie：

```js
Set-cookie：user="wang", domain="m.zhuanzhuan.58.com"; path=/user/ 
```

但是访问其他路径[http://m.zhuanzhuan.58.com/other/](https://link.zhihu.com/?target=http%3A//m.zhuanzhuan.58.com/other/)就会获得

```js
 cookie: id="123432" 
```

如果访问[http://m.zhuanzhuan.58.com/user/](https://link.zhihu.com/?target=http%3A//m.zhuanzhuan.58.com/user/)就会获得

```js
 cookie: id="123432"
 cookie: user="wang" 
```

### 1.2. Expire Attribute

服务端部分代码:

```python
session = request.cookies.get('session')
```

`session = None`, 一直以为是服务器无法获取到客户端传来的 cookie, 其实是因时区问题导致的 cookie “提前过期”, 客户端在发送http请求时直接丢弃 cookie 所导致的, 关于时区问题即浏览器时间比本地时间早了几个小时, 然后每次的cookie expiry time都是设置的两分钟, 这就导致每次发送请求的时候浏览器检查cookie发现过期, 直接丢弃, 

![b](b.png)

可能会好奇, 为什么浏览器使用 Date: Tue, 20 Jun 2023 01:18:03 GMT, 即GMT时区而不是本地时区呢?

From [RFC2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html) we got the so called *HTTP format*:

> All HTTP date/time stamps MUST be represented in Greenwich Mean Time (GMT), without exception. For the purposes of HTTP, GMT is exactly equal to UTC (Coordinated Universal Time). https://stackoverflow.com/a/35729939/16317008

这就要解决一个问题, 服务器与客户端不同时区, 怎么设置expire时间呢? 因为我的服务器代码用的是:

```
expires=datetime.datetime.now()+ datetime.timedelta(minutes=2)
```

这获取的是服务器的时间, 但若客户端所在位置不同时区, 那肯定这个expiry时间是不对的,

解决办法是使用相对时间, 或者再发送expiry时间时先把其转为 GMT格式,

在flask中使用前者, 我们在本地时间Jun 19, 22:30 发送http请求, 可以看到expiry时间以正确改正为GMT, 

```
Date: Tue, 20 Jun 2023 01:30:44 GMT
Server: Werkzeug/2.3.6 Python/3.9.6
Set-Cookie: session=1038b6460; Expires=Tue, 20 Jun 2023 01:32:44 GMT; Max-Age=120; HttpOnly; Path=/
```

flask代码, 不要使用`expires` 参数:

```
resp.set_cookie('session', session,
                    max_age=datetime.timedelta(minutes=2),
                    httponly=True)
```

然后等两分钟后重新发送http请求, 原cookie将会被浏览器自动丢弃, 服务器端自然无法获得, 即再新建session, 

### 1.3. Security: HttpOnly Cookie

An **HttpOnly Cookie** is a tag added to a browser cookie that prevents client-side scripts from accessing data. It provides a gate that prevents the specialized cookie from being accessed by anything other than the server. Using the HttpOnly tag when generating a cookie helps mitigate the risk of client-side scripts accessing the protected cookie, thus making these cookies more secure. 

参考:

- [What is an HttpOnly Cookie? - Knowledge Base | CookiePro](https://www.cookiepro.com/knowledge/httponly-cookie/)
- [Using HTTP cookies - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies)
- [这一次带你彻底了解Cookie - 知乎](https://zhuanlan.zhihu.com/p/31852168)