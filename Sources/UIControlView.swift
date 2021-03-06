import UIKit

class UIControlView {
    
    let shared = UIControlView()
    
    static private var initY = [CGFloat]()
    static private var viewClosing = false
    
    static private var currentVC = UIViewController()
    static private var currentConfig = UIControlViewConfig()
    
    static private let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })!.bounds
    
    //MARK: - Config
    // viewWidth
    static public var viewWidth: CGFloat = window.width-30 {
        didSet {
            if viewWidth >= window.width {
                viewWidth = window.width-30
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
    static public var closeButton = CloseConfig()
    
    // Delegate
    static var delegate: UIControlViewDelegate?
    static var colorDelegate: UIControlViewColorDelegate?
    
    // Queue
    static private var queue = [UIControlViewQueue]()
    
    //MARK: - Show
    static func show(_ vc: UIViewController, type: viewType = .actions([])) {
        var actions: [UIControlViewAction] {
            if case .actions(let allActions) = type {
                return allActions
            }
            return []
        }
        
        var customHeight: CGFloat {
            switch type {
            case .actions(_):
                return viewHeight
            case .color(_, _):
                return 150
            }
        }
        
        let config = UIControlViewConfig(cornerRadius: cornerRadius, viewWidth: viewWidth, viewHeight: customHeight,
                                         showHideIndicator: showHideIndicator, itemsToScroll: itemsToScroll)
        
        closeButton.action = ({
            UISelectionFeedbackGenerator().selectionChanged()
            
            if queue.count == 1 {
                closeFirst(slideAnimation: showWithSlideAnimation)
                delegate?.didHideView(.isButton, .isMain)
            } else {
                closeAll(slideAnimation: showWithSlideAnimation)
                delegate?.didHideView(.isButton, .isAllClosed)
            }
        })
        
        var uuid = [Int]()
        
        if queue.count <= maxView {
            if queue.count == 0 {
                let defUUID = [UIControlViewID.backViewID, UIControlViewID.containerViewID, UIControlViewID.hideViewID]
                uuid = defUUID
                queue.append(UIControlViewQueue(uuid: defUUID, config: config, actions: actions))
                CloseButton.show(closeButton, forVC: vc)
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
                
                let customConfig = UIControlViewConfig(viewWidth: config.viewWidth+wPlus, viewHeight: customHeight,
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
                actionView.center.y = toPosition(.prepare)
                
                UIView.animate(withDuration: animationDuration, animations: {
                    actionView.center.y = toPosition(.show)
                })
            } else {
                actionView.alpha = 0
                actionView.center.y = toPosition(.show)
                
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
        UIView.animate(withDuration: animationDuration, animations: {
            if let actionView = currentVC.view.viewWithTag(UIControlViewID.backViewID) {
                if slideAnimation {
                    actionView.layer.position.y = toPosition(.close)
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
        let lastID = queue.last!.uuid![0]
        
        UIView.animate(withDuration: animationDuration, animations: {
            if let actionView = currentVC.view.viewWithTag(lastID) {
                if slideAnimation {
                    actionView.layer.position.y = toPosition(.close)
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
                        actionView.layer.position.y = toPosition(.close)
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
        let topPadding = UIControlViewHelper.getPadding(.top)
        let bottomPadding = UIControlViewHelper.getPadding(.bottom)
        
        let screen = topPadding + window.height + bottomPadding
        
        var dismissDragSize: CGFloat {
            return bottomPadding.isZero ? screen - (topPadding*1.3) : screen - (bottomPadding*4.4)
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
    static private func toPosition(_ position: presentPosition) -> CGFloat {        
        let topPadding = UIControlViewHelper.getPadding(.top)
        let bottomPadding = UIControlViewHelper.getPadding(.bottom)
        
        var bottomSpace: CGFloat {
            return bottomPadding.isZero ? 10 : 30
        }
        
        var getPrepare: CGFloat {
            if showWithSlideAnimation {
                return window.height + bottomPadding + topPadding + currentConfig.viewHeight
            } else {
                return 0.0
            }
        }
        
        var getShow: CGFloat {
            var yPlus: CGFloat {
                if queue.count == 1 {
                    return 0
                } else if queue.count > 2 {
                    return CGFloat(3 * queue.count)-3
                } else {
                    return 3
                }
            }
            
            var indicator: CGFloat {
                if showHideIndicator {
                    return 3.5
                }
                return 0
            }
            
            let lastHeight = queue.last!.config.viewHeight!
            
            return window.height-lastHeight-bottomSpace+(lastHeight/2)-yPlus-indicator
        }
        
        var getClose: CGFloat {
            return window.height + (topPadding*4)
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
