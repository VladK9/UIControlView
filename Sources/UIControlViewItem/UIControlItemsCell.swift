import UIKit
import Foundation

class UIControlItemsCell: UICollectionViewCell {
    
    var itemTintColor: itemTintColor!
    var itemBackColor: itemBackColor!
    
    var item = UIControlViewAction(item: .onlyTitle(""), tintColor: .standard, backColor: .standard, handler: {_ in})
    
    let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel()
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconView)
        addSubview(titleLabel)
        
        switch item.item {
        case .onlyTitle(_):
            titleLabel.font = UIControlViewHelper.roundedFont(fontSize: 11, weight: .semibold)
            titleLabel.numberOfLines = 3
        case .onlyIcon(_):
            titleLabel.numberOfLines = 0
        case .TitleWithIcon(_, _):
            titleLabel.font = UIControlViewHelper.roundedFont(fontSize: 9, weight: .semibold)
            titleLabel.numberOfLines = 2
        default: break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                UIView.animate(withDuration: 0.27, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    self.transform = self.transform.scaledBy(x: 0.95, y: 0.95) //0.93
                    
                    switch self.itemBackColor {
                    case .clear:
                        self.backgroundColor = .clear
                    case .custom(let backColor):
                        let auto = UIControlViewHelper.detectTheme(dark: UIColor.white.withAlphaComponent(0.05),
                                                                   light: backColor.withAlphaComponent(0.05),
                                                                   any: UIColor.black.withAlphaComponent(0.05))
                        
                        self.backgroundColor = auto
                    case .standard:
                        let auto = UIControlViewHelper.detectTheme(dark: UIColor.white.withAlphaComponent(0.05),
                                                                   light: UIColor.black.withAlphaComponent(0.05),
                                                                   any: UIColor.black.withAlphaComponent(0.05))
                        
                        self.backgroundColor = auto
                    case .customHEX(let hex):
                        let color = UIControlViewHelper.HexToUIColor(hex).withAlphaComponent(0.05)
                        let auto = UIControlViewHelper.detectTheme(dark: UIColor.white.withAlphaComponent(0.05),
                                                                   light: color,
                                                                   any: UIColor.black.withAlphaComponent(0.05))
                        
                        self.backgroundColor = auto
                    case .none:
                        self.backgroundColor = .clear
                    }
                })
            } else {
                UIView.animate(withDuration: 0.27, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    self.transform = .identity
                    
                    switch self.itemBackColor {
                    case .clear:
                        self.backgroundColor = .clear
                    case .custom(let backColor):
                        let auto = UIControlViewHelper.detectTheme(dark: .clear, light: backColor.withAlphaComponent(0.05), any: .clear)
                        
                        self.backgroundColor = auto
                    case .standard:
                        self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.05)
                    case .customHEX(let hex):
                        let color = UIControlViewHelper.HexToUIColor(hex).withAlphaComponent(0.05)
                        let auto = UIControlViewHelper.detectTheme(dark: .clear, light: color, any: .clear)
                        
                        self.backgroundColor = auto
                    case .none:
                        self.backgroundColor = .clear
                    }
                })
            }
        }
    }
    
}
