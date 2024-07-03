---
title: SwiftUI 踩坑记
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

### 4. 隐藏 NavigationLink 的箭头

```swift
List { 
    ForEach(elements) { element in
        ZStack {
            CustomView(element: element)
            NavigationLink(destination: DestinationView()) {
                EmptyView()
            }.opacity(0.0)
        }
    }
}
```

https://stackoverflow.com/a/68779379/16317008

### 5. 使用 SwiftData `Predicate` 的 View 不可以直接放到 NavigationStack 中

```swift
// 加一层 DummyView()
struct ContentView: View {
    var body: some View {
        NavigationStack {
            DummyView()
        }
    }
}

struct DummyView: View {
    var body: some View {
        ListsView()
    }
}

struct ListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Item> { _ in true }) 
		// ...
}
```

### 6. List Item 宽度填满屏幕

```swift
List {
    ...
}
.listStyle(PlainListStyle())
```

### 7. 本地后台通知 badge 数目

被新出的接口 `setBadgeCount(_ newBadgeCount: Int)` 误导了, 想着维护一个本地 count, 每次通知来了增加一, 可是 `UNUserNotificationCenterDelegate` 压根没有 *应用在后台时 来新通知* 的回调函数, 只有下面这个两个: 

- `userNotificationCenter(_ center:, willPresent:)`: get called the app was running in the foreground.
- `userNotificationCenter(_ center:, didReceive:)`: get called user interact with the notification.

然后苦逼的我苦苦思索了一下午不得解, 最后还是用了原来的旧方法:

```swift
func createNotificationContent(for reminder: Reminder) -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "有任务要做啦"
    content.body = reminder.title
    content.sound = .default
    // 'applicationIconBadgeNumber' was deprecated in iOS 17.0: Use -[UNUserNotificationCenter setBadgeCount:withCompletionHandler:] instead. 
    content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
    return content
}
```

### 8. 监控从后台进入主页面事件

除了 scene delegate, 比较简单的方法是使用 onReceive() modifier, 

```swift
@main
struct todolistApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onReceive(NotificationCenter.default.publisher(
                  for: UIApplication.didBecomeActiveNotification)) { _ in
                    NotificationManager.clearBadges()
                }
        }
    }
}

```

