
import UIKit
import Foundation

class UIControlView {
    
    let shared = UIControlView()
    
    static private let maxView: Int = 2 // maximum 3 UIControlView (0..3)
    static private var currentVC = UIViewController()
    static private var currentConfig = UIControlViewConfig()
    
    //MARK: - Config
    // View size
    static public var viewWidth: CGFloat = UIScreen.main.bounds.width-26
    static public var viewHeight: CGFloat = 80
    
    // Show/Hide indicator or not
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
    static public var closeBackColor: UIColor!
    static public var closeTintColor: UIColor!
    
    // View delegate
    static var delegate: UIControlViewDelegate?
    
    // View queue
    static private var queue = [UIControlViewQueue]()
    
    //MARK: - present
    static func show(_ vc: UIViewController, actions: [UIControlViewAction], config: UIControlViewConfig) {
        let screen = UIScreen.main.bounds
        let topPadding = CGFloat((UIApplication.shared.keyWindow?.safeAreaInsets.top)!)
        let bottomPadding = CGFloat((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!)
        
        let hide = CloseConfig(title: closeTitle, backColor: closeBackColor, tintColor: closeTintColor, action: ({
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
                let defID = [UIControlViewID.backViewID, UIControlViewID.containerViewID, UIControlViewID.hideViewID]
                uuid = defID
                queue.append(UIControlViewQueue(uuid: defID, config: config, actions: actions))
                CloseView.show(hide, forVC: vc)
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
                
                let customConfig = UIControlViewConfig(viewWidth: config.viewWidth+wPlus,
                                                       viewHeight: config.viewHeight,
                                                       showHideIndicator: config.showHideIndicator)
                
                let lastID = [queue.last!.uuid![0]+1, queue.last!.uuid![1]+1, queue.last!.uuid![2]+1]
                uuid = lastID
                queue.append(UIControlViewQueue(uuid: lastID, config: customConfig, actions: actions))
            }
            
            let actionView = UIControlViewItem.init(items: actions,
                                                    viewSize: CGSize(width: queue.last!.config.viewWidth, height: queue.last!.config.viewHeight),
                                                    config: queue.last!.config, uuid: uuid)
            
            vc.view.addSubview(actionView)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(UIControlViewDrag(_:)))
            pan.maximumNumberOfTouches = 1
            pan.cancelsTouchesInView = true
            actionView.addGestureRecognizer(pan)
            
            currentVC = vc
            currentConfig = config
            
            var yPlus: CGFloat {
                print(queue.count)
                if queue.count == 1 {
                    return 0
                } else if queue.count > 2 {
                    return CGFloat(4 * queue.count)-4
                } else {
                    return 4
                }
            }
            
            var viewY: CGFloat {
                if bottomPadding.isZero {
                    return screen.height-(topPadding+bottomPadding+config.viewHeight+15+yPlus)
                } else {
                    return screen.height-(topPadding+bottomPadding+config.viewHeight+5+yPlus)
                }
            }
            
            print(screen.height)
            print(bottomPadding)
            print(topPadding)
            
            actionView.center.x = UIApplication.shared.keyWindow!.frame.midX
            
            if showWithSlideAnimation {
                actionView.layer.position.y = screen.height + bottomPadding + topPadding
                
                UIView.animate(withDuration: animationDuration, animations: {
                    actionView.layer.position.y = viewY
                })
            } else {
                actionView.alpha = 0
                actionView.layer.position.y = viewY
                UIView.animate(withDuration: animationDuration, animations: {
                    actionView.alpha = 1
                })
            }
        }
    }
    
    //MARK: - closeFirst
    static private func closeFirst(slideAnimation: Bool = true) {
        UIView.animate(withDuration: animationDuration, animations: {
            if let actionView = currentVC.view.viewWithTag(UIControlViewID.backViewID) {
                if slideAnimation {
                    actionView.layer.position.y = UIScreen.main.bounds.height
                } else {
                    actionView.alpha = 0
                }
                print("closed")
            } else {
                print("No actionView 1")
            }
        }, completion: { (finished: Bool) in
            if let actionView = currentVC.view.viewWithTag(UIControlViewID.backViewID) {
                actionView.removeFromSuperview()
                print("removed")
            } else {
                print("No actionView 2")
            }
        })
        
        queue.removeAll()
        CloseView.hide(forVC: currentVC)
    }
    
    //MARK: - closeLast
    static func closeLast(slideAnimation: Bool = true) {
        let lastID = queue.last!.uuid![0]
        UIView.animate(withDuration: animationDuration, animations: {
            if let actionView = currentVC.view.viewWithTag(lastID) {
                if showWithSlideAnimation {
                    actionView.layer.position.y = UIScreen.main.bounds.height
                } else {
                    actionView.alpha = 0
                }
                print("last closed")
            } else {
                print("No actionView last 1")
            }
        }, completion: { (finished: Bool) in
            if let actionView = currentVC.view.viewWithTag(lastID) {
                actionView.removeFromSuperview()
                print("last removed")
            } else {
                print("No actionView last 2")
            }
        })
        
        queue.removeLast()
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
                    if showWithSlideAnimation {
                        actionView.layer.position.y = UIScreen.main.bounds.height
                    } else {
                        actionView.alpha = 0
                    }
                    print("closed")
                } else {
                    print("No actionView 1")
                }
            }, completion: { (finished: Bool) in
                if let actionView = currentVC.view.viewWithTag(reversedID[index]) {
                    actionView.removeFromSuperview()
                    print("removed")
                } else {
                    print("No actionView 2")
                }
            })
        }
        
        queue.removeAll()
        CloseView.hide(forVC: currentVC)
    }
    
    private struct PanState: Equatable {
        var closing = false
        var velocity: CGFloat = 0.0
    }
    
    static private var panState = PanState()
    
    //MARK: - UIControlViewDrag
    @objc static private func UIControlViewDrag(_ sender: UIPanGestureRecognizer) {
        let topPadding = CGFloat((UIApplication.shared.keyWindow?.safeAreaInsets.top)!)
        let bottomPadding = CGFloat((UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!)
        let screen = UIScreen.main.bounds
        let allScreen = topPadding + screen.height + bottomPadding
        
        let velocity = sender.velocity(in: sender.view)
        let translation = sender.translation(in: sender.view)
        
        var dismissDragSize: CGFloat {
            if bottomPadding.isZero {
                return allScreen - (topPadding*4.65)
            } else {
                return allScreen - (bottomPadding*5.5)
            }
        }
        
        switch sender.state {
        case .began:
            print("began")
        case .changed:
            panState = panChanged(current: panState, view: sender.view!, velocity: velocity, translation: translation)
        case .ended, .cancelled:
            if ((sender.view!.frame.origin.y) >= dismissDragSize) || (velocity.y > 180) {
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
                    sender.view?.transform = .identity
                })
            }

            panState = .init()
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - panChanged()
    static private func panChanged(current: PanState, view: UIView, velocity: CGPoint, translation: CGPoint) -> PanState {
        let bounceOffset: CGFloat = 5
        let rubberBanding = true
        
        var state = current
        let height = view.bounds.height - bounceOffset
        if height <= 0 { return state }
        
        var translationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.7)
        
        if !state.closing {
            if !rubberBanding && translationAmount < 0 { return state }
            state.closing = true
        }
        
        if !rubberBanding && translationAmount < 0 { translationAmount = 0 }
        
        view.transform = CGAffineTransform(translationX: 0, y: translationAmount)
        
        return state
    }
    
}
