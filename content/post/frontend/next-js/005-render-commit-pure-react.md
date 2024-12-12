---
title: Render and Commit Phase in React (Pure Component)
date: 2024-12-12 08:38:30
tags:
 - front-end
---

永恒不变的真理: 默认情况下, 当一个组件重新渲染时, React 将递归渲染它的所有子组件

---

可以简单认为 react 调用组件函数时, 有两个阶段 render 和 commit. 

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

上面给的例子中, useEffect 的依赖是个空数组, 这是不是意味着它永远不会被执行?

```ts
// 情况 1: 没有依赖数组
useEffect(() => {
  console.log("每次渲染都会执行");
});

// 情况 2: 空依赖数组 []
useEffect(() => {
  console.log("只在组件首次渲染后执行一次");
}, []);

// 情况 3: 有依赖项的数组 [dep1, dep2]
useEffect(() => {
  console.log("当依赖项改变时执行");
}, [userId, count]);
```

上面获取用户数据的例子:

```ts
function UserProfile() {
  const [user, setUser] = useState(null);

  useEffect(() => {
    // 这段代码会在组件首次渲染后执行一次
    fetch('/api/user')
      .then(r => r.json())
      .then(setUser);
  }, []); // 空数组意味着"只执行一次"

  return user ? <h1>Hello, {user.name}</h1> : <h1>Loading...</h1>;
}
```

执行流程：

1. 组件挂载
2. 首次渲染（显示 Loading...）
3. useEffect 执行一次（发起 API 请求）
4. 数据返回，setUser 触发重新渲染
5. 第二次渲染（显示用户名）
6. useEffect 不再执行（因为依赖数组是空的）

可能用到的场景比如需要在 userId 改变时重新获取数据：

```ts
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    // 当 userId 改变时，这个 effect 会重新执行
    fetch(`/api/user/${userId}`)
      .then(r => r.json())
      .then(setUser);
  }, [userId]); // 依赖于 userId

  return user ? <h1>Hello, {user.name}</h1> : <h1>Loading...</h1>;
}
```

--------

pure 函数就是 只要输入相同, 则输出一定相同, 在 React Component 中 pure component 可以理解为 只要传入的 props 相同, 用户操作(比如点击按钮) 相同, 那 render 阶段返回的 html 就应该相同, 可能总结也不准确, 所以我们来讨论什么行为是 impure, 只要不犯错, 那做的都是对的

```ts
// ❌ Bad: Modifying props during render
function RichTextEditor({ content }) {
  // 开发者想在每次渲染时更新内容的最后修改时间
  content.lastModified = Date.now();
  content.version++;
  
  return <div>
    <Editor content={content} />
    <div>Last modified: {content.lastModified}</div>
  </div>;
}
```

正确做法：

```ts
// 让父组件传入一个修改函数控制更新
function RichTextEditor({ content, onContentChange }) {
  const handleChange = (newContent) => {
    onContentChange({
      ...newContent,
      lastModified: Date.now(),
      version: (newContent.version || 0) + 1
    });
  };

  return <div>
    <Editor 
      content={localContent}
      onChange={handleChange}
    />
    <div>Last modified: {localContent.lastModified}</div>
  </div>;
}
```

为什么这么操作是 pure?

这个组件在渲染过程中只做了两件事：

1. 定义了一个事件处理函数 handleChange
2. 返回 JSX

关键是：它没有直接修改传入的 content 对象, handleChange 虽然会触发修改，但它是事件处理函数，不是在渲染过程中执行的

```ts
// ❌ Bad: Modifying props during render
function SignupForm({ formData }) {
  // 开发者想在渲染时添加验证状态
  formData.errors = validateFields(formData);
  formData.isValid = Object.keys(formData.errors).length === 0;
  
  return <form>
    <input value={formData.email} />
    {formData.errors.email && <span>{formData.errors.email}</span>}
  </form>;
}
```

正确做法：

```ts
function SignupForm({ initialData }) {
  const [formData, setFormData] = useState(initialData);
  const [errors, setErrors] = useState(...);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    const newErrors = {};
    if (name === 'email' && !/^\S+@\S+$/i.test(value)) {
      newErrors.email = '请输入有效的邮箱';
    }
    setErrors(newErrors);
  };

  return (
    <form>
      <input
        name="email"
        value={formData.email || ''}
        onChange={handleChange}
      />
      {errors.email && <span>{errors.email}</span>}
    </form>
  );
}
```

> 修改 props 有两个选择
>
> 第一种: 父组件传递一个 修改函数, 然后在子组件的 event handler 调用这个函数来修改 props, 如第一个例子
>
> 第二种: 通过 useState() 创建一个 props 副本, 在 event handler 种调用 setState 修改, 如第二个例子

```ts
// ❌ Impure: Performing side effects during render phase
function SearchBar() {
  // Wrong: API call during render
  const results = fetch(`/api/search?q=test`);
  
  return <div>{results}</div>;
}

// ✅ Pure: Move side effect to event handler
function SearchBar() {
  const [results, setResults] = useState(null);
  
  const handleSearch = async (query) => {
    const data = await fetch(`/api/search?q=${query}`);
    setResults(data);
  };
  
  return <div>
    <input onChange={e => handleSearch(e.target.value)} />
    {results && <div>{results}</div>}
  </div>;
}

// ❌ Impure: Modifying DOM in render
function NotificationBell() {
  // Wrong: DOM manipulation during render
  if (hasNewNotifications) {
    document.title = `(${count}) New Messages`;
  }
  
  return <bell-icon />;
}

// ✅ Pure: Handle in click event
function NotificationBell() {
  const handleClick = () => {
    // OK to modify DOM in event handler
    document.title = `(${count}) New Messages`;
  };
  
  return <bell-icon onClick={handleClick} />;
}

// ❌ Impure: Local storage operations during render
function UserPreferences({ theme }) {
  // Wrong: localStorage operation during render
  localStorage.setItem('theme', theme);
  
  return <div className={theme}>...</div>;
}

// ✅ Pure: Handle in effect or event
function UserPreferences({ theme }) {
  // Option 1: Handle in effect if needs to sync with prop
  useEffect(() => {
    localStorage.setItem('theme', theme);
  }, [theme]);
  
  // Option 2: Handle in event if user-triggered
  const handleThemeChange = (newTheme) => {
    localStorage.setItem('theme', newTheme);
  };
  
  return <div className={theme}>
    <button onClick={() => handleThemeChange('dark')}>Dark</button>
  </div>;
}

// ❌ Impure: WebSocket connection during render
function ChatRoom() {
  // Wrong: Creating WebSocket during render
  const ws = new WebSocket('ws://chat');
  
  return <div>Chat Room</div>;
}

// ✅ Pure: Handle connection in effect
function ChatRoom() {
  useEffect(() => {
    const ws = new WebSocket('ws://chat');
    return () => ws.close(); // Cleanup on unmount
  }, []);
  
  return <div>Chat Room</div>;
}
```

> In React, **side effects usually belong inside [event handlers.](https://react.dev/learn/responding-to-events)** Event handlers are functions that React runs when you perform some action—for example, when you click a button. Even though event handlers are defined *inside* your component, they don’t run *during* rendering! **So event handlers don’t need to be pure.** 
>
> If you’ve exhausted all other options and can’t find the right event handler for your side effect, you can still attach it to your returned JSX with a [`useEffect`](https://react.dev/reference/react/useEffect) call in your component. This tells React to execute it later, after rendering, when side effects are allowed. **However, this approach should be your last resort.**