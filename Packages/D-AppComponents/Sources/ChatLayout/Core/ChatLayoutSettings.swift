//
// ChatLayout
// ChatLayoutSettings.swift
// https://github.com/ekazaev/ChatLayout
//
// Created by Eugene Kazaev in 2020-2024.
// Distributed under the MIT license.
//
// Become a sponsor:
// https://github.com/sponsors/ekazaev
//

import Foundation
import UIKit

/// `CollectionViewChatLayout` 的设置。
public struct ChatLayoutSettings: Equatable {
    /// `CollectionViewChatLayout` 的预计项目大小。此值将用作项目的初始大小，最终大小将使用
    /// `UICollectionViewCell.preferredLayoutAttributesFitting(...)` 计算。
    public var estimatedItemSize: CGSize?

    /// 部分内项目之间的间距。
    public var interItemSpacing: CGFloat = 0

    /// 部分之间的间距。
    public var interSectionSpacing: CGFloat = 0

    /// `CollectionViewChatLayout` 内容的额外内边距。
    public var additionalInsets: UIEdgeInsets = .zero
}

