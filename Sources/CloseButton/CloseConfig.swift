import UIKit
import Foundation

public struct CloseConfig {
    
    // Title
    public var title: String?
    
    // Action when tap CloseButton
    public var action: (() -> Void)?
    
    // Background color
    public var backColor: UIColor!
    
    // Text color
    public var tintColor: UIColor!
    
    public init(title: String?, backColor: UIColor?, tintColor: UIColor?, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
        self.backColor = backColor
        self.tintColor = tintColor
    }
    
}
