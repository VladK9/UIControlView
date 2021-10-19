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
    
    // Background color
    public var backColor: backColor!
    
    // Text color
    public var tintColor: tintColor!
    
    // Action when tap CloseButton
    public var action: (() -> Void)?
    
    public init(title: String = "Close",
                backColor: backColor = .color(.black), tintColor: tintColor = .auto,
                action: (() -> Void)?) {
        self.title = title
        
        self.backColor = backColor
        self.tintColor = tintColor
        
        self.action = action
    }
    
}
