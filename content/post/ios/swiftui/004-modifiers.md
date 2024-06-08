---
title: SwiftUI Modifiers
date: 2024-06-07 16:22:30
categories:
 - ios
---

### 1. `.foregroundStyle()` and `.tint()`

- `.tint`
  - Targets: Works mainly on **interactive controls** like `Button`, `Toggle`, `Picker`, etc.
  - Effect: Changes the color of text and icons within these controls, but usually **doesn't affect plain `Text` views or other non-interactive elements**.
- `.foregroundStyle()`
  - More versatile, it changes the style (not just the color) of all foreground elements within a view hierarchy, including text, icons, shapes, etc. 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/b68b2b854568f35c371b5e1d22b60231.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/918b49e2021b1534f1274e732efe1522.jpg)

