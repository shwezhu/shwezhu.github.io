---
title: ECMAScript vs JavaScript
date: 2023-06-13 10:36:28
categories:
  - JavaScript
  - Basics
tags:
  - JavaScript
---

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