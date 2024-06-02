---
title: SwiftUI Basics - Weather App
date: 2024-05-31 16:17:30
categories:
 - ios
---

### 1. Color

`background()` 应该传入 `Color.red` 而不是直接 `.red`, 否则显示可能会不符合预期, 这和 [Implicit Member Expression](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/expressions/#Implicit-Member-Expression) 有关系.  

> This is called **implicit member expression**. in situations where the type can be inferred from other information, like return types, the actual type name can be omitted. 
>
> in
>
> ```swift
> .background(Color.red)
> ```
>
> it cannot be omitted, as the parameter isnt typed `Color`, but `some View`. it wouldn't know where to look for `red` if type was missing. [Source](https://stackoverflow.com/a/70132472/16317008)

如下定义所示, 调用 foregroundColor 时就可以直接使用 `.red`, 不必指定类型, 

```swift
func foregroundColor(_ color: Color?) -> some View

func background<S>(
    _ style: S,
    ignoresSafeAreaEdges edges: Edge.Set = .all
) -> some View where S : ShapeStyle
```

### 2. 使用 HStack 水平排列

Button 直接放入 VStack, 默认会在中间, 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/2f90b40d6bfa9c748e1f9dce5ec3a737.jpg)

