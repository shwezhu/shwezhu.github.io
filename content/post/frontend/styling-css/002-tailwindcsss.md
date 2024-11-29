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

断点（breakpoints）用于创建响应式设计，允许在不同屏幕尺寸下应用不同的样式规则：

`sm:` 前缀用于小屏幕设备。例如，`w-full md:w-1/2` : 小屏幕都会自动应用 w-full, 宽度大于 md 的, 宽度自动变为 w-1/2

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
