---
title: Swift Basic Syntax and Data types
date: 2024-05-15 22:03:35
categories:
 - swift
 - ios
---

# 1. Implicit returns SE-0255

If the entire body of the function is a single expression, the function implicitly returns that expression.

```swift
// for: external parameter name
func greeting(for person: String) -> String {
    "Hello, " + person + "!"
}
print(greeting(for: "Dave"))
// Prints "Hello, Dave!"
```

## 2. Closure Expression

```swift
{ (<#parameters#>) -> <#return type#> in
   <#statements#>
}

// example
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
reversedNames = names.sorted(by: { (s1: String, s2: String) -> Bool in
    return s1 > s2
})
```

```swift
// Implicit Returns from Single-Expression Closures
// Inferring Type From Contextin page link
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
reversedNames = names.sorted(by: { s1, s2 in s1 > s2 } )
```

## 3. Properties

### 3.1. Lazy Stored Properties

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

### 3.2. Computed Properties

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

## 4. Function

### 4.1. Variadic Parameters

A *variadic parameter* accepts zero or more values of a specified type. 

```swift
func total(_ numbers: Double...) -> Double {
    var total: Double = 0
    for number in numbers {
        total += number
    }
    return total
}
total(1, 2, 3) // 6
```

### 4.2. In-Out Parameters

Function parameters are constants by default. Trying to change the value of a function parameter from within the body of that function results in a compile-time error. 

If you want a function to modify a parameter’s value, and you want those changes to persist after the function call has ended, define that parameter as an *in-out parameter* instead.

```swift
func swapTwoInts(_ a: inout Int, _ b: inout Int) {
    let temporaryA = a
    a = b
    b = temporaryA
}

var someInt = 3
var anotherInt = 107
swapTwoInts(&someInt, &anotherInt)
print("someInt is now \(someInt), and anotherInt is now \(anotherInt)")
// Prints "someInt is now 107, and anotherInt is now 3"
```















