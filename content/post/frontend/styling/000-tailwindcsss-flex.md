---
title: Tailwind CSS Commonly Used Class
date: 2024-01-06 12:46:22
categories:
 - front-end
tags:
 - front-end
typora-root-url: ../../../static
---

## 1. Main Axis vs Cross Axis - Flex

> When elements are placed in a Flexbox container, they **lose** their original block and inline layout characteristics, with their sizing and positioning controlled by Flexbox properties. 
>
> flexbox 和 block container 是不同的概念, 即块级元素和inline元素重在强调 他们会占多大空间, 如何占 (一行还是可以并列) 而felx box在于强调它里面的元素是怎么安排的. (Flexbox and block containers are different concepts. Block and inline elements mainly **emphasize** the space they occupy and how they occupy it (whether they take up a full line or can be inline). Flexbox, on the other hand, focuses on how the elements inside are arranged.)

```jsx
<div className="flex flex-col">
    ...
</div>

<div className="flex flex-row">
    ...
</div>
```

> 为什么使用 class="flex flex-row" 只是用 class="flex-row" 不行吗?
> `flex` 确保元素变成一个 Flex 容器。`flex-row` 确保该容器内的项目沿着水平轴排列。

另外注意, **flex items 会自动填充满其 flex container 的沿着交叉轴方向的空间**, 也就是说, flex items 的宽度或高度会等于交叉轴的长度, 具体是高度还是宽度, 取决于主轴方向, **交叉轴方向就是主轴方向的垂直方向**. 

根据下面这个例子, 因为主轴方向是水平, 因此 flex items 的高度会等于 flex container 的高度, 至于宽度, 则是由其内容决定的 (flex-grow 默认值为 0).  

```jsx
<div className="flex flex-row h-64 border-2">
    <button className={'border-2'}>hello</button>
    <button className={'border-2'}>hello</button>
</div>
```

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/08/be19d5bccdb9e13c9239fc123b59393a.png)

> flex items 的三个属性 `flex-grow`, `flex-shrink`, `flex-basis` 的默认值是 flex-grow: 0, flex-shrink: 1, flex-basis: auto. 
> 注意这是 flex items 的属性, 不是 flex container 的属性. 

## 2. `flex-none`

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

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/08/289cb461d529a333865315227f29006a.png)

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

### 3.2 垂直居中

与上面类似, 不再赘述


## 4. 宽度高度内边距外边距

1. **宽度（Width）**:
   - Tailwind 使用 `w-{size}` 的模式来设置宽度，其中 `{size}` 可以是具体的数值或者百分比。例如：
     - `w-1/2`：元素宽度为容器宽度的 50%。
     - `w-4`：元素宽度为 1rem（默认情况下，所有的尺寸都基于 4 倍体系）。
     - `w-full`：元素宽度为 100%。

2. **高度（Height）**:
   - 高度的设置方式与宽度类似，使用 `h-{size}` 的格式。例如：
     - `h-10`：高度为 2.5rem。
     - `h-screen`：高度为视口的高度。

3. **内边距（Padding）**:
   - 内边距使用 `p-{size}` 的格式，针对所有四个方向，或者使用 `px-`、`py-`、`pt-`、`pb-`、`pl-`、`pr-` 分别设置水平、垂直、上、下、左、右的内边距。例如：
     - `p-4`：所有方向的内边距都是 1rem。
     - `px-2`：水平方向（左右）的内边距是 0.5rem。

4. **外边距（Margin）**:
   - 外边距的设置与内边距类似，使用 `m-{size}`，或者 `mx-`、`my-`、`mt-`、`mb-`、`ml-`、`mr-` 来分别设置。例如：
     - `m-5`：所有方向的外边距都是 1.25rem。
     - `mt-3`：上方外边距是 0.75rem。

## 5. Breakpoints

在 Tailwind CSS 中，断点（breakpoints）用于创建响应式设计，允许在不同屏幕尺寸下应用不同的样式规则。以下是 Tailwind CSS 中一些常见断点的用法及其解释：

1. **sm（Small）**:
   - `sm:` 前缀用于小屏幕设备。例如，`w-full md:w-1/2` : 小屏幕都会自动应用 w-full, 宽度大于 md 的, 宽度自动变为 w-1/2
