import UIKit
import Foundation

public enum itemTintColor {
    case standard
    case custom(_ color: UIColor)
    case customHEX(_ hex: String)
    case coloredImage(_ tintColor: UIColor)
}

public enum itemBackColor {
    case standard
    case clear
    case custom(_ color: UIColor) // alpha: CGFloat = 0.05
    case customHEX(_ hex: String)
}

public enum selectedImage {
    case singleImage(_ image: UIImage)
    case multiImage(_ selected: UIImage, _ unselected: UIImage)
}

public enum selectedTitle {
    case singleTitle(_ title: String)
    case multiTitle(_ selected: String, _ unselected: String)
}

public enum itemSetup {
    case onlyTitle(_ title: String)
    case onlyIcon(_ icon: UIImage)
    case TitleWithIcon(_ title: String, _ icon: UIImage)
}

public typealias UIControlViewActionHandler = (UIControlViewAction) -> Void

public class UIControlViewAction {
    
    public var item: itemSetup
    
    public var tintColor: itemTintColor
    public var backColor: itemBackColor
    
    private(set) var handler: UIControlViewActionHandler?
    
    public init(item: itemSetup, tintColor: itemTintColor = .standard, backColor: itemBackColor = .standard,
                handler: @escaping UIControlViewActionHandler) {
        self.item = item
        
        self.tintColor = tintColor
        self.backColor = backColor
        
        self.handler = handler
    }
    
}
