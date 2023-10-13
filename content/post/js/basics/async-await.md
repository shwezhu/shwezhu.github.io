---
title: Promise Object in Javascript
date: 2023-10-13 11:26:29
categories:
  - javascript
  - basics
tags:
  - javascript
---

## 1. Concurrency models

- Processes
- ﻿﻿Threads (system or green)
- ﻿﻿**Futures**
- ﻿﻿Coroutines
- ﻿﻿CSP
- ﻿﻿Actor

Learn more: [java - What's the difference between a Future and a Promise? - Stack Overflow](https://stackoverflow.com/questions/14541975/whats-the-difference-between-a-future-and-a-promise)

## 2. Promise

Essentially, a promise is a returned object to which you attach callbacks, instead of passing callbacks into a function. 

 Imagine a function, `createAudioFileAsync()`, which asynchronously generates a sound file given a configuration record and two callback functions: one called if the audio file is successfully created, and the other called if an error occurs.

Here's some code that uses `createAudioFileAsync()`:

```js
function successCallback(result) {
  console.log(`Audio file ready at URL: ${result}`);
}

function failureCallback(error) {
  console.error(`Error generating audio file: ${error}`);
}

createAudioFileAsync(audioSettings, successCallback, failureCallback);
```

If `createAudioFileAsync()` were rewritten to return a promise, you would attach your callbacks to it instead:

JSCopy to Clipboard

```js
createAudioFileAsync(audioSettings).then(successCallback, failureCallback);
```

## 3. Create a promise object

You can create a promise using the promise constructor like this:

```js
let promise = new Promise(function(resolve, reject) {    
    // Make an asynchronous call and either resolve or reject
});
```

The **`Promise`** object represents the eventual completion (or failure) of an asynchronous operation and its resulting value.

A promise in JavaScript is an object that may **produce** a single value in the future: either a resolved value, or a reason that it's not resolved (e.g., a network error occurred). It will be in one of 3 possible states: 

- **Fulfilled:** e.g., `resolve()` was called
- **Rejected:** e.g., `reject()` was called
- **Pending:** not yet fulfilled or rejected

The *eventual state* of a pending promise can either be *fulfilled* with a value or *rejected* with a reason (error). When either of these options occur, the associated handlers queued up by a promise's `then` method are called. 

**e.g.,** 

```js
const fs = require('fs');

// Returns a promise
function readFileAsync(filePath) {
  return new Promise((resolve, reject) => {
    fs.promises.readFile(filePath, 'utf-8')
      .then(data => {
        resolve(data); // Resolve the Promise with the file data
      })
      .catch(error => {
        reject(error); // Reject the Promise if there's an error
      });
  });
}

// Attach callbacks to the returned promise object with its 'then()' function
readFileAsync('./book.txt')
  .then(data => {
    console.log('File content:', data);
  })
  .catch(error => {
    console.error('Error reading the file:', error);
  });
```

The Promise object knows when to call the `.then()` method (which contains `console.log('File content:', data);`) or the `.catch()` method (which contains `console.error('Error reading the file:', error);`) based on how the Promise is resolved or rejected.

## 4. async & await 

知道了什么是 Promise 对象后, 再来看异步函数, 

```javascript
fetch('https://example.com').then((response) => {
    return response.text()
}).then((text) => {
    console.log(text)
})
```

这里注意 callback 参数名字可以随意取, 之所以第一个 callback 的参数叫 `response` 是因为 `fetch()` 返回的是一个 promise 对象, 该 promise 的值是一个 Response 对象, 至于第二个 callback 也是, 叫 `text` 的原因是 Response 对象的 `text()` 函数返回一个值为字符串的 promise 对象, 因为 `fetch()` 和 `response.text()` 都返回一个 promise 对象, 所以我们才可以连续调用 `then()`, 别忘了 `then()` 是promise 对象的函数, 如果不考虑 readability 我们可以改成如下:

```javascript
fetch('https://example.com').then((value) => {
    return value.text()
}).then((value) => {
    console.log(value)
})
```

又因为 arrow function的特性, 即不用 `{}` 包裹函数体, 则默认返回第一行代码, 即

```javascript
() => 'hello world'
// 等价于
() => {
  return 'hello world'
}
```

所以上面代码又可以简写为:

```javascript
fetch('https://example.com')
    .then((response) => response.text())
    .then((text) => console.log(text))
```

注意以下两点: 

- 每个 Promise 对象都有一个 `then()` 和 `catch()` 方法, 
- 每个异步函数都会返回一个 promise,  explicitly or implicitly, 

所以上面我们可以写成 `fetch().then(...)` 的原因是 `fetch()` 是个异步函数, 所以它也会返回一个 promise 对象, 因此 `fetch()` 后面的`.then()` 调用的其实是 `fetch()` 所返回的 promise 对象的 `then()` 函数,  

另外需要注意的是, 调用 `fetch()` 后, `fetch()` **立即**就返回了个 promise 对象, 只是这时该 promise 对象的状态为 pending, 当 `fetch()` 的操作完成, 即当 `resolve()` 或 `reject()` 被调用的时候, 该 promise 对象的状态 变为 not pending, 此时此 promise 的函数 `then()` 将会被自动调用, 

前面我们说到, 调用异步函数会立即返回一个处于 pending 状态的 promise 对象, 主程序接着往下执行, 至于返回的那个 promise 对象, js 引擎会在其状态变为 not pending 的时候调用其 `then()` 函数, 有时候我们的下一步操作需要前一步的结果, 这时候我们可以用 `then()` 进行嵌套, 但我们不可能把之后所有的代码都嵌套在 `then()` 吧, 这样可读性也不好, 这个时候就需要用到 `await`, `await` 可以阻塞主程序, 知道其修饰的异步函数执行完成, 

当然 `await` 还附加一个功能, 就是本来一个异步函数返回的是一个 promise 对象, 对于一个 promise 对象, 我们肯定需要调用其 `then()` 函数, 不然执行完了, 那值没有用, 还调用那个异步函数干嘛呢? 若我们调用异步函数的时候在前修饰 `await`, 此时该异步函数就**不会立即返回**, 而是执行完后才会返回, 且返回的是 promise 对象的值, 而不是一个 promise 对象, 这里我们看段代码, 分析一下:

```javascript
async function getData() {
    let response = await fetch('https://example.com');
    return await response.text()
}

getData().then((value) => {
    console.log(value)
})

// 打印 获取到的html文件的内容
```

根据上面的分析, 因为前面加了 `await`,  `await fetch('https://example.com')` 返回的是一个 promise 对象的值, 并不是一个 promise 对象, 那这个值是什么呢? 是个字符串还是个整数, 又或者是其它类的对象? 

想回答这个问题, 我们需要知道当没有被 `await` 修饰的时候 `fetch()` 返回的是什么呢? 当然是一个 promise 对象, 什么样的 promise 对象呢? 我的意思是这个 promise 对像的值是什么?  答: `fetch()` returns a promise that resolves with a [`Response`](https://developer.mozilla.org/en-US/docs/Web/API/Response) object. 

所以我们知道了, `await fetch('https://example.com')` 返回的是一个 Response 对象, 那为什么我们之后的代码 `response.text()` 又用 `await` 修饰呢? 原因很简单, `response.text()` 返回的也是个 promise 对象, 我们不想在获取到其 text 之前让主程序继续执行, 所以使用 await 进行阻塞, 我们来看看文档描述: 

[`Response.json()`](https://developer.mozilla.org/en-US/docs/Web/API/Response/json): Returns a promise that resolves with the result of parsing the response body text as [`JSON`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON).

[`Response.text()`](https://developer.mozilla.org/en-US/docs/Web/API/Response/text): Returns a promise that resolves with a text representation of the response body.

验证了我们的猜想, 且可能细心的同学会发现函数 `getData()`  最后返回的是 `await response.text()`, 虽然 `response.text()` 返回的是一个 promise 对象, 但因为修饰了 `await` 此时返回的是 promise 对象的值, 根据上面 `Response.text()` 描述, 此时返回的就是个字符串, 那为什么我们可以使用`getData().then(...)`呢?

答案是: Async functions always return a promise. If the return value of an async function is not explicitly a promise, **it will be implicitly wrapped in a promise**.

所以

```js
async function foo() {
  return 1;
}
```

会被转换为:

```js
function foo() {
  return Promise.resolve(1);
}
// Promise.resolve(1) 创建一个 promise 对象, 值为 1
```

所以, 你知道为什么我们可以使用 `getData().then(...)` 了吧, 假如 `return await response.text()` 返回的是 `'hello world'`, 那最后一行代码就会变为 `return Promise.resolve('hello world')` , 再之后的事, `then()` 是怎么把 promise 的值当作参数传给 callback function的过程, 前面已经介绍, 不再赘述, 

另外注意, 异步函数 `getData()` 必须要有 return 语句, 否则其返回的 promise 对象的值为 undefined, 即:

```javascript
async function getData() {
    let response = await fetch('https://example.com');
    let txt = await response.text()
    console.log(txt)
}

getData().then((value) => {
    console.log(value)
});

// 打印: undefined
```

另外还想加一点, 

The `then()` function returns a **new promise**, different from the original: 

```js
const promise = doSomething();
const promise2 = promise.then(successCallback, failureCallback);
```

The arguments of `then` are optional, for instance,  `catch(failureCallback)` is short for `then(null, failureCallback)` 

也就是说我们上面调用的 promise 对象的 `then()` 函数, 其实是有两个参数的, 即第一个参数是当 promise 对象状态为 `Fulfilled` 的时候调用的, 第二个参数是当该 promise 对象的状态为 `Rejected` 也就是执行失败的时候调用的, 一般我们写成 `.catch(failureCallback)` 而不是 `.then(null, failureCallback)` 

References:

- [Using promises - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises)
- [async function - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)
- [Master the JavaScript Interview: What is a Promise? | by Eric Elliott | JavaScript Scene | Medium](https://medium.com/javascript-scene/master-the-javascript-interview-what-is-a-promise-27fc71e77261)
- [What is a Promise? JavaScript Promises for Beginners](https://www.freecodecamp.org/news/what-is-promise-in-javascript-for-beginners/)