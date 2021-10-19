import UIKit

class UIControlViewColor: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var viewSize = CGSize()
    
    var colors_top = [UIColor]()
    var colors_bottom = [UIColor]()
    
    var itemsConfig = UIControlViewConfig()
    var selectedItem: selectedColor = .none
    
    let cellSpacing: CGFloat = 4
    let cellInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    var delegate: UIControlViewColorDelegate?
    
    let hideIndicator: UIView = {
        let hideView = UIView()
        hideView.backgroundColor = UIControlViewColors.revColor!.withAlphaComponent(0.15)
        hideView.isUserInteractionEnabled = false
        hideView.layer.cornerRadius = 2
        return hideView
    }()
    
    //MARK: - itemsView
    let topView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colorView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        
        colorView.backgroundColor = UIControlViewColors.mainColor
        colorView.isScrollEnabled = true
        colorView.allowsMultipleSelection = false
        colorView.showsHorizontalScrollIndicator = false
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 4
        
        return colorView
    }()
    
    let bottomView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colorView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        
        colorView.backgroundColor = UIControlViewColors.mainColor
        colorView.isScrollEnabled = false
        colorView.allowsMultipleSelection = false
        colorView.showsHorizontalScrollIndicator = false
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 4
        
        return colorView
    }()
    
    fileprivate let cellID_top = "UIControlView_color_top"
    fileprivate let cellID_bottom = "UIControlView_color_bottom"
    
    //MARK: - count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topView {
            return colors_top.count
        } else {
            return 5
        }
    }
    
    //MARK: - cellForItem
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID_top, for: indexPath) as! UIControlColorCell
            
            cell.colorView.backgroundColor = colors_top[indexPath.item]
            
            cell.selectedIcon.frame.size = CGSize(width: cell.frame.width, height: cell.frame.height/2.1)
            cell.selectedIcon.frame.origin = CGPoint(x: 0, y: cell.frame.height/2-(cell.selectedIcon.frame.height/2))
            
            cell.backgroundColor = colors_top[indexPath.item]
            cell.layer.cornerRadius = itemsConfig.cornerRadius-2
            cell.layer.borderColor = (colors_top[indexPath.item].darker(by: 20))?.cgColor
            cell.layer.borderWidth = 1
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID_bottom, for: indexPath) as! UIControlColorCell
            
            cell.colorView.backgroundColor = colors_bottom[indexPath.item]
            
            cell.selectedIcon.frame.size = CGSize(width: cell.frame.width, height: cell.frame.height/3.1)
            cell.selectedIcon.frame.origin = CGPoint(x: 0, y: cell.frame.height/2-(cell.selectedIcon.frame.height/2))
            
            cell.backgroundColor = colors_bottom[indexPath.item]
            cell.layer.cornerRadius = itemsConfig.cornerRadius-2
            cell.layer.borderColor = (colors_bottom[indexPath.item].darker(by: 20))?.cgColor
            cell.layer.borderWidth = 1
            
            return cell
        }
    }
    
    //MARK: - didSelect
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == topView {
            colors_bottom = generateColors(colors_top[indexPath.item])
            
            bottomView.reloadData()
            bottomView.performBatchUpdates(nil, completion: { (result) in
                self.bottomView.selectItem(at: IndexPath(item: 2, section: 0), animated: true, scrollPosition: .init())
                self.delegate?.didSelectColor(self.colors_bottom[2])
            })
        } else {
            delegate?.didSelectColor(colors_bottom[indexPath.item])
        }
    }
    
    //MARK: - layout cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = colors_top.count
        
        if collectionView == topView {
            let insetsSpace = (count+1) * Int(cellInsets.left)
            let customInset = Double(insetsSpace)/Double(count)
            
            var width: CGFloat {
                if count > 10 {
                    return (Double(viewSize.width)/Double(10))-customInset
                } else {
                    return (Double(viewSize.width)/Double(count))-customInset
                }
            }
            
            return CGSize(width: width, height: 50-(cellInsets.top*2))
        } else {
            let insetsSpace = (count+2) * Int(cellInsets.left)
            let customInset = Double(insetsSpace)/Double(count)
            let width = (Double(viewSize.width)/Double(5))-customInset
            
            return CGSize(width: width, height: 100-(cellInsets.top*2))
        }
    }
    
    //MARK: - layout cell insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellInsets.top, left: cellInsets.left, bottom: cellInsets.bottom, right: cellInsets.right)
    }
    
    //MARK: - init
    public init(colors: [UIColor], selectedItem: selectedColor, delegate: UIControlViewColorDelegate?, viewSize: CGSize, config: UIControlViewConfig, uuid: [Int]) {
        super.init(frame: CGRect.zero)
        
        self.delegate = delegate
        
        if colors.isEmpty {
            colors_top.append(UIColor.black)
        } else {
            colors_top = colors
        }
        
        colors_bottom = generateColors(colors[0])
        
        self.viewSize = viewSize
        itemsConfig = config
        
        setupView()
        
        backgroundColor = UIControlViewColors.mainColor
        
        if itemsConfig.showHideIndicator {
            backgroundColor = UIControlViewColors.mainColor
            addSubview(hideIndicator)
            frame.size = CGSize(width: viewSize.width, height: viewSize.height+7)
            topView.frame.origin = CGPoint(x: 0, y: 7)
        } else {
            frame.size = viewSize
            topView.frame.origin = CGPoint(x: 0, y: 0)
        }
        
        topView.frame.size = viewSize
        
        switch selectedItem {
        case .none: break
        case .selected(let top, let bottom):
            if !colors.isEmpty {
                colors_bottom = generateColors(colors_top[top])
                
                topView.selectItem(at: IndexPath(item: top, section: 0), animated: true, scrollPosition: .init())
                bottomView.selectItem(at: IndexPath(item: bottom, section: 0), animated: true, scrollPosition: .init())
                
                self.delegate?.didSelectColor(self.colors_bottom[bottom])
            }
        }
        
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
            
            frame.size = CGSize(width: viewSize.width, height: viewSize.height+7)
            topView.frame.size = CGSize(width: viewSize.width, height: 50)
            
            bottomView.frame = CGRect(x: 0, y: 57, width: viewSize.width, height: 100)
            bottomView.UIControlViewRoundCorners([.bottomLeft, .bottomRight], radius: itemsConfig.cornerRadius)
        } else {
            frame.size = viewSize
            topView.frame.size = CGSize(width: viewSize.width, height: 50)
            bottomView.frame = CGRect(x: 0, y: 50, width: viewSize.width, height: 100)
            
            topView.UIControlViewRoundCorners([.topLeft, .topRight], radius: itemsConfig.cornerRadius)
            bottomView.UIControlViewRoundCorners([.bottomLeft, .bottomRight], radius: itemsConfig.cornerRadius)
        }
        
        layer.cornerRadius = itemsConfig.cornerRadius
    }
    
    //MARK: - setupView
    private func setupView() {
        topView.delegate = self
        topView.dataSource = self
        topView.register(UIControlColorCell.self, forCellWithReuseIdentifier: cellID_top)
        
        bottomView.delegate = self
        bottomView.dataSource = self
        bottomView.register(UIControlColorCell.self, forCellWithReuseIdentifier: cellID_bottom)
        
        addSubview(topView)
        addSubview(bottomView)
        
        UIControlViewShadow(offset: CGSize(width: 0, height: 5), color: .black, radius: 7.0, opacity: 0.2)
    }
    
    private func execute(_ action: UIControlViewAction, with handler: @escaping UIControlViewActionHandler) {
        handler(action)
    }
    
    //MARK: - theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        topView.backgroundColor = UIControlViewColors.mainColor
        topView.reloadData()
    }
    
    private func generateColors(_ initColor: UIColor) -> [UIColor] {
        return [initColor.darker(by: 20)!, initColor.darker(by: 10)!,
                initColor,
                initColor.lighter(by: 10)!, initColor.lighter(by: 20)!]
    }
    
}
