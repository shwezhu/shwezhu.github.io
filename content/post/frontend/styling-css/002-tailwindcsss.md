---
title: Tailwind CSS Commonly Used Class
date: 2024-01-06 12:46:22
categories:
 - front-end
tags:
 - front-end
typora-root-url: ../../../static
---

设置 Tailwind CSS: 

https://tailwindcss.com/docs/installation

```js
// tailwind.config.js
module.exports = {
  // ./src/index.html, /src/pages/about.html 等等都会被匹配到
  content: ["./src/**/*.{html,js}"],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

----

block 元素水平居中: `mx-auto`, 注意对 inline 无效, 原因: `margin-left: auto`, `margin-right: auto` 无法适用 inline 元素.

```
<nav className="fixed bottom-0 left-0 right-0 z-50 bg-white dark:bg-gray-900 border-t dark:border-gray-800 safe-area-pb">
            <div className="mx-auto px-4 max-w-lg">
                <div className="flex justify-around items-center h-16">
                	<Link>
                		...
                	</Link>
                	<Link>
                		...
                	</Link>
                	<Link>
                		...
                	</Link>
                	....
```



## 响应式

### 导航栏

```html
<div>
    <div className="mx-auto px-4 w-full max-w-7xl border-2">
        <div className="flex justify-around items-center">
            <Link href="/" className="text-blue-600 dark:text-blue-400">首页</Link>
            <Link href="/discuss" className="text-blue-600 dark:text-blue-400">讨论</Link>
            <Link href="/search" className="text-blue-600 dark:text-blue-400">搜索</Link>
        </div>
    </div>
</div>
```

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/12/a3f08d9ac96f269da225d22fa7b5bda3.png)

> `max-w-7xl` 限制最大宽度在 7xl 以内, 注意 `w-full` 并不多余, 因为盒子可能不会自动占满整个宽度, 它确保了容器行为的可预测性
>
> 水平方向: `justify-around` 控制 flex 子元素在主轴（默认是水平方向）上的分布, 子元素会平均分布，每个元素两侧有相等的空间, 与 `justify-between` 的区别是, `around` 在两端也会留有空间（约为中间空间的一半）
>
> 垂直方向居中: `items-center`: 控制 flex 子元素在交叉轴（默认是垂直方向）上的对齐方式

----

**宽度（Width）**:

- `w-1/2`元素宽度为容器宽度的 50%, `w-4 `元素宽度为 1rem（默认情况下，所有的尺寸都基于 4 倍体系）, `w-full` 元素宽度为 100%

**高度（Height）**:

`h-10` 高度为 2.5rem, `h-screen`高度为视口的高度, 这里和高度为100%也是有区别的, 100%的时候放到手机上, 可能会出现整个页面比手机高, 而不是刚刚好

**内边距（Padding）**:

 `px-`、`py-`、`pt-`、`pb-`、`pl-`、`pr-` , 例如：`p-4` 所有方向的内边距都是 1rem, `px-2`水平方向（左右）的内边距是 0.5rem

**外边距（Margin）**:

 `mx-`、`my-`、`mt-`、`mb-`、`ml-`、`mr-` 例如：`m-5`所有方向的外边距都是 1.25rem,`mt-3` 上方外边距是 0.75rem

----
