---
title: Tailwind CSS Flex
date: 2024-01-06 18:46:20
categories:
 - front-end
tags:
 - front-end
---

## Flex main axis and cross axis

使用 flex 布局时，首先想到的是两根轴线 — 主轴和交叉轴。主轴由 flex-direction 定义，另一根轴垂直于它。我们使用 flexbox 的所有属性都跟这两根轴线有关，所以有必要在一开始首先理解它: [Basic concepts of flexbox - CSS: Cascading Style Sheets | MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_flexible_box_layout/Basic_concepts_of_flexbox)

## Flex container and flex items

当一个元素设置为 flex container 时, 该元素的子元素就是 flex items,无论其子元素原本是 block 还是 inline 元素, flex items 的渲染显示是根据其自己的 flex 属性和 flex container 的属性来决定的, 而不是根据其原本的 display 属性来决定的. 因此 flex container 中的 `<div>` 和 `<a>` 显示效果是一样的. 

Flex items 有他们自己的属性, 如 flex-grow, flex-basis, align-self, order 等, 当然 flex container 也有他们自己的属性, 如 flex-direction, justify-content, align-items, align-content 等. Flex items 的属性需要在 flex container 内使用, 单独使用是无效的, 毕竟 flex items 是 flex container 的子元素. 否则, flex items 也就不是 flex items 了.

## Flex Items 常用属性

下面这些属性是用来控制 Flex items 的, 不可以用在 Flex container 上.

- **flex-grow:** 用来指定一个 flex 子项（flex item）相对于其他子项在可用空间中的扩展比例, 沿主轴方向。
  - Tailwind CSS:
    - `flex-grow` (flex-grow: 1; items 将等分可用空间)
    - `flex-grow-0` (flex-grow: 0; items 不会增长)

举例:
```jsx
<div style="display: flex;">
  <div style="flex-grow: 2;">A</div>
  <div style="flex-grow: 1;">B</div>
  <div style="flex-grow: 1;">C</div>
</div>
```

假设容器有额外的空间，这个空间将按照 2:1:1 的比例分配给三个子项。因此，A 将增长的空间是 B 或 C 的两倍。如果所有子项原本大小相同，A 将最终比 B 或 C 大。

> 易错点, flex-grow 是 flex items 的属性, 用来控制 flex tiems 如何在**主轴方向**上增长, 不要简单的以为是用来控制在水平方向上增长的.
> 比如在 flex-col 的情况下，flex-grow 影响的是items的高度，而不是宽度，因为主轴是垂直的。
> 若flex box的属性为 flex-row, 此时主轴是水平的, 此时若 flex items 没有设置 flex-grow, 则 flex items 的宽度是由其内容决定的, 也就是说, flex items 的宽度是不会随着 flex container 的宽度而变化的.

- **flex-shrink:** 控制 Flex items 在必要时如何缩小以适应空间, 同 flex-grow 沿主轴方向。
  - Tailwind CSS:
    - `flex-shrink` (flex-shrink: 1; items 将在空间不足时缩小)
    - `flex-shrink-0` (flex-shrink: 0; items 不会缩小)

- **flex-basis:** 指定了 flex items 在主轴方向的初始大小
  - Tailwind CSS:
    - `basis-[size]` (设置特定的尺寸，如 `basis-1/4`, `basis-5` 等)
    - `basis-1/6` 设置为 flex box 的 1/6, 可能是宽度, 也可能是高度, 取决于 flex box 的主轴方向

> 前面两个属性 flex-grow 和 flex-shrink 是用来控制 flex box 剩余空间如何细分给每个 flex items 的, 而 flex-basis 是用来控制 flex items 的初始大小的, 也就是说, flex items 的初始大小是由 flex-basis 决定的, 而不是由其内容决定的. 

- **flex:** 是 `flex-grow`, `flex-shrink` 和 `flex-basis` 的简写。
  - Tailwind CSS:
    - `flex-auto` (flex: 1 1 auto; 项目基于内容尺寸增长和缩小)
    - `flex-initial` (flex: 0 1 auto; 项目基于内容尺寸缩小但不增长)
    - `flex-none` (flex: none; 项目不会增长或缩小) 

> 默认值: `0 1 auto` 基于内容尺寸缩小但不增长

- **align-self:** 允许单个项目有不同于 Flex 容器的 `align-items` 值, 因此也是沿交叉轴方向。
  - Tailwind CSS:
    - `self-auto` (align-self: auto; 默认值)
    - `self-start` (align-self: flex-start; 顶部对齐)
    - `self-end` (align-self: flex-end; 底部对齐)
    - `self-center` (align-self: center; 中心对齐)
    - `self-stretch` (align-self: stretch; 拉伸填满容器)
    - `self-baseline` (align-self: baseline; 基线对齐)

- **order:** 改变项目在 Flex 容器中的位置。
  - Tailwind CSS:
    - `order-[number]` (设置项目的顺序，如 `order-1`, `order-2` 等)
    - `order-first` (order: -9999; 使项目排在最前)
    - `order-last` (order: 9999; 使项目排在最后)
    - `order-none` (order: 0; 默认排序)

## Flex box 常用属性

- **display: flex;**
  - Tailwind CSS: `flex`
  - 作用：将元素设置为 Flex 容器，其直接子元素将成为 Flex item。

- **flex-direction: row | row-reverse | column | column-reverse;**
  - 作用：设置 Flex 容器主轴方向
  - Tailwind CSS: 
    - `flex-row` (行，水平方向)
    - `flex-col` (列，垂直方向)

- **justify-content: flex-start | flex-end | center | space-between | space-around | space-evenly;**
  - 作用：在主轴上对齐 Flex 项目
  - Tailwind CSS:
    - `justify-start` (主轴起点对齐)
    - `justify-end` (主轴终点对齐)
    - `justify-center` (主轴中心对齐)
    - `justify-between` (项目之间平均分布)
    - `justify-around` (项目周围平均分布)
    - `justify-evenly` (项目间和周围平均分布)

- **align-items: stretch | flex-start | flex-end | center | baseline;**
  - 作用：在交叉轴上对齐 Flex 项目
  - Tailwind CSS:
    - `items-stretch` (拉伸填满容器高度)
    - `items-start` (交叉轴起点对齐)
    - `items-end` (交叉轴终点对齐)
    - `items-center` (交叉轴中心对齐)
    - `items-baseline` (基线对齐)

- **flex-wrap: nowrap | wrap | wrap-reverse;**
  - Tailwind CSS:
    - `flex-nowrap` (不换行)
    - `flex-wrap` (换行)
    - `flex-wrap-reverse` (反向换行)
  - 作用：定义 Flex 项目是否换行。

- **align-content: flex-start | flex-end | center | space-between | space-around | space-evenly;**
  - https://tailwindcss.com/docs/align-content

