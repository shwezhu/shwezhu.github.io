---
title: Property Wrappers - SwiftUI
date: 2024-06-02 16:32:10
categories:
 - ios
---

### 1. @State 

`@State` is a property wrapper struct that just wraps any value to make sure your view will refresh or redraw **whenever that value changes**. References: https://stackoverflow.com/a/59616812/16317008

**Always declare state as private,** and place it in the highest view in the view hierarchy that needs access to the value. Learn more: https://stackoverflow.com/a/72946113/16317008

@State 修饰的变量, 声明的时候一般要初始化, 因为 @State 都会被 private 修饰, 不能被外部访问, 而 @Binding 修饰的变量声明时不应该有值, 因为它要接受外部的 binding 值, 以便可以修改, 正如[文档](https://arc.net/l/quote/itwvjdmw)所表述: A binding connects a property to a source of truth stored elsewhere, instead of storing data directly. 

```swift
@State private var isPlaying: Bool = false
@Binding var isPlaying: Bool 
```

看到[一篇文章](https://onevcat.com/2021/01/swiftui-state/), 例子举的很好, 帮助理解State, 分享在这: 在 SwiftUI 中，我们使用 `@State` 进行私有状态管理，并驱动 `View` 的显示，下面的 `ContentView` 将在点击加号按钮时将显示的数字 +1：

```swift
struct ContentView: View {
    @State private var value = 99
    var body: some View {
        VStack(alignment: .leading) {
            Text("Number: \(value)")
            Button("+") { value += 1 }
        }
    }
}
```

当我们想要将这个状态值传递给下层子 View 的时候，直接在子 View 中声明一个变量就可以了:

```swift
struct DetailView: View {
    let number: Int
    var body: some View {
        Text("Number: \(number)")
    }
}

struct ContentView: View {
    @State private var value = 99
    var body: some View {
        VStack(alignment: .leading) {
            DetailView(number: value)
            Button("+") { value += 1 }
        }
    }
}
```

在 `ContentView` 中的 `@State value` 发生改变时，*`ContentView.body` 被重新求值，`DetailView` 将被重新创建*，包含新数字的 `Text` 被重新渲染。

如果我们希望的不完全是这种被动的传递，而是希望 `DetailView` 也拥有这个传入的状态值，并且可以自己对这个值进行管理的话，一种方法是在让 `DetailView` 持有自己的 `@State`，然后通过初始化方法把值传递进去：

```swift
struct DetailView0: View {
    @State var number: Int
    var body: some View {
        HStack {
            Text("0: \(number)")
            Button("+") { number += 1 }
        }
    }
}

// ContentView
@State private var value = 99
var body: some View {
    // ...
    DetailView0(number: value)
}
```

这种方法能够奏效，但是违背了 `@State` 文档中关于这个属性标签的说明：

> … declare your state properties as private, to prevent clients of your view from accessing them.

**如果一个 `@State` 无法被标记为 private 的话，一定是哪里出了问题**。一种很朴素的想法是，将 `@State` 声明为 `private`，然后使用合适的 `init` 方法来设置它。

```swift
struct DetailView1: View {
    @State private var number: Int

    init(number: Int) {
        self.number = number + 1
    }
    //
}
```

另外还有一些想说的, 看下面代码: 

```swift
struct DetailView: View {
    let randomNumber = Int.random(in: 1...100)
    var body: some View {
        Text("Random Number: \(randomNumber)")
    }
}

struct ContentView: View {
    @State private var value = 99
    
    var body: some View {
        Text("Number: \(value)")
        DetailView()
        Button("+") { value += 1 }
    }
}
```

 每次点击按钮, DetailView 的数字也会变化, 这就意味着每次 ContentView 被重新渲染的时候, 它的子 view 也被重新渲染了, 可是根据[官方文档](https://arc.net/l/quote/ekwiznyu)表述: When the @State value changes, SwiftUI updates the parts of the view hierarchy that depend on the value. 可是子 view `DetailView` 并没有依赖 @State value, 为什么还会被更新呢, 难道说每次 view 更新都会带着更新他的所有子 views? 答案是: 对的. 了解更多: [swift - Why does one child view in SwiftUI re-render on parent state change but another doesn't? - Stack Overflow](https://stackoverflow.com/questions/78635057/why-does-one-child-view-in-swiftui-re-render-on-parent-state-change-but-another)

### 2. @Published

> ⚠️ In iOS 17 and later, the `ObservableObject` protocol has been replaced by the `Observable` macro. It is now recommended to use the `Observable` macro to create observable objects and the `@Observable` property wrapper to publish property changes. [Click to learn more](https://www.youtube.com/watch?v=EK7SthdWV2w&t=306s)

In practical terms, that means **whenever an object with a property marked** `@Published` is changed, all views using that object will be reloaded to reflect those changes.

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/429b5b2b4d2b2bb43f74563fa5c27715.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/02e6f5fb20d45ebdc1f70a677f0d42f4.jpg)

Learn more: [SwiftUI Data Flow in iOS 17 - Observation & @Observable - YouTube](https://www.youtube.com/watch?v=EK7SthdWV2w&t=306s)

MVVM: [SwiftUI - Intro to MVVM | Example Refactor | Model View ViewModel](https://www.youtube.com/watch?v=FwGMU_Grnf8)

### 3. 