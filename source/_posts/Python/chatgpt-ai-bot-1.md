---
title: 利用ChatGPT接口实现一个AI Bot (一)
date: 2023-06-03 10:51:25
categories:
  - Python
tags:
  - Python
  - Practice
---

### 1. 基本使用

使用Openai提供的chatgpt API有两种方法, 直接朝`URL = "https://api.openai.com/v1/chat/completions"`发http请求:

```python
import requests

openai.api_key = "YOUR_API_KEY"
URL = "https://api.openai.com/v1/chat/completions"

payload = {
  "model": "gpt-3.5-turbo",
  "temperature" : 1.0,
  "messages" : [
    {"role": "system", "content": f"You are an assistant who tells any random and very short fun fact about this world."},
    {"role": "user", "content": f"Write a fun fact about programmers."},
    {"role": "assistant", "content": f"Programmers drink a lot of coffee!"},
    {"role": "user", "content": f"Write one related to the Python programming language."}
  ]
}

headers = {
  "Content-Type": "application/json",
  "Authorization": f"Bearer {openai.api_key}"
}

response = requests.post(URL, headers=headers, json=payload)
response = response.json()

print(response['choices'][0]['message']['content'])
```

另外一个使用官方提供的库, 我选择了第二个:

```shell
pip3 install openai
```

之后发送http请求就很简单:

```python
import openai

openai.api_key = "YOUR_API_KEY"

response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    temperature=1,
    max_tokens=1000,
    messages=[
        {"role": "user", "content": "Who won the 2018 FIFA world cup?"}
    ]
)

print(response['choices'][0]['message']['content'])
```

#### 1.1. 报错: urllib3 版本问题

导入openai包后运行, 报错:

```
ImportError: urllib3 v2.0 only supports OpenSSL 1.1.1+, currently the 'ssl' module is compiled with LibreSSL 2.8.3. See: https://github.com/urllib3/urllib3/issues/2168
```

信息量有点大, 一点一点分析, 

[urllib3](https://urllib3.readthedocs.io/en/stable/) 就是python用来发http请求的package, 即http客户端, 用法如下:

```python
>>> import urllib3
>>> resp = urllib3.request("GET", "https://httpbin.org/robots.txt")
>>> resp.status
200
>>> resp.data
b"User-agent: *\nDisallow: /deny\n"
```

[OpenSSL](https://www.openssl.org/) 就是用来加密通信的: for general-purpose cryptography and secure communication. 本来http是纯文本通信的, 之后有了https即你发送的数据都是被加密的, 





参考:

- [A Complete Guide to the ChatGPT API](https://www.makeuseof.com/chatgpt-api-complete-guide/?newsletter_popup=1)
- [Fixing ImportError: urllib3 v2.0 only supports OpenSSL 1.1.1+ | Level Up Coding](https://levelup.gitconnected.com/fixing-importerror-urllib3-v2-0-5fbfe8576957)
- [python - ImportError: urllib3 v2.0 only supports OpenSSL 1.1.1+, currently the 'ssl' module is compiled with LibreSSL 2.8.3 - Stack Overflow](https://stackoverflow.com/questions/76187256/importerror-urllib3-v2-0-only-supports-openssl-1-1-1-currently-the-ssl-modu)
- [OpenSSL](https://www.openssl.org/) 