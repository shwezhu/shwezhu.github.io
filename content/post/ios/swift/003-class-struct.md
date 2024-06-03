---
title: Struct & Class - Swift
date: 2024-05-26 16:03:35
categories:
 - ios
---

### 1. Struct vs Class

Structures are value types—unlike classes—local changes to a structure aren’t visible to the rest of your app unless you intentionally communicate those changes as part of the flow of your app. 

- **Structures are Value Types:** When you pass a structure to a function, or assign it to a variable, a *copy* of the structure's data is created. Modifying the copy doesn't affect the original.

- **Classes are Reference Types:** When you pass a class instance around, you're essentially passing a reference to the *same* underlying object. Changes made through one reference impact the original object and are visible everywhere else it's referenced.

References: [Choosing Between Structures and Classes | Apple Developer Documentation](https://developer.apple.com/documentation/swift/choosing-between-structures-and-classes)

### 2. Property observers: `didSet` and `willSet`

Property observers let you execute code whenever a property has changed. To make them work, we use either `didSet` to execute code when a property has just been set, or `willSet` to execute code before a property has been set.

```swift
class LightBulb {
    var brightness: Int = 0 {
        willSet(newBrightness) { // 显式声明 newValue 参数
            print("旧亮度为 \(brightness)，即将调整为 \(newBrightness)")
        }
        didSet {
            print("亮度从 \(oldValue) 调整为 \(brightness)")
        }
    }
}

let bulb = LightBulb()
bulb.brightness = 50  // 输出：旧亮度为 0，即将调整为 50
                      // 输出：亮度从 0 调整为 50
```

- `didSet`：在属性值被修改*后*执行，可以访问旧值（`oldValue`）和新值。`oldValue` 是默认参数，表示修改前的旧值。你不能显式地声明 `oldValue` 参数，它只能在 `didSet` 内部使用默认名称。

- `willSet`：在属性值被修改*前*执行，可以访问旧值和新值（`newValue`）。

### 3. 



