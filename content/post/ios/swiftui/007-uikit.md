---
title: UIKit in SwiftUI
date: 2024-06-08 21:55:30
categories:
 - ios
---

### 1. UIViewControllerRepresentable

`UIViewControllerRepresentable` is a view that represents a UIKit view controller. Use a [`UIViewControllerRepresentable`](https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable) instance to create and manage a [`UIViewController`](https://developer.apple.com/documentation/uikit/uiviewcontroller) object in your SwiftUI interface. 

We want use SFSafariViewController, cause SwiftUI cannot use `SFSafariViewController` directly, so we wrap it with `UIViewControllerRepresentable`. 

```swift
import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    // typealias Context = UIViewControllerRepresentableContext<Self>
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // This method is usually left empty for SFSafariViewController.
    }
}
```

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/06/09bfd9ae3e90671f9516329428798591.jpg)