import UIKit

class UIControlViewItem: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var selectedItems = [Int]()
    
    var actionViewSize = CGSize()
    var itemsData = [UIControlViewAction]()
    var itemsConfig = UIControlViewConfig()
    
    let cellSpacing: CGFloat = 4
    let cellInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    let hideIndicator: UIView = {
        let hideView = UIView()
        hideView.backgroundColor = UIControlViewColors.revColor!.withAlphaComponent(0.15)
        hideView.isUserInteractionEnabled = false
        hideView.layer.cornerRadius = 2
        return hideView
    }()
    
    //MARK: - itemsView
    let itemsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemsView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        
        itemsView.backgroundColor = UIControlViewColors.mainColor
        itemsView.isScrollEnabled = true
        itemsView.allowsMultipleSelection = true
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
        
        cell.item = item
        
        switch item.item {
        case .onlyTitle(let title):
            cell.titleLabel.text = title
        case .onlyIcon(let icon):
            cell.iconView.image = icon
        case .TitleWithIcon(let title, let icon):
            cell.titleLabel.text = title
            cell.iconView.image = icon
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
            cell.backgroundColor = UIControlViewColors.defaultCellColor
        case .customHEX(let hex):
            let color = UIControlViewHelper.HexToUIColor(hex).withAlphaComponent(0.05)
            let auto = UIControlViewHelper.detectTheme(dark: .clear, light: color, any: .clear)
            
            cell.backgroundColor = auto
        }
        
        switch item.item {
        case .onlyTitle(_):
            cell.titleLabel.frame = CGRect(x: 4, y: 0,
                                           width: cell.frame.width-8, height: cell.frame.height/1.7)
            cell.titleLabel.center.y = cell.frame.height/2
            
            cell.titleLabel.isHidden = false
            cell.iconView.isHidden = true
        case .onlyIcon(_):
            cell.iconView.frame = CGRect(x: 4, y: 0,
                                         width: cell.frame.width-8, height: cell.frame.height/1.7)
            cell.iconView.center.y = cell.frame.height/2
            
            cell.iconView.isHidden = false
            cell.titleLabel.isHidden = true
        case .TitleWithIcon(_, _):
            cell.iconView.frame = CGRect(x: 4, y: cell.frame.height/2-cell.frame.height/3.5,
                                         width: cell.frame.width-8, height: cell.frame.height/2.6)
            cell.titleLabel.frame = CGRect(x: 4, y: cell.iconView.frame.origin.y+cell.iconView.frame.height+1,
                                           width: cell.frame.width-8, height: 15)
            
            cell.titleLabel.isHidden = false
            cell.iconView.isHidden = false
        }
        
        if (itemsData[indexPath.item].handler ?? nil) == nil {
            cell.sel = item.selectionConfig
            if itemsData[indexPath.item].isPreselected {
                cell.isSelected = true
            }
        }
        
        cell.layer.cornerRadius = itemsConfig.cornerRadius-2
        
        return cell
    }
    
    //MARK: - didSelectItem
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = itemsData[indexPath.item]
        let act = itemsData[indexPath.item].handler ?? nil
        
        DispatchQueue.main.async {
            if act != nil {
                let handler = action.handler
                self.execute(action, with: handler!)
            } else {
                self.execute(action, with: action.isSelected!)
            }
        }
    }
    
    //MARK: - didDeselectItem
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let act = itemsData[indexPath.item].handler ?? nil
        
        if act != nil {
            let action = itemsData[indexPath.item]
            
            DispatchQueue.main.async {
                let handler = action.handler
                self.execute(action, with: handler!)
            }
        } else {
            execute(itemsData[indexPath.item], with: itemsData[indexPath.item].isUnselected!)
        }
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
            if count > itemsToScroll {
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
        
        var allSelectedItems: [Int] {
            var selectedItm = [Int]()
            for index in 0..<items.count {
                if items[index].isPreselected {
                    selectedItm.append(index)
                }
            }
            return selectedItm
        }
        
        selectedItems = allSelectedItems
        
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
        
        for index in 0..<selectedItems.count {
            let ip = IndexPath(item: selectedItems[index], section: 0)
            itemsView.selectItem(at: ip, animated: true, scrollPosition: .init())
        }
    }
    
    private func execute(_ action: UIControlViewAction, with handler: @escaping UIControlViewActionHandler) {
        handler(action)
    }
    
    //MARK: - theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        for index in 0..<itemsData.count {
            let indexPath = IndexPath(item: index, section: 0)
            let cell = itemsView.cellForItem(at: indexPath) as! UIControlItemsCell
            
            let act = itemsData[index].handler ?? nil
            
            if act != nil {
                switch itemsData[index].backColor {
                case .clear:
                    break
                case .custom(let color):
                    if #available(iOS 13.0, *) {
                        let userInterfaceStyle = traitCollection.userInterfaceStyle
                        if userInterfaceStyle == .dark {
                            cell.titleLabel.textColor = .systemGray
                            cell.backgroundColor = .clear
                        } else {
                            cell.titleLabel.textColor = color.withAlphaComponent(0.55)
                            cell.backgroundColor = color.withAlphaComponent(0.05)
                        }
                    } else {
                        
                    }
                case .standard:
                    cell.backgroundColor = UIControlViewColors.defaultCellColor
                case .customHEX(let hex):
                    let color = UIControlViewHelper.HexToUIColor(hex).withAlphaComponent(0.05)
                    let auto = UIControlViewHelper.detectTheme(dark: .clear, light: color, any: .clear)
                    
                    cell.backgroundColor = auto
                }
            }
        }
    }
    
}
