---
title: Swift Syntax - Function & Class
date: 2024-05-26 16:03:35
categories:
 - swift
 - ios
---

## Function


### Optional Parameters

Swift中可选参数的行为很容易误导人, 让人错误的以为可选参数在调用函数的时候可以不提供, 然而并不是这样, 可选参数只是允许该参数值为 `nil`, 即使该值是 `nil`, 也必须显示提供. 

```swift
// withGreeting: external parameter name (or argument label)
func greet(name: String, withGreeting greeting: String?) {
    if let greeting = greeting {
        print("\(greeting), \(name)!")
    } else {
        print("\(name)!")
    }
}

// 即使 withGreeting 为 nil, 也必须提供 
greet(name: "Alice", withGreeting: nil) // No greeting: "Alice!"
greet(name: "Bob", withGreeting: "Hi") // Uses the provided greeting: "Hi, Bob!"
```

> "if let greeting = greeting" 这不是这个赋值语句吗, 怎么能用来判断呢?
>
> 在 Swift 中，`if let` 语句是一种特殊的语法结构，用于可选绑定（optional binding）。它不仅可以用来赋值，还可以用来判断一个可选值是否为 `nil`，并在可选值不为 `nil` 的情况下解包这个值。
>
> `if let` 语句的形式如下：
>
> ```swift
> if let unwrappedValue = optionalValue {
>     // 使用 unwrappedValue
> } else {
>     // optionalValue 为 nil
> }
> ```
>
> 在这段代码中：
>
> - `optionalValue` 是一个可选类型（即 `Optional`），可能包含一个值，也可能为 `nil`。
> - `unwrappedValue` 是一个常量，只有在 `optionalValue` 不为 `nil` 时才会被赋值，并且会被解包（unwrap）。

### Default Parameters

默认参数为参数提供一个默认值，这样在调用函数时**可以忽略这些参数**。

```swift
func greet(name: String, withGreeting greeting: String = "Hello") {
    print("\(greeting), \(name)!")
}

greet(name: "Alice") // 输出: "Hello, Alice!"
greet(name: "Bob", withGreeting: "Hi") // 输出: "Hi, Bob!"
```

```swift
func greet(name: String, withGreeting greeting: String) {
    print("\(greeting), \(name)!")
}

// compile error: 'nil' is not compatible with expected argument type 'String'
greet(name: "Alice", withGreeting: nil)
```

> 分清你要的东西是什么, 是允许参数为 nil 还是调用函数的时候不提供参数. 

### 可选参数常见用法 nil-coalescing operator

前面已经学到了使用 if 进行 unwrap 可选参数的值, 如下:

```swift
if let unwrappedValue = optionalValue {
 // 使用 unwrappedValue
} else {
 // optionalValue 为 nil
}
```

还有另一个常见的用法: nil-coalescing operator

```swift
func greet(name: String?) {
    // 如果 name 为 nil, 则 greetingName == "Guest"
    let greetingName = name ?? "Guest"
    ...
}
```

