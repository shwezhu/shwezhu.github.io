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
