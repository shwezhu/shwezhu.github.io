---
title: Tailwind CSS Flex
date: 2024-01-06 20:46:20
categories:
 - front-end
tags:
 - front-end
---

## Block and Inline

- 块级元素独占一行, 宽度默认是父元素的 100%, 高度由内容决定, 不能与其他元素并列. 
  - 特殊情况: button 默认是 inline-block, 即支持设置宽高, 即使你把 button 的 display 设置为 block, 其宽度依然不会是父元素的 100%, 而是由内容决定的. 
  - 其他的 inline 元素, 如 span, a, 如果设置为 block, 则其宽度会自动变为父元素的 100%. 
- 内联元素不会独占一行, 宽度由内容决定, 可以与其他元素并列, 但是**不能设置宽高**, 若要设置宽和高, 需要将其转换为块级元素. 如 `display: block` 或 `display: inline-block`.
  - 特殊情况1: 内联元素不可以设置上下 padding 和 margin, 
  - 特殊情况2: `margin-left: auto`, `margin-right: auto` 无法用于居中内联元素. 这也是为什么 tailwind css 中 `mx-auto` 使内联元素水平居中的原因.

> flex 子元素既不是块级元素, 也不是内联元素, 而是 flex 元素, 有自己的特性. 若同在 flex box内, 则 `<a>` 与 `<div>` 在显示上是完全一样的, 因为他们都是 flex items. 
> 注意 flex 子元素的默认值是 `flex: 0 1 auto`, 即 `flex-grow: 0`, `flex-shrink: 1`, `flex-basis: auto`, 即默认情况下, flex 子元素是允许在必要情况下缩小的, 而不会增长, 从而导致 flex 子元素的宽度不是父元素的 100%, 而是由内容决定的.

