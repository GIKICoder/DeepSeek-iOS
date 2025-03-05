//
//  UIImageExtensions.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/10.
//

import UIKit

public extension UIImage {
    
    var circle: UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(ovalIn: rect).addClip()
        draw(in: rect)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }

    /// 拉伸 UIImage, 拉伸比例 0.5
    var stretchd: UIImage {
        stretched(0.5)
    }

    /// 拉伸 UIImage，指定拉伸比例
    /// - Parameter insetRatio: 拉伸比例
    func stretched(_ insetRatio: CGFloat) -> UIImage {
        let center = CGPoint(x: size.width * insetRatio, y: size.height * insetRatio)
        return resizableImage(
            withCapInsets: UIEdgeInsets(top: center.y, left: center.x, bottom: center.y, right: center.x),
            resizingMode: .stretch
        )
    }
}

public extension UIImage {
    /// Creates a dynamic image that automatically switches between light and dark mode versions.
    /// - Parameters:
    ///   - lightName: The name of the image to use in light mode.
    ///   - darkName: The name of the image to use in dark mode.
    ///   - traitCollection: The trait collection to use for the initial image. Defaults to nil.
    /// - Returns: A UIImage that will automatically update based on the current trait collection.
    static func dynamicImage(lightName: String, darkName: String, compatibleWith traitCollection: UITraitCollection? = nil) -> UIImage? {
        let lightImage = UIImage(named: lightName)
        let darkImage = UIImage(named: darkName)

        guard let light = lightImage, let dark = darkImage else {
            print("WARNING: Failed to load images for dynamic image: \(lightName), \(darkName)")
            return lightImage ?? darkImage
        }

        let asset = UIImageAsset()
        asset.register(light, with: UITraitCollection(userInterfaceStyle: .light))
        asset.register(dark, with: UITraitCollection(userInterfaceStyle: .dark))

        return asset.image(with: traitCollection ?? UITraitCollection.current)
    }
}

// MARK: - UIImage+Color

public extension UIImage {
    /// Creates an image of the specified color with optional rounded corners.
    ///
    /// - Parameters:
    ///   - color: The color of the image.
    ///   - size: The size of the image. Default is 1x1.
    ///   - cornerRadius: The radius for the rounded corners. Default is 0 (no rounded corners).
    /// - Returns: A UIImage filled with the specified color and rounded corners.
    static func image(withColor color: UIColor, size: CGSize = CGSize(width: 1, height: 1), cornerRadius: CGFloat = 0) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            color.setFill()
            path.fill()
        }
    }
}

// MARK: - UIImage + Cropped
public extension UIImage {
    
    var hasAlpha: Bool {
        guard let cgImage = self.cgImage else { return false }
        let alphaInfo = cgImage.alphaInfo
        return (alphaInfo == .first || alphaInfo == .last ||
                alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast)
    }
    
    func croppedImage(withFrame frame: CGRect, angle: Int, circularClip: Bool) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, !hasAlpha && !circularClip, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        if circularClip {
            context.addEllipse(in: CGRect(origin: .zero, size: frame.size))
            context.clip()
        }
        
        // To conserve memory in not needing to completely re-render the image re-rotated,
        // map the image to a view and then use Core Animation to manipulate its rotation
        if angle != 0 {
            let imageView = UIImageView(image: self)
            imageView.layer.minificationFilter = .nearest
            imageView.layer.magnificationFilter = .nearest
            imageView.transform = CGAffineTransform.identity.rotated(by: CGFloat(angle) * (.pi/180.0))
            let rotatedRect = imageView.bounds.applying(imageView.transform)
            let containerView = UIView(frame: CGRect(origin: .zero, size: rotatedRect.size))
            containerView.addSubview(imageView)
            imageView.center = containerView.center
            context.translateBy(x: -frame.origin.x, y: -frame.origin.y)
            containerView.layer.render(in: context)
        } else {
            context.translateBy(x: -frame.origin.x, y: -frame.origin.y)
            draw(at: .zero)
        }
        
        guard let croppedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        guard let cgImage = croppedImage.cgImage else { return nil }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
}

public extension UIImage {
    /// 创建黑色系统图标
    /// - Parameter systemName: 系统图标名称
    /// - Returns: 黑色的系统图标
    static func blackSystemImage(_ systemName: String) -> UIImage? {
        UIImage(systemName: systemName)?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
    }
    
    /// 创建指定颜色的系统图标
    /// - Parameters:
    ///   - systemName: 系统图标名称
    ///   - color: 需要的颜色
    /// - Returns: 指定颜色的系统图标
    static func systemImage(_ systemName: String, tintColor color: UIColor) -> UIImage? {
        UIImage(systemName: systemName)?
            .withTintColor(color, renderingMode: .alwaysOriginal)
    }
}
