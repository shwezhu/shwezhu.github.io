---
title: Property Wrappers - SwiftUI
date: 2024-06-02 16:32:10
categories:
 - ios
---

### 1. @State 

`@State` is a property wrapper struct that just wraps any value to make sure your view will refresh or redraw **whenever that value changes**. References: https://stackoverflow.com/a/59616812/16317008

#### 1.1. Two-Way Binding - Projected Value

For state variables — variables defined with a [`State`](https://developer.apple.com/documentation/SwiftUI/State) property wrapper — the dollar sign (`$`) prefix tells SwiftUI to pass the **projectedValue**, which is a **Binding**. 

首先看看 projectedValue 和 Binding 是干什么的: 

> Use the *projected value* to get a *Binding* to the *stored value*. To access the `projectedValue`, prefix the property variable with a dollar sign (`$`).
>
> Use a binding to create a two-way connection **between** a property that stores data, **and** a view that displays and changes the data. A binding connects a property to a source of truth stored elsewhere, instead of storing data directly.

 For example, a button that toggles between play and pause can create a binding to a property of its parent view using the `Binding` property wrapper. 

```swift
struct PlayButton: View {
    // create a binding to a property of its parent view. 
    @Binding var isPlaying: Bool

    var body: some View {
        Button(isPlaying ? "Pause" : "Play") {
            isPlaying.toggle()
        }
    }
}
```

The parent view declares a property to hold the playing state, using the [`State`](https://developer.apple.com/documentation/swiftui/state) property wrapper to indicate that this property is the value’s source of truth.

```swift
struct PlayerView: View {
    var episode: Episode
    // @State indicates that this property is the value’s source of truth.
    @State private var isPlaying: Bool = false


    var body: some View {
        VStack {
            Text(episode.title)
                .foregroundStyle(isPlaying ? .primary : .secondary)
            PlayButton(isPlaying: $isPlaying) // Pass a binding.
        }
    }
}
```

通过 `$` 来访问 State 修饰的属性可以得到该属性的 Projected Value, 而 Binding 就是一个行为: 允许子 view 修改父 view 的属性的值. 

比如上面我们创建 PlayButton 视图实例的时候 `PlayButton(isPlaying: $isPlaying)`, 就是把 PlayerView 的属性 `isPlaying` 的 Projected Value `$isPlaying` 传递给`PlayButton`, `$isPlaying` 的类型是 `Binding<bool>`, 之所以可以这么传递, 是因为 `PlayButton` 的属性是 `@Binding var isPlaying: Bool`. 即把父视图的属性 `isPlaying` 绑定到了子视图的 `isPlaying` 属性上, 因此子视图修改其自己的属性 `isPlaying` 时, 也会影响父视图的 `isPlaying`. 

References: 

- https://arc.net/l/quote/dtuxzrwy
- https://stackoverflow.com/a/59616812/16317008
- https://developer.apple.com/documentation/swiftui/state/projectedvalue

### 2. @Published

> ⚠️ In iOS 17 and later, the `ObservableObject` protocol has been replaced by the `Observable` macro. It is now recommended to use the `Observable` macro to create observable objects and the `@Observable` property wrapper to publish property changes. [Click to learn more](https://www.youtube.com/watch?v=EK7SthdWV2w&t=306s)

In practical terms, that means **whenever an object with a property marked** `@Published` is changed, all views using that object will be reloaded to reflect those changes.

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/429b5b2b4d2b2bb43f74563fa5c27715.jpg)

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/02e6f5fb20d45ebdc1f70a677f0d42f4.jpg)

Learn more: [SwiftUI Data Flow in iOS 17 - Observation & @Observable - YouTube](https://www.youtube.com/watch?v=EK7SthdWV2w&t=306s)