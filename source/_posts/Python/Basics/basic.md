---
title: Python 基础
date: 2023-06-17 22:51:31
categories:
  - Python
tags:
  - Python
---

关于dict

```python
dict = {'a': 1}

# This will raise a KeyError
print(dict['b'])

# Using .get() with a default value 
print(dict.get('b', 0)) # Prints 0
```



An **HTTP cookie** (web cookie, browser cookie) is a small piece of data that a server sends to a user's web browser. The browser may store the cookie and send it back to the same server with later requests. Typically, an HTTP cookie is used to tell if two requests come from the same browser—keeping a user logged in, for example. It remembers stateful information for the [stateless](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview#http_is_stateless_but_not_sessionless) HTTP protocol. [Using HTTP cookies - HTTP | MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies)

[Get and set cookies with Flask - Python Tutorial](https://pythonbasics.org/flask-cookies/)



```shell
curl -i -X GET http://rest-api.io/items
curl -i -X GET http://rest-api.io/items/5069b47aa892630aae059584
curl -i -X DELETE http://rest-api.io/items/5069b47aa892630aae059584
curl -i -X POST -H 'Content-Type: application/json' -d '{"name": "New item", "year": "2009"}' http://rest-api.io/items
curl -i -X PUT -H 'Content-Type: application/json' -d '{"name": "Updated item", "year": "2010"}' http://rest-api.io/items/5069b47aa892630aae059584
```



**HttpOnly Cookie** 

https://security.stackexchange.com/questions/186441/any-reason-not-to-set-all-cookies-to-use-httponly-and-secure

https://www.cookiepro.com/knowledge/httponly-cookie/

https://stackoverflow.com/questions/8064318/how-to-read-a-httponly-cookie-using-javascript

**set_cookie**(*key*, *value=''*, *max_age=None*, *expires=None*, *path='/'*, *domain=None*, *secure=False*, *httponly=False*, *samesite=None*)

https://flask.palletsprojects.com/en/2.0.x/api/#:~:text=is%20timezone%2Daware.-,set_cookie,-(key%2C

1. The cookies are scoped to a different path. Cookies have a path attribute that specifies which URLs they apply to. If the cookies are scoped to a different path, document.cookie will not see them.



一直尝试用 js 获取cookie, 殊不知, 人家 browser 会自动发送回 cookie!!!!



```js
    function getCookie(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2)
            return parts.pop().split(';').shift();
        else
            return null;
    }
```

一直无法返回cookie, 是因时区问题, 即浏览器时间比本地时间早了几个小时, 然后每次的cookie expiry time都是设置的两分钟, 这就导致每次发送请求的时候浏览器检查cookie发现过期, 直接丢弃, 

你可能会好奇, 为什么浏览器使用 Date: Tue, 20 Jun 2023 01:18:03 GMT, 即GMT时区而不是本地时区呢?

From [RFC2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html) we got the so called *HTTP format*:

> All HTTP date/time stamps MUST be represented in Greenwich Mean Time (GMT), without exception. For the purposes of HTTP, GMT is exactly equal to UTC (Coordinated Universal Time). https://stackoverflow.com/a/35729939/16317008

当然服务器也要维护一个对应的数据结构, 以防止浏览器没有丢弃cookie, 

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

