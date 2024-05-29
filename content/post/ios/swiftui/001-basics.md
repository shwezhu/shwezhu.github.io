---
title: SwiftUI Basics
date: 2024-05-27 18:26:30
categories:
 - swift
 - ios
---

### 1. Property Wrappers

```swift
struct TaskEditView: View {
    @State var selectedTaskItem: TaskItem?
    @State var name: String
    
    init(passedTaskItem: TaskItem? = nil) {
        if let taskItem = passedTaskItem {
            self._selectedTaskItem = State(initialValue: taskItem)
            self._name = State(initialValue: taskItem.name ?? "")
        } else {
            self._name = State(initialValue: "")
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Task")) {
                TextField("Task Name", text: self.$name)
            }
        }
    }
}
```

`@State` 属性包装器在创建时, 会自动生成三个重要的组件：

1. **Wrapped Value (`self.name`)**: 这是通过 `@State` 包装的值的直接访问方式，即在你的例子中是类型为 `String` 的值。
2. **Storage (`self._name`)**: 这是对包装器本身的直接访问，允许你看到和操作底层的存储机制，通常在初始化或特定的操作中使用。
3. **Projected Value (`self.$name`)**: 这是一个提供了双向数据绑定能力的 `Binding` 类型。当你使用 `@State` 属性时，SwiftUI 为你自动生成这个 `Binding`，它允许你将状态与 UI 组件绑定，**使得 UI 可以显示状态的当前值，并在状态变化时自动更新显示. 这也是为什么上面有代码: `TextField("Task Name", text: self.$name)`

参考: https://stackoverflow.com/a/65209375/16317008

### 2. Modifiers

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/05/df1383f3a902606d7301b8da47bff81f.jpg)

### 3. Image & Space

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/05/43d67a15e7778406b97e2cbfc1d27cf6.jpg)
