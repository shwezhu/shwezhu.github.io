---
title: SwiftUI 琐碎小知识
date: 2024-05-31 16:17:30
categories:
 - ios
---

### 1. 使用 HStack 水平排列

注意: Button 直接放入 VStack, 默认会在中间, 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/2f90b40d6bfa9c748e1f9dce5ec3a737.jpg)

### 2. 擅用三元操作符

刚开始想到的是新增一个 buttonName 属性, button 被点击时根据 showChild 来修改 buttonName 的值, 这样太麻烦了. 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/e782ef3efeb84ce96b8952fa9ee20d46.jpg)

### 3. NavigationLink 内 Button 点击不会生效

```swift
NavigationLink (destination: ...) {
    ReminderCatagoryView(reminderCount: allReminders.count, catagoryName: "All")
}

ReminderCatagoryView {
  var body: some view {
    ...
    Image(systemName: "flag.slash")
    .onTapGesture(perform: onDropped) // 使用onTapGesture
  }
}
```

