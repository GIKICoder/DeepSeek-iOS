//
//  @filename   UIImageView + Skeleton.swift
//  @pacakage
//
//  @author     jeffy
//  @date       2024/10/11
//  @abstract
//
//  Copyright (c) 2024 and Confidential to jeffy All rights reserved.
//

import Skeleton
import UIKit

public class SkeletonImageView: UIImageView {
    private var skeletonView: GradientContainerView = .init()

    override public init(frame: CGRect = .zero) {
        super.init(frame: frame)
        skeletonView = GradientContainerView(frame: bounds)
        skeletonView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        skeletonView.gradientLayer.colors = UIColor.skeletonCGColors
        skeletonView.gradientLayer.slide(to: .right)
        addSubview(skeletonView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var image: UIImage? {
        didSet {
            imageDidChange()
        }
    }

    public func showSkeleton() {
        skeletonView.isHidden = false
        skeletonView.gradientLayer.slide(to: .right)
    }

    public func hideSkeleton() {
        skeletonView.isHidden = true
    }

    public func imageDidChange() {
        if image != nil {
            hideSkeleton()
        } else {
            showSkeleton()
        }
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        skeletonView.gradientLayer.colors = UIColor.skeletonCGColors
    }
}

extension UIColor {
    // MARK: - Static properties

    static var skeletonCGColors: [CGColor] {
     
        let baseColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1)
            } else {
                return UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1)
            }
        }
        let darkColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1).brightened_(by: 0.8)
            } else {
                return UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1).brightened_(by: 0.95)
            }
        }
        
        return [baseColor.cgColor,
                darkColor.cgColor,
                baseColor.cgColor]
    }
    
    // MARK: - function

    func alpha(_ value: CGFloat) -> UIColor {
        withAlphaComponent(value)
    }
    
    func brightened_(by factor: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * factor, alpha: a)
    }
}

