---
title: Hooks React - Next.js
date: 2024-12-11 20:50:01
tags:
 - front-end
---

## useCallback & useMemo

```ts
const cachedFn = useCallback(fn, dependencies)


```

useCallback包裹的**函数**, 相当于对函数做了缓存, 当父组件重新渲染时, 函数不会重新定义==>子组件不会重新渲染

useMemo包裹的**变量**，相当于对变量做了缓存，当父组件重新渲染时，变量不会改变==》子组件不会重渲染

useCallback 和 useMemo 参数相同, 第一个参数是函数, 第二个参数是依赖项的数组

useMemo、useCallback 都是使参数（函数）不会因为其他不相关的参数变化而重新渲染, 主要区别是 React.useMemo 将调用 fn 函数并返回其结果，而 React.useCallback 将返回 fn 函数而不调用它

useMemo、useCallback 与 useEffect 类似，[] 内可以放入你改变数值就重新渲染参数（函数）的对象。如果 [] 为空就是只渲染一次，之后都不会渲染



```ts
const MemoizedComponent = memo(SomeComponent, arePropsEqual?)
```



有一个父组件, 其中包含子组件, 子组件接收一个函数作为props, 通常而言, 如果父组件更新了, 子组件也会执行更新, 但是大多数场景下, 更新是没有必要的, 我们可以借助useCallback来返回函数, 然后把这个函数作为props传递给子组件, 这样, 子组件就能避免不必要的更新

useCallback不能滥用, 否则只会消耗性能, 利用闭包缓存上次结果, 成本为额外的缓存, 与比较逻辑, 不是绝对的优化, 而是一种成本的交换，并非使用所有场景



`memo` 允许你的组件在 props 没有改变的情况下跳过重新渲染, 注意 `momo` 是 API 不是 hook, 







