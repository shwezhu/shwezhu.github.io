---
title: Pure Function & State & Event Loop - React
date: 2024-01-07 10:27:22
categories:
 - front-end
tags:
 - front-end
---

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
  
- **Rendering** the component
  - The process of rendering is recursive. 
  
- React **commits** changes to the DOM
  - React will apply the minimal necessary operations (calculated while rendering!) to make the DOM match the latest rendering output. 
  - Think the [clock and input](https://react.dev/learn/render-and-commit) example. 

> The default behavior of rendering all components nested within the updated component is not optimal for performance if the updated component is very high in the tree. If you run into a performance issue, there are several opt-in ways to solve it described in the [Performance](https://reactjs.org/docs/optimizing-performance.html) section. **Don’t optimize prematurely!**

> When developing in “Strict Mode”, React calls each component’s function twice, which can help surface mistakes caused by impure functions. [Source](https://react.dev/learn/render-and-commit)

Learn more: [Render and Commit – React](https://react.dev/learn/render-and-commit)

## 函数组件无副作用

1. **Same inputs, same output**: 函数组件的输出（即渲染的UI）仅依赖于它的props和state。换句话说，给定相同的props和state，组件将始终渲染相同的输出。

2. **不改变外部状态**: 在理想情况下，函数组件不应该改变外部状态，**不应该直接修改传入的props或外部的全局变量**。

3. **无副作用操作**: **函数组件在其主体内不应该执行有副作用的操作**，比如直接进行网络请求、订阅事件、直接操作DOM等。这些操作应该放在特定的生命周期方法或钩子（如`useEffect`）中。

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

## State

When you call `useState`, you are telling React that you want this component to remember something:

```javascript
const [index, setIndex] = useState(0);
```

In this case, you want React to remember `index`.

> **State is tied to a position in the render tree**: When you give a component state, you might think the state “lives” inside the component. But the state is actually held inside React. React associates each piece of state it’s holding with the correct component by where that component sits in the render tree. [source](https://arc.net/l/quote/hwsdijzo)

Here’s how that happens in action:

```javascript
const [index, setIndex] = useState(0);
```

1. **Your component renders the first time.** Because you passed 0 to useState as the initial value for `index`, it will return [0, setIndex]. React remembers 0 is the latest state value.
2. **You update the state.** When a user clicks the button, it calls setIndex(index + 1). `index` is 0, so it’s setIndex(1). This tells React to remember index is 1 now and triggers another render.
3. **Your component’s second render.** React still sees useState(0), but because React remembers that you set `index` to 1, it returns [1, setIndex] instead.

> State is local to a **component instance** on the screen. In other words, if you render the same component twice, each copy will have completely isolated state! Changing one of them will not affect the other.

