---
title: Swift Functions
date: 2024-05-26 16:03:35
categories:
 - swift
 - ios
---

## Functions


### 1. Optional Parameters

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

### 2. Default Parameters

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

> 参数必须为可选参数才可以使用 `??` , **只有可选参数可以为空**, 如果参数不是可选参数, 给的默认值也不能是空, 
>
> ```swift
> // 报错: Nil default argument value cannot be converted to type 'String'
> init(name: String = nil) {
>         self.name = name ?? ""
> }
> ```

### 3. Optional Chaining

尝试访问可选值的属性或方法时会用到, 如果可选值有值, 那么调用成功, 如果可选值是 `nil`, 则调用返回 `nil`, 整个过程不会因为尝试访问 `nil` 的属性而导致程序崩溃. 

```swift
class Cat {
    var name: String
    init(name: String) {
        self.name = name
    }
}

func printCatName(_ cat: Cat?) {
    // 若 cat 为 nil, 不会出现 nil 不存在 name 属性的异常
    if let name = cat?.name {
        print("The cat's name is \(name).")
    } else {
        print("No cat provided.")
    }
}
```

注意 Optional chaining 可以用于一切尝试访问可选值属性的行为, 以避免尝试访问 nil 的属性不存在异常发生,  上面的例子只是参数为可选值的情况, 

观察下面这段代码, 从逻辑上来说 selectedTaskItem 在 if 语句后必不为空, 所以下意识会想到 这里的 Optional Chaining 是不是多余的? 

```swift
@State var selectedTaskItem: TaskItem?

withAnimation {
    if selectedTaskItem == nil {
        selectedTaskItem = TaskItem(context: viewContext)
    }

    selectedTaskItem?.created = Date()
    selectedTaskItem?.name = name
    selectedTaskItem?.dueDate = dueDate
    selectedTaskItem?.scheduleTime = scheduleTime

    self.presentationMode.wrappedValue.dismiss()
}
```

答案并不是, 如果直接写为 `selectedTaskItem.name = name`, 则编译器会报错: `Value of optional type 'TaskItem?' must be unwrapped to refer to member 'created' of wrapped base type 'TaskItem'`

这是因为在 Swift 中，即使你在条件分支中对一个可选变量进行了赋值，这个变量的类型仍然保持为可选类型 (`Optional`)。因此，即使我们已经确信该可选变量不为 `nil`，编译器仍要求我们对其进行安全访问，因为从类型系统的角度来看，该变量仍然是可选的。

