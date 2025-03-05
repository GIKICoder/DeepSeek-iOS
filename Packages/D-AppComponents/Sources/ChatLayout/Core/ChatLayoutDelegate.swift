//
// ChatLayout
// ChatLayoutDelegate.swift
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

/// 表示 `CollectionViewChatLayout` 询问布局属性修改的时间点。
public enum InitialAttributesRequestType: Hashable {
    /// `UICollectionView` 初次询问某个项目的布局。
    case initial

    /// 某个项目正在被无效化。
    case invalidation
}

/// `CollectionViewChatLayout` 的委托
public protocol ChatLayoutDelegate: AnyObject {
    /// `CollectionViewChatLayout` 将调用此方法以询问是否应该在当前布局中呈现头部。
    /// - 参数:
    ///   - chatLayout: `CollectionViewChatLayout` 的引用。
    ///   - sectionIndex: 部分的索引。
    /// - 返回: `Bool`。
    func shouldPresentHeader(_ chatLayout: CollectionViewChatLayout,
                             at sectionIndex: Int) -> Bool

    /// `CollectionViewChatLayout` 将调用此方法以询问是否应该在当前布局中呈现尾部。
    /// - 参数:
    ///   - chatLayout: `CollectionViewChatLayout` 的引用。
    ///   - sectionIndex: 部分的索引。
    /// - 返回: `Bool`。
    func shouldPresentFooter(_ chatLayout: CollectionViewChatLayout,
                             at sectionIndex: Int) -> Bool

    /// `CollectionViewChatLayout` 将调用此方法以询问项目应该具有的大小。
    ///
    /// **注意:**
    ///
    /// 如果你试图通过在此方法中返回精确的项目大小来加速布局过程 -
    /// 不要忘记更改 `UICollectionReusableView.preferredLayoutAttributesFitting(...)` 方法，并且不要
    /// 在那里调用 `super.preferredLayoutAttributesFitting(...)`，因为无论如何它都会使用自动布局引擎测量 `UIView`。
    ///
    /// - 参数:
    ///   - chatLayout: `CollectionViewChatLayout` 的引用。
    ///   - kind: 由 `ItemKind` 表示的元素类型。
    ///   - indexPath: 项目的索引路径。
    /// - 返回: `ItemSize`。
    func sizeForItem(_ chatLayout: CollectionViewChatLayout,
                     of kind: ItemKind,
                     at indexPath: IndexPath) -> ItemSize

    /// `CollectionViewChatLayout` 将调用此方法以询问项目应该具有的对齐类型。
    /// - 参数:
    ///   - chatLayout: `CollectionViewChatLayout` 的引用。
    ///   - kind: 由 `ItemKind` 表示的元素类型。
    ///   - indexPath: 项目的索引路径。
    /// - 返回: `ChatItemAlignment`。
    func alignmentForItem(_ chatLayout: CollectionViewChatLayout,
                          of kind: ItemKind,
                          at indexPath: IndexPath) -> ChatItemAlignment

    /// 询问委托修改布局属性实例，以便它表示正在插入项目的初始视觉状态。
    ///
    /// `originalAttributes` 实例是一个引用类型，因此可以直接修改。
    ///
    /// - 参数:
    ///   - chatLayout: `CollectionViewChatLayout` 的引用。
    ///   - kind: 由 `ItemKind` 表示的元素类型。
    ///   - indexPath: 项目的索引路径。
    ///   - originalAttributes: `CollectionViewChatLayout` 将使用的 `ChatLayoutAttributes`。
    ///   - state: `InitialAttributesRequestType` 实例。表示此方法何时被调用。
    func initialLayoutAttributesForInsertedItem(_ chatLayout: CollectionViewChatLayout,
                                                of kind: ItemKind,
                                                at indexPath: IndexPath,
                                                modifying originalAttributes: ChatLayoutAttributes,
                                                on state: InitialAttributesRequestType)

    /// 询问委托修改布局属性实例，以便它表示通过 `UICollectionView.deleteSections(_:)` 删除项目的最终视觉状态。
    ///
    /// `originalAttributes` 实例是一个引用类型，因此可以直接修改。
    ///
    /// - 参数:
    ///   - chatLayout: `CollectionViewChatLayout` 的引用。
    ///   - kind: 由 `ItemKind` 表示的元素类型。
    ///   - indexPath: 项目的索引路径。
    ///   - originalAttributes: `CollectionViewChatLayout` 将使用的 `ChatLayoutAttributes`。
    func finalLayoutAttributesForDeletedItem(_ chatLayout: CollectionViewChatLayout,
                                             of kind: ItemKind,
                                             at indexPath: IndexPath,
                                             modifying originalAttributes: ChatLayoutAttributes)

    /// 返回项目之间的间隔。如果返回 `nil` - 将使用 `ChatLayoutSettings` 中的值。
    ///
    /// - 参数:
    ///   - chatLayout: `CollectionViewChatLayout` 的引用。
    ///   - kind: 由 `ItemKind` 表示的元素类型。
    ///   - indexPath: 项目的索引路径。
    func interItemSpacing(_ chatLayout: CollectionViewChatLayout,
                          of kind: ItemKind,
                          after indexPath: IndexPath) -> CGFloat?

    /// 返回部分之间的间隔。如果返回 `nil` - 将使用 `ChatLayoutSettings` 中的值。
    ///
    /// - 参数:
    ///   - chatLayout: `CollectionViewChatLayout` 的引用。
    ///   - kind: 由 `ItemKind` 表示的元素类型。
    ///   - sectionIndex: 部分的索引。
    func interSectionSpacing(_ chatLayout: CollectionViewChatLayout,
                             after sectionIndex: Int) -> CGFloat?
}

/// 默认扩展。
public extension ChatLayoutDelegate {
    /// 默认实现返回: `false`。
    func shouldPresentHeader(_ chatLayout: CollectionViewChatLayout,
                             at sectionIndex: Int) -> Bool {
        false
    }

    /// 默认实现返回: `false`。
    func shouldPresentFooter(_ chatLayout: CollectionViewChatLayout,
                             at sectionIndex: Int) -> Bool {
        false
    }

    /// 默认实现返回: `ItemSize.auto`。
    func sizeForItem(_ chatLayout: CollectionViewChatLayout,
                     of kind: ItemKind,
                     at indexPath: IndexPath) -> ItemSize {
        .auto
    }

    /// 默认实现返回: `ChatItemAlignment.fullWidth`。
    func alignmentForItem(_ chatLayout: CollectionViewChatLayout,
                          of kind: ItemKind,
                          at indexPath: IndexPath) -> ChatItemAlignment {
        .fullWidth
    }

    /// 默认实现将 `ChatLayoutAttributes.alpha` 设置为零。
    func initialLayoutAttributesForInsertedItem(_ chatLayout: CollectionViewChatLayout,
                                                of kind: ItemKind,
                                                at indexPath: IndexPath,
                                                modifying originalAttributes: ChatLayoutAttributes,
                                                on state: InitialAttributesRequestType) {
        originalAttributes.alpha = 0
    }

    /// 默认实现将 `ChatLayoutAttributes.alpha` 设置为零。
    func finalLayoutAttributesForDeletedItem(_ chatLayout: CollectionViewChatLayout,
                                             of kind: ItemKind,
                                             at indexPath: IndexPath,
                                             modifying originalAttributes: ChatLayoutAttributes) {
        originalAttributes.alpha = 0
    }

    /// 默认实现返回: `nil`。
    func interItemSpacing(_ chatLayout: CollectionViewChatLayout,
                          of kind: ItemKind,
                          after indexPath: IndexPath) -> CGFloat? {
        nil
    }

    /// 默认实现返回: `nil`。
    func interSectionSpacing(_ chatLayout: CollectionViewChatLayout,
                             after sectionIndex: Int) -> CGFloat? {
        nil
    }
}
