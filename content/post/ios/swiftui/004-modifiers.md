---
title: SwiftUI Modifiers
date: 2024-06-07 16:22:30
categories:
 - ios
---

## 1. `.foregroundStyle()` and `.tint()`

- `.tint`
  - Targets: Works mainly on **interactive controls** like `Button`, `Toggle`, `Picker`, etc.
  - Effect: Changes the color of text and icons within these controls, but usually **doesn't affect plain `Text` views or other non-interactive elements**.
- `.foregroundStyle()`
  - More versatile, it changes the style (not just the color) of all foreground elements within a view hierarchy, including text, icons, shapes, etc. 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/b68b2b854568f35c371b5e1d22b60231.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/918b49e2021b1534f1274e732efe1522.jpg)

## 2. Other Common Used Modifiers

### 2.1. Text Modifiers

- `.font()`: `.largeTitle`, `.title`, `.title2`, `.headline`, `.subheadline`, `.body`, `.footnote`, `.font(.system(...))`

### 2.2. Image Modifiers

`.resizable()`, `.scaledToFit()`, `.scaledToFill()`, `aspectRatio(contentMode: .fill)`, `imageScale()`

> **Note**
>
> `.frame()` must be used after `.resizable()`, because image is not resizable by default. 
>
> `.scaledToFit()` and `.scaledToFill()` should be used before `.frame()`, if used after `.frame()`, it will not work. 

## 3. `padding()`

Adds an equal padding amount to specific edges of this view. 

padding 不要理解成 css 中的 padding 内边距, 在 swiftui 中它更像是一个外边距, 应用哪个 view 上面, 就会为其产生外边距, 而不是内侧. 我们看一下 padding 的词典解释: soft material such as foam or cloth used to pad or stuff something. 填充的东西, 比如在亚马逊买的杯子, 快递盒子里面有个泡沫, 泡沫里面才是 杯子, 而这个泡沫就是被子的 padding. 所以应用 padding modifier 的顺序也是至关重要. 

原理: The `padding` modifier adds padding to a view. It does so by taking the proposed size and subtracting the padding. 

解释: 

- SwiftUI布局是一个自上而下的过程, 父视图向 padding 提议一个可用的尺寸（proposed size）如 30
-  `padding` 收到 proposed size: 30, 会减去 16(默认) = 14, 将 proposed size = 14 传给子视图
- 原始视图基于这个较小的建议尺寸来决定自己的大小 (可以遵从或者不遵从, 取决与 view 的类型和应用的 modifier, 如 `.fixedSize()` 就会让 view 一直 report 理想的尺寸, 而不是父视图 propose 的尺寸)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/a882160400235c6d24501f1d7da567c0.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/5307d95b2a1819df63696dff31854401.jpg)

## 4. `.aspectRatio(1, contentMode: .fit)` 和  `.resizable()` 

`.aspectRatio()` 最常见的就是和 `.resizable()` 一起使用. 

### 4.1. `.resizable()`

```swift
func resizable(
    capInsets: EdgeInsets = EdgeInsets(),
    resizingMode: Image.ResizingMode = .stretch
) -> Image

// stretch: A mode to enlarge or reduce the size of an image so that it fills the available space.
```

所以应用了 resizable 的图片, 大小是根据可以用空间改变的, 这里的可用空间也可以理解为父视图为其 propose 的尺寸. 

如下, 图片默认, 是不接受父视图的 propose size, 只会 report 自己的 size. 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/deec310feffb04bd8358afc2160c004c.jpg)

加上 resizable, 图片便会接受 proposed size, 而  `aspectRatio(...)` 刚好就是修改 proposed size 的 (根据指定比例), 它俩天生一对. 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/0b21372a47e485e9de0514800f46357b.jpg)

比如我让图片的比例显示为正方形:

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/34929a01980bc6d950df3cb460b6b702.jpg)

虽然是正方形了, 宽高比为 1:1, 可能会问, 不是说 `resizable()` 让图片接受 propose size 吗, 为什么还是超出了 frame, 你仔细看清楚, 图片的直接上级是  `aspectRatio(...)` 而不是 `VStack` 的 `frame`, frame 给 vstack 一个 propose size, 然后 vstack 再把这个 size 传递给 `aspectRatio(...)`, 即 width: 200, height: 300, 然后我们给 `aspectRatio(...)` 的参数是 .fill, 宽高比为 1, 所以 `aspectRatio(...)` 修改 propose size 为 300 * 300 给 image, 因此呈现了现在的结果, 此时可以配合 ` .clipShape() ` 剪切掉图片多余的部分. 

### 4.2. `aspectRatio(...)`

- 第一个参数是宽高比（可选）, 若不提供, 则向上级 report 子视图理想的宽高比. 

- 第二个参数 `contentMode`: A flag indicating whether this view should fit or fill the parent context.

看个例子就明白了:

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/ac21acd601632c0d4631b04101704a54.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/6030eaef9667219db109b234fc47f51b.jpg)

> Note: In the initial image example, we didn't specify a fixed aspect ratio. By leaving the parameter off, the underlying view's [ideal size](https://www.swiftuifieldguide.com/layout/ideal-size/) is used to compute the aspect ratio. To compute the ideal size, the aspect ratio first proposes a ` nil×nil` size to its child. The child's ideal size is used as the aspect ratio, and the aspect ratio then either fits or fills a rectangle with the computed ratio within its proposal. [swiftuifieldguide.com](https://arc.net/l/quote/soiifgxm)

`.fill` 常与` .clipShape() `搭配使用.  **当你想确保 frame 被完全填满, 不留空白时使用**

`fit` 适应  frame, 当打算显示整个图像, 不丢失任何部分时使用

### 4.3. [Gotchas ](https://www.swiftuifieldguide.com/layout/aspect-ratio/#gotchas)

Perhaps surprisingly, the aspect ratio modifier only changes the *proposal*. For example, in [the view below](https://www.swiftuifieldguide.com/layout/aspect-ratio/#gotchas), it'll propose a square size to the text. However, as we can see from the border, the aspect ratio directly *reports* its child's size, and it doesn't report a square size.

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/c75f7a5823677fad634f98958e21c3eb.jpg)

上面这句话中的 proposal 和 report 是什么?

> The essence of SwiftUI's layout system is very simple: a parent **proposes** a size to its child, and the child **reports** a size.  
>
> 发现一个[动画](https://www.swiftuifieldguide.com/layout/introduction/#proposing)很清楚的解释了这一过程, 可以去查看, 如果不是很理解可以看这个视频: [How layout works in SwiftUI ](https://www.youtube.com/watch?v=04fzFk367Dg&t=28s)
>
> All SwiftUI layout happens in three simple steps, and understanding these steps is the key to getting great layouts every time. The steps are:
>
> 1. A parent view proposes a size for its child.
> 2. Based on that information, the child then chooses its own size and the parent *must* respect that choice.
> 3. The parent then positions the child in its coordinate space.

再看最上面那句话: the aspect ratio modifier only changes the *proposal*, 显然这是在说 aspect ratio modifier 只会偷偷修改建议尺寸的大小(比例), 但是孩子上报的尺寸 他会如实上报, 即我把我的建议尺寸给你, 接不接受就看你自己了. 且 swiftui 的逻辑是, 上级视图必须无条件接受(上报)下级尺寸的报告. 

了解更多: [Aspect Ratio - SwiftUI Field Guide](https://www.swiftuifieldguide.com/layout/aspect-ratio/#gotchas)

References: 

[Aspect Ratio - SwiftUI Field Guide](https://www.swiftuifieldguide.com/layout/aspect-ratio/)

[Introduction - SwiftUI Field Guide](https://www.swiftuifieldguide.com/layout/introduction/)

### 5. Flexible Frames

A flexible frame allows us to specify a minimum, ideal, and maximum value for each dimension. We can think of a frame as a “wrapper” view around its child that can **both change the proposal to its child and change the reported size**. One the most common usages is using `maxWidth: .infinity` to fill up the available width. 

> One the most common usages is using `maxWidth: .infinity` to fill up the available width. 注意, 是 maxWidth 不是 width. 

frame 的默认宽度是其子视图的 report width,  若指定 `maxWidth: .infinity` , 则 frame 会填满父视图, 若父视图宽度小于子视图的 report width, frame 的宽度将保持在 子视图的 report width, 类似 [child's report width, .infinity)

可以使用 `minWidth: 0`, 无条件接受父视图的宽度, 

> If we want to unconditionally accept the proposed width (regardless of the content's width), we can specify a minimum width of `0` and a maximum width of `.infinity`.

References: [Flexible Frames - SwiftUI Field Guide](https://www.swiftuifieldguide.com/layout/flexible-frames/)

## 5. 实例分析



