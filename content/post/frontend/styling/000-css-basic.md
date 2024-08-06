---
title: Tailwind CSS Flex
date: 2024-01-06 20:46:20
categories:
 - front-end
tags:
 - front-end
typora-root-url: ../../../static
---

## 1. Block vs Inline

- block 元素独占一行, 宽度默认是父元素的 100%, 高度由内容决定
  - 特殊情况: button 默认是 inline-block, 支持设置宽高, **即使把 button 的 display 设置为 block, 其宽度依然不会是父元素的 100%, 而是由内容决定的.** 
  - 其他的 inline 元素, 如 `<span>`, `<a>`, `<strong>`, 如果设置为 block, 则其宽度会自动变为父元素的 100%. 

- inline 元素不会独占一行, 宽高度由内容决定
  - 不能设置宽高, 若要设置宽和高, 需要将其转换为块级元素. 如 `display: block` 或 `display: inline-block`. 
  - 不可以设置上下 padding 和 margin, 可以设置左右 padding 和 margin.
  - 特殊情况: `margin-left: auto`, `margin-right: auto` 无法适用 inline 元素. 这也是为什么 tailwind css 中 `mx-auto` 使 inline 元素水平居中的原因.

- inline-block, 既可以设置宽高, 也可以设置所有 padding 和 margin, 其他与 inline 元素一样.

> flex 子元素既不是块级元素, 也不是内联元素, 而是 flex 元素, 有自己的特性. 若同在 flex box内, 则 `<a>` 与 `<div>` 在显示上是完全一样的, 因为他们都是 flex items. 
> 注意 flex 子元素的默认值是 `flex: 0 1 auto`, 即 `flex-grow: 0`, `flex-shrink: 1`, `flex-basis: auto`, 即默认情况下, flex 子元素是允许在必要情况下缩小的, 而不会增长, 从而导致 flex 子元素的宽度不是父元素的 100%, 而是由内容决定的.

## 2. Flex - Layout

Flex 有很多性质, 要区分哪些性质是用到 Flex Box 上的, 哪些是用到 Flex Items 上的. 可直接观看: https://youtu.be/fYq5PXgSsbE?si=yeeW9PDx-Als9CWX

### 2.1. Flex Box

- `flex-direction`: row | row-reverse | column | column-reverse;
  - Tailwind CSS: `flex-row`, `flex-col`

- `justify-content`: flex-start | flex-end | center | space-between | space-around | space-evenly;
  - Tailwind CSS: `justify-start`, `justify-end`, `justify-center`, `justify-between`,

- `align-items`: flex-start | flex-end | center 
  - Tailwind CSS: `items-start`, `items-end`, `items-center`

> **常用技巧:**
>
> 1. justify-between 主要是用来设置 flex items 之间的间距, 一般是让两个元素分布在容器左右或上下两端, 
> 2. 聊天软件, 自己信息靠右, 对方信息靠左, 不可以使用 `justify-self` 或 `align-self`, 前者是用于 Grid 布局的, 后者是用于 Flex 布局的交叉轴上的对齐方式. 更不可以单独对一个元素设置 `justify-start` 或 `justify-end`, 因为这是 flex box 的属性, 会影响所有的 flex items, 而不是单个元素. 你可以使用 `margin-left: auto` 或 `margin-right: auto` 来实现这个效果. 
> 3. `mx-auto` 用于水平居中, `my-auto` 用于垂直居中, 
> 4. 也可使用 order 属性来调整元素的顺序, 配合 justify-between 使用 (控制在两端, 一左一右), 只有两个元素这种简单情况下推荐使用. 

```js
export default function Message({role, text, time}) {
    const messageClass = role === 'bot' ? 'mr-auto bg-gray-300 text-black' : 'ml-auto bg-blue-300 text-white'
    const timePos = role === 'bot' ? 'order-2' : 'order-1'
    const rolePos = role === 'bot' ? 'order-1' : 'order-2'
    const sentTime = new Date(time).toLocaleString()

    return (
        <div className={messageClass} >
            <div className={'flex flex-row justify-between'}>
                <span className={rolePos}>{role}</span>
                <span className={timePos}>{sentTime}</span>
            </div>
            <p>{text}</p>
        </div>
    )
}
```

### 2.2. Flex Items

- **flex-grow:** 用来指定一个 flex 子项（flex item）相对于其他子项在可用空间中的扩展比例, 沿主轴方向。
  - Tailwind CSS 类名:`flex-grow`, `flex-grow-0` 
- **align-self:** 用来指定flex子项在**交叉轴**上的对齐方式, 会覆盖父容器的 align-items 属性。
  - 很好理解, align-self 是用来指定单个 flex item 在交叉轴上的对齐方式, 而 align-items 是用来指定所有 flex items 在交叉轴上的对齐方式. 前者用在 item上, 后者用在 flex box 上, 前者会覆盖后者.
  - Tailwind CSS 类名: `self-auto`, `self-start`, `self-center`, `self-end`, `self-stretch`
  - 了解更多: [Align Self - Tailwind CSS](https://tailwindcss.com/docs/align-self)

> **常用技巧-1:** 把 navigator 和 footer 设置为 `flex-grow: 0`, 然后中间的内容设置为 `flex-grow: 1`, 这样中间的内容会占据剩余的空间, 从而实现中间内容自动填充剩余空间的效果. (前提是他们都是 flex items, 即他们都在 flex box 内)

> **常用技巧-2:** 通常把元素设置为 flex-grow 后, 会自动填充剩余空间, 但如果该元素的内容很多, 就会导致溢出, 比如对话框, 此时应该会想到加个 overflow 属性, 但是这样并不会起作用, 原因是你没设置该元素的高度, 此时可以给个高度0, 这样即使内容为空因为 flex-grow 会自动填充剩余空间, 若内容溢出因为定义了高度, overflow 属性就会起作用了. 
> 了解更多: https://stackoverflow.com/a/14964944/16317008

**易错点-1:** flex-grow 是 flex items 的属性, 用来控制 flex tiems 如何在**主轴方向**上增长, 不要简单的以为是用来控制在水平方向上增长的. 比如在 flex-col 的情况下，flex-grow 影响的是items的高度，而不是宽度，因为主轴是垂直的. 

**易错点-2:** `justify-items` 和 `justify-self` 专门用于Grid布局, 不用于Flex布局, 了解更多: [Justify Items - Tailwind CSS](https://tailwindcss.com/docs/justify-items)

## 3. Position Absolute

最近写菜单栏的时候, 菜单栏展开后会将下面的内容挤下去, 像下面这样:

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/08/a199c94496cc4d1f2fbfdd7fd09478c4.jpg)

基本上菜单栏都很窄, 所以当菜单栏展开时, 我希望的是不影响下面的内容, 但是正常情况下两个元素要么是 inline 那种可以在同一行, 要么是 block 那种独占一行, 无法实现我想要的效果. 此时就可以使用 absolute 来实现, 如下:

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/08/997c2961834e857ceb3fbc392b90cb56.jpg)

> Absolute positioned elements are removed from the normal flow, and **can overlap elements**.

此时也应该注意覆盖的问题, 若对话框宽度为 100vw, 可能会覆盖掉对话框, 因此要将 z-index 设置大一些.  
