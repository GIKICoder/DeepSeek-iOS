//
//  UIColorExtensions.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/10.
//

import UIKit

public extension UIColor {

    /// 初始化 UIColor 使用十六进制字符串
    /// - Parameters:
    ///   - hex: 十六进制字符串，可以以 "#" 开头或不以 "#" 开头
    ///   - alpha: 颜色的透明度，值范围从 0.0 到 1.0
    @objc convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    @objc convenience init(hexValue: UInt32) {
        let red = CGFloat((hexValue & 0x00FF_0000) >> 16) / 255.0
        let green = CGFloat((hexValue & 0x0000_FF00) >> 8) / 255.0
        let blue = CGFloat(hexValue & 0x0000_00FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    @objc convenience init(hexValue: UInt32, alpha: CGFloat) {
        let red = CGFloat((hexValue & 0x00FF_0000) >> 16) / 255.0
        let green = CGFloat((hexValue & 0x0000_FF00) >> 8) / 255.0
        let blue = CGFloat(hexValue & 0x0000_00FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    static var random: UIColor {
        let red = CGFloat.random(in: 0 ... 1)
        let green = CGFloat.random(in: 0 ... 1)
        let blue = CGFloat.random(in: 0 ... 1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - Theme
public extension UIColor {
    
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return light
            case .dark:
                return dark
            case .unspecified:
                return dark
            @unknown default:
                return dark
            }
        }
    }

    var hexString: String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#000000"
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        let hex = String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        return hex
    }
}


// MARK: - UIColor Extension for Interpolation

public extension UIColor {
    
    /// 插值两个颜色
    /// - Parameters:
    ///   - from: 起始颜色
    ///   - to: 目标颜色
    ///   - fraction: 插值比例 (0.0 - 1.0)
    /// - Returns: 插值后的颜色
    static func interpolate(from: UIColor, to: UIColor, with fraction: CGFloat) -> UIColor {
        let f = min(max(0, fraction), 1)
        
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        
        from.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        
        var tRed: CGFloat = 0
        var tGreen: CGFloat = 0
        var tBlue: CGFloat = 0
        var tAlpha: CGFloat = 0
        
        to.getRed(&tRed, green: &tGreen, blue: &tBlue, alpha: &tAlpha)
        
        let red = fRed + (tRed - fRed) * f
        let green = fGreen + (tGreen - fGreen) * f
        let blue = fBlue + (tBlue - fBlue) * f
        let alphaFraction = fAlpha + (tAlpha - fAlpha) * f
        
        return UIColor(red: red, green: green, blue: blue, alpha: alphaFraction)
    }
}

// MARK: - UIColor + UIImage
public extension UIColor {

    func as1ptImage() -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
