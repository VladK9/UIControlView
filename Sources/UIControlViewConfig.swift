import UIKit

public enum selectedColor {
    case none
    case selected(top: Int, bottom: Int)
}

public enum viewType {
    case actions(_ actions: [UIControlViewAction])
    case color(_ colors: [UIColor], selected: selectedColor = .none)
}

// MARK: - UIControlViewConfig
public struct UIControlViewConfig {
    
    // UIControlView corner radius
    public var cornerRadius: CGFloat!
    
    // UIControlView size
    public var viewWidth: CGFloat!
    public var viewHeight: CGFloat!
    
    // Show/hide indicator
    public var showHideIndicator: Bool!
    
    // Max items to start scroll
    public var itemsToScroll: Int!
    
    public init(cornerRadius: CGFloat = 9,
                viewWidth: CGFloat = UIApplication.shared.windows.first(where: { $0.isKeyWindow })!.bounds.width-30,
                viewHeight: CGFloat = 80,
                showHideIndicator: Bool = false,
                itemsToScroll: Int = 5) {
        self.cornerRadius = cornerRadius
        
        self.viewWidth = viewWidth
        self.viewHeight = viewHeight
        
        self.showHideIndicator = showHideIndicator
        self.itemsToScroll = itemsToScroll
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
    static let defaultCellColor = UIColor(named: "UIControlViewDefaultCellColor")
    
}
