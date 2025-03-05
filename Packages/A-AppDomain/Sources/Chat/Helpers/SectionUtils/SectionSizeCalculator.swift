//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/21.
//

import Foundation
import AppFoundation
import UIKit

// MARK: - Cell Size Constants

public struct CellSizeConstants {
    
    /// 消息背景卡片的最大宽度
    static public let maxMessageWidth: CGFloat = AppF.screenWidth - 48 - 16
    /// 消息内容的最大宽度
    static public let maxContentWidth: CGFloat = maxMessageWidth - contentPadding.left  - contentPadding.right
    
    /// Message 消息内边距, 背景和内容的内边距
    static public let contentPadding: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    /// Message 消息最小尺寸
    static public let minContentSize: CGSize = CGSize(width: 48, height: 48)
    
    /// 消息背景卡片的左边距
    static public let leftPadding: CGFloat = 48.0
    
    /// Cell 的固定宽度
    static public let cellWidth: CGFloat = AppF.screenWidth

}
// MARK: - CellSizeCalculator

public class CellSizeCalculator {
    
    /// 消息背景卡片的最大宽度
    private let maxContentWidth: CGFloat
    
    /// Message 消息内边距, 背景和内容的内边距
    private let contentPadding: UIEdgeInsets
    
    /// Message 消息最小尺寸
    private let minContentSize: CGSize
    
    /// 消息背景卡片的左边距
    private let leftPadding: CGFloat
    
    /// 设备屏幕宽度
    private let screenWidth: CGFloat
    
    /// 初始化器允许自定义常量，默认为 CellSizeConstants 中的值
    public init(
        maxContentWidth: CGFloat = CellSizeConstants.maxMessageWidth,
        contentPadding: UIEdgeInsets = CellSizeConstants.contentPadding,
        minContentSize: CGSize = CellSizeConstants.minContentSize,
        leftPadding: CGFloat = CellSizeConstants.leftPadding,
        screenWidth: CGFloat = CellSizeConstants.cellWidth
    ) {
        self.maxContentWidth = maxContentWidth
        self.contentPadding = contentPadding
        self.minContentSize = minContentSize
        self.leftPadding = leftPadding
        self.screenWidth = screenWidth
    }
    
    /// 计算背景的EdgeInsets
    /// - Parameter textSize: 文本的尺寸
    /// - Returns: 背景的EdgeInsets
    func background(innerSize: CGSize) -> UIEdgeInsets {
        let calculatedWidth = innerSize.width + contentPadding.left + contentPadding.right
        let width = max(calculatedWidth, minContentSize.width)
        let adjustedWidth = min(width, maxContentWidth)
        let left = leftPadding
        let right = screenWidth - left - adjustedWidth
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
    
    func message(innerSize: CGSize) -> UIEdgeInsets {
        let background = background(innerSize: innerSize)
        return background + contentPadding
    }
    
    /// 计算Cell的尺寸
    /// - Parameter textSize: 文本的尺寸
    /// - Returns: Cell的CGSize
    func cellSize(innerSize: CGSize) -> CGSize {
        let width = screenWidth
        let height = innerSize.height + contentPadding.top + contentPadding.bottom
        return CGSize(width: width, height: height)
    }
}

extension UIEdgeInsets {
    /// 实现两个 UIEdgeInsets 的减法运算
    /// - Parameter rhs: 要减去的 UIEdgeInsets
    /// - Returns: 新的 UIEdgeInsets
    static func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: lhs.top + rhs.top,
            left: lhs.left + rhs.left,
            bottom: lhs.bottom + rhs.bottom,
            right: lhs.right + rhs.right
        )
    }

}
