import UIKit

public enum tintColor {
    case color(_ color: UIColor)
    case theme(light: UIColor, dark: UIColor, any: UIColor)
    case auto
}

public enum backColor {
    case color(_ color: UIColor)
    case theme(light: UIColor, dark: UIColor, any: UIColor)
}

public struct CloseConfig {
    
    // Title
    public var title: String!
    
    // Text color
    public var tintColor: tintColor!
    
    // Background color
    public var backColor: backColor!
    
    // Action when tap CloseButton
    public var action: (() -> Void)?
    
    public init(title: String = "Close",
                tintColor: tintColor = .auto,
                backColor: backColor = .color(.black),
                action: (() -> Void)? = nil) {
        self.title = title
        
        self.backColor = backColor
        self.tintColor = tintColor
        
        self.action = action
    }
    
}
