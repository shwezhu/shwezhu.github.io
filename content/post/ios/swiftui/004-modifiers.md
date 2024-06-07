---
title: SwiftUI Modifiers
date: 2024-06-07 16:22:30
categories:
 - ios
---

### 1. `Color.red` vs `.red`

`background()` 应该传入 `Color.red` 而不是直接 `.red`, 否则显示可能会不符合预期, 这和 [Implicit Member Expression](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/expressions/#Implicit-Member-Expression) 有关系.  

> This is called **implicit member expression**. in situations where the type can be inferred from other information, like return types, the actual type name can be omitted. 
>
> in `.background(Color.red)` it cannot be omitted, as the parameter isnt typed `Color`, but `some View`. it wouldn't know where to look for `red` if type was missing. [Source](https://stackoverflow.com/a/70132472/16317008)
>

如下定义所示, 调用 foregroundColor 时就可以直接使用 `.red`, 不必指定类型, 因为其参数类型就是 Color, 可以自动推断出来, 而 background 参数类型确实 S: ShapeStyle, 所以不能推断, 当然之所以能够用 color, 是因为 Color confirmed ShapeStyle, 

```swift
func foregroundColor(_ color: Color?) -> some View

func background<S>(
    _ style: S,
    ignoresSafeAreaEdges edges: Edge.Set = .all
) -> some View where S : ShapeStyle
```

### 2. `.foregroundStyle()` and `.tint()`

- `.tint`
  - Targets: Works mainly on **interactive controls** like `Button`, `Toggle`, `Picker`, etc.
  - Effect: Changes the color of text and icons within these controls, but usually **doesn't affect plain `Text` views or other non-interactive elements**.
- `.foregroundStyle()`
  - More versatile, it changes the style (not just the color) of all foreground elements within a view hierarchy, including text, icons, shapes, etc. 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/b68b2b854568f35c371b5e1d22b60231.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/918b49e2021b1534f1274e732efe1522.jpg)