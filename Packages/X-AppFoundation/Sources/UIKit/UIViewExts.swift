//
//  UIViewExtensions.swift
//
//
//  Created by GIKI on 2024/10/22.
//

import Foundation
import UIKit

public extension UIView {
    ///  Border color of view; also inspectable from Storyboard.
    @IBInspectable var layerBorderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            // Fix React-Native conflict issue
            guard String(describing: type(of: color)) != "__NSCFType" else { return }
            layer.borderColor = color.cgColor
        }
    }
    
    ///  Border width of view; also inspectable from Storyboard.
    @IBInspectable var layerBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    ///  Corner radius of view; also inspectable from Storyboard.
    @IBInspectable var layerCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
    
    ///  Check if view is in RTL format.
    var isRightToLeft: Bool {
        return effectiveUserInterfaceLayoutDirection == .rightToLeft
    }
    
    ///  Take screenshot of view (if applicable).
    var screenshot: UIImage? {
        let size = layer.frame.size
        guard size != .zero else { return nil }
        return UIGraphicsImageRenderer(size: layer.frame.size).image { context in
            layer.render(in: context.cgContext)
        }
    }
    
    ///  Shadow color of view; also inspectable from Storyboard.
    @IBInspectable var layerShadowColor: UIColor? {
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    ///  Shadow offset of view; also inspectable from Storyboard.
    @IBInspectable var layerShadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    ///  Shadow opacity of view; also inspectable from Storyboard.
    @IBInspectable var layerShadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    ///  Shadow radius of view; also inspectable from Storyboard.
    @IBInspectable var layerShadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    ///  Masks to bounds of view; also inspectable from Storyboard.
    @IBInspectable var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    ///  Size of view.
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
    
    ///  Get view's parent view controller
    var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    ///  Height of view.
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    ///  Width of view.
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    ///  x origin of view.
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    ///  y origin of view.
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
}

public extension UIView {
    
    /// 左边位置（frame.origin.x）
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    /// 顶部位置（frame.origin.y）
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    /// 右边位置（frame.origin.x + frame.size.width）
    var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            frame.origin.x = newValue - frame.size.width
        }
    }
    
    /// 底部位置（frame.origin.y + frame.size.height）
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            frame.origin.y = newValue - frame.size.height
        }
    }
    
    /// 中心点的 X 坐标（center.x）
    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            center.x = newValue
        }
    }
    
    /// 中心点的 Y 坐标（center.y）
    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            center.y = newValue
        }
    }
}


public extension UIView {
    convenience init(color: UIColor) {
        self.init(frame: .zero)
        backgroundColor = color
    }
}

public extension UIView {
    var asJpeg: Data? {
        asImage?.jpegData(compressionQuality: 0.8)
    }
    
    var asImage: UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { rendererContext in layer.render(in: rendererContext.cgContext) }
        return image
    }
    
    func addUpDownGradient(start: UIColor, end: UIColor) {
        addGradient(colors: [start, end], startPoint: CGPointMake(0.5, 0), endPoint: CGPointMake(0.5, 1))
    }
    
    ///  addGradient 添加一个渐变。它接受渐变的颜色、开始点和结束点作为参数。
    ///  colors 参数是一个 UIColor 数组，定义了渐变中使用的颜色。
    ///  startPoint 和 endPoint 参数定义了渐变的方向和范围，它们的值是在单位坐标系中指定的，其中 (0,0) 是图层的左上角，(1,1) 是图层的右下角。
    ///  通过调整 startPoint 和 endPoint，你可以控制渐变的方向。例如，(0,0) 到 (1,1) 创建了一个从左上角到右下角的渐变。你可以根据需要调整这些点来改变渐变的方向。
    func addGradient(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.insertSublayer(gradientLayer, at: 0)
    }

}

// MARK: - ViewController

public extension UIView {
    @objc var navigationController: UINavigationController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            responder = nextResponder
            if let navigationController = nextResponder as? UINavigationController {
                return navigationController
            }
        }
        return nil
    }
    
    @objc var viewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            responder = nextResponder
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    @objc var topViewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            responder = nextResponder
            if let viewController = nextResponder as? UIViewController, viewController.presentingViewController == nil {
                if let navigationController = viewController as? UINavigationController {
                    return navigationController.topViewController
                }
                return viewController
            }
        }
        return nil
    }
    
    func findViewController<T: UIViewController>() -> T? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? T {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    @objc func findViewController(_ test: (UIViewController) -> Bool) -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController, test(viewController) {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

// MARK: - Layout

public extension UIView {
    func pinToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview else {
            assertionFailure("""
            The view must have a superview before calling pinToSuperview.
            You can add the view to a superview before calling pinToSuperview or
            call pinToSuperview in viewDidMoveToSuperview.
            """)
            return
        }
        
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
    func pinLeading(constant: CGFloat = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview else {
            assertionFailure("""
            The view must have a superview before calling pinToSuperview.
            You can add the view to a superview before calling pinToSuperview or
            call pinToSuperview in viewDidMoveToSuperview.
            """)
            return
        }
        
        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: constant).isActive = true
    }
    
    func pinTrailing(constant: CGFloat = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview else {
            assertionFailure("""
            The view must have a superview before calling pinToSuperview.
            You can add the view to a superview before calling pinToSuperview or
            call pinToSuperview in viewDidMoveToSuperview.
            """)
            return
        }
        
        trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: constant).isActive = true
    }
    
    func pinTop(constant: CGFloat = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview else {
            assertionFailure("""
            The view must have a superview before calling pinToSuperview.
            You can add the view to a superview before calling pinToSuperview or
            call pinToSuperview in viewDidMoveToSuperview.
            """)
            return
        }
        
        topAnchor.constraint(equalTo: superview.topAnchor, constant: constant).isActive = true
    }
    
    func pinBottomAnchor(constant: CGFloat = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview else {
            assertionFailure("""
            The view must have a superview before calling pinToSuperview.
            You can add the view to a superview before calling pinToSuperview or
            call pinToSuperview in viewDidMoveToSuperview.
            """)
            return
        }
        
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: constant).isActive = true
    }
    
    var isVisible: Bool {
        get { !isHidden }
        set { isHidden = !newValue }
    }
}

// MARK: - Layout


public extension UIView {
    func findView(in view: UIView, test: (UIView) -> Bool) -> UIView? {
        if test(view) {
            return view
        }
        
        for subview in view.subviews {
            if let foundView = findView(in: subview, test: test) {
                return foundView
            }
        }
        
        return nil
    }
}


public extension UIView {
    
    /// 判断当前布局是否为阿拉伯语（右到左布局）
    var isRTL: Bool {
        // 获取当前的布局方向
        let layoutDirection = UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute)
        
        // 检查是否为右到左布局
        let isRTL = (layoutDirection == .rightToLeft)
        
        // 可选：进一步确认当前语言是否为阿拉伯语
        if isRTL {
            if let languageCode = Locale.current.languageCode {
                return languageCode.hasPrefix("ar")
            }
            return false
        }
        
        return false
    }
}


// MARK: - 添加圆角
public extension UIView {
    
    /// 为视图的顶部添加圆角
    /// - Parameter radius: 圆角的半径
    func addTopCorners(radius: CGFloat) {
        // 设置圆角半径
        self.layer.cornerRadius = radius
        // 指定只应用于左上和右上角
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        // 确保子视图不超出圆角范围
        self.layer.masksToBounds = true
    }
    
    /// 为视图的底部添加圆角
    /// - Parameter radius: 圆角的半径
    func addBottomCorners(radius: CGFloat) {
        // 设置圆角半径
        self.layer.cornerRadius = radius
        // 指定只应用于左下和右下角
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        // 确保子视图不超出圆角范围
        self.layer.masksToBounds = true
    }
    
    
    /// 设置视图的上部分圆角
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - corners: 需要圆角的方向，默认为 [.topLeft, .topRight]
    func setRoundedCorners(radius: CGFloat, corners: UIRectCorner = [.topLeft, .topRight]) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        layer.mask = maskLayer
    }
}

extension UIView {
  @objc public var isArabic: Bool {
    effectiveUserInterfaceLayoutDirection == .rightToLeft
  }
}
