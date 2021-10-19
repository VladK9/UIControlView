import UIKit

class UIControlView {
    
    let shared = UIControlView()
    
    static private var initY = [CGFloat]()
    static private var viewClosing = false
    
    static private var currentVC = UIViewController()
    static private var currentConfig = UIControlViewConfig()
    
    //MARK: - Config
    // viewWidth
    static public var viewWidth: CGFloat = UIScreen.main.bounds.width-30 {
        didSet {
            if viewWidth >= UIScreen.main.bounds.width {
                viewWidth = UIScreen.main.bounds.width-30
            }
        }
    }
    
    // viewHeight
    static public var viewHeight: CGFloat = 80 {
        didSet {
            if viewHeight > 120 {
                viewHeight = 120
            }
            
            if viewHeight < 80 {
                viewHeight = 80
            }
        }
    }
    
    // Max view to show
    static private var maxView: Int = 3
    
    // Max items to start scroll
    static public var itemsToScroll: Int = 5
    
    // Corner radius
    static public var cornerRadius: CGFloat = 9
    
    // Show/Hide indicator
    static public var showHideIndicator: Bool = false
    
    // Show/Hide view with slide animation or not
    static public var showWithSlideAnimation: Bool = true
    
    // Animation duration
    static private var animationDuration: TimeInterval {
        if showWithSlideAnimation {
            return 0.25
        } else {
            return 0.20
        }
    }
    
    // Close button config
    static public var closeTitle: String!
    static public var closeBackColor: backColor!
    static public var closeTintColor: tintColor!
    
    // Delegate
    static var delegate: UIControlViewDelegate?
    static var colorDelegate: UIControlViewColorDelegate?
    
    // Queue
    static private var queue = [UIControlViewQueue]()
    
    //MARK: - Show
    static func show(_ vc: UIViewController, type: viewType = .actions([])) {
        var actions: [UIControlViewAction] {
            switch type {
            case .actions(let allActions):
                return allActions
            case .color(_,_): break
            }
            
            return []
        }
        
        let config = UIControlViewConfig(cornerRadius: cornerRadius, viewWidth: viewWidth, viewHeight: viewHeight,
                                         showHideIndicator: showHideIndicator, itemsToScroll: itemsToScroll)
        
        let close = CloseConfig(title: closeTitle, backColor: closeBackColor, tintColor: closeTintColor, action: ({
            UISelectionFeedbackGenerator().selectionChanged()
            
            if queue.count == 1 {
                closeFirst(slideAnimation: showWithSlideAnimation)
                delegate?.didHideView(.isButton, .isMain)
            } else {
                closeAll(slideAnimation: showWithSlideAnimation)
                delegate?.didHideView(.isButton, .isAllClosed)
            }
        }))
        
        var uuid = [Int]()
        
        if queue.count <= maxView {
            if queue.count == 0 {
                let defUUID = [UIControlViewID.backViewID, UIControlViewID.containerViewID, UIControlViewID.hideViewID]
                uuid = defUUID
                queue.append(UIControlViewQueue(uuid: defUUID, config: config, actions: actions))
                CloseButton.show(close, forVC: vc)
            } else {
                var wPlus: CGFloat {
                    if queue.count+1 == 1 {
                        return 0
                    } else if queue.count+1 > 2 {
                        return CGFloat(6 * queue.count+1)
                    } else {
                        return 6
                    }
                }
                
                let customConfig = UIControlViewConfig(viewWidth: config.viewWidth+wPlus, viewHeight: config.viewHeight,
                                                       showHideIndicator: config.showHideIndicator,
                                                       itemsToScroll: config.itemsToScroll)
                
                let lastID = [queue.last!.uuid![0]+1, queue.last!.uuid![1]+1, queue.last!.uuid![2]+1]
                uuid = lastID
                queue.append(UIControlViewQueue(uuid: lastID, config: customConfig, actions: actions))
            }
            
            var actionView = UIView()
            
            switch type {
            case .actions:
                actionView = UIControlViewItem.init(items: actions,
                                                    viewSize: CGSize(width: queue.last!.config.viewWidth, height: queue.last!.config.viewHeight),
                                                    config: queue.last!.config,
                                                    uuid: uuid)
            case .color(let colors, let selected):
                actionView = UIControlViewColor.init(colors: colors, selectedItem: selected,
                                                     delegate: colorDelegate,
                                                     viewSize: CGSize(width: queue.last!.config.viewWidth, height: 150),
                                                     config: queue.last!.config,
                                                     uuid: uuid)
            }
            
            vc.view.addSubview(actionView)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(UIControlViewDrag(_:)))
            pan.maximumNumberOfTouches = 1
            pan.cancelsTouchesInView = true
            actionView.addGestureRecognizer(pan)
            
            currentVC = vc
            currentConfig = config
            
            actionView.center.x = currentVC.view.center.x
            
            if showWithSlideAnimation {
                actionView.center.y = toPosition(type, .prepare)
                
                UIView.animate(withDuration: animationDuration, animations: {
                    actionView.center.y = toPosition(type, .show)
                })
            } else {
                actionView.alpha = 0
                actionView.center.y = toPosition(type, .show)
                
                UIView.animate(withDuration: animationDuration, animations: {
                    actionView.alpha = 1
                })
            }
            
            initY.append(actionView.frame.origin.y)
        } else {
            print("Max view count")
        }
    }
    
    //MARK: - closeFirst
    static private func closeFirst(slideAnimation: Bool = true) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let topPadding = (windowScene.keyWindow?.safeAreaInsets.top)!
        
        UIView.animate(withDuration: animationDuration, animations: {
            if let actionView = currentVC.view.viewWithTag(UIControlViewID.backViewID) {
                if slideAnimation {
                    actionView.layer.position.y = UIScreen.main.bounds.height + (topPadding*4)
                } else {
                    actionView.alpha = 0
                }
            }
        }, completion: { (finished: Bool) in
            if let actionView = currentVC.view.viewWithTag(UIControlViewID.backViewID) {
                actionView.removeFromSuperview()
            }
        })
        
        queue.removeAll()
        CloseButton.hide(forVC: currentVC)
        initY.removeAll()
    }
    
    //MARK: - closeLast
    static func closeLast(slideAnimation: Bool = true) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let topPadding = (windowScene.keyWindow?.safeAreaInsets.top)!
        
        let lastID = queue.last!.uuid![0]
        
        UIView.animate(withDuration: animationDuration, animations: {
            if let actionView = currentVC.view.viewWithTag(lastID) {
                if slideAnimation {
                    actionView.layer.position.y = UIScreen.main.bounds.height + (topPadding*4)
                } else {
                    actionView.alpha = 0
                }
            }
        }, completion: { (finished: Bool) in
            if let actionView = currentVC.view.viewWithTag(lastID) {
                actionView.removeFromSuperview()
            }
        })
        
        queue.removeLast()
        initY.removeLast()
    }
    
    //MARK: - closeAll
    static func closeAll(slideAnimation: Bool = true) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let topPadding = (windowScene.keyWindow?.safeAreaInsets.top)!
        
        var allID: [Int] {
            var values = [Int]()
            for index in 0..<queue.count {
                values.append(queue[index].uuid![0])
            }
            return values
        }
        
        let reversedID = Array(allID.reversed())
        
        for index in 0..<queue.count {
            UIView.animate(withDuration: animationDuration, animations: {
                if let actionView = currentVC.view.viewWithTag(reversedID[index]) {
                    if slideAnimation {
                        actionView.layer.position.y = UIScreen.main.bounds.height + (topPadding*4)
                    } else {
                        actionView.alpha = 0
                    }
                }
            }, completion: { (finished: Bool) in
                if let actionView = currentVC.view.viewWithTag(reversedID[index]) {
                    actionView.removeFromSuperview()
                }
            })
        }
        
        queue.removeAll()
        CloseButton.hide(forVC: currentVC)
        initY.removeAll()
    }
    
    //MARK: - UIControlViewDrag
    @objc static private func UIControlViewDrag(_ sender: UIPanGestureRecognizer) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let topPadding = (windowScene.keyWindow?.safeAreaInsets.top)!
        let bottomPadding = (windowScene.keyWindow?.safeAreaInsets.bottom)!
        
        let screen = topPadding + UIScreen.main.bounds.height + bottomPadding
        
        var dismissDragSize: CGFloat {
            if bottomPadding.isZero {
                return screen - (topPadding*1.3)
            } else {
                return screen - (bottomPadding*4.4)
            }
        }
        
        switch sender.state {
        case .changed:
            panChanged(sender)
        case .ended, .cancelled:
            panEnded(sender, dismissDragSize: dismissDragSize)
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - panChanged()
    static private func panChanged(_ gesture: UIPanGestureRecognizer) {
        let view = gesture.view!
        let translation = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)
        
        let rubberBanding = true
        
        var translationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.7)
        
        if !viewClosing {
            viewClosing = true
        }
        
        if !rubberBanding && translationAmount < 0 { translationAmount = 0 }
        
        if gesture.direction(in: view) == .Up && gesture.view!.frame.origin.y < initY.last! {
            for order in 0..<queue.count-1 {
                var t: Double {
                    if order == 0 {
                        return 0.04
                    } else if order == 1 {
                        return 0.08
                    } else {
                        return 0.12
                    }
                }

                if let actionView = currentVC.view.viewWithTag(queue[order].uuid[0]) {
                    let backTranslationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.55+t)
                    actionView.transform = CGAffineTransform(translationX: 0, y: backTranslationAmount)
                }
            }
        }

        if gesture.direction(in: view) == .Down {
            for order in 0..<queue.count-1 {
                var t: Double {
                    if order == 0 {
                        return 0.6
                    } else if order == 1 {
                        return 0.63
                    } else if order == 2 {
                        return 0.67
                    } else {
                        return 0.7
                    }
                }
                
                if let actionView = currentVC.view.viewWithTag(queue[order].uuid[0]) {
                    if velocity.y > 180 {
                        UIView.animate(withDuration: 0.2, animations: {
                            actionView.transform = .identity
                        })
                    } else {
                        if actionView.frame.origin.y <= initY[order] {
                            let backTranslationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), t)
                            actionView.transform = CGAffineTransform(translationX: 0, y: backTranslationAmount)
                        }
                    }
                    
                }
            }
        }
        
        view.transform = CGAffineTransform(translationX: 0, y: translationAmount)
    }
    
    // MARK: - panEnded()
    static private func panEnded(_ gesture: UIPanGestureRecognizer, dismissDragSize: CGFloat) {
        let velocity = gesture.velocity(in: gesture.view).y
        if ((gesture.view!.frame.origin.y) >= dismissDragSize) || (velocity > 180) {
            if queue.count > 1 {
                closeLast(slideAnimation: true)
                delegate?.didHideView(.isSwipe, .isSubview)
            } else if queue.count == 1 {
                closeFirst(slideAnimation: true)
                delegate?.didHideView(.isSwipe, .isMain)
            } else {
                closeFirst(slideAnimation: true)
                delegate?.didHideView(.isSwipe, .isMain)
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                for index in 0..<queue.count {
                    if let actionView = currentVC.view.viewWithTag(queue[index].uuid[0]) {
                        actionView.transform = .identity
                    }
                }
            })
        }
        
        viewClosing = false
    }
    
    private enum presentPosition {
        case prepare
        case show
        case close
    }
    
    // MARK: - toPosition()
    static private func toPosition(_ type: viewType, _ position: presentPosition) -> CGFloat {
        let screen = UIScreen.main.bounds
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let topPadding = (windowScene?.keyWindow?.safeAreaInsets.top)!
        let bottomPadding = (windowScene?.keyWindow?.safeAreaInsets.bottom)!
        
        var getPrepare: CGFloat {
            if showWithSlideAnimation {
                return screen.height + bottomPadding + topPadding + currentConfig.viewHeight
            } else {
                return 0.0
            }
        }
        
        var getShow: CGFloat {
            var yPlus: CGFloat {
                if queue.count == 1 {
                    return 0
                } else if queue.count > 2 {
                    return CGFloat(4 * queue.count)-4
                } else {
                    return 4
                }
            }
            
            //MARK: - -FIX
            var yInd: CGFloat {
                switch type {
                case .actions:
                    if showHideIndicator {
                        return 3.5
                    } else {
                        return 0
                    }
                case .color(_,_):
                    if queue.count == 0 {
                        if showHideIndicator {
                            return 3.5
                        } else {
                            return 0
                        }
                    } else {
                        if showHideIndicator {
                            return 38.5
                        } else {
                            return 35
                        }
                    }
                }
            }
            
            //MARK: - -rewrite
            var customH: CGFloat {
                let h = queue.last!.config.viewHeight!
                if h > 100 {
                    return h/1.25
                } else if h > 80 {
                    return h/1.1
                }
                
                return h
            }
            
            var viewY: CGFloat {
                if bottomPadding.isZero {
                    return screen.height-customH-yInd+topPadding-yPlus
                } else {
                    return screen.height-customH-yInd-(bottomPadding*1.3)+topPadding-yPlus
                }
            }
            
            return viewY
        }
        
        var getClose: CGFloat {
            return UIScreen.main.bounds.height + (topPadding*4)
        }
        
        switch position {
        case .prepare:
            return getPrepare
        case .show:
            return getShow
        case .close:
            return getClose
        }
    }
    
}
