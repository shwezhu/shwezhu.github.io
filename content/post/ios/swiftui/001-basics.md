---
title: SwiftUI Basics - Weather App
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

1. **Wrapped Value (`self.name`)**: 这是通过 `@State` 包装的值的直接访问方式，即在你的例子中是类型为 `String` 的值。
2. **Storage (`self._name`)**: 这是对包装器本身的直接访问，允许你看到和操作底层的存储机制，通常在初始化或特定的操作中使用。
3. **Projected Value (`self.$name`)**: 类型: `Binding<String>`, passing data down to subviews 经常会用到, 注意这是双向的, 如果在其 subview 修改 name, 主 view 中的 name 也会被修改, 这才是使用 binding 的目的, 即子视图打算修改主视图的数据. 

参考: https://stackoverflow.com/a/65209375/16317008

### 2. The Order of Applying Modifiers matters

可以看出 background 并没有作用在 frame 上, 即每个 modifier 都是返回了一个新的视图, 当前 modifier 都是作用在了前面的视图上, 所以使用 modifier 的顺序会影响最终视图的结果, 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/05/df1383f3a902606d7301b8da47bff81f.jpg)

### 3. Image & Space

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/05/8a5cd0431f346d79496187cf2c56c5ea.jpg)

> 把 Spacer() 理解成一个双向弹簧, 负责挤压元素

### 4. Background Color - LinearGradient

```swift
struct BackgroundView: View {
    var isNight: Bool
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [isNight ? .black : .blue, isNight ? .gray : .white]), startPoint:.top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

// 在 ZStack 中创建背景实例
ZStack {
  BackgroundView(isNight: false)
  // 其他组件...
}
```

除了 LinearGradient() 还可以使用ContainerRelativeShape()创建背景, 另外颜色也有 `.gradient ` 属性, 即不用像上面那样手动指定开头结尾了, 比较简洁但失去了定制性. 

```swift
struct BackgroundView: View {
    var isNight: Bool
    
    var body: some View {
        ContainerRelativeShape()
            .fill(.blue.gradient) // 颜色可以用 .gradient
            .ignoresSafeArea()  // 背景全屏
    }
}
```

### 5. 读文档写代码

```swift
Button {
    print("hello")
} label: {
    Text("Change Location")
        .frame(width: 280, height: 50)
        .background(.white)
        .font(.system(size: 20, weight: .bold, design: .default))
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
}
```

看 `clipShape` 的签名:

```swift
func clipShape<S>(
    _ shape: S,
    style: FillStyle = FillStyle()
) -> some View where S : Shape
```

1. style 有默认值可以不填, shape 没有默认值, 所以主要看 shape. 

2. shape 为类型 S 即符合 协议 Shape 的任何对象都可以, 那就看看 Shape 协议是什么. 
3. 打开开发者文档, 找到 Shape 往下拉, 找到 Conforming Types, 可以发现有好多 shape 可以使用, 
4. 这里选择 RoundedRectangle, 点击, 查看其初始化函数, 看看怎么创建 RoundedRectangle 对象
5. 有两个初始化函数, 这里选择`init(cornerSize: CGSize, style: RoundedCornerStyle = .continuous)`
6. 两个参数, cornerSize 不可省略, 查看 `CGSize` 构造函数: `init(width: Float, height: Float)`
7. 最后创建出圆角矩形: `.clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))`

### 6. 练习代码

```swift
struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint:.top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Halifax, CA")
                    // Every modifier wraps the previous view into another view.
                    .font(.system(size: 32, weight: .medium, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                VStack(spacing: 10) { // spacing: space between views in VStack
                    Image(systemName: "sun.snow.fill")
                        .renderingMode(.original)
                        .resizable() // 让图像可以调整大小
                        .aspectRatio(contentMode: .fit) // 缩放模式
                        .frame(width: 180, height: 180)
                    Text("-3°")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 40)
                HStack(spacing: 20) {
                    WeatherDayView(imageName: "snow", dayOfWeek: "TUE", temperature: -3)
                    WeatherDayView(imageName: "sun.rain.fill", dayOfWeek: "WED", temperature: -5)
                    WeatherDayView(imageName: "sun.max.fill", dayOfWeek: "THU", temperature: -2)
                    WeatherDayView(imageName: "wind", dayOfWeek: "FRI", temperature: 0)
                }
                Spacer() // Fill the remaining space in a VStack, pushing views above to the top.
                Button {
                    print("hello")
                } label: {
                    Text("Change Location")
                        .frame(width: 280, height: 50)
                        .background(.white)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                }
                Spacer() // 想象成弹簧卡在中间
            }
        }
    }
}

struct WeatherDayView: View {
    var imageName: String
    var dayOfWeek: String
    var temperature: Int
    
    var body: some View {
        VStack {
            Text(dayOfWeek)
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundStyle(.white)
                .padding()
            VStack(spacing: 10) {
                Image(systemName: imageName)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                Text("\(temperature)°")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    ContentView()
}
```

效果图:

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/05/69f2f45f523c984efcee3d4c6a98feba.jpg)





