---
title: Promise Object in Javascript
date: 2023-11-28 12:34:29
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

## 2. Promise object

You can create a promise using the Promise constructor, which takes a function as its argument. This function, often referred to as the "executor," takes two parameters: `resolve` and `reject`. 

```js
let myPromise = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve("hello world")
    }, 250)
})

myPromise.then((value) => {
    console.log(myPromise)
    console.log(value)
})

console.log(myPromise)

// Promise { <pending> }
// Promise { 'hello world' }
// hello world
```

As you can see above, `myPromise.then(...)` is executed after `console.log(myPromise)`. This is because a Promise object has three state: `pending`, `fulfilled` or `rejected`, and `then()` won't get executed by the JS engine when the state of the Promise object is `pending`. 

> The `Promise` object has several fields and methods, including:
>
> 1. **`state`**: A **private** field that represents the current state of the promise (`pending`, `fulfilled` or `rejected`).
> 2. **`result`**: A **private** field that holds the result value if the promise is fulfilled or the reason if it is rejected.
> 3. **`then()`**, **`catch()`**, **`finally()`** methods, only get executed when the state of Promise object is `fulfilled` or `rejected`. 

Besides, you can see the output above (`Promise { 'hello world' }`) that a Promise object is just a wrapper, which contains a resolved value (a string, number, json, object...) and has three methods. 

## 3. A real world example

```js
function fetch(input: RequestInfo | URL, init?: RequestInit): Promise<Response>
```

As you can see, `fetch()` returns a `Promise` object whose value supposed to be an object of `Response`. There are two way to use `fetch()`. 

### 3.1. Use `await/async`

```js
async function main() {
    let response
    try {
        // 'response' is not a Promise object, 
        // it's the resolved value the Promise object
        response = await fetch('https://www.google.com');
    } catch (err) {
        console.error("an err happened");
        return
    }
    console.log(response.ok);
}

main().then()
```

You may wonder why we need call `then()` after `main()`, the reason is that `async functions` always return a promise. 

> If the return value of an async function is not explicitly a promise, **it will be implicitly wrapped in a promise**. An async function is really just a fancy Promise wrapper.

If you call main like this:

```js
...

await main();
```

There will be an error: 

```
await main();
^^^^^

SyntaxError: await is only valid in async functions and the top level bodies of modules
```

This is another syntax to call async function:

```js
(async () => {
  await main()
})()
```

### 3.2. With Promise chain 

```js
fetch('https://www.google.com')
    .then(response => console.log(response.status))
    .catch(err => console.error("An err occurred."))
```

Because `fetch()` retuens a Promise object, we can call `then()` directly, like above. 

This looks more concise than ealier example.