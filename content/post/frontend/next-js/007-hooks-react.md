---
title: Hooks React - Next.js
date: 2024-12-11 20:50:01
tags:
 - front-end
---

> Always keep in mind: By default, React rerenders a component and all its children whenever the parent component rerenders - even if the props haven't changed.

文章推荐:

- [React Hooks 如何工作的](https://eliav2.github.io/how-react-hooks-work/)

## useCallback & useMemo

React.memo 缓存了整个组件 (拿缓存换效率), 让一个组件只有在 props 改变的时候才会被重新渲染, 

函数或变量都可以当作 props 传递给子组件, 因此若父组件重新渲染, 那么函数和变量其实也是重新定义的, 即使他们的定义或者数值没有改变, 这又回导致子组件被重新渲染 , 即使我们使用了 React.memo

这时候就需要 useCallback 和 useMemo 上场了, 

```ts
const cachedFunction = useCallback(fn, dependencies)
const cachedVariable = useCallback(fn, dependencies)
```

- useCallback包裹的**函数**, 相当于对函数做了缓存, 当父组件重新渲染时, 函数不会重新定义即 props 不会改变 ==>子组件不会重新渲染

- useMemo包裹的**变量**, 相当于对变量做了缓存, 当父组件重新渲染时, 变量不会改变即 props 不会改变 ==》子组件不会重渲染

useCallback 和 useMemo 参数相同, 第一个参数是函数, 第二个参数是依赖项的数组

useMemo, useCallback 都是使参数（函数）不会因为其他不相关的参数变化而重新渲染, 主要区别是 React.useMemo 将调用 fn 函数并返回其结果, 而 React.useCallback 只是返回 fn 函数而不调用它

useMemo、useCallback 与 useEffect 类似, [] 内可以放入你改变数值就重新渲染参数（函数）的对象, 如果 [] 为空就是只渲染一次，之后都不会渲染

> useCallback不能滥用, 否则只会消耗性能, 利用闭包缓存上次结果, 成本为额外的缓存, 与比较逻辑, 不是绝对的优化, 而是一种成本的交换，并非使用所有场景

参考: https://juejin.cn/post/6997231767077781540

## Custom hooks

> A custom Hook is a JavaScript function whose name starts with ”`use`” and that may call other Hooks. [React docs](https://legacy.reactjs.org/docs/hooks-custom.html)

所有 Hooks 必须以 use 开头, 这不是约定, 而是 React 规则要求, 自定义 hooks 和 普通函数的区别:

- 自定义 hooks 可以使用其他 hooks, 而普通函数不能
- 自定义 hooks 能保持状态 (可以使用 useState) , 普通函数每次调用都是独立的

可以参考 [stack overflow](https://stackoverflow.com/a/64904812/16317008) 的一个回答: 

> React Hooks are JS functions with the power of react, it means that you can add some logic that you could also add into a normal JS function, but also you will be able to use the native hooks like useState, useEffect, etc, to power up that logic, to add it state, or add it side effects, memoization or more. So I believe hooks are a really good thing to **manage the logic of the components in a isolated way**.

这里有个例子可以帮助理解上面这段话, 尤其是最后一句:

```jS
// 组件变得非常简洁
function UserList() {
  const { data, loading, error } = useFetch('/api/users')

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>
  return <div>{data.map(user => <div>{user.name}</div>)}</div>
}

// 自定义 Hook, 保存状态, 独立组建逻辑
function useFetch(url) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      ...
  }, [url])

  return { data, loading, error }
}
```

