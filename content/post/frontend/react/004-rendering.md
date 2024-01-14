---
title: Rendering - React
date: 2024-01-07 19:27:22
categories:
 - front-end
tags:
 - front-end
---

## setState async

我们知道 setState 会导致组件重新渲染, setState() 或者说由 useState 钩子产生的 setXXX() 函数是异步的。这意味着当你调用这些函数来更新组件的状态时，状态并不会立即改变, 因此组件也不会立即渲染。

例如在一个 event handler 中你调用 setXXX() 后，当前的状态值不会立即改变, 如果你紧接着读取该状态，会得到旧的值: 

```javascript
const [count, setCount] = useState(0);

// 使用 useEffect 来获取更新后的状态
useEffect(() => {
    // 这里的 count 是更新后的值
    console.log(count); // 现在是 1
}, [count]);

function onCLick() {
   // 更新状态
   setCount(count + 1);
   // 这里立即读取 count，将得到旧值, 因为在组件当前状态下, count 并没有改变
   console.log(count); // 仍然是 0
}
```

> 下面是我最开始的理解: 一般我们会在一个事件回调函数里去调用一个 setXXX() 函数, 当我们调用后接着读取那个 state 的值, 其实是从 [React 单独维护的数据结构中读取 state 的值](https://arc.net/l/quote/hwsdijzo), 因为组件的 state 和 组件本身是隔离开的, *所以我们读取 state 有可能读取到的是更新后的值*, 也有可能读取到的是没更新的值, 这取决于 setXXX() 什么时候被调用, 但一般它不会立即被调用, 因为事件循环还有其它任务要处理,

上面的斜体字: “所以我们读取 state 有可能读取到的是更新后的值, 也有可能读取到的是没更新的值”, 这段理解是不对的, 就像上面的 `console.log(count)`, 我们直接传入的就是 count 当前的值, 大致过程如下:

- 状态更新是异步的：当您在事件处理函数中调用 setXXX(newValue)，React 会将这个状态更新排队，而不是立即执行。这意味着 React 会等到当前执行的代码（比如事件处理函数）完成后，才开始处理状态更新。
- 组件的渲染与状态更新：React 会在稍后的时间处理排队的状态更新。当状态更新被处理时，**如果新的状态与旧的状态不同，React 会重新渲染组件**。在这个新的渲染过程中，组件函数会用新的状态值重新执行。
- 读取 state 的值：在调用 setXXX() 之后立即读取 state 变量，您会得到调用之前的值。这是因为状态更新还没有被处理，组件也还没有重新渲染。状态变量在组件的每次渲染中都是“固定”的，**它代表了该渲染周期内 state 的值**。
- 事件循环和异步行为：React 利用了 JavaScript 的事件循环来实现状态更新的异步行为。当您在一个事件回调中调用 setXXX() 时，实际的状态更新和组件的重新渲染会发生在后续的事件循环中，而不是立即发生。

> React [batches state updates](https://react.dev/learn/queueing-a-series-of-state-updates). It updates the screen after all the event handlers have run and have called their set functions. This prevents multiple re-renders during a single event. 

## Why is setState async

- 性能优化：React 通过异步更新状态，可以批量处理多个状态更新，而不是对每个状态更新都重新渲染组件。这种批处理方式减少了不必要的渲染次数，提高了应用的性能。

- 避免直接操作 DOM：React 通过维护一个状态和虚拟 DOM 的机制，确保在实际 DOM 更新之前，所有的状态更新都已经被处理。这种方式允许 React 优化 DOM 操作，减少实际 DOM 的操作次数。

## setState 的坑

刚开始很容易写出以下错误代码:

```javascript
const [age, setAge] = useState(0);

function handleClick() {
  setAge(() => age + 1);
  // ...
```

这样访问准确来说并不是**上一次**的state, 而是组件在它**当时**状态值, 因为有可能发生多次连续的状态更新, 比如其它 event handler 也调用了 setAge 函数, 不要忘了这些 setXXX() 是异步的, 会被React集中到一起执行, 所以要确保 setAge() 更新的是上一次的值, 要使用（即 setXXX(previousState => newState)），这样可以确保你的更新基于最新的状态值。

正确方式如下:

```javascript
const [age, setAge] = useState(0);

function handleClick() {
  setAge(age => age + 1);
  // ...
```

注意第二个 setXXX() 的参数是一个匿名函数, 这个**匿名函数的参数**是上一次的 state, 由 React 负责传入, 返回值更新后的 state, 

## JavaScript Event Loop 浏览器

下面介绍的是浏览器的事件循环模型, 并不是 nodes.js 的事件循环模型.

1. **调用栈（Call Stack）**：
   - 调用栈是一个LIFO（后进先出）结构，用于跟踪程序中的函数调用。
   - 当一个函数被执行时，它被添加到调用栈的顶部；当函数执行完毕时，它被从栈顶移除。

2. **事件队列（Event Queue）**：
   - 当异步事件（如用户输入、文件读取等）发生时，相关的回调函数被添加到事件队列中。
   - 事件队列是一种FIFO（先进先出）结构。

3. **事件循环（Event Loop）的工作原理**：
   - 事件循环的作用是监控调用栈和事件队列。
   - 如果调用栈为空，事件循环会查看事件队列。如果事件队列中有等待的回调函数，事件循环会将它们依次移动到调用栈中进行执行。
   - 这个循环过程是持续不断的，这就是为什么它被称为“事件循环”。

4. **宏任务（Macro Tasks）与微任务（Micro Tasks）**：
   - 宏任务包括脚本执行、setTimeout、setInterval等。
   - 微任务通常来自Promise、MutationObserver等。
   - 在每次宏任务执行完毕后，会处理所有的微任务队列，然后再执行下一个宏任务。

了解更多: 
- [Difference between the Event Loop in Browser and Node Js? - DEV Community](https://dev.to/jasmin/difference-between-the-event-loop-in-browser-and-node-js-1113)
- [The event loop - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Event_loop)
- [The Node.js Event Loop, Timers, and process.nextTick() | Node.js](https://nodejs.org/en/guides/event-loop-timers-and-nexttick)

## 组件渲染过程

This process of requesting and serving UI has three steps:

- **Triggering** a render
  - A render is triggered when a component’s `props` or `state` changes. 
  - A render can also be triggered by its parent component re-rendering.

> 这里注意, 使用自定义 hook 时, 其返回的 state 变化时, 也会触发组件的重新渲染. 并不是自定义 hook 的状态改变而导致的重新渲染, 而是自定义 hook 返回的 state 改变而导致的重新渲染. 自定义 Hooks 的主要优势在于它们允许你重用状态逻辑，而不是创建全新的状态机制。每次在组件中使用自定义 Hook 时 (若该 hook 中定义了 state `const [xxx, setXXX] = useState(xx)`) ，都相当于在该组件内部创建了一个新的独立状态 xxx, 因此当 hook 中调用 setXXX 时, 会触发该组件的重新渲染. 
  
- **Rendering** the component
  - The process of rendering is recursive. 
  
- React **commits** changes to the DOM
  - React will apply the minimal necessary operations (calculated while rendering!) to make the DOM match the latest rendering output. 
  - Think the [clock and input](https://react.dev/learn/render-and-commit) example. 

> The default behavior of rendering all components nested within the updated component is not optimal for performance if the updated component is very high in the tree. If you run into a performance issue, there are several opt-in ways to solve it described in the [Performance](https://reactjs.org/docs/optimizing-performance.html) section. **Don’t optimize prematurely!**

> When developing in “Strict Mode”, React calls each component’s function twice, which can help surface mistakes caused by impure functions. [Source](https://react.dev/learn/render-and-commit)

Learn more: [Render and Commit – React](https://react.dev/learn/render-and-commit)

## 组件渲染会导致异步函数暂停吗

React组件的重新渲染不会导致其中正在执行的异步函数暂停或中断, 

```javascript
function MyComponent() {
    console.log('组件开始渲染');

    // 异步函数
    setTimeout(() => {
        console.log('异步函数执行');
    }, 0);

    console.log('组件渲染中');

    // 组件渲染的返回
    return <div>Hello World</div>;
}

// 当MyComponent被渲染时
ReactDOM.render(<MyComponent />, document.getElementById('root'));
```

在这个例子中，当`MyComponent`组件开始渲染时，它首先打印`"组件开始渲染"`。接下来，尽管有一个`setTimeout`异步函数，它不会立即执行。相反，组件会继续执行下一行同步代码，打印`"组件渲染中"`。只有在所有同步代码执行完毕后，即组件渲染完成后，事件循环才会处理`setTimeout`中的异步回调，打印`"异步函数执行"`。

因此，在React中，组件的渲染过程是不会被其中的异步函数所打断的。同步代码总是在异步代码之前执行完毕。这保证了组件的渲染逻辑的一致性和可预测性。