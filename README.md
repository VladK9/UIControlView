
### About

<p align="center">
  <img src="https://github.com/VladK9/UIControlView/blob/main/Assets/Preview.png" width="500">
</p>

Bottom view with multiple actions

## Features

- Highly customizable
   - cornerRadius
   - view width/height
   - showHideIndicator
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
  <img src="https://github.com/VladK9/UIControlView/blob/main/Assets/Multiple view's.png" width="500">
</p>

- Swipe to hide or press button
- Support dark/light theme
