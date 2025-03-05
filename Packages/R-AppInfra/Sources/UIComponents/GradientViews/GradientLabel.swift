//
//  GradientLabel.swift
//  AppComponents
//
//  Created by GIKI on 2024/12/23.
//

import UIKit
import CoreText
import AppFoundation

@objcMembers
public class GradientLabel: UILabel {
    private var gradientLayer: CAGradientLayer?
    private var textMaskLayer: CATextLayer?
    
    // 渐变方向枚举
    public enum GradientDirection {
        case leftToRight    // 从左到右
        case rightToLeft    // 从右到左
        case topToBottom    // 从上到下
        case bottomToTop    // 从下到上
        case custom(start: CGPoint, end: CGPoint) // 自定义方向
        
        var startPoint: CGPoint {
            switch self {
            case .leftToRight:
                return CGPoint(x: 0.0, y: 0.5)
            case .rightToLeft:
                return CGPoint(x: 1.0, y: 0.5)
            case .topToBottom:
                return CGPoint(x: 0.5, y: 0.0)
            case .bottomToTop:
                return CGPoint(x: 0.5, y: 1.0)
            case .custom(let start, _):
                return start
            }
        }
        
        var endPoint: CGPoint {
            switch self {
            case .leftToRight:
                return CGPoint(x: 1.0, y: 0.5)
            case .rightToLeft:
                return CGPoint(x: 0.0, y: 0.5)
            case .topToBottom:
                return CGPoint(x: 0.5, y: 1.0)
            case .bottomToTop:
                return CGPoint(x: 0.5, y: 0.0)
            case .custom(_, let end):
                return end
            }
        }
    }
    
    // 可配置属性
    public var gradientColors: [UIColor] = [
        UIColor(hex: "FFA336"),
        UIColor(hex: "FF36C7"),
        UIColor(hex: "8C45FF"),
        UIColor(hex: "3333FF")
    ] {
        didSet {
            updateGradientColors()
        }
    }
    
    public var gradientDirection: GradientDirection = .leftToRight {
        didSet {
            updateGradientDirection()
        }
    }
    
    public override var text: String? {
        didSet {
            updateMaskLayer()
        }
    }
    
    public override var font: UIFont! {
        didSet {
            updateMaskLayer()
        }
    }
    
    public override var textAlignment: NSTextAlignment {
        didSet {
            updateMaskLayer()
        }
    }
    
    public override var numberOfLines: Int {
        didSet {
            updateMaskLayer()
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            gradientLayer?.frame = bounds
            textMaskLayer?.frame = bounds
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        // 初始化渐变层
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = gradientColors.map { $0.cgColor }
        gradient.startPoint = gradientDirection.startPoint
        gradient.endPoint = gradientDirection.endPoint
        layer.addSublayer(gradient)
        gradientLayer = gradient
        
        // 初始化遮罩层
        let maskLayer = CATextLayer()
        maskLayer.frame = bounds
        maskLayer.string = self.attributedTextString()
        maskLayer.alignmentMode = convertTextAlignment(labelAlignment: self.textAlignment)
        maskLayer.contentsScale = UIScreen.main.scale
        maskLayer.isWrapped = true
        maskLayer.truncationMode = .end
        gradient.mask = maskLayer
        textMaskLayer = maskLayer
    }
    
    private func updateGradientColors() {
        gradientLayer?.colors = gradientColors.map { $0.cgColor }
    }
    
    private func updateGradientDirection() {
        gradientLayer?.startPoint = gradientDirection.startPoint
        gradientLayer?.endPoint = gradientDirection.endPoint
    }
    
    private func updateMaskLayer() {
        guard let maskLayer = textMaskLayer else { return }
        maskLayer.string = self.attributedTextString()
        maskLayer.font = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        maskLayer.fontSize = font.pointSize
        maskLayer.alignmentMode = convertTextAlignment(labelAlignment: self.textAlignment)
    }
    
    private func attributedTextString() -> NSAttributedString? {
        guard let text = self.text else { return nil }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.font as Any,
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    // 辅助方法：将 UILabel 的 textAlignment 转换为 CATextLayer 的 alignmentMode
    private func convertTextAlignment(labelAlignment: NSTextAlignment) -> CATextLayerAlignmentMode {
        switch labelAlignment {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        case .justified:
            return .justified
        case .natural:
            return .natural
        @unknown default:
            return .natural
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
        textMaskLayer?.frame = bounds
        textMaskLayer?.string = self.attributedTextString()
    }
}
