
### About

<p align="center">
  <img src="https://github.com/VladK9/UIControlView/blob/main/Assets/Banner-2.png">
</p>

Bottom view with infinity actions

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
   <img src="https://github.com/VladK9/UIControlView/blob/main/Assets/Without Indicator.jpg" width="310">
   <img src="https://github.com/VladK9/UIControlView/blob/main/Assets/With Indicator.jpg" width="310">
   
   - show with slide/fade animation
   <img src="https://github.com/VladK9/UIControlView/blob/main/Assets/Animation.GIF" width="350">
   
   - close button title
   - close button background color
   ```swift
   .theme(light: .black, dark: .white, any: .white)
   .color(.black)
   ```
   - close button tint color
   ```swift
   .theme(light: .black, dark: .white, any: .white)
   .color(.black)
   .auto - Color depends on closeBackColor (dark or light)
   ```


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
   - coloredImage(_ tintColor: UIColor) // If a multi-color image is used, only the text color changes
   ```
    
   Background color
   ```swift
   - standard
   - clear
   - custom(_ color: UIColor)
   - customHEX(_ hex: String)
   ```
   ## Item action

   Single action
    ```swift
   .init(item: .onlyTitle("Item with single action"), tintColor: .customHEX("#0C5AA9"), backColor: .custom(.blue), handler: { _ in
   }),
   ```

   Double action
   ```swift
   .init(item: .onlyTitle("Item with double action"),
         selectionConfig: .backWithBorder(.systemPurple),
         isPreselected: true,
         isSelected: { _ in
            //Selected
         }, isUnselected: { _ in
            //Unselected
         }),
     ```
   
- The ability to show one above the other view's
<p float="left">
  <img src="https://github.com/VladK9/UIControlView/blob/main/Assets/Multiple view's.png" width="400">
</p>

- Swipe to hide or press button
- Support dark/light theme

## Installation
Put `Sources` folder in your Xcode project. Make sure to enable `Copy items if needed`.

## Usage

## Actions

```swift
let view = UIControlView.self
let actions: [UIControlViewAction] = [
    .init(item: .TitleWithIcon("Item 1", UIImage(systemName: "highlighter")!), tintColor: .customHEX("890596"), backColor: .custom(.purple), handler: { _ in
    }),
    .init(item: .onlyTitle("Item 2"), tintColor: .customHEX("#0C5AA9"), backColor: .custom(.blue), handler: { _ in
    }),
    .init(item: .onlyTitle("Item with double action"),
          selectionConfig: .backWithBorder(.systemPurple),
          isPreselected: true,
          isSelected: { _ in
              //Selected
          }, isUnselected: { _ in
              //Unselected
          })
]
      
view.showHideIndicator = false
view.closeTitle = "Close"
view.closeBackColor = .theme(light: .black, dark: .white, any: .white) // .color(.black)
view.closeTintColor = .auto
view.showWithSlideAnimation = true
view.delegate = self
view.show(self, type: .actions(actions))
```

## Color

<img src="https://github.com/VladK9/UIControlView/blob/main/Assets/ColorView.jpeg" width="330">

```swift
let view = UIControlView.self
let colors: [UIColor] = [.gray, .systemBlue, .brown, .systemTeal, .systemCyan, .systemPink, .systemRed, .systemMint]
      
view.showHideIndicator = false
view.closeTitle = "Close"
view.closeBackColor = .theme(light: .black, dark: .white, any: .white) // .color(.black)
view.closeTintColor = .auto
view.showWithSlideAnimation = true
view.delegate = self
view.colorDelegate = self
view.show(self, type: .color(colors, selected: .none)) // selected: .selected(top: Int, bottom: Int) - Selected item on start
```

## Delegate

To get `hide method` or `order`, set the delegate with protocol `UIControlViewDelegate`:

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

To get `selected color`, set the delegate with protocol `UIControlViewColorDelegate`:

```swift
func didSelectColor(_ color: UIColor) {
    ... = color
}
```
