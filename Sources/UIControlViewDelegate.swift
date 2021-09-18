import UIKit
import Foundation

public enum HideMethod {
    case isSwipe
    case isButton
}

public enum HideOrder {
    case isMain
    case isSubview
    case isAllClosed
}

public protocol UIControlViewDelegate: AnyObject {
    
    /**
     UIControlView: Called when pressed hide button or swiped last view.
     */
    func didHideView(_ method: HideMethod, _ order: HideOrder)
    
}

public extension UIControlViewDelegate {
    
    func didHideView(_ method: HideMethod, order: HideOrder) {}
}
