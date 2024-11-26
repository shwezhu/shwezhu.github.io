---
title: Commonly Used Flex Styles
date: 2024-11-26 20:46:20
categories:
 - front-end
tags:
 - front-end
typora-root-url: ../../../static
---

建议: css内容, 并列的东西放一块, 而不是分类放, 这样修改比较容易找位置看对比, 比如下面的内容, 最好是把 `course-details` 和 `course-title-description` 的 css 放一块, 这样我们想修改二者的css做对比的时候才比较好找他们对应的css, 而不是每次都得往下翻很久...

```html
<article className="course-card">
  <div className="course-title-description">
    ...
  </div>
  <div className="course-details">
    <div className="course-meta">
      ...
    </div>
    <div className="course-stats">
      ...
    </div>
  </div>
</article>
```

-----





一个盒子, 两端各放一个

```css
<div class="flex-between">
  <div>Left element</div>
  <div>Right element</div>
</div>
```





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

## 3. 水平和垂直居中 - Flex

### 3.1 水平居中

对于 `flex-row` 主轴就是水平方向, 简单使用 justify-center (沿主轴方向操作 flex items) 即可使 flex items 水平居中. 

```jsx
<div className="flex flex-row justify-center">
    ...
</div>
```

对于 `flex-col` 主轴就是垂直方向, 使用 items-center (沿交叉轴方向操作 flex items) 即可使 flex items 水平居中. 

```jsx
<div className="flex flex-col items-center h-64 border-2">
    <button className={'border-2'}>hello</button>
    <button className={'border-2'}>hello</button>
</div>
```

> 你也可以使用 mx-auto, 但 mx-auto 只作用于块级元素, 因此你可能需要把 flex items 改为块级元素, 别忘了 flex items 既不是块级元素也不是行内元素, 你需要将其父的 display: flex 去掉. 



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
