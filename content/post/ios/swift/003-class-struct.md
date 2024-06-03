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

The default parameter names are `newValue` for `willSet` and `oldValue` for `didSet`, or you can name them yourself as in `willSet(newTotalSteps)`.

### 3. Properties

*Stored* and *computed properties* are usually associated with instances of a particular type. However, properties can also be associated with the type itself. Such properties are known as *type properties*.

In addition, you can define **property observers** to monitor changes in a property’s value, which you can respond to with custom actions. Property observers can be added to stored properties you define yourself, and also to properties that a subclass inherits from its superclass. 

You can also use a **property wrapper** to reuse code in the getter and setter of multiple properties.

#### 3.1. Lazy Stored Properties

A *lazy stored property* is a property whose initial value isn’t calculated until the first time it’s used. 

```swift
class DataManager {
    lazy var importer = DataImporter()
    var data: [String] = []
    // the DataManager class would provide data management functionality here
}

let manager = DataManager()
manager.data.append("Some data")
manager.data.append("Some more data")
// the DataImporter instance for the importer property hasn't yet been created

print(manager.importer.filename)
// the DataImporter instance for the importer property has now been created
// Prints "data.txt"
```

Because it’s possible for a `DataManager` instance to manage its data without ever importing data from a file, `DataManager` doesn’t create a new `DataImporter` instance when the `DataManager` itself is created. Instead, it makes more sense to create the `DataImporter` instance if and when it’s first used.

#### 3.2. Computed Properties

```swift
struct Rectangle {
   var width: Double
   var height: Double
   var area: Double {
       return width * height
   }
}

let rectangle = Rectangle(width: 5.0, height: 10.0)
print(rectangle.area)  // 50.0
```

References: https://arc.net/l/quote/uimgdzep

### 4. Computed Properties - getter and setter

In addition to stored properties, classes, structures, and enumerations can define *computed properties*, which don’t actually store a value. Instead, they provide a getter and an optional setter to retrieve and set other properties and values indirectly.

```swift
class Rectangle {
    var width: Double
    var height: Double

    var area: Double {
        get {
            return width * height
        }
        set(newArea) {
            width = sqrt(newArea / height) // 根据新面积调整宽度
        }
    }
}

let rect = Rectangle(width: 5, height: 4)
print(rect.area)  // 输出 20.0

rect.area = 50  // 修改面积，触发 setter
print(rect.width) // 输出 7.071... (约等于 √50/4)
```

> Stored property has default setter and getter, you cannot override `get`/`set` for a stored property.  But You can use property observers `willSet`/`didSet` to achiveve what you want.  Source: https://stackoverflow.com/a/24116083/16317008

### 6. Property Wrappers

Learn more: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/#Property-Wrappers
