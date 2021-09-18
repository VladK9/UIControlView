import UIKit
import Foundation

// MARK: - UIControlViewConfig
public struct UIControlViewConfig {
    
    // UIControlView corner radius
    public var cornerRadius: CGFloat!
    
    // Maximum items in UIControlView
    public var maxItems: Int!
    
    // UIControlView size
    public var viewWidth: CGFloat!
    public var viewHeight: CGFloat!
    
    // Show hide indicator or not
    public var showHideIndicator: Bool!
    
    // Enable sizeToFit
    public var sizeToFit: Bool!
    
    public init(cornerRadius: CGFloat = 9,
                maxItems: Int = 8,
                viewWidth: CGFloat = UIScreen.main.bounds.width-26,
                viewHeight: CGFloat = 80,
                showHideIndicator: Bool = false,
                sizeToFit: Bool = false) {
        self.cornerRadius = cornerRadius
        self.maxItems = maxItems
        
        self.viewWidth = viewWidth
        self.viewHeight = viewHeight
        
        self.showHideIndicator = showHideIndicator
        self.sizeToFit = sizeToFit
    }
}

// MARK: - UIControlViewQueue
public struct UIControlViewQueue {
    
    public var uuid: [Int]!
    public var config: UIControlViewConfig!
    public var actions: [UIControlViewAction]!
    
    public init(uuid: [Int], config: UIControlViewConfig, actions: [UIControlViewAction]) {
        self.uuid = uuid
        self.config = config
        self.actions = actions
    }
}

// MARK: - UIControlViewIDQueue
public struct UIControlViewIDQueue {
    
    public struct uuidQueue {
        var backView: Int!
        var itemsView: Int!
        var hideIndicator: Int!
    }
    
    public var uuid: [uuidQueue]!
    
    public init(uuid: [uuidQueue]) {
        self.uuid = uuid
    }
}

// MARK: - UIControlViewID
class UIControlViewID {
    
    let shared = UIControlViewID()
    
    static let backViewID = 100010001
    static let containerViewID = 200020002
    static let hideViewID = 300030003
    static let IDArray = [backViewID, containerViewID, hideViewID]
}

class UIControlViewColors {
    
    let shared = UIControlViewColors()
    
    static let mainColor = UIColor(named: "UIControlViewMainColor")
    static let revColor = UIColor(named: "UIControlViewRevMainColor")
    
}
