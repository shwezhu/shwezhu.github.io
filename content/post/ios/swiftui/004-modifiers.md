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

## 3. `.aspectRatio(1, contentMode: .fit)`

- 第一个参数是宽高比（可选）

- 第二个参数是 `contentMode`: A flag indicating whether this view should fit or fill the parent context.

`fill` 填充 `frame(...)` , 若 `aspectRatio(...)` 比例和 `frame(...)` 宽高比不一样, 图像会超出frame, 常与` .clipped() `搭配使用. 如例子 2 和 3. **当你想确保 `frame` 被完全填满，不留空白时使用**

`fit` 适应  `frame(...)` , 图像永远不会超过 frame, 如 4, 5. **当打算显示整个图像，不丢失任何部分时使用**

只使用 `.aspectRatio(1, contentMode: .fill)`, 而无 frame 和 clip 把图像固定在frame内, 一般都会出现无法预期的情况. 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/85acefde62a46cb6ae8e50fd625d4852.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/61ee9b23631dbfabb9a602aeb2fc697a.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/07/d971ad9617f274b4262c0536df80a74c.jpg)
