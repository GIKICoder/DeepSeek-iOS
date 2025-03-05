//
// ChatLayout
// ChatLayoutAttributes.swift
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

/// 自定义实现的 `UICollectionViewLayoutAttributes`
public final class ChatLayoutAttributes: UICollectionViewLayoutAttributes {
    /// 当前项目的对齐方式。可以在 `UICollectionViewCell.preferredLayoutAttributesFitting(...)` 中更改
    public var alignment: ChatItemAlignment = .fullWidth

    /// 项目之间的间距。可以在 `UICollectionViewCell.preferredLayoutAttributesFitting(...)` 中更改
    public var interItemSpacing: CGFloat = 0

    /// 使用 `ChatLayoutSettings` 设置的 `CollectionViewChatLayout` 的额外内边距。为了方便而添加。
    public internal(set) var additionalInsets: UIEdgeInsets = .zero

    /// `UICollectionView` 的框架大小。为了方便而添加。
    public internal(set) var viewSize: CGSize = .zero

    /// `UICollectionView` 调整后的内容内边距。为了方便而添加。
    public internal(set) var adjustedContentInsets: UIEdgeInsets = .zero

    /// `CollectionViewChatLayout` 的可见边界大小，排除 `adjustedContentInsets`。为了方便而添加。
    public internal(set) var visibleBoundsSize: CGSize = .zero

    /// `CollectionViewChatLayout` 的可见边界大小，排除 `adjustedContentInsets` 和 `additionalInsets`。为了方便而添加。
    public internal(set) var layoutFrame: CGRect = .zero

    #if DEBUG
    var id: UUID?
    #endif

    convenience init(kind: ItemKind, indexPath: IndexPath = IndexPath(item: 0, section: 0)) {
        switch kind {
        case .cell:
            self.init(forCellWith: indexPath)
        case .header:
            self.init(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
        case .footer:
            self.init(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: indexPath)
        }
    }

    /// 返回 `ChatLayoutAttributes` 的一个精确副本。
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ChatLayoutAttributes
        copy.viewSize = viewSize
        copy.alignment = alignment
        copy.interItemSpacing = interItemSpacing
        copy.layoutFrame = layoutFrame
        copy.additionalInsets = additionalInsets
        copy.visibleBoundsSize = visibleBoundsSize
        copy.adjustedContentInsets = adjustedContentInsets
        #if DEBUG
        copy.id = id
        #endif
        return copy
    }

    /// 返回一个布尔值，表示两个 `ChatLayoutAttributes` 是否被认为是相等的。
    public override func isEqual(_ object: Any?) -> Bool {
        super.isEqual(object)
            && alignment == (object as? ChatLayoutAttributes)?.alignment
            && interItemSpacing == (object as? ChatLayoutAttributes)?.interItemSpacing
    }

    /// 此属性对象表示的 `ItemKind`。
    public var kind: ItemKind {
        switch (representedElementCategory, representedElementKind) {
        case (.cell, nil):
            .cell
        case (.supplementaryView, .some(UICollectionView.elementKindSectionHeader)):
            .header
        case (.supplementaryView, .some(UICollectionView.elementKindSectionFooter)):
            .footer
        default:
            preconditionFailure("不支持的元素类型。")
        }
    }

    func typedCopy() -> ChatLayoutAttributes {
        guard let typedCopy = copy() as? ChatLayoutAttributes else {
            fatalError("内部不一致。")
        }
        return typedCopy
    }
}
