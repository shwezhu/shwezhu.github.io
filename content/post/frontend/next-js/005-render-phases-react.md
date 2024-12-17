---
title: Render Phases - React.js
date: 2024-12-16 23:38:39
tags:
 - front-end
---

[一篇文章](https://eliav2.github.io/how-react-hooks-work/)总结的比较好, 渲染的两个阶段: Render, Commit:

**Render**

- construction of sub React-tree by recursively calling the React component function body (or the render method on class components)- in this article we call this **update phase**.
- passing this React-tree to the renderer that will figure out what’s sections of the DOM needs to be updated.

**Commit**

- the renderer updates the DOM using [React’s “diffing” algorithm](https://reactjs.org/docs/reconciliation.html#the-diffing-algorithm).
- now the browser DOM is fully updated in memory but the browser has not painted it to the UI(the event loop has not yet ended). means that any access to the DOM here will get the updated DOM properties(such location and dimensions), but changes has not flushed to the UI just yet.
- *useLayoutEffect cleanup from previous render* 
- **[useLayoutEffect](https://reactjs.org/docs/hooks-reference.html#uselayouteffect)** is now called.
- javascript event loop has ended, and the browser paints the updated DOM (the UI is fully updated).
- *useEffect cleanup from previous render*
- **[useEffect](https://reactjs.org/docs/hooks-reference.html#useeffect)** is now called (asynchronously).

注意, 每次在 useEffect 执行前, React 会先清理上次渲染时调用的 useEffect, 这非常有必要, 不要忘了, useEffect 是用来执行副作用的地方, 比如我们可能在 useEffect 中使用了定时器, 有可能发生的是, 上次渲染因调用 useEffect 启动的定时器还没结束, 又发生了一次新的渲染, 此时在调用 useEffect 之前, 清理掉之前的的定时器, 也是很有必要的, 或者另一个例子:

```js
function ChatRoom({ roomId }) {
  useEffect(() => {
    // 设置订阅
    const connection = createConnection(roomId);
    connection.connect();

    // 清理函数
    return () => {
      connection.disconnect();
    };
  }, [roomId]);
}
```





---

React 调用组件函数时, 有两个阶段 render 和 commit. 

```ts
function ProfileCard() {
  // 整个函数体的执行就是 render phase
  const [user, setUser] = useState({ name: "Alice", age: 25 });
  
  // Render Phase 已经包含了完整的数据计算和 JSX 生成
  // 这里的 JSX 已经包含了实际的数据
  return (
    <div>
      <h1>{user.name}</h1>  {/* "Alice" 在 Render Phase 就确定了 */}
      <p>{user.age}</p>     {/* 25 在 Render Phase 就确定了 */}
    </div>
  );
}
```

当然在 render 阶段也不是所有的代码都会执行,  useEffect() 并不会被执行

```ts
function MyComponent() {
  const [count, setCount] = useState(0);
  
  useEffect(() => {
    // 这里的代码在 commit phase 执行, 也就是 render phase 之后
    document.title = `Count is ${count}`;
  }, [count]);

  return <div>{count}</div>;
}
```

-----

都知道, 在 Render Phase 已经完成了所有数据的计算和完整的 Virtual DOM 的生成, Commit Phase 则负责把这些变更实际应用到浏览器的 DOM 中, 并处理副作用 useEffect, 

可是有个问题, 已经渲染完了, 都更新到 DOM 了, 再执行 useEffect 还有什么意义呢, useEffect 不就是为了拉去数据 然后插入到视图中吗?

useEffect 的真正作用

```ts
function UserProfile() {
  const [user, setUser] = useState(null);

  // 第一次渲染
  console.log("1. Render Phase 执行");
  const content = user 
    ? <h1>Welcome, {user.name}</h1> 
    : <h1>Loading...</h1>;

  useEffect(() => {
    console.log("3. Commit Phase 之后执行 Effect");
    // 获取数据
    fetch('/api/user')
      .then(r => r.json())
      .then(userData => {
        console.log("4. 数据到达，调用 setUser");
        setUser(userData);
      });
  }, []);

  console.log("2. 返回 JSX");
  return content;
}
```

执行的逻辑是

1. 组件首次渲染，显示 "Loading..."
2. DOM 更新完成
3. useEffect 执行，发起 API 请求
4. 数据返回后，setUser 触发新的渲染
5. 组件重新渲染，这次显示 "Welcome, [name]"

所以 useEffect 不是为了"把数据插入已渲染的视图"，而是：

1. 触发一个新的数据获取流程
2. 通过 setState 引发新的**渲染周期**

```ts
// 🚫 错误理解：视图是个框架，等着数据填充
<div id="user">{等待 useEffect 填充数据}</div>

// ✅ 正确理解：每次都是完整的渲染
// 第一次渲染
<div id="user">Loading...</div>

// 数据到达后的第二次渲染
<div id="user">Welcome, Alice</div>
```

若 useEffect 的依赖是空数组, 表示只在组件首次渲染后执行一次, 之后不会再执行, 

