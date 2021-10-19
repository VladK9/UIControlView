import UIKit

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

//MARK: - UIControlViewColorDelegate
public protocol UIControlViewColorDelegate: AnyObject {
    
    func didSelectColor(_ color: UIColor)
    
}

public extension UIControlViewDelegate {
    
    func didSelectColor(_ color: UIColor) {}
    
}
