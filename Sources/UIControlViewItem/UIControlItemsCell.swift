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
                })
            } else {
                UIView.animate(withDuration: 0.27, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    self.transform = .identity
                })
            }
        }
    }
    
}
