---
title: Tailwind CSS Tricks
date: 2024-01-06 22:35:10
categories:
 - front-end
tags:
 - front-end
typora-root-url: ../../../static
---

## 1. `flex-none`

由于 flex items 三属性 `flex-grow`, `flex-shrink`, `flex-basis` 的默认值分别是 0, 1, auto, 即 flex items 默认允许在必要情况下缩小, 比如有左右两个 flex items, 当左边的 flex items 的内容很多, 而右边的 flex items 的内容很少, 此时右边的 flex items 会被压缩, 以适应 flex container 的宽度, **即使右边的 flex items 设置了宽度, 也会被压缩.**

这就导致有时候会遇到明明设置了宽度, 却“不起作用”的情况, 其实就是被压缩了, 这时候就需要使用 `flex-none` (`0 0 auto`) 来禁止 flex items 在必要情况下缩小, 从而保证 flex items 的宽度不会被压缩.

如下, 若没有 `flex-none`, 因为段落内容较多, 会导致image被压缩, 即使设置了宽度, 
```jsx
<div className={'flex items-start p-3 max-h-80 border-b-2'}>
    <a href={`#`} className="flex-none">
        <img src={'#'} alt="User avatar" className="rounded-full h-11 w-11"/>
    </a>
    <p className={'mt-2'}>
        Compound indexes collect and sort data from two or more fields in each document in a collection. Data is grouped by the first field in the index and then by each subsequent field.
    </p>
</div>
```

![aa](/002-tailwind-css-tricks/aa.png)
