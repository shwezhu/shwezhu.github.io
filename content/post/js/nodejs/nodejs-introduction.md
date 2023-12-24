---
title: Nodejs Intro
date: 2023-06-11 19:45:27
categories:
  - javascript
  - nodejs
tags:
  - javascript
---

## 1. Intro

Node. js is not a programming language. Rather, it's a `runtime environment` that's used to run JavaScript outside the browser. For example on the `server` or in the `command line`.

Recall a paragraph which introduces js engine:

> The use of JavaScript engines is not limited to browsers. For example, the **V8 engine is a `core component` of the [Node.js](https://www.webopedia.com/definitions/node-js/)**. V8 is the Javascript engine **inside of** node.js that parses and runs your Javascript. The same V8 engine is used **inside of** Chrome to run javascript in the Chrome browser. Both `chrome browser` and `node.js` have `v8` inside.

> A Node.js app runs in a `single process`, without creating a new thread for every request. Node.js provides a set of asynchronous I/O primitives in its standard library that prevent JavaScript code from blocking and generally, libraries in Node.js are written using non-blocking paradigms, making blocking behavior the exception rather than the norm.

## 2. npm usage

`npm` is the package manager for JavaScript, commonly used with Node.js. It is widely used for **managing dependencies** in JavaScript projects and for **running scripts** defined in a project's `package.json` file.

`npm` is known for its robust handling of scripts and automation tasks. The `package.json` file in a Node.js project allows developers to define various scripts for tasks like building, testing, and deploying applications.

`pip`, by contrast, is more focused on the installation and management of Python packages. It doesn't inherently provide the same level of scripting and automation capabilities as npm does with Node.js.

```shell
npm init: This command initializes a new Node.js project. It creates a package.json file which holds various metadata relevant to the project.

npm install: This command is used to install dependencies listed in the package.json file. When used with the --save flag, it also updates the package.json file with the newly installed package.

npm install <package-name>: This command installs a specific package. For example, npm install express installs the Express framework.

npm install -g <package-name>: The -g flag installs the package globally, making it available as a command line tool.

npm uninstall <package-name>: This command removes a package from the node_modules directory and updates the package.json file.

npm update: This command updates the installed packages to their latest versions based on the version range specified in the package.json file.

npm list: This command displays a tree of every package installed in the current project.
```

## 3. Install

```shell
# which will insatll both nodejs and npm
brew install node
# uninstall
brew uninstall node
```

Another way: go to [Download | Node.js](https://nodejs.org/en/download), note that when you install, the install pragram will reminds you:

```
This package will install:
•	Node.js v16.17.0 to /usr/local/bin/node
•	npm v8.15.0 to /usr/local/bin/npm
```

```
npm -v
node -v

node -v: This command is used to print the version of Node.js that you’re currently using.
node xxx.js: This command is used to execute a JavaScript file named xxx.js in Node.js.
```

## 4. Install on IDEA

Go to Settings->Plugins,  search and install `Node.js`, then the code below will work fine:

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

References:

- [About npm | npm Docs](https://docs.npmjs.com/about-npm)
- https://nodejs.dev/en/learn/