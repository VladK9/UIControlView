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
    
    // Action when tap CloseButton
    public var action: (() -> Void)?
    
    // Background color
    public var backColor: backColor!
    
    // Text color
    public var tintColor: tintColor!
    
    public init(title: String = "Close",
                backColor: backColor = .color(.black), tintColor: tintColor = .color(.white),
                action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
        self.backColor = backColor
        self.tintColor = tintColor
    }
    
}
