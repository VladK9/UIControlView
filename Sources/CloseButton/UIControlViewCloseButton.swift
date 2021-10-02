import UIKit

class UIControlViewCloseButton: UIView {
    
    private var stackView: UIStackView = UIStackView()
    private var containerView: UIView = UIView()
    
    var currentConfig = CloseConfig()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .white
        label.font = UIControlViewHelper.roundedFont(fontSize: 15, weight: .semibold)
        return label
    }()
    
    private var action: (() -> Void)? = nil
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    //MARK: - Add all subviews to the view
    private func setupView() {
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.addArrangedSubview(titleLabel)
        
        containerView.addSubview(stackView)
        addSubview(containerView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        self.containerView.isUserInteractionEnabled = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TapAction))
        self.containerView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func TapAction() {
        action?()
    }
    
    public func set(_ config: CloseConfig?) {
        currentConfig = config!
        
        titleLabel.text = config!.title
        
        switch config?.backColor {
        case .color(let color):
            containerView.backgroundColor = color
        case .theme(let light, let dark, let any):
            let auto = UIControlViewHelper.detectTheme(dark: dark, light: light, any: any)
            containerView.backgroundColor = auto
        case .none:
            containerView.backgroundColor = .black
        }
        
        switch config?.tintColor {
        case .color(let color):
            titleLabel.textColor = color
        case .theme(let light, let dark, let any):
            let auto = UIControlViewHelper.detectTheme(dark: dark, light: light, any: any)
            titleLabel.textColor = auto
        case .auto:
            if containerView.backgroundColor!.isLight {
                titleLabel.textColor = .black
            } else {
                titleLabel.textColor = .white
            }
        case .none:
            titleLabel.textColor = .white
        }
        
        action = config?.action
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = min(frame.size.height, frame.size.width)/2
        containerView.layer.masksToBounds = true
        
        layer.cornerRadius = min(frame.size.height, frame.size.width)/2
    }
    
    //MARK: - theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        switch currentConfig.backColor {
        case .color(let color):
            containerView.backgroundColor = color
        case .theme(let light, let dark, let any):
            let auto = UIControlViewHelper.detectTheme(dark: dark, light: light, any: any)
            containerView.backgroundColor = auto
        case .none:
            containerView.backgroundColor = .black
        }
        
        switch currentConfig.tintColor {
        case .color(let color):
            titleLabel.textColor = color
        case .theme(let light, let dark, let any):
            let auto = UIControlViewHelper.detectTheme(dark: dark, light: light, any: any)
            titleLabel.textColor = auto
        case .auto:
            if containerView.backgroundColor!.isLight {
                titleLabel.textColor = .black
            } else {
                titleLabel.textColor = .white
            }
        case .none:
            titleLabel.textColor = .white
        }
    }
    
}

public class CloseView {
    
    fileprivate var CloseButton: UIControlViewCloseButton? = nil
    
    public static var shared = CloseView()
    
    fileprivate let keyWindow: UIWindow? = {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .first { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .map { $0?.windows.first } ?? UIApplication.shared.delegate?.window ?? nil
        }
        
        return UIApplication.shared.delegate?.window ?? nil
    }()
    
    //MARK: - Show
    public static func show(_ config: CloseConfig, forVC: UIViewController) {
        shared.CloseButton = UIControlViewCloseButton()
        shared.CloseButton?.set(config)
        
        guard let window = shared.keyWindow, let button = shared.CloseButton else { return }
        
        forVC.navigationController?.navigationBar.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var topConstant: CGFloat
        if #available(iOS 11, *) {
            topConstant = window.safeAreaInsets.top + 4
        } else {
            topConstant = 3
        }
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: window.topAnchor, constant: topConstant),
            button.trailingAnchor.constraint(lessThanOrEqualTo: window.trailingAnchor, constant: -16),
        ])
        
        shared.playFadeInAnimation()
    }
    
    //MARK: - playFadeInAnimation
    private func playFadeInAnimation() {
        guard let button = CloseButton else { return }
        
        button.alpha = 0
        
        UIView.animate(withDuration: 0.25, animations: {
            button.alpha = 1
        })
    }
    
    //MARK: - playFadeOutAnimation
    private func playFadeOutAnimation(_ completion: ((Bool) -> Void)?) {
        guard let button = CloseButton else {
            completion?(false)
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            button.alpha = 0
        }, completion: completion)
    }
    
    //MARK: - Hide
    public static func hide(forVC: UIViewController, completion: (() -> ())? = nil) {
        DispatchQueue.main.async {
            shared.playFadeOutAnimation({ success in
                guard success else {
                    completion?()
                    return
                }
                
                shared.CloseButton?.removeFromSuperview()
                shared.CloseButton = nil
                
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
    }
}
