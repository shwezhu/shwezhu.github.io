---
title: ECMAScript vs JavaScript & CommonJS vs ES Modules
date: 2023-06-13 10:36:28
categories:
  - JavaScript
  - Basics
tags:
  - JavaScript
---

## ECMAScript vs JavaScript

**ECMAScript = ES:**

- ECMAScript is a Standard for scripting languages.
- Languages like Javascript are based on the ECMAScript standard.
- ECMA Standard is based on several originating technologies, the most well known being JavaScript (Netscape) and JScript (Microsoft).
- ECMA means European Computer Manufacturer’s Association

**JavaScript = JS:**

- JavaScript is the most popular implementation of the ECMAScript Standard.
- The core features of Javascript are based on the ECMAScript standard, but Javascript also has other additional features that are not in the ECMA specifications/standard.
- ActionScript and JScript are other languages that implement the ECMAScript.
- JavaScript was submitted to ECMA for standardization but due to trademark issues with the name Javascript the standard became called ECMAScript.
- Every browser has a JavaScript interpreter.

**ES5 = ECMAScript 5:**

- ES5 is a version of the ECMAScript (old/current one).
- ES5 is the JavaScript you know and use in the browser today.
- ES5 does not require a build step (transpilers) to transform it into something that will run in today's browsers.
- ECMAScript version 5 was finished in December 2009, the latest versions of all major browsers (Chrome, Safari, Firefox, and IE) have implemented version 5.
- Version 5.1 was finished in June, 2011.

**ES6 = ECMAScript 6 = ES2015 = ECMAScript 2015:**

- ES2015 is a version of the ECMAScript (new/future one).
- Officially the name ES2015 should be used instead of ES6.
- ES6 will tackle many of the core language shortcomings addressed in TypeScript and CoffeeScript.
- ES6 is the next iteration of JavaScript, but it does not run in today's browsers.
- There are quite a few transpilers that will export ES5 for running in browsers.

**BabelJS:**

- BabelJS is the most popular transpiler that transforms new JavaScript ES6 to Old JavaScript ES5.
- BabelJS makes it possible for writing the next generation of JavaScript today (means ES2015).
- BabelJS simply takes ES2015 file and transform it into ES5 file.
- Current browsers versions can now understand the new JavaScript code (ES2015), even if they don't yet support it.

**TypeScript and CoffeeScript:**

- Both provides syntactic sugar on top of ES5 and then are transcompiled into ES5 compliant JavaScript. 
- You write TypeScript or CoffeeScript then the transpiler transforms it into ES5 JavaScript.

原文: https://stackoverflow.com/a/33748400/16317008

## CommonJS vs ES Modules

**CommonJS** is an older module system for JavaScript that was designed for server-side JavaScript development with Node.js. It was later adopted by the front-end community as well (this way you don't need a gazillion script tags in your HTML). 

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
// my-module.js
export const myValue = 42;

// main.js
import { myValue } from './my-module.js';
console.log(myValue); // 42
```

### Advantages of ES Modules over CommonJS

1. Static Analysis: ES modules are designed to be statically analyzable, while CommonJS modules are not. This means that the import and export statements can be analyzed at build time, enabling tools to optimize the code and generate smaller, more efficient bundles.
2. Native Support in Browsers: ES modules are natively supported in modern browsers, while CommonJS modules are not. This means that there's no need for additional build tools or plugins to use ES modules in the browser.
3. Better Performance: ES modules are designed to be loaded statically, while CommonJS modules are mainly loaded dynamically and synchronously. This can lead to slower performance and a blocking of the main thread. Static analysis refers to the process of analyzing code without executing it, and dynamic imports introduce runtime behavior into a module system. This means that the exact module that will be imported cannot be determined until the code is executed, making it difficult to analyze the module dependencies and relationships ahead of time (AOT).
4. Improved Code Organization: ES modules provide a way to specify the dependencies between different parts of your code, making it easier to understand and maintain your codebase.

原文: https://dev.to/costamatheus97/es-modules-and-commonjs-an-overview-1i4b