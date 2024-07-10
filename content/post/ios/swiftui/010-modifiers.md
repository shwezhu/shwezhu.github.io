---
title: SwiftUI Modifiers
date: 2024-07-09 20:55:10
categories:
 - ios
---

## 1. `padding()`

Adds an equal padding amount to specific edges of this view. 

padding 不要理解成 css 中的 padding 内边距, 在 swiftui 中它更像是一个外边距, 应用哪个 view 上面, 就会为其产生外边距, 而不是内侧. 我们看一下 padding 的词典解释: soft material such as foam or cloth used to pad or stuff something. 填充的东西, 比如在亚马逊买的杯子, 快递盒子里面有个泡沫, 泡沫里面才是 杯子, 而这个泡沫就是被子的 padding. 所以应用 padding modifier 的顺序也是至关重要. 

原理: The `padding` modifier adds padding to a view. It does so by taking the proposed size and subtracting the padding. 

解释: 

- 在SwiftUI中，布局是一个自上而下的过程。父视图A会向子视图B提议一个可用的尺寸（proposed size）如 30。
- 当一个视图应用了 `padding` 修饰符后，它会创建一个新的容器视图C, padding 默认为 16。
- 这个容器视图C在接收到父视图A的尺寸建议(30)时，会先从这个建议尺寸中减去padding的值(16)。
- 然后，它会将剩下的尺寸(14)建议传递给它所包装的原始视图B。
- 原始视图基于这个较小的建议尺寸来决定自己的大小。

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/a882160400235c6d24501f1d7da567c0.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/5307d95b2a1819df63696dff31854401.jpg)

## 2. Flexible Frames

One the most common usages is using `maxWidth: .infinity` to fill up the available width. 

If you want to unconditionally accept the **proposed width** (regardless of the content's width), we can specify a minimum width of `0` .  

这就适合显示图片, 因为图片尺寸很可能不一样, 我们需要使用 frame 让每个图片大小都相同, 当然此时还要配合 `scaledToFill()` 和 `.clipShape`, 前者让图片填满整个 frame, 后者剪切图片多余的部分不让图片超出 frame. 

这里就有个问题, 如果不使用 frame, 那要显示的东西就是默理想大小, 即使frame的父视图不够大, 如下图所示:

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/1e9dcde21606cda26f0a178ca38642fb.jpg)

试想如果 text("hello world") 是图片, 那就会导致图片大小(宽高)不一致, 可是如果我们使用 frame, 就需要

## 3.  LazyVGrid

### 3.1. Column Layout Algorithm 

The column layout algorithm runs in two steps. It takes the remaining width, and distributes it among the columns, similar to [HStack](https://www.swiftuifieldguide.com/layout/hstack/). These are the steps to distribute the space:

- 初始设置: 首先, 系统计算出可用的总宽度, 通常是 LazyVGrid 的容器宽度。

- For each column but the last, the spacing is subtracted from the remaining width. 系统会从总宽度中减去除最后一列外所有列之间的间距。例如,如果有3列,只需要减去2个间距的宽度。
- The columns are given their width in order, but all the fixed width columns come first.
- For each column, we propose the remaining width divided by the number of remaining columns, and subtract the returned column width from the remainder. 对于每一个灵活宽度的列: a. 系统计算当前剩余宽度除以剩余的列数。 b. 将这个值作为建议宽度提供给列。 c. 列可能会接受这个宽度,或者要求更小的宽度。 d. 系统从剩余宽度中减去列实际使用的宽度。重复进行...

Each of the column types responds differently to the proposed width:

- A fixed column discards the proposed width and always becomes the fixed size.
- An adaptive column accepts the proposed width. 
- A flexible column becomes the proposed width, clamped to its constraints.  flexible column 会采用建议宽度,但会被限制在其约束范围内. 

After all columns have a width, the grid will expand the adaptive columns. For each adaptive column, it will take the column's width and try to fit in as many columns as possible (given the constraints).

### 3.2. Flexible vs Adaptive

Flexible 列着重于分配可用空间，保持列数不变。

Adaptive 列着重于它们会根据可用空间自动调整列数 (一般都会指定最小尺寸), 如果空间不足，后面的 grid item 换行到下一行。

### 3.2. Pratice

若grid里只有 adaptive 列, 则所有列均分屏幕宽度高度, 即每个 grid item 大小相同:

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/288b4b8a2dfbe9aa1b7c380afdfd937a.jpg)

根据这个逻辑, 若我们在





References: [LazyVGrid - SwiftUI Field Guide](https://www.swiftuifieldguide.com/layout/lazyvgrid/)

