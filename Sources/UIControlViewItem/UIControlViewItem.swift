import UIKit
import Foundation

class UIControlViewItem: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var actionViewSize = CGSize()
    var itemsData = [UIControlViewAction]()
    var itemsConfig = UIControlViewConfig()
    
    let cellSpacing: CGFloat = 4
    var cellInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    let hideIndicator: UIView = {
        let hideView = UIView()
        hideView.backgroundColor = UIControlViewColors.revColor!.withAlphaComponent(0.15)
        hideView.isUserInteractionEnabled = false
        hideView.layer.cornerRadius = 3
        return hideView
    }()
    
    //MARK: - itemsView
    let itemsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemsView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        
        itemsView.backgroundColor = UIControlViewColors.mainColor
        itemsView.isScrollEnabled = true
        itemsView.allowsMultipleSelection = false
        itemsView.showsHorizontalScrollIndicator = false
        itemsView.accessibilityIdentifier = "UIControlAction_CollectionView_items"
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 4
        
        return itemsView
    }()
    
    fileprivate let cellID = "UIControlAction_items"
    
    //MARK: - count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsData.count
    }
    
    //MARK: - cellForItem
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UIControlItemsCell
        
        let item = itemsData[indexPath.item]
        let count = itemsData.count
        let insets = cellInsets
        let actionViewWidth = actionViewSize.width
        let actionViewHeight = Double(actionViewSize.height)
        
        cell.item = item
        
        switch item.item {
        case .onlyTitle(let title):
            cell.titleLabel.text = title
        case .onlyIcon(let icon):
            cell.iconView.image = icon
        case .TitleWithIcon(let title, let icon):
            cell.titleLabel.text = title
            cell.iconView.image = icon
        default: break
        }
        
        cell.itemTintColor = item.tintColor
        cell.itemBackColor = item.backColor
        
        switch item.tintColor {
        case .custom(let color):
            let templateImage = cell.iconView.image?.withRenderingMode(.alwaysTemplate)
            let alphaColor = color.withAlphaComponent(0.55)
            let auto = UIControlViewHelper.detectTheme(dark: .systemGray, light: alphaColor, any: .systemGray)
            
            cell.titleLabel.textColor = auto
            
            cell.iconView.image = templateImage
            cell.iconView.tintColor = color
        case .standard:
            let templateImage = cell.iconView.image?.withRenderingMode(.alwaysTemplate)
            
            cell.iconView.image = templateImage
            cell.iconView.tintColor = UIControlViewColors.revColor!
            cell.titleLabel.textColor = .systemGray
        case .coloredImage(let tintColor):
            cell.titleLabel.textColor = tintColor.withAlphaComponent(0.55)
        case .customHEX(let hex):
            let color = UIControlViewHelper.HexToUIColor(hex)
            let templateImage = cell.iconView.image?.withRenderingMode(.alwaysTemplate)
            let alphaColor = color.withAlphaComponent(0.55)
            let auto = UIControlViewHelper.detectTheme(dark: .systemGray, light: alphaColor, any: .systemGray)
           
            cell.titleLabel.textColor = auto
            
            cell.iconView.image = templateImage
            cell.iconView.tintColor = color
        }
        
        switch item.backColor {
        case .clear:
            cell.backgroundColor = .clear
        case .custom(let color):
            let alphaColor = color.withAlphaComponent(0.05)
            let auto = UIControlViewHelper.detectTheme(dark: .clear, light: alphaColor, any: .clear)
            
            cell.backgroundColor = auto
        case .standard:
            let auto = UIControlViewHelper.detectTheme(dark: .clear, light: .darkGray, any: .clear)
            
            cell.backgroundColor = auto.withAlphaComponent(0.05)
        case .customHEX(let hex):
            let color = UIControlViewHelper.HexToUIColor(hex).withAlphaComponent(0.05)
            let auto = UIControlViewHelper.detectTheme(dark: .clear, light: color, any: .clear)
            
            cell.backgroundColor = auto
        }
        
        let insetsSpace = (count+1) * Int(insets.left)
        let customInset = Double(insetsSpace)/Double(count)
        let itemsToScroll = itemsConfig.itemsToScroll!
        
        var cellSz: CGSize {
            if count >= itemsToScroll {
                return CGSize(width: (Double(actionViewWidth)/Double(itemsToScroll))-4.8,
                              height: actionViewHeight-Double(insets.top*2))
            } else {
                return CGSize(width: ((Double(actionViewWidth)/Double(count))-customInset),
                              height: actionViewHeight-Double(insets.top*2))
            }
        }
        
        switch item.item {
        case .onlyTitle(_):
            cell.titleLabel.frame = CGRect(x: 4, y: 0,
                                           width: cellSz.width-8, height: cell.frame.height/1.7)
            cell.titleLabel.center.y = cell.frame.height/2 //cell.center.y
            
            cell.titleLabel.isHidden = false
            cell.iconView.isHidden = true
        case .onlyIcon(_):
            cell.iconView.frame = CGRect(x: 4, y: 0,
                                         width: cellSz.width-8, height: cell.frame.height/1.7)
            cell.iconView.center.y = cell.frame.height/2
            
            cell.iconView.isHidden = false
            cell.titleLabel.isHidden = true
        case .TitleWithIcon(_, _):
            cell.iconView.frame = CGRect(x: 4, y: cell.frame.height/2-cell.frame.height/3.5,
                                         width: cellSz.width-8, height: cell.frame.height/2.6)
            cell.titleLabel.frame = CGRect(x: 4, y: cell.iconView.frame.origin.y+cell.iconView.frame.height+1,
                                           width: cellSz.width-8, height: 15)
            
            cell.titleLabel.isHidden = false
            cell.iconView.isHidden = false
        default: break
        }
        
        cell.layer.cornerRadius = itemsConfig.cornerRadius-2
        
        return cell
    }
    
    //MARK: - didSelect
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = itemsData[indexPath.item]
        let handler = action.handler
        execute(action, with: handler!)
    }
    
    //MARK: - layout cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let actionViewWidth = actionViewSize.width
        let actionViewHeight = Double(actionViewSize.height)
        let count = itemsData.count
        let insets = cellInsets
        
        let insetsSpace = (count+1) * Int(insets.left)
        let customInset = Double(insetsSpace)/Double(count)
        let itemsToScroll = itemsConfig.itemsToScroll!
        
        var item: CGSize {
            if count >= itemsToScroll {
                return CGSize(width: (Double(actionViewWidth)/Double(itemsToScroll))-4.8,
                              height: actionViewHeight-Double(insets.top*2))
            } else {
                return CGSize(width: ((Double(actionViewWidth)/Double(count))-customInset),
                              height: actionViewHeight-Double(insets.top*2))
            }
        }
        
        return item
    }
    
    //MARK: - layout cell insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellInsets.top, left: cellInsets.left, bottom: cellInsets.bottom, right: cellInsets.right)
    }
    
    //MARK: - init
    public init(items: [UIControlViewAction], viewSize: CGSize, config: UIControlViewConfig, uuid: [Int]) {
        super.init(frame: CGRect.zero)
        
        itemsData = items
        actionViewSize = viewSize
        itemsConfig = config
        
        setupView()
        
        if itemsConfig.showHideIndicator {
            backgroundColor = UIControlViewColors.mainColor
            addSubview(hideIndicator)
            frame.size = CGSize(width: viewSize.width, height: viewSize.height+7)
            itemsView.frame.origin = CGPoint(x: 0, y: 7)
        } else {
            frame.size = viewSize
            itemsView.frame.origin = CGPoint(x: 0, y: 0)
        }
        
        itemsView.frame.size = viewSize
        
        tag = uuid[0]
    }
    
    //MARK: - aCoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        if itemsConfig.showHideIndicator {
            hideIndicator.frame = CGRect(x: frame.width/2-20, y: 3, width: 40, height: 4)
            
            frame.size = CGSize(width: actionViewSize.width, height: actionViewSize.height+7)
            itemsView.frame.size = actionViewSize
            
            itemsView.UIControlViewRoundCorners([.bottomLeft, .bottomRight], radius: itemsConfig.cornerRadius)
        } else {
            frame.size = actionViewSize
            itemsView.frame.size = actionViewSize
        }
        
        layer.cornerRadius = itemsConfig.cornerRadius
        itemsView.layer.cornerRadius = layer.cornerRadius
    }
    
    //MARK: - setupView
    private func setupView() {
        itemsView.delegate = self
        itemsView.dataSource = self
        itemsView.register(UIControlItemsCell.self, forCellWithReuseIdentifier: cellID)
        
        addSubview(itemsView)
        
        UIControlViewShadow(offset: CGSize(width: 0, height: 4), color: .black, radius: 6.0, opacity: 0.2)
    }
    
    private func execute(_ action: UIControlViewAction, with handler: @escaping UIControlViewActionHandler) {
        handler(action)
    }
    
    //MARK: - theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        itemsView.backgroundColor = UIControlViewColors.mainColor
        itemsView.reloadData()
    }
    
}
