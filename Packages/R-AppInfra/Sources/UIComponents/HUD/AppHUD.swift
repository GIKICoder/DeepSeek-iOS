import UIKit
import ProgressHUD
import Toast

public class AppHUD {
    
    // MARK: - 单例
    public static let shared = AppHUD()
    private init() {
        configDefaultStyle()
    }
    
    // MARK: - 默认配置
    private func configDefaultStyle() {
        // ProgressHUD默认配置
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorHUD = .systemGray
        ProgressHUD.colorBackground = .clear
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.colorProgress = .systemBlue
        ProgressHUD.colorStatus = .label
        ProgressHUD.fontStatus = .systemFont(ofSize: 16)
        
        // Toast默认配置
        var style = ToastStyle()
        style.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        style.messageColor = .white
        style.messageFont = .systemFont(ofSize: 14)
        ToastManager.shared.style = style
        ToastManager.shared.position = .bottom
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.isQueueEnabled = true
    }
}

// MARK: - ProgressHUD Methods
public extension AppHUD {
    
    // MARK: Banner
    /// 显示横幅通知
    static func banner(_ title: String, _ message: String? = nil, delay: TimeInterval? = nil) {
        if let delay = delay {
            ProgressHUD.banner(title, message, delay: delay)
        } else {
            ProgressHUD.banner(title, message)
        }
    }
    
    /// 隐藏横幅
    static func bannerHide() {
        ProgressHUD.bannerHide()
    }
    
    // MARK: Animation
    
    /// 显示加载Loading
    /// - Parameters:
    ///   - message: <#message description#>
    ///   - interaction: 交互阻断
    static func loading(_ message: String? = nil,
                       interaction: Bool = false) {
        ProgressHUD.animate(message, interaction: interaction)
    }
    
    /// 显示动画加载
    static func animate(_ message: String? = nil,
                       _ animationType: AnimationType? = nil,
                       interaction: Bool = true) {
        if let type = animationType {
            ProgressHUD.animate(message, type, interaction: interaction)
        } else {
            ProgressHUD.animate(message, interaction: interaction)
        }
    }
    
    // MARK: Progress
    /// 显示进度
    static func progress(_ messageOrProgress: Any, _ progress: CGFloat? = nil) {
        if let message = messageOrProgress as? String, let progress = progress {
            ProgressHUD.progress(message, progress)
        } else if let progress = messageOrProgress as? CGFloat {
            ProgressHUD.progress(progress)
        }
    }
    
    // MARK: Success/Failure
    /// 显示成功
    static func succeed(_ message: String? = nil, delay: TimeInterval? = nil) {
        if let delay = delay {
            ProgressHUD.succeed(message, delay: delay)
        } else {
            ProgressHUD.succeed(message)
        }
    }
    
    /// 显示失败
    static func failed(_ message: String? = nil, delay: TimeInterval? = nil) {
        if let delay = delay {
            ProgressHUD.failed(message, delay: delay)
        } else {
            ProgressHUD.failed(message)
        }
    }
    
    // MARK: Symbol
    /// 显示系统符号
    static func symbol(_ message: String? = nil, name: String) {
        if let message = message {
            ProgressHUD.symbol(message, name: name)
        } else {
            ProgressHUD.symbol(name: name)
        }
    }
    
    // MARK: Dismiss
    /// 隐藏HUD
    static func dismiss() {
        ProgressHUD.dismiss()
    }
    
    /// 移除HUD
    static func remove() {
        ProgressHUD.remove()
    }
}

// MARK: - Toast Methods
public extension AppHUD {
    /// 显示Toast
    static func showToast(_ message: String?,
                         duration: TimeInterval = 2.0,
                         position: ToastPosition = .bottom,
                         title: String? = nil,
                         image: UIImage? = nil,
                         style: ToastStyle? = nil,
                         completion: ((_ didTap: Bool) -> Void)? = nil) {
        guard let message = message else { return }
        UIWindow.current?.makeToast(message,
                                                duration: duration,
                                                position: position,
                                                title: title,
                                                image: image,
                                                  style: style ?? ToastStyle(),
                                                completion: completion)
    }
    
    /// 显示加载指示器
    static func showActivity(position: ToastPosition = .center) {
        UIWindow.current?.makeToastActivity(position)
    }
    
    /// 隐藏加载指示器
    static func hideActivity() {
        UIWindow.current?.hideToastActivity()
    }
    
    /// 隐藏所有Toast
    static func hideAllToasts() {
        UIWindow.current?.hideAllToasts()
    }
}

// MARK: - Configuration
public extension AppHUD {
    /// ProgressHUD配置项
    struct ProgressConfig {
        var animationType: AnimationType = .circleStrokeSpin
        var colorHUD: UIColor = .systemGray
        var colorBackground: UIColor = .clear
        var colorAnimation: UIColor = .systemBlue
        var colorProgress: UIColor = .systemBlue
        var colorStatus: UIColor = .label
        var mediaSize: CGFloat = 60
        var marginSize: CGFloat = 20
        var fontStatus: UIFont = .systemFont(ofSize: 16)
        var imageSuccess: UIImage?
        var imageError: UIImage?
        
        public init() {}
    }
    
    /// Toast配置项
    struct ToastConfig {
        var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
        var messageColor: UIColor = .white
        var messageFont: UIFont = .systemFont(ofSize: 14)
        var titleColor: UIColor = .white
        var titleFont: UIFont = .boldSystemFont(ofSize: 14)
        var position: ToastPosition = .bottom
        var isTapToDismissEnabled: Bool = true
        var isQueueEnabled: Bool = true
        
        public init() {}
    }
    
    /// 配置ProgressHUD
    static func configProgress(_ config: ProgressConfig) {
        ProgressHUD.animationType = config.animationType
        ProgressHUD.colorHUD = config.colorHUD
        ProgressHUD.colorBackground = config.colorBackground
        ProgressHUD.colorAnimation = config.colorAnimation
        ProgressHUD.colorProgress = config.colorProgress
        ProgressHUD.colorStatus = config.colorStatus
        ProgressHUD.mediaSize = config.mediaSize
        ProgressHUD.marginSize = config.marginSize
        ProgressHUD.fontStatus = config.fontStatus
        if let successImage = config.imageSuccess {
            ProgressHUD.imageSuccess = successImage
        }
        if let errorImage = config.imageError {
            ProgressHUD.imageError = errorImage
        }
    }
    
    /// 配置Toast
    static func configToast(_ config: ToastConfig) {
        var style = ToastStyle()
        style.backgroundColor = config.backgroundColor
        style.messageColor = config.messageColor
        style.messageFont = config.messageFont
        style.titleColor = config.titleColor
        style.titleFont = config.titleFont
        
        ToastManager.shared.style = style
        ToastManager.shared.position = config.position
        ToastManager.shared.isTapToDismissEnabled = config.isTapToDismissEnabled
        ToastManager.shared.isQueueEnabled = config.isQueueEnabled
    }
}

extension UIWindow {
    static var current: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
