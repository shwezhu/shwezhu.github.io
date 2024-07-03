---
title: SwiftUI 琐碎小知识
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

### 8. UNUserNotificationCenterDelegate 和 UIApplicationDelegate 协议

**注意:** 使用 `UNUserNotificationCenterDelegate` 时, 要记得初始化, 因为其方法都是在特定条件下被系统自动调用的, 如果你不告诉系统谁是你的 通知代表, 系统只会调用默认 通知代表的方法, 即什么都不做. 

初始化方法一, 在实现 UNUserNotificationCenterDelegate 接口的类的 init() 函数中指定, 然后在程序启动时创建改该类的实例 (间接调用 init 函数)

```swift
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
  // 单例模式
  static let shared = NotificationDelegate()
  
  override init() {
    super.init()
    // 告诉系统谁是你的 通知代表 是谁
    UNUserNotificationCenter.current().delegate = self
  }

    func userNotificationCenter(willPresent notification...) {
        // In App, no sound, just banner.
        completionHandler([.banner])
    }
    ...
}

class AppDelegate: NSObject, UIApplicationDelegate {
    // 应用 launch (杀后台再进) 时被调用, 从后台切入不会被调用
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 确保 NotificationDelegate 的 init 函数被调用, 即初始化 NotificationDelegate.shared
        _ = NotificationDelegate.shared
        return true
    }
    // 进入前台 active 的时候被调用
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("aaa")
        NotificationManager.clearBadges()
    }
}

@main
struct todolistApp: App {
     // ApplicationDelegate 被指定为 AppDelegate, 程序启动会调用其application(...) 函数, 也就会初始化 NotificationDelegate.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDeleagte
    
    init() {
        NotificationManager.requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
    }
}
```

方法二, 合并  UNUserNotificationCenterDelegate 和 UIApplicationDelegate 

```swift
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: - UIApplicationDelegate
    
    // 应用 launch (杀后台再进) 时被调用, 从后台切入不会被调用
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 这行代码很重要
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("aaa")
        NotificationManager.clearBadges()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Tells the delegate how to handle a notification that arrived while the app was running in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // In App, no sound, just banner.
        completionHandler([.banner])
    }
    
    // When there is a notification, and user click the notification, this function will be called.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
```

> UIApplicationDelegate,  UNUserNotificationCenterDelegate 的方法都是在特定场景被自动调用的, 我们只需要写好方法体内的逻辑就好了, 要做的就是指定 UIApplicationDelegate 是谁, UNUserNotificationCenterDelegate  是谁:
>
> ```swift
> // 指定 UNUserNotificationCenterDelegate 
> UNUserNotificationCenter.current().delegate = self
> // 指定 UIApplicationDelegate
> @UIApplicationDelegateAdaptor(AppDelegate.self) var appDeleagte
> ```

### 8. 
