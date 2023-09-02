---
title: ECMAScript vs JavaScript & CommonJS vs ES Modules
date: 2023-06-13 10:36:28
categories:
  - javascript
  - basics
tags:
  - javascript
---

## 1. ECMAScript vs JavaScript

**ECMAScript = ES:**

- ECMAScript is a Standard for scripting languages.
- Languages like Javascript are based on the ECMAScript standard.

**JavaScript = JS:**

- JavaScript is the most popular implementation of the ECMAScript Standard.
- The core features of Javascript are based on the ECMAScript standard, but Javascript also has other additional features that are not in the ECMA specifications/standard.
- Every browser has a JavaScript interpreter.

**ES5 = ECMAScript 5:**

- ES5 is a version of the ECMAScript. 
- ES5 does not require a build step (transpilers) to transform it into something that will run in today's browsers.
- ECMAScript version 5 was finished in December 2009, the latest versions of all major browsers (Chrome, Safari, Firefox, and IE) have implemented version 5.

**ES6 = ES2015:**

- ES2015 is a version of the ECMAScript (new/future one).
- Officially the name ES2015 should be used instead of ES6.
- There are quite a few transpilers that will export ES5 for running in browsers.

**TypeScript and CoffeeScript:**

- Both provides syntactic sugar on top of ES5 and then are transcompiled into ES5 compliant JavaScript. 
- You write TypeScript or CoffeeScript then the transpiler transforms it into ES5 JavaScript.

原文: https://stackoverflow.com/a/33748400/16317008

## 2. CommonJS vs ES Modules

**CommonJS** is an older module system for JavaScript that was designed for server-side JavaScript development with Node.js. 

```javascript
// my-module.js
module.exports = {
  myValue: 42
};

// main.js
const myModule = require('./my-module.js');
console.log(myModule.myValue); // 42
```

ES modules are a standardized module system for JavaScript that was introduced in ES6. It provides a way to organize and reuse code in a modular and maintainable manner. 

```javascript
// foo.js
function sayHello() {
    console.log('hello')
}

let a = 100

export {a, sayHello}

// main.js
import {a, sayHello} from "./foo";

console.log(a)
sayHello()
```

> As of right now ES6 import, export is [always compiled to CommonJS](https://babeljs.io/en/repl#?browsers=&build=&builtIns=false&spec=false&loose=false&code_lz=JYWwDg9gTgLgBAbzgCwKYBt0QIxwL5wBmUEIcA5AHQD0amE5AUIwMYQB2AzhOqpVgHMAFHSzYhASglwgA&debug=false&forceAllTransforms=false&shippedProposals=false&circleciRepo=&evaluate=false&fileSize=false&timeTravel=false&sourceType=module&lineWrap=true&presets=es2015%2Creact%2Cstage-2&prettier=false&targets=&version=7.8.4&externalPlugins=), so there is **no benefit** using one or other. Although usage of ES6 is recommended since it should be advantageous when native support from browsers released. The reason being, you can import partials from one file while with CommonJS you have to require all of the file. [source](https://stackoverflow.com/a/60331886/16317008)

### 2.1. Advantages of ES Modules over CommonJS

1. Static Analysis: ES modules are designed to be statically analyzable, while CommonJS modules are not. This means that the import and export statements can be analyzed at build time, enabling tools to optimize the code and generate smaller, more efficient bundles.
2. Native Support in Browsers: ES modules are natively supported in modern browsers, while CommonJS modules are not. This means that there's no need for additional build tools or plugins to use ES modules in the browser.
3. Better Performance: ES modules are designed to be loaded statically, while CommonJS modules are mainly loaded dynamically and synchronously. This can lead to slower performance and a blocking of the main thread. Static analysis refers to the process of analyzing code without executing it, and dynamic imports introduce runtime behavior into a module system. This means that the exact module that will be imported cannot be determined until the code is executed, making it difficult to analyze the module dependencies and relationships ahead of time (AOT).
4. Improved Code Organization: ES modules provide a way to specify the dependencies between different parts of your code, making it easier to understand and maintain your codebase.

原文: https://dev.to/costamatheus97/es-modules-and-commonjs-an-overview-1i4b

## 3. ES2015 New Features

- ECMAScript 2015 introduces two new ways of declaring variables: `let` and `const`. 

- Arrow Functions and Lexical `this`
- JavaScript Classes
- ECMAScript 2015 Promises

了解更多: [A Rundown of JavaScript 2015 features](https://auth0.com/blog/a-rundown-of-es6-features/)
