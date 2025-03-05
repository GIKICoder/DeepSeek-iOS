//
//  AlertBaseView.swift
//  DorisKit
//
//  Created by GIKI on 2024/6/24.
//
import UIKit


open class AlertBaseView: UIView, CAAnimationDelegate {
    let AlertWindowLevel: UIWindow.Level = .init(rawValue: 1997.0)

    static var visibleCount: Int {
        visibleAlertIds.count
    }
    static private(set) var visibleAlertIds: Set<String> = []

    public weak var baseDelegate: (any AlertBaseViewDelegate)?
    public var containerView: UIView = .init()

    /// 背景黑色透明度
    public var backMaskValue: CGFloat = 0.4
    /// 是否点击背景隐藏
    public var tapBckHidden: Bool = true
    /// 是否需要滑动也隐藏，默认: false
    public var needsPanHidden: Bool = false
    /// 消失动画类型
    public var hideAnimationType: AlertHideAnimation = .downFadeOut
    public var hideDuration: TimeInterval = 0.3
    /// 出现动画类型
    public var showAnimationType: AlertShowAnimation = .downFadeIn
    public var showDuration: TimeInterval = 0.3
    /// 是否禁用结束编辑
    public var disableEndEdit: Bool = false

    /// 唯一标识符, 用于限制同一个弹窗，重复弹出
    /// 标识符为空字符串时，不做限制
    /// 默认为空字符串
    public var identifier: String = ""

    private(set) var maskControlView: UIView = .init()

    // Properties to support CAAnimationDelegate
    var alertWindow: UIWindow?
    weak var oldKeyWindow: UIWindow?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.identifier = "\(type(of: self))"  + "\(Date().timeIntervalSince1970)"
        setupDefaults()
    }

    public required init?(coder: NSCoder) {
        self.identifier = "\(type(of: self))"  + "\(Date().timeIntervalSince1970)"
        super.init(coder: coder)
        setupDefaults()
    }
    
    deinit {
        let id = identifier
        Task { @MainActor in
            Self.visibleAlertIds.remove(id)
        }
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        Self.visibleAlertIds.remove(identifier)
    }

    // MARK: - Setup UI

    func setup() {
        maskControlView = UIView(frame: bounds)
        maskControlView.backgroundColor = UIColor.black.withAlphaComponent(backMaskValue)
        addSubview(maskControlView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(backGroundViewTouchAction))
        maskControlView.addGestureRecognizer(tap)

        if needsPanHidden {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(_panGestureAction(_:)))
            maskControlView.addGestureRecognizer(panGesture)
        }
        addSubview(containerView)

        setupContainerView()
        setupContainerSubViews()
        layoutContainerViewSubViews()
    }

    // MARK: - To be override

    open func setupDefaults() {
        showAnimationType = .downFadeIn
        hideAnimationType = .downFadeOut
        backMaskValue = 0.4
        showDuration = 0.3
        hideDuration = 0.3
    }
    
    open func setupContainerView() {
        // 设置 containerView 的 frame、圆角、背景色、阴影等
    }

    open func setupContainerSubViews() {
        // 添加 containerView 的子视图
    }

    open func layoutContainerViewSubViews() {
        // 设置 containerView 的子视图的布局或约束
    }

    open func actionAlertViewWillShow() {
        baseDelegate?.actionAlertViewWillShow?()
        NotificationCenter.default.post(name: .AlertViewWillShow, object: self)
    }

    open func actionAlertViewDidShow() {
        baseDelegate?.actionAlertViewDidShow?()
        NotificationCenter.default.post(name: .AlertViewDidShow, object: self)
    }

    open func actionAlertViewWillDismiss() {
        baseDelegate?.actionAlertViewWillDismiss?()
        NotificationCenter.default.post(name: .AlertViewWillDismiss, object: self)
    }

    open func actionAlertViewDidDismiss() {
        baseDelegate?.actionAlertViewDidDismiss?()
        NotificationCenter.default.post(name: .AlertViewDidDismiss, object: self)
    }

    open func actionAlertViewDidSelectBackGroundView() {
        baseDelegate?.actionAlertViewDidSelectBackGroundView?()
    }

    /// 子类实现自定义动画时不用调用 super
    open func showAnimationCustom() {
        if let delegate = baseDelegate?.actionAlertViewShowAnimationCustom {
            delegate(self)
        } else {
            assertionFailure("!!!没有实现自定义动画方法")
        }
    }

    /// 子类实现自定义动画时不用调用 super
    open func hideAnimationCustom() {
        if let delegate = baseDelegate?.actionAlertViewHideAnimationCustom {
            delegate(self)
        } else {
            assertionFailure("!!!没有实现自定义动画方法")
        }
    }

    // MARK: - show

    func show() {
        setup()
        showAnimation()
    }

    func showAnimation() {
        layoutIfNeeded()
        if !disableEndEdit {
            UIApplication.shared.alertCompatibleKeyWindow?.endEditing(true)
        }

        actionAlertViewWillShow()

        switch showAnimationType {
        case .fadeIn:
            showAnimationFadeIn()
        case .downFadeIn:
            showAnimationDownFadeIn()
        case .bounce:
            showAnimationBounce()
        case .fromBottom:
            showAnimationFromBottom()
        case .fromTop:
            showAnimationFromTop()
        case .fromRight:
            showAnimationFromRight()
        case .fromLeft:
            showAnimationFromLeft()
        case .custom:
            showAnimationCustom()
        case .none:
            break
        }

        maskControlView.alpha = 0
        UIView.animate(withDuration: showDuration) {
            self.maskControlView.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + showDuration) {
            self.actionAlertViewDidShow()
        }
    }

    // MARK: - dismiss

    @objc public func dismiss() {
        if !disableEndEdit {
            endEditing(true)
        }
        
        actionAlertViewWillDismiss()
        hideAnimation()

        if let oldKeyWindow = oldKeyWindow {
            oldKeyWindow.isHidden = false
        }
    }

    func hideAnimation() {
        switch hideAnimationType {
        case .fadeOut:
            hideAnimationFadeOut()
        case .downFadeOut:
            hideAnimationDownFadeOut()
        case .bounce:
            hideAnimationBounce()
        case .toBottom:
            hideAnimationToBottom()
        case .toTop:
            hideAnimationToTop()
        case .toRight:
            hideAnimationToRight()
        case .toLeft:
            hideAnimationToLeft()
        case .custom:
            hideAnimationCustom()
        case .none:
            break
        }

        UIView.animate(withDuration: hideDuration) {
            self.maskControlView.alpha = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + hideDuration) {
            self.containerView.removeFromSuperview()
            //            self.containerView = nil
            if let alertWindow = self.alertWindow {
                alertWindow.removeFromSuperview()
                self.alertWindow = nil
            } else {
                self.removeFromSuperview()
            }
            self.actionAlertViewDidDismiss()
        }
    }

    // MARK: - Gesture

    @objc private func backGroundViewTouchAction() {
        actionAlertViewDidSelectBackGroundView()
        if tapBckHidden {
            dismiss()
        }
    }

    @objc private func _panGestureAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            if needsPanHidden {
                dismiss()
            }
        }
    }

    // MARK: - Container top cornerRadii

    public func addContainerTopMaskLayer(cornerRadii: CGFloat) {
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.cornerRadius = cornerRadii
    }
}

extension AlertBaseView {

    /// 检查标识符是否可用
    /// 如果已经存在则返回 false，否则返回 true
    static public func checkUniqueIdentifier(_ uniqueIdentifier: String) -> Bool {
        return visibleAlertIds.insert(uniqueIdentifier).inserted
    }
}
