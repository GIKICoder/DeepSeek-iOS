//
//  FSPageControl.swift
//  FSPagerView
//
//  Created by Wenchao Ding on 17/12/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

import UIKit

@IBDesignable
open class FSPageControl: UIControl {
    /// The number of page indicators of the page control. Default is 0.
    @IBInspectable
    open var numberOfPages: Int = 0 {
        didSet {
            setNeedsCreateIndicators()
        }
    }

    /// The current page, highlighted by the page control. Default is 0.
    @IBInspectable
    open var currentPage: Int = 0 {
        didSet {
            setNeedsUpdateIndicators()
        }
    }

    /// The spacing to use of page indicators in the page control.
    @IBInspectable
    open var itemSpacing: CGFloat = 6 {
        didSet {
            setNeedsUpdateIndicators()
        }
    }

    /// The spacing to use between page indicators in the page control.
    @IBInspectable
    open var interitemSpacing: CGFloat = 6 {
        didSet {
            setNeedsLayout()
        }
    }

    /// The distance that the page indicators is inset from the enclosing page control.
    @IBInspectable
    open var contentInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    /// The horizontal alignment of content within the control’s bounds. Default is center.
    override open var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        didSet {
            setNeedsLayout()
        }
    }

    /// Hide the indicator if there is only one page. default is NO
    @IBInspectable
    open var hidesForSinglePage: Bool = false {
        didSet {
            setNeedsUpdateIndicators()
        }
    }

    open var useDiameter = false

    var strokeColors: [UIControl.State: UIColor] = [:]
    var fillColors: [UIControl.State: UIColor] = [:]
    var paths: [UIControl.State: UIBezierPath] = [:]
    var images: [UIControl.State: UIImage] = [:]
    var alphas: [UIControl.State: CGFloat] = [:]
    var transforms: [UIControl.State: CGAffineTransform] = [:]

    fileprivate weak var contentView: UIView!

    fileprivate var needsUpdateIndicators = false
    fileprivate var needsCreateIndicators = false
    fileprivate var indicatorLayers = [CAShapeLayer]()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = {
            let x = self.contentInsets.left
            let y = self.contentInsets.top
            let width = self.frame.width - self.contentInsets.left - self.contentInsets.right
            let height = self.frame.height - self.contentInsets.top - self.contentInsets.bottom
            let frame = CGRect(x: x, y: y, width: width, height: height)
            return frame
        }()
    }

    override open func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        let diameter = itemSpacing
        let spacing = interitemSpacing
        var x: CGFloat = {
            switch self.contentHorizontalAlignment {
            case .left, .leading:
                return 0
            case .center, .fill:
                let midX = self.contentView.bounds.midX
                let amplitude = CGFloat(self.numberOfPages / 2) * diameter + spacing * CGFloat((self.numberOfPages - 1) / 2)
                return midX - amplitude
            case .right, .trailing:
                let contentWidth = diameter * CGFloat(self.numberOfPages) + CGFloat(self.numberOfPages - 1) * spacing
                return contentView.frame.width - contentWidth
            default:
                return 0
            }
        }()
        for (index, value) in indicatorLayers.enumerated() {
            let state: UIControl.State = (index == currentPage) ? .selected : .normal
            let image = images[state]
            var size = image?.size ?? CGSize(width: diameter, height: diameter)
            if useDiameter {
                size = CGSize(width: diameter, height: diameter)
            }
            let origin = CGPoint(x: x - (size.width - diameter) * 0.5, y: contentView.bounds.midY - size.height * 0.5)
            value.frame = CGRect(origin: origin, size: size)
            x = x + spacing + diameter
        }
    }

    /// Sets the stroke color for page indicators to use for the specified state. (selected/normal).
    ///
    /// - Parameters:
    ///   - strokeColor: The stroke color to use for the specified state.
    ///   - state: The state that uses the specified stroke color.
    @objc(setStrokeColor:forState:)
    open func setStrokeColor(_ strokeColor: UIColor?, for state: UIControl.State) {
        guard strokeColors[state] != strokeColor else {
            return
        }
        strokeColors[state] = strokeColor
        setNeedsUpdateIndicators()
    }

    /// Sets the fill color for page indicators to use for the specified state. (selected/normal).
    ///
    /// - Parameters:
    ///   - fillColor: The fill color to use for the specified state.
    ///   - state: The state that uses the specified fill color.
    @objc(setFillColor:forState:)
    open func setFillColor(_ fillColor: UIColor?, for state: UIControl.State) {
        guard fillColors[state] != fillColor else {
            return
        }
        fillColors[state] = fillColor
        setNeedsUpdateIndicators()
    }

    /// Sets the image for page indicators to use for the specified state. (selected/normal).
    ///
    /// - Parameters:
    ///   - image: The image to use for the specified state.
    ///   - state: The state that uses the specified image.
    @objc(setImage:forState:)
    open func setImage(_ image: UIImage?, for state: UIControl.State) {
        guard images[state] != image else {
            return
        }
        images[state] = image
        setNeedsUpdateIndicators()
    }

    @objc(setAlpha:forState:)

    /// Sets the alpha value for page indicators to use for the specified state. (selected/normal).
    ///
    /// - Parameters:
    ///   - alpha: The alpha value to use for the specified state.
    ///   - state: The state that uses the specified alpha.
    open func setAlpha(_ alpha: CGFloat, for state: UIControl.State) {
        guard alphas[state] != alpha else {
            return
        }
        alphas[state] = alpha
        setNeedsUpdateIndicators()
    }

    /// Sets the path for page indicators to use for the specified state. (selected/normal).
    ///
    /// - Parameters:
    ///   - path: The path to use for the specified state.
    ///   - state: The state that uses the specified path.
    @objc(setPath:forState:)
    open func setPath(_ path: UIBezierPath?, for state: UIControl.State) {
        guard paths[state] != path else {
            return
        }
        paths[state] = path
        setNeedsUpdateIndicators()
    }

    // MARK: - Private functions

    fileprivate func commonInit() {
        // Content View
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.clear
        addSubview(view)
        contentView = view
        isUserInteractionEnabled = false
    }

    fileprivate func setNeedsUpdateIndicators() {
        needsUpdateIndicators = true
        setNeedsLayout()
        DispatchQueue.main.async {
            self.updateIndicatorsIfNecessary()
        }
    }

    fileprivate func updateIndicatorsIfNecessary() {
        guard needsUpdateIndicators else {
            return
        }
        guard indicatorLayers.count > 0 else {
            return
        }
        needsUpdateIndicators = false
        contentView.isHidden = hidesForSinglePage && numberOfPages <= 1
        if !contentView.isHidden {
            for layer in indicatorLayers {
                layer.isHidden = false
                updateIndicatorAttributes(for: layer)
            }
        }
    }

    fileprivate func updateIndicatorAttributes(for layer: CAShapeLayer) {
        let index = indicatorLayers.firstIndex(of: layer)
        let state: UIControl.State = index == currentPage ? .selected : .normal
        if let image = images[state] {
            layer.strokeColor = nil
            layer.fillColor = nil
            layer.path = nil
            layer.contents = image.cgImage
        } else {
            layer.contents = nil
            let strokeColor = strokeColors[state]
            let fillColor = fillColors[state]
            if strokeColor == nil && fillColor == nil {
                layer.fillColor = (state == .selected ? UIColor.white : UIColor.gray).cgColor
                layer.strokeColor = nil
            } else {
                layer.strokeColor = strokeColor?.cgColor
                layer.fillColor = fillColor?.cgColor
            }
            layer.path = paths[state]?.cgPath ?? UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: itemSpacing, height: itemSpacing)).cgPath
        }
        if let transform = transforms[state] {
            layer.transform = CATransform3DMakeAffineTransform(transform)
        }
        layer.opacity = Float(alphas[state] ?? 1.0)
    }

    fileprivate func setNeedsCreateIndicators() {
        needsCreateIndicators = true
        DispatchQueue.main.async {
            self.createIndicatorsIfNecessary()
        }
    }

    fileprivate func createIndicatorsIfNecessary() {
        guard needsCreateIndicators else {
            return
        }
        needsCreateIndicators = false
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if currentPage >= numberOfPages {
            currentPage = numberOfPages - 1
        }
        for layer in indicatorLayers {
            layer.removeFromSuperlayer()
        }
        indicatorLayers.removeAll()
        for _ in 0 ..< numberOfPages {
            let layer = CAShapeLayer()
            layer.actions = ["bounds": NSNull()]
            contentView.layer.addSublayer(layer)
            indicatorLayers.append(layer)
        }
        setNeedsUpdateIndicators()
        updateIndicatorsIfNecessary()
        CATransaction.commit()
    }
}

extension UIControl.State: Hashable {
    public var hashValue: Int {
        return Int((6777 * rawValue + 3777) % UInt(UInt16.max))
    }
}
