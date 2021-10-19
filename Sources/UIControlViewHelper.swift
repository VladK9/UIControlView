import UIKit
import Foundation

class UIControlViewHelper {
    
    let shared = UIControlViewHelper()
    
    //MARK: - roundedFont()
    static func roundedFont(fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        if #available(iOS 13.0, *) {
            if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: fontSize)
            } else {
                return systemFont
            }
        } else {
            return systemFont
        }
    }
    
    //MARK: - detectTheme()
    static func detectTheme(dark: UIColor, light: UIColor, any: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
            if userInterfaceStyle == .dark {
                return dark
            } else {
                return light
            }
        } else {
            return any
        }
    }
    
    //MARK: - HexToUIColor(_ hex: String)
    static func HexToUIColor(_ hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

// MARK: - Detect gesture direction
extension UIPanGestureRecognizer {

    public struct PanGestureDirection: OptionSet {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        static let Up = PanGestureDirection(rawValue: 1 << 0)
        static let Down = PanGestureDirection(rawValue: 1 << 1)
        //static let Left = PanGestureDirection(rawValue: 1 << 2)
        //static let Right = PanGestureDirection(rawValue: 1 << 3)
    }

    private func getDirectionBy(velocity: CGFloat, greater: PanGestureDirection, lower: PanGestureDirection) -> PanGestureDirection {
        if velocity == 0 {
            return []
        }
        return velocity > 0 ? greater : lower
    }

    public func direction(in view: UIView) -> PanGestureDirection {
        let velocity = self.velocity(in: view)
        let yDirection = getDirectionBy(velocity: velocity.y, greater: PanGestureDirection.Down, lower: PanGestureDirection.Up)
        //let xDirection = getDirectionBy(velocity: velocity.x, greater: PanGestureDirection.Right, lower: PanGestureDirection.Left)
        return (yDirection)
    }
}

extension UIView {
    
    //MARK: - UIControlViewShadow()
    func UIControlViewShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
    
    //MARK: - UIControlViewRoundCorners()
    func UIControlViewRoundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
    
}

extension UIColor {
    
    //MARK: - isLight
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.8
    }
    
    //MARK: - lighter/darker
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
    
}
