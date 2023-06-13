---
title: Nodejs 安装与介绍
date: 2023-06-11 19:45:27
categories:
  - JavaScript
  - Nodejs
tags:
  - JavaScript
  - Nodejs
---

### 1. Intro

NodeJS 不是语言而是 Javascript 的运行环境, 所以就不能像研究语言那样的顺序去研究它了, 而是研究它是个啥:

> Node. js is not a programming language. Rather, it's a `runtime environment` that's used to run JavaScript outside the browser. For example on the `server` or in the `command line`.

突然想到之前学JS的时候记的一段话, 介绍 JS engine 的: 

> The use of JavaScript engines is not limited to browsers. For example, the **V8 engine is a `core component` of the [Node.js](https://www.webopedia.com/definitions/node-js/)**. V8 is the Javascript engine **inside of** node.js that parses and runs your Javascript. The same V8 engine is used **inside of** Chrome to run javascript in the Chrome browser. Both `chrome browser` and `node.js` have `v8` inside.

当时没看太懂, 但自己知道是因为对环境语言本身的理解不够, 现在再看, 总结的不错

### 2. npm

就像 pip 对于 Python, npm 对于 nodejs, 就大概这么个意思, packages manager, 

```shell
npm install <package-name>

pip install <package-name>
```

### 3. Install

在 [Download | Node.js](https://nodejs.org/en/download) 下载对应 OS 安装包, 安装的时候, 显示:

This package will install:

•	Node.js v16.17.0 to /usr/local/bin/node
•	npm v8.15.0 to /usr/local/bin/npm

可以看出此安装包包括 npm 和 nodejs, 安装完成后输入 `npm --version`, `node --version` 测试, 

在 IDEA 上怎么用 Nodejs 呢? 在 IDEA 下载个插件 Node.js, 然后创建 js 文件, 运行下面代码就可以了:

```js
const http = require('http');

const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
```

#### 4. Find More

A Node.js app runs in a `single process`, without creating a new thread for every request. Node.js provides a set of asynchronous I/O primitives in its standard library that prevent JavaScript code from blocking and generally, libraries in Node.js are written using non-blocking paradigms, making blocking behavior the exception rather than the norm.

参考:

- [About npm | npm Docs](https://docs.npmjs.com/about-npm)
- 很好的文档 https://nodejs.dev/en/learn/