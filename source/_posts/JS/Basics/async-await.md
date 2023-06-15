---
title: Async & Await Functions in JavaScript
date: 2023-06-14 16:36:29
categories:
  - JavaScript
  - Basics
tags:
  - JavaScript
---

**Async functions always return a promise**. If the return value of an async function is not explicitly a promise, it will be implicitly wrapped in a promise. **A Promise is an object** representing the eventual completion or failure of an asynchronous operation. 

```javascript
async function foo() {
  return 1;
}
// similar to:
function foo() {
  return Promise.resolve(1);
}
```





> **Note:** The `await` keyword is only valid inside `async` functions within regular JavaScript code. If you use it outside of an `async` function's body, you will get a SyntaxError. 





参考:

- [Using promises - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises)
- [async function - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)
- 