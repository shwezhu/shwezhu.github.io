---
title: 利用Openai API实现自己的Chat AI Bot (一)
date: 2023-06-06 22:28:25
categories:
  - Python
tags:
  - Python
  - Practice
---

### 1. 任务类型

每次朝 ChatGPT 发送一个任务本质就是朝 openai 提供的 api endpoints 发送请求, 根据任务类型有多种不同的 api, 具体任务类型有:

- [Completions](https://platform.openai.com/docs/api-reference/completions): Given a prompt, the model will return one or more predicted completions. 

```shell
POST https://api.openai.com/v1/completions
```

- [Chat](https://platform.openai.com/docs/api-reference/chat): Given a list of messages describing a conversation, the model will return a response.

```shell
POST https://api.openai.com/v1/chat/completions
```

- [Images](https://platform.openai.com/docs/api-reference/images): Given a prompt and/or an input image, the model will generate a new image.

```shell
POST https://api.openai.com/v1/images/generations
```

如果想处理图片, 那就向 `https://api.openai.com/v1/images/generations` 发送 http 请求, 当然还要加上一些 parameters, 具体下面会介绍, 还有其它类型的任务具体可参照[官方文档](https://platform.openai.com/docs/api-reference), 

### 2. 不同的模型

不同的类型支持的模型不同, 常见的model如下: 

|                          | MODEL FAMILIES                                               | API ENDPOINT                               |
| :----------------------- | :----------------------------------------------------------- | :----------------------------------------- |
| Newer models (2023–)     | gpt-4, gpt-3.5-turbo                                         | https://api.openai.com/v1/chat/completions |
| Older models (2020–2022) | text-davinci-003, text-davinci-002, davinci, curie, babbage, ada | https://api.openai.com/v1/completions      |

想象不同的模型和任务类型的区别, 其实就是不同的任务类型对应不同的的 api endpoints, 如 [Chat](https://platform.openai.com/docs/api-reference/chat) 的 api endpoint 为 `https://api.openai.com/v1/chat/completions`, [Completions](https://platform.openai.com/docs/api-reference/completions) 的api endpoint为 `https://api.openai.com/v1/completions`, 然后不同的类型支持的模型不同, 前者 [Chat](https://platform.openai.com/docs/api-reference/chat) 支持 `gpt-4` 和 `gpt-3.5-turbo` , 后者 [Completions](https://platform.openai.com/docs/api-reference/completions)  支持 `text-davinci-003` , 

### 3. [Chat](https://platform.openai.com/docs/api-reference/chat) vs [Completions](https://platform.openai.com/docs/api-reference/completions) 模型用哪个?

当然是使用 Chat, 因为它支持 `gpt-4` 和 `gpt-3.5-turbo` model, 而 Completions 不支持, 它支持 `text-davinci-003` model, 

The difference between these APIs derives mainly from the underlying GPT models that are available in each. The **chat completions** API is the interface to our most capable model (`gpt-4`), and our most cost effective model (`gpt-3.5-turbo`). For reference, `gpt-3.5-turbo` performs at a similar capability level to `text-davinci-003` but at 10% the price per token! 

### 4. Request 参数

选择好任务类型了, 接下来就是发送 http 请求, 我们要向 ChatGPT 提供我们的问题吧, 怎么提供呢, 通过 http 请求参数, 接下来就介绍一下参数, 上面只是知道了不同的任务类型对应不同的 url, 仅仅发送 GET 请求还不行, 需要加一些必要的参数如max_token, key, 以及 prompt 或 message, 这也是最重要一个参数即我们的信息内容也就是我们的问题. 

对于上面的任务类型, 下文使用 Completions, 所以每次的 http 请求的 url 为: `https://api.openai.com/v1/completions`, 先介绍一下该任务类型的参数, 至于其它任务类型的参数[官方文档](https://platform.openai.com/docs/api-reference)都有介绍, 在这也不一一陈述, 

**`model`**: 必填参数, 即你使用哪个 model, 如是 gpt-3.5-turbo 还是 gpt-4, 关于 model 选择建议, 官方也有说: [which-model-should-i-us](https://platform.openai.com/docs/guides/gpt/which-model-should-i-use) 

**`prompt`**: 这个也是最重要的参数了, 就是我们的问题, 要求 GPT 做的事

**`max_tokens`**: 这个参数就涉及到开销💰了, 就是限制回答的 token size, 另外文档解释容易 confuse 的地方是 `prompt + maxt_token < context length`, 一般模型的 context length 是2048, 但新的貌似都是 4096 了, gpt-4 貌似更多, 即对一般的模型你的 prompt token size 加上参数 `max_tokens` 不可以超过 2048, 不仅疑问, 如果我们设置了更小的 `max_tokens`, 那 gpt 会不会每次回答都尝试用简短的内容来说, 这样肯定导致不好的效果, 测试了一下, 如果你设置了很小的 `max_tokens`, gpt 的回复会直接被 cut off, 并然后看到[论坛](https://community.openai.com/t/question-regarding-max-tokens/16259)也有人关注这个问题, 一个人的回答如下: I asked the support and they clarified that GPT-3 will **not** attempt to create shorter texts with a smaller `max_tokens` value. The text will indeed just be cut off. So in my case, I guess it makes sense to use a higher value to have more “wiggle room”.

**`temperature`**: 范围 0-2, Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.

**`user`**: A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse. [Learn more](https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids).

任务类型 Completions 的其它参数不一一介绍, 可以去文档查看, 下面举个完整请求的例子, 根据openai文档, Completions 的 http 请求格式如下(除了参数 `model` , 其它参数都可省略), 注意看目的 url, 别弄错了, 

```shell
curl https://api.openai.com/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "prompt": "Say this is a test",
    "max_tokens": 7,
    "temperature": 0
  }'
```

如果请求成功, 会返回一个包含回答的 json 对象, 用 python 实现 : 

```python
import requests

api_key = 'YOUR_API'
api_url = 'https://api.openai.com/v1/completions'

payload = {
    "model": "text-davinci-003",
    "temperature": 1.0,
    "prompt": "Hi, who are you"
}

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {api_key}"
}

response = requests.post(api_url, json=payload, headers=headers)

if response.ok:
    print(response.json())
else:
    print('Error:', response.status_code, response.text)
```

> 注意对于 [Completions](https://platform.openai.com/docs/api-reference/completions), 参数 `prompt` 是可选的即可有可无, 但若你要使用 [Chat](https://platform.openai.com/docs/api-reference/chat), 就需要使用参数 `message` 代替 `prompt` 来提供我们对GPT的问题, 且 `message` 不可省略, 关于参数 `message` 的介绍可参考 [Chat](https://platform.openai.com/docs/api-reference/chat) 的文档, 

还记得 Completions 和 Chat 是什么吗? 就是第一节介绍的不同类型的任务, 他们对应不同的 url, 对于 Chat, 请求格式如下, 其实格式并没变, 只是个别参数和目的 url 变了, 具体实现可参考上面 Completions 类型的实现, 

```shell
curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### 5. 使用 openai package 发送 http 请求

另外也可以使用官方提供的 Python 库发送 http 请求:

```shell
pip3 install openai
```

之后发送 http 就很简单:

```python
import openai

openai.api_key = "YOUR_API_KEY"
# 这里 openai.ChatCompletion 其实就是我们上面的任务类型选择, 显然这里选择的是 Chat, 
# 即目的 url 是 https://api.openai.com/v1/chat/completions
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

#### 5.1. 报错: urllib3 版本问题

导入openai包后运行, 报错:

```
ImportError: urllib3 v2.0 only supports OpenSSL 1.1.1+, currently the 'ssl' module is compiled with LibreSSL 2.8.3. See: https://github.com/urllib3/urllib3/issues/2168
```

一点一点分析, [urllib3](https://urllib3.readthedocs.io/en/stable/) 就是python用来发http请求的package, 即http客户端, 用法如下:

```python
>>> import urllib3
>>> resp = urllib3.request("GET", "https://httpbin.org/robots.txt")
>>> resp.status
200
>>> resp.data
b"User-agent: *\nDisallow: /deny\n"
```

关于此错误解决办法可参考: [HTTPS 连接过程分析以及 SSL 证书和 OpenSSL 介绍](https://davidzhu.xyz/2023/06/03/Other/ssl-secure-communication/)

### 6. 记住之前的聊天内容

http 无状态, openai 服务器那边也没在应用层实现维护状态的机制, 所以是无记忆的, 需要我们自己来维护聊天历史, 即每次把历史聊天记录发给 gpt, 才能实现 “记忆” 功能, 看到一个很好的例子, 具体过程如下:

第一次

```python
# Note: you need to be using OpenAI Python v0.27.0 for the code below to work
import openai

openai.ChatCompletion.create(
  model="gpt-3.5-turbo",
  messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello"},
    ]
)
```

第二次就要带着第一次的问题和回答, 当然这样也会用掉更多的 tokens, 啥你不知道tokens是啥? 是money 💰

```python
# Note: you need to be using OpenAI Python v0.27.0 for the code below to work
import openai

openai.ChatCompletion.create(
  model="gpt-3.5-turbo",
  messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello"},
        {"role": "assistant", "content": "Hello, how can I help you?"},
        {"role": "user", "content": "who is more stylish Pikachu or Neo"},
    ]
)
```

第三次:

```python
# Note: you need to be using OpenAI Python v0.27.0 for the code below to work
import openai

openai.ChatCompletion.create(
  model="gpt-3.5-turbo",
  messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello"},
        {"role": "assistant", "content": "Hello, how can I help you"},
        {"role": "user", "content": "What is more stylish Pikachu or Neo"},
        {"role": "assistant", "content": "Well Neo of course"},
        {"role": "user", "content": "Why?"},
    ]
)
```

参考:

- [A Complete Guide to the ChatGPT API](https://www.makeuseof.com/chatgpt-api-complete-guide/?newsletter_popup=1)
- [Fixing ImportError: urllib3 v2.0 only supports OpenSSL 1.1.1+ | Level Up Coding](https://levelup.gitconnected.com/fixing-importerror-urllib3-v2-0-5fbfe8576957)
- [python - ImportError: urllib3 v2.0 only supports OpenSSL 1.1.1+, currently the 'ssl' module is compiled with LibreSSL 2.8.3 - Stack Overflow](https://stackoverflow.com/questions/76187256/importerror-urllib3-v2-0-only-supports-openssl-1-1-1-currently-the-ssl-modu)
- [OpenAI ChatGPT (GPT-3.5) API error: "'messages' is a required property" when testing the API with Postman - Stack Overflow](https://stackoverflow.com/questions/75971578/openai-chatgpt-gpt-3-5-api-error-messages-is-a-required-property-when-tes)
- [GPT - OpenAI API](https://platform.openai.com/docs/guides/gpt/chat-completions-vs-completions)
- [GPT-3.5-turbo how to remember previous messages like Chat-GPT website - API - OpenAI Developer Forum](https://community.openai.com/t/gpt-3-5-turbo-how-to-remember-previous-messages-like-chat-gpt-website/170370/6)