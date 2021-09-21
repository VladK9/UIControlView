
### About



<p align="center">
  <img src="https://github.com/VladK9/UIControlView/blob/main/Assets/Banner.png">
</p>

Bottom view with multiple actions

## Navigate

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Delegate](#delegate)

## Features

- Highly customizable
   - cornerRadius
   - view width/height
   - show/hide indicator
   - show with slide/fade animation
   - close button title
   - close button background color
   - close button tint color


   ### Each item config
   
   Item
   ```swift
   - onlyTitle(_ title: String)
   - onlyIcon(_ icon: UIImage)
   - TitleWithIcon(_ title: String, _ icon: UIImage)
   ```
   
   <p float="left">
   <img src="https://github.com/VladK9/UIControlView/blob/main/Assets/Item configs.png" width="350">
   </p>
   
   Tint color
   ```swift
   - standard
   - custom(_ color: UIColor)
   - customHEX(_ hex: String)
   - coloredImage(_ tintColor: UIColor)
   ```
    
   Background color
   ```swift
   - standard
   - clear
   - custom(_ color: UIColor)
   - customHEX(_ hex: String)
   ```
   
- The ability to show one above the other view's
<p float="left">
  <img src="https://github.com/VladK9/UIControlView/blob/main/Assets/Multiple view's.png" width="400">
</p>

- Swipe to hide or press button
- Support dark/light theme

## Installation
Put `Sources` folder in your Xcode project. Make sure to enable Copy items if needed.

## Usage

```swift
let view = UIControlView.self
let actions: [UIControlViewAction] = [
    .init(item: .TitleWithIcon("Item 1", UIImage(systemName: "highlighter")!), tintColor: .customHEX("890596"), backColor: .custom(.purple), handler: { _ in
    }),
    .init(item: .TitleWithIcon("Item 2", UIImage(systemName: "folder")!), tintColor: .customHEX("#0C5AA9"), backColor: .custom(.blue), handler: { _ in
    }),
    .init(item: .TitleWithIcon("Item 3", UIImage(systemName: "trash")!), tintColor: .custom(.red), backColor: .custom(.red), handler: { _ in
    })
]
      
view.showHideIndicator = false
view.closeTitle = "Close"
view.closeBackColor = .black
view.closeTintColor = .white
view.showWithSlideAnimation = true
view.delegate = self
view.show(self, actions: actions)
```

## Delegate

To get `hide method` or `order` of view, set the delegate with protocol `UIControlViewDelegate`:

```swift
func didHideView(_ method: HideMethod, _ order: HideOrder) {
    if method == .isSwipe {
        print("isSwipe")
    } else if method == .isButton {
        print("isButton")
    }
        
    if order == .isMain {
        print("isMain")
    } else if order == .isSubview {
        print("isSubview")
    } else if order == .isAllClosed {
        print("isAllClosed")
    }
}
```
