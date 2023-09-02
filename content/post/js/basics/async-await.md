---
title: Javascript 中的 Promise 对象和异步函数
date: 2023-06-16 00:34:29
categories:
  - javascript
  - basics
tags:
  - javascript
---

## 1. Promise

想看异步函数还是得先看看新标准 ES2015 中介绍的 Promise 是什么, 看个例子, 直观感受一下, 

```javascript
// 创建一个 Promise 对象, 注意参数, 以及参数的参数, 😂
const myPromise = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve('Hi, World!');
    }, 100);
});

console.log(myPromise);

setTimeout(() => {
    console.log(myPromise);
}, 200)
```

打印如下:

```
Promise { <pending> }
Promise { 'Hi, World!' }
```

可以看到, 刚开始 `myPromise` 的状态是 pending, 过了 100ms 之后调用了 `resolve()` , 使 promise 变成非 pending 状态, 此时打印 `myPromise` 可以看到其值就是 `resolve()` 的参数, 这样很麻烦, 因为我们还得故意让程序睡眠 200ms 才能打印出其值, 

我们知道每个 promise 对象都有一个 `then()` 方法, 该方法在 promise 对象的状态为 not pending 的时候会被自动调用, 所以上面的代码可以改进一下:

```js
const myPromise = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve('Hi, World!');
    }, 100);
});

myPromise.then((value) => {
    console.log(value)
})

// Hi, World!
```

这里注意, `then()` 的参数是一个函数(假设改函数叫 func), 则函数 func 只可接受一个参数, 这个参数就是 `then()` 用来传递 promise 对象的值的, 在这里也就是字符串 `'Hi, World!'`, 所以你看这里, 当 `myPromise` 状态为 not pending 时, 其函数 `then()` 才会被调用, 然后`then()` 会把 `myPromise` 的值这里也就是 `'Hi, World!'` 当作参数传递给那个 callback function, 这一点很重要, 即 `then()` 会自动把其所属的 promise 对象的值作为参数传递给其 callback function, 

另外注意, `then()` 并不会阻塞程序, 就好像是 JS 引擎会持续监控处于 pending 状态的 promise 对象, 当这些 promise 对象状态为 not pending 时, 他们的 `then()` 函数就会被自动调用, 

```js
const myPromise = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve('Hi, World!');
    }, 100);
});

myPromise.then((value) => {
    console.log(value)
})

console.log(myPromise)
```

上面这段代码会打印:

```js
Promise { <pending> }
Hi, World!
```

证明 `then()` 并不会阻塞程序, 经过了这个例子你知道了 Promise 对象是什么吧? 有两个状态, pending 和 not pending, js 引擎会根据 promise 对象的状态来调用其 `then()` 函数, 怎么改变一个 promise 对象的状态呢?  调用创建 promise 对象的时候穿进来的两个参数即 `resolve()` 或 `reject()`, 

来看看专业描述:

A promise in JavaScript is an object that may **produce** a single value in the future: either a resolved value, or a reason that it's not resolved (e.g., a network error occurred). It will be in one of 3 possible states: 

- **Fulfilled:** e.g., `resolve()` was called
- **Rejected:** e.g., `reject()` was called
- **Pending:** not yet fulfilled or rejected

Each promise object has a `then()` method, and the *eventual state* of a *pending promise* can either be ***fulfilled*** with a value or ***rejected*** with a reason (error). 

## 2. async & await 

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

参考:

- [Using promises - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises)
- [async function - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)
- [Master the JavaScript Interview: What is a Promise? | by Eric Elliott | JavaScript Scene | Medium](https://medium.com/javascript-scene/master-the-javascript-interview-what-is-a-promise-27fc71e77261)
- [What is a Promise? JavaScript Promises for Beginners](https://www.freecodecamp.org/news/what-is-promise-in-javascript-for-beginners/)