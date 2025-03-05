//
//  StringExtensions.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/10.
//

import UIKit

extension String {
    
    public var isBlank: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    public mutating func trim() {
        self = self.trimmed()
    }
    
    /// Trims white space and new line characters, returns a new string
    public func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
#if os(iOS)
    
    /// 计算文字尺寸
    /// - Parameters:
    ///   - width: 最大宽度
    ///   - font: 字体
    ///   - numberOfLines: 最大行数（0表示不限制行数）
    ///   - lineBreakMode: 换行模式
    /// - Returns: 计算得到的文字尺寸
    public func calcSize(_ width: CGFloat,
                         font: UIFont,
                         numberOfLines: Int = 0,
                         lineBreakMode: NSLineBreakMode? = nil) -> CGSize {
        // 创建段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        if let lineBreakMode = lineBreakMode {
            paragraphStyle.lineBreakMode = lineBreakMode
        }
        
        // 设置属性
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        
        // 计算尺寸
        let maxSize = CGSize(width: width, height: CGFloat(Double.greatestFiniteMagnitude))
        var boundingRect = (self as NSString).boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        // 处理行数限制
        if numberOfLines > 0 {
            let maxHeight = ceil(font.lineHeight * CGFloat(numberOfLines))
            boundingRect.size.height = min(boundingRect.size.height, maxHeight)
        }
        
        // 向上取整确保显示完整
        return CGSize(
            width: ceil(boundingRect.width),
            height: ceil(boundingRect.height)
        )
    }
    
    /// Returns hight of rendered string
    public func calcHeight(_ width: CGFloat, font: UIFont, lineBreakMode: NSLineBreakMode?) -> CGFloat {
        var attrib: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        if lineBreakMode != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = lineBreakMode!
            attrib.updateValue(paragraphStyle, forKey: NSAttributedString.Key.paragraphStyle)
        }
        let size = CGSize(width: width, height: CGFloat(Double.greatestFiniteMagnitude))
        return ceil((self as NSString).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attrib, context: nil).height)
    }
    
    public func addToPasteboard() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = self
    }
#endif
    
}

extension String {
    
    public func trim(to maximumCharacters: Int) -> String {
        "\(self[..<index(startIndex, offsetBy: maximumCharacters)])" + "..."
    }
    
    
    public func truncated(head: Int = 20, tail: Int = 20) -> String {
        guard count > head + tail else { return self }
        let headIndex = index(startIndex, offsetBy: head)
        let tailIndex = index(endIndex, offsetBy: -tail)
        return String(self[..<headIndex]) + "..." + String(self[tailIndex...])
    }
}

// MARK: - String + URL
extension String {
    //  URL encode a string (percent encoding special chars)
    public func urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    //  URL encode a string (percent encoding special chars) mutating version
    mutating func urlEncode() {
        self = urlEncoded()
    }
    
    //  Removes percent encoding from string
    public func urlDecoded() -> String {
        return removingPercentEncoding ?? self
    }
    
    //  Mutating versin of urlDecoded
    mutating func urlDecode() {
        self = urlDecoded()
    }
}

// MARK: - String Extension
extension String {
    // MD5
    public var md5: String {
        guard let data = self.data(using: .utf8) else { return self }
        return data.md5
    }
    
    // SHA256
    public var sha256: String {
        guard let data = self.data(using: .utf8) else { return self }
        return data.sha256
    }
}

extension String {
    
    /// Localized string
    ///
    /// Example:
    /// ```
    /// "Hello".localized
    /// ```
    public var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
