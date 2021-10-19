import UIKit

class UIControlColorCell: UICollectionViewCell {
    
    let colorView: UIView = {
        let colorView = UIView()
        return colorView
    }()
    
    let selectedIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(colorView)
        
        colorView.addSubview(selectedIcon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                selectedIcon.isHidden = false
            } else {
                selectedIcon.isHidden = true
            }
        }
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
