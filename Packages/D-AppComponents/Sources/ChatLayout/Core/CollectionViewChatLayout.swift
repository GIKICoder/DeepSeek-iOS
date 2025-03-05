//
// ChatLayout
// CollectionViewChatLayout.swift
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

/// 一个集合视图布局，设计用于以类似 `UITableView` 的网格显示项目，同时将它们对齐到 `UICollectionView` 的前端或后端。
/// 通过保持从底部的内容偏移量不变，此布局促进了类似聊天的行为。此外，它能够处理自动调整大小的单元格和补充视图。
///
/// ### 自定义属性:
/// `CollectionViewChatLayout.delegate`
///
/// `CollectionViewChatLayout.settings`
///
/// `CollectionViewChatLayout.keepContentOffsetAtBottomOnBatchUpdates`
///
/// `CollectionViewChatLayout.processOnlyVisibleItemsOnAnimatedBatchUpdates`
///
/// `CollectionViewChatLayout.visibleBounds`
///
/// `CollectionViewChatLayout.layoutFrame`
///
/// ### 自定义方法:
/// `CollectionViewChatLayout.getContentOffsetSnapshot(...)`
///
/// `CollectionViewChatLayout.restoreContentOffset(...)`
open class CollectionViewChatLayout: UICollectionViewLayout {
    // MARK: 自定义属性

    /// `CollectionViewChatLayout` 委托。
    open weak var delegate: ChatLayoutDelegate?

    /// `CollectionViewChatLayout` 的附加设置。
    public var settings = ChatLayoutSettings() {
        didSet {
            guard collectionView != nil,
                  settings != oldValue else {
                return
            }
            invalidateLayout()
        }
    }

    /// 默认的 `UIScrollView` 行为是保持内容偏移量从顶部边缘不变。如果此标记设置为 `true`，`CollectionViewChatLayout` 应尝试补偿批量更新更改，以保持当前内容在 `UICollectionView` 可见部分的底部。
    ///
    /// **注意：**
    /// 请记住，如果在批量内容插入时也发生变化（例如键盘框架变化），`CollectionViewChatLayout` 通常会在动画开始后获取该信息，并且无法补偿该变化。这应该手动完成。
    public var keepContentOffsetAtBottomOnBatchUpdates: Bool = false

    /// UICollectionView 的默认行为是在内容大小小于可见区域时保持 UICollectionViewCells 在可见矩形的顶部。通过将相应的标志设置为 true，可以逆转此行为以实现类似 Telegram 的结果。
    public var keepContentAtBottomOfVisibleArea: Bool = false

    /// 有时 `UIScrollView` 在动画期间如果有太多修正它的 `contentOffset` 会表现得很奇怪。特别是当 `UIScrollView` 的内容大小先变小，然后在新出现的单元格大小被计算后再次扩展。因此 `CollectionViewChatLayout` 尝试只处理当前屏幕上可见的元素。但这通常是不需要的。此标志允许您对这种行为进行精细控制。
    /// 默认为 `true` 以保持与库的旧版本兼容。
    ///
    /// **注意：**
    /// 此标志仅用于提供对批量更新的精细控制。如果有疑问 - 使其保持 `true`。
    public var processOnlyVisibleItemsOnAnimatedBatchUpdates: Bool = true

    /// 一种在自动布局更改后启用自动调整大小无效的模式。建议在多个更改同时以动画方式发生时继续使用重新加载/重新配置方法。这种方法确保 `CollectionViewChatLayout` 能够处理这些变化，同时准确地保持内容偏移。考虑在没有更好替代方案时使用它。
    ///
    /// **注意：**
    /// 这是一个实验性标志。
    @available(iOS 16.0, *)
    public var supportSelfSizingInvalidation: Bool {
        get {
            _supportSelfSizingInvalidation
        }
        set {
            _supportSelfSizingInvalidation = newValue
        }
    }

    /// 表示当前可见的矩形。
    open var visibleBounds: CGRect {
        guard let collectionView else {
            return .zero
        }
        return CGRect(x: adjustedContentInset.left,
                      y: collectionView.contentOffset.y + adjustedContentInset.top,
                      width: collectionView.bounds.width - adjustedContentInset.left - adjustedContentInset.right,
                      height: collectionView.bounds.height - adjustedContentInset.top - adjustedContentInset.bottom)
    }

    /// 表示所有项目对齐的矩形。
    open var layoutFrame: CGRect {
        guard let collectionView else {
            return .zero
        }
        let additionalInsets = settings.additionalInsets
        return CGRect(x: adjustedContentInset.left + additionalInsets.left,
                      y: adjustedContentInset.top + additionalInsets.top,
                      width: collectionView.bounds.width - additionalInsets.left - additionalInsets.right - adjustedContentInset.left - adjustedContentInset.right,
                      height: controller.contentHeight(at: state) - additionalInsets.top - additionalInsets.bottom - adjustedContentInset.top - adjustedContentInset.bottom)
    }

    // MARK: 继承的属性

    /// 设计 `CollectionViewChatLayout` 布局时使用的语言方向。
    open override var developmentLayoutDirection: UIUserInterfaceLayoutDirection {
        .leftToRight
    }

    /// 一个布尔值，指示是否在适当的时候自动翻转水平坐标系统。
    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        _flipsHorizontallyInOppositeLayoutDirection
    }

    /// 自定义 layoutAttributesClass 是 `ChatLayoutAttributes`。
    public override class var layoutAttributesClass: AnyClass {
        ChatLayoutAttributes.self
    }

    /// 自定义 invalidationContextClass 是 `ChatLayoutInvalidationContext`。
    public override class var invalidationContextClass: AnyClass {
        ChatLayoutInvalidationContext.self
    }

    /// 集合视图内容的宽度和高度。
    open override var collectionViewContentSize: CGSize {
        let contentSize: CGSize
        if state == .beforeUpdate {
            contentSize = controller.contentSize(for: .beforeUpdate)
        } else {
            contentSize = controller.contentSize(for: .afterUpdate)
        }
        return contentSize
    }

    /// 在 iOS 15.1 中存在一个问题，当用户滚动时，UICollectionView 忽略建议的内容偏移。此标记启用一个黑客来稍后补偿此偏移量。您可以在必要时禁用它。
    /// Bug 报告：https://feedbackassistant.apple.com/feedback/9727104
    ///
    /// PS：此问题在 15.2 中已修复
    public var enableIOS15_1Fix: Bool = true

    // MARK: 内部属性

    var adjustedContentInset: UIEdgeInsets {
        guard let collectionView else {
            return .zero
        }
        return collectionView.adjustedContentInset
    }

    var viewSize: CGSize {
        guard let collectionView else {
            return .zero
        }
        return collectionView.frame.size
    }

    // MARK: 私有属性

    private struct PrepareActions: OptionSet {
        let rawValue: UInt

        static let recreateSectionModels = PrepareActions(rawValue: 1 << 0)
        static let updateLayoutMetrics = PrepareActions(rawValue: 1 << 1)
        static let cachePreviousWidth = PrepareActions(rawValue: 1 << 2)
        static let cachePreviousContentInsets = PrepareActions(rawValue: 1 << 3)
        static let switchStates = PrepareActions(rawValue: 1 << 4)
    }

    private struct InvalidationActions: OptionSet {
        let rawValue: UInt

        static let shouldInvalidateOnBoundsChange = InvalidationActions(rawValue: 1 << 0)
    }

    private lazy var controller = StateController(layoutRepresentation: self)

    private var state: ModelState = .beforeUpdate

    private var prepareActions: PrepareActions = []

    private var invalidationActions: InvalidationActions = []

    private var cachedCollectionViewSize: CGSize?

    private var cachedCollectionViewInset: UIEdgeInsets?

    // 这些属性用于保持在插入/删除动画期间使用的布局属性副本在项目自我调整大小时保持最新。如果我们不保持这些副本的更新，则动画将从估计的高度开始。
    private var attributesForPendingAnimations = [ItemKind: [ItemPath: ChatLayoutAttributes]]()

    private var invalidatedAttributes = [ItemKind: Set<ItemPath>]()

    private var dontReturnAttributes: Bool = true

    private var currentPositionSnapshot: ChatLayoutPositionSnapshot?

    private let _flipsHorizontallyInOppositeLayoutDirection: Bool

    private var reconfigureItemsIndexPaths: [IndexPath] = []

    private var _supportSelfSizingInvalidation: Bool = false

    // MARK: iOS 15.1 修复标志

    private var needsIOS15_1IssueFix: Bool {
        guard enableIOS15_1Fix else {
            return false
        }
        guard #unavailable(iOS 15.2) else {
            return false
        }
        guard #available(iOS 15.1, *) else {
            return false
        }
        return isUserInitiatedScrolling && !controller.isAnimatedBoundsChange
    }

    // MARK: 构造函数

    /// 默认构造函数。
    /// - 参数:
    ///   - flipsHorizontallyInOppositeLayoutDirection: 指示是否在适当的时候自动翻转水平坐标系统。在实践中，这用于支持从右到左的布局。
    public init(flipsHorizontallyInOppositeLayoutDirection: Bool = true) {
        _flipsHorizontallyInOppositeLayoutDirection = flipsHorizontallyInOppositeLayoutDirection
        super.init()
        resetAttributesForPendingAnimations()
        resetInvalidatedAttributes()
    }

    /// 从给定的解压器中返回一个初始化的对象。
    public required init?(coder aDecoder: NSCoder) {
        _flipsHorizontallyInOppositeLayoutDirection = true
        super.init(coder: aDecoder)
        resetAttributesForPendingAnimations()
        resetInvalidatedAttributes()
    }

    // MARK: 自定义方法

    /// 获取最近提供边缘的项目的当前偏移量。
    /// - 参数 edge: `UICollectionView` 的边缘
    /// - 返回: `ChatLayoutPositionSnapshot`
    open func getContentOffsetSnapshot(from edge: ChatLayoutPositionSnapshot.Edge) -> ChatLayoutPositionSnapshot? {
        guard let collectionView else {
            return nil
        }
        let insets = UIEdgeInsets(top: -collectionView.frame.height,
                                  left: 0,
                                  bottom: -collectionView.frame.height,
                                  right: 0)
        let visibleBounds = visibleBounds
        let layoutAttributes = controller.layoutAttributesForElements(in: visibleBounds.inset(by: insets),
                                                                      state: state,
                                                                      ignoreCache: true)
            .sorted(by: { $0.frame.maxY < $1.frame.maxY })

        switch edge {
        case .top:
            guard let firstVisibleItemAttributes = layoutAttributes.first(where: { $0.frame.minY >= visibleBounds.higherPoint.y }) else {
                return nil
            }
            let visibleBoundsTopOffset = firstVisibleItemAttributes.frame.minY - visibleBounds.higherPoint.y - settings.additionalInsets.top
            return ChatLayoutPositionSnapshot(indexPath: firstVisibleItemAttributes.indexPath,
                                              kind: firstVisibleItemAttributes.kind,
                                              edge: .top,
                                              offset: visibleBoundsTopOffset)
        case .bottom:
            guard let lastVisibleItemAttributes = layoutAttributes.last(where: { $0.frame.minY <= visibleBounds.lowerPoint.y }) else {
                return nil
            }
            let visibleBoundsBottomOffset = visibleBounds.lowerPoint.y - lastVisibleItemAttributes.frame.maxY - settings.additionalInsets.bottom
            return ChatLayoutPositionSnapshot(indexPath: lastVisibleItemAttributes.indexPath,
                                              kind: lastVisibleItemAttributes.kind,
                                              edge: .bottom,
                                              offset: visibleBoundsBottomOffset)
        }
    }

    /// 无效化 `UICollectionView` 的布局，并尝试保持 `ChatLayoutPositionSnapshot` 中提供的项目的偏移量
    /// - 参数 snapshot: `ChatLayoutPositionSnapshot`
    open func restoreContentOffset(with snapshot: ChatLayoutPositionSnapshot) {
        guard let collectionView else {
            return
        }

        // 我们不希望在查找位置时返回属性，以便 `UICollectionView` 不会创建可能在找到实际位置时不使用的多余单元格。
        dontReturnAttributes = true
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        currentPositionSnapshot = snapshot
        let context = ChatLayoutInvalidationContext()
        context.invalidateLayoutMetrics = false
        invalidateLayout(with: context)

        dontReturnAttributes = false
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        currentPositionSnapshot = nil
    }

    /// 如果您想使用新的 `UICollectionView.reconfigureItems(..)` API 并期望重新配置也以动画方式发生
    /// - 您必须在 `UICollectionView` 方法旁边调用此方法。`UIKit` 以其经典方式使用私有 API 来处理它。
    ///
    /// 注意：重新配置项目未暴露给布局，它可能表现得很奇怪，如果您遇到类似的问题 - 转到 `UICollectionView.reloadItems(..)` 作为更安全的选择。
    open func reconfigureItems(at indexPaths: [IndexPath]) {
        reconfigureItemsIndexPaths = indexPaths
    }

    // MARK: 提供布局属性

    /// 告诉布局对象更新当前布局。
    open override func prepare() {
        super.prepare()

        guard let collectionView,
              !prepareActions.isEmpty else {
            return
        }

        if prepareActions.contains(.switchStates) {
            controller.commitUpdates()
            state = .beforeUpdate
            resetAttributesForPendingAnimations()
            resetInvalidatedAttributes()
        }

        if prepareActions.contains(.recreateSectionModels) {
            var sections: ContiguousArray<SectionModel<CollectionViewChatLayout>> = []
            for sectionIndex in 0..<collectionView.numberOfSections {
                // 头部
                let header: ItemModel?
                if delegate?.shouldPresentHeader(self, at: sectionIndex) == true {
                    let headerPath = IndexPath(item: 0, section: sectionIndex)
                    header = ItemModel(with: configuration(for: .header, at: headerPath))
                } else {
                    header = nil
                }

                // 项目
                var items: ContiguousArray<ItemModel> = []
                for itemIndex in 0..<collectionView.numberOfItems(inSection: sectionIndex) {
                    let itemPath = IndexPath(item: itemIndex, section: sectionIndex)
                    items.append(ItemModel(with: configuration(for: .cell, at: itemPath)))
                }

                // 尾部
                let footer: ItemModel?
                if delegate?.shouldPresentFooter(self, at: sectionIndex) == true {
                    let footerPath = IndexPath(item: 0, section: sectionIndex)
                    footer = ItemModel(with: configuration(for: .footer, at: footerPath))
                } else {
                    footer = nil
                }
                var section = SectionModel(interSectionSpacing: interSectionSpacing(at: sectionIndex),
                                           header: header,
                                           footer: footer,
                                           items: items,
                                           collectionLayout: self)
                section.assembleLayout()
                sections.append(section)
            }
            controller.set(sections, at: .beforeUpdate)
        }

        if prepareActions.contains(.updateLayoutMetrics),
           !prepareActions.contains(.recreateSectionModels) {
            var sections: ContiguousArray<SectionModel> = controller.layout(at: state).sections
            sections.withUnsafeMutableBufferPointer { directlyMutableSections in
                for sectionIndex in 0..<directlyMutableSections.count {
                    var section = directlyMutableSections[sectionIndex]

                    // 头部
                    if var header = section.header {
                        header.resetSize()
                        section.set(header: header)
                    }

                    // 项目
                    var items: ContiguousArray<ItemModel> = section.items
                    items.withUnsafeMutableBufferPointer { directlyMutableItems in
                        nonisolated(unsafe) let directlyMutableItems = directlyMutableItems
                        DispatchQueue.concurrentPerform(iterations: directlyMutableItems.count) { rowIndex in
                            directlyMutableItems[rowIndex].resetSize()
                        }
                    }
                    section.set(items: items)

                    // 尾部
                    if var footer = section.footer {
                        footer.resetSize()
                        section.set(footer: footer)
                    }

                    section.assembleLayout()
                    directlyMutableSections[sectionIndex] = section
                }
            }
            controller.set(sections, at: state)
        }

        if prepareActions.contains(.cachePreviousContentInsets) {
            cachedCollectionViewInset = adjustedContentInset
        }

        if prepareActions.contains(.cachePreviousWidth) {
            cachedCollectionViewSize = collectionView.bounds.size
        }

        prepareActions = []
    }

    /// 检索指定矩形中所有单元格和视图的布局属性。
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 这个早期返回防止在屏幕外批量更新发生后导致重叠/位置错误的元素。此问题的根本原因是，当通过插入/删除/重新加载/移动函数向集合视图发送更新时，`UICollectionView` 期望 `layoutAttributesForElementsInRect:` 立即返回批量更新后的布局属性。不幸的是，这是不可能的 - 当批量更新发生时，`invalidateLayout:` 立即被调用，带有一个 `invalidateDataSourceCounts` 设置为 `true` 的上下文。在这个时候，`CollectionViewChatLayout` 无法知道数据源计数变化的细节（插入/删除/移动发生的位置）。`CollectionViewChatLayout` 只有在 `prepareForCollectionViewUpdates:` 被调用时才会获得这些更新的详细信息。此时，我们可以更新布局的真实来源 `StateController`，这使我们能够解析批量更新后的布局，并从此函数返回批量更新后的布局属性。在 `invalidateLayout:` 被调用，`invalidateDataSourceCounts` 设置为 `true` 和 `prepareForCollectionViewUpdates:` 被调用之间，`layoutAttributesForElementsInRect:` 被调用，期望我们已经有一个完全解析的布局。如果我们在那个时候返回错误的布局属性，那么我们将会有重叠的元素/视觉缺陷。为了解决这个问题，我们可以返回 `nil`，这解决了这个 bug。`UICollectionViewCompositionalLayout`，以经典的 UIKit 方式，通过实现私有函数 `_prepareForCollectionViewUpdates:withDataSourceTranslator:` 来避免这个 bug/特性，该函数在 `layoutAttributesForElementsInRect:` 被调用之前为布局提供更新的详细信息，使他们能够及时解析他们的布局。
        guard !dontReturnAttributes else {
            return nil
        }

        let visibleAttributes = controller.layoutAttributesForElements(in: rect, state: state)
        return visibleAttributes
    }

    /// 检索与指定索引路径对应的单元格的布局信息。
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard !dontReturnAttributes else {
            return nil
        }
        let attributes = controller.itemAttributes(for: indexPath.itemPath, kind: .cell, at: state)

        return attributes
    }

    /// 检索指定补充视图的布局属性。
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                            at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard !dontReturnAttributes else {
            return nil
        }

        let kind = ItemKind(elementKind)
        let attributes = controller.itemAttributes(for: indexPath.itemPath, kind: kind, at: state)

        return attributes
    }

    // MARK: 协调动画变化

    /// 为视图边界的动画变化或项目的插入或删除准备布局对象。
    open override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        controller.isAnimatedBoundsChange = true
        controller.process(changeItems: [])
        state = .afterUpdate
        prepareActions.remove(.switchStates)
        guard let collectionView,
              oldBounds.width != collectionView.bounds.width,
              keepContentOffsetAtBottomOnBatchUpdates,
              controller.isLayoutBiggerThanVisibleBounds(at: state) else {
            return
        }
        let newBounds = collectionView.bounds
        let heightDifference = oldBounds.height - newBounds.height
        controller.proposedCompensatingOffset += heightDifference + (oldBounds.origin.y - newBounds.origin.y)
    }

    /// 在视图的边界发生任何动画变化或项目的插入或删除之后进行清理。
    open override func finalizeAnimatedBoundsChange() {
        if controller.isAnimatedBoundsChange {
            state = .beforeUpdate
            resetInvalidatedAttributes()
            resetAttributesForPendingAnimations()
            controller.commitUpdates()
            controller.isAnimatedBoundsChange = false
            controller.proposedCompensatingOffset = 0
            controller.batchUpdateCompensatingOffset = 0
        }
    }

    // MARK: 上下文无效化

    /// 询问布局对象，是否对自我调整大小的单元格的更改需要布局更新。
    open override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
                                              withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        let preferredAttributesItemPath = preferredAttributes.indexPath.itemPath
        guard let preferredMessageAttributes = preferredAttributes as? ChatLayoutAttributes,
              let item = controller.item(for: preferredAttributesItemPath, kind: preferredMessageAttributes.kind, at: state) else {
            return true
        }

        let shouldInvalidateLayout = item.calculatedSize == nil
            || (_supportSelfSizingInvalidation ? (item.size.height - preferredMessageAttributes.size.height).rounded() != 0 : false)
            || item.alignment != preferredMessageAttributes.alignment
            || item.interItemSpacing != preferredMessageAttributes.interItemSpacing

        return shouldInvalidateLayout
    }

    /// 检索一个上下文对象，该对象标识由于动态单元格更改而应更改的布局部分。
    open override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
                                           withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        guard let preferredMessageAttributes = preferredAttributes as? ChatLayoutAttributes,
              // 在 iOS <16 中模型更新后可能会被调用。检查此索引路径的模型是否存在。
              controller.item(for: preferredMessageAttributes.indexPath.itemPath, kind: .cell, at: state) != nil else {
            return super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        }

        let preferredAttributesItemPath = preferredMessageAttributes.indexPath.itemPath

        if state == .afterUpdate {
            invalidatedAttributes[preferredMessageAttributes.kind]?.insert(preferredAttributesItemPath)
        }

        let layoutAttributesForPendingAnimation = attributesForPendingAnimations[preferredMessageAttributes.kind]?[preferredAttributesItemPath]

        let newItemSize = itemSize(with: preferredMessageAttributes)
        let newItemAlignment = alignment(for: preferredMessageAttributes.kind, at: preferredMessageAttributes.indexPath)
        let newInterItemSpacing = interItemSpacing(for: preferredMessageAttributes.kind, at: preferredMessageAttributes.indexPath)
        controller.update(preferredSize: newItemSize,
                          alignment: newItemAlignment,
                          interItemSpacing: newInterItemSpacing,
                          for: preferredAttributesItemPath,
                          kind: preferredMessageAttributes.kind,
                          at: state)

        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredMessageAttributes, withOriginalAttributes: originalAttributes) as! ChatLayoutInvalidationContext

        let heightDifference = newItemSize.height - originalAttributes.size.height
        let isAboveBottomEdge = originalAttributes.frame.minY.rounded() <= visibleBounds.maxY.rounded()

        if heightDifference != 0,
           (keepContentOffsetAtBottomOnBatchUpdates && controller.contentHeight(at: state).rounded() + heightDifference > visibleBounds.height.rounded()) || isUserInitiatedScrolling,
           isAboveBottomEdge {
            let offsetCompensation: CGFloat = min(controller.contentHeight(at: state) - collectionView!.frame.height + adjustedContentInset.bottom + adjustedContentInset.top, heightDifference)
            context.contentOffsetAdjustment.y += offsetCompensation
            invalidationActions.formUnion([.shouldInvalidateOnBoundsChange])
        }

        if let attributes = controller.itemAttributes(for: preferredAttributesItemPath, kind: preferredMessageAttributes.kind, at: state)?.typedCopy() {
            layoutAttributesForPendingAnimation?.frame = attributes.frame
            if state == .afterUpdate {
                controller.totalProposedCompensatingOffset += heightDifference
                controller.offsetByTotalCompensation(attributes: layoutAttributesForPendingAnimation, for: state, backward: true)
                if controller.insertedIndexes.contains(preferredMessageAttributes.indexPath) ||
                    controller.insertedSectionsIndexes.contains(preferredMessageAttributes.indexPath.section) {
                    layoutAttributesForPendingAnimation.map { attributes in
                        guard let delegate else {
                            attributes.alpha = 0
                            return
                        }
                        delegate.initialLayoutAttributesForInsertedItem(self, of: .cell, at: attributes.indexPath, modifying: attributes, on: .invalidation)
                    }
                }
            }
        } else {
            layoutAttributesForPendingAnimation?.frame.size = newItemSize
        }

        if #available(iOS 13.0, *) {
            switch preferredMessageAttributes.kind {
            case .cell:
                context.invalidateItems(at: [preferredMessageAttributes.indexPath])
            case .footer,
                 .header:
                context.invalidateSupplementaryElements(ofKind: preferredMessageAttributes.kind.supplementaryElementStringType, at: [preferredMessageAttributes.indexPath])
            }
        }

        context.invalidateLayoutMetrics = false

        return context
    }

    /// 询问布局对象新边界是否需要布局更新。
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let shouldInvalidateLayout = cachedCollectionViewSize != .some(newBounds.size) ||
            cachedCollectionViewInset != .some(adjustedContentInset) ||
            invalidationActions.contains(.shouldInvalidateOnBoundsChange)
            || (isUserInitiatedScrolling && state == .beforeUpdate)

        invalidationActions.remove(.shouldInvalidateOnBoundsChange)
        return shouldInvalidateLayout
    }

    /// 检索一个上下文对象，该对象定义在边界更改发生时应更改的布局部分。
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let invalidationContext = super.invalidationContext(forBoundsChange: newBounds) as! ChatLayoutInvalidationContext
        invalidationContext.invalidateLayoutMetrics = false
        return invalidationContext
    }

    /// 使用提供的上下文对象无效化当前布局。
    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        guard let collectionView else {
            super.invalidateLayout(with: context)
            return
        }

        guard let context = context as? ChatLayoutInvalidationContext else {
            assertionFailure("`context` 必须是 `ChatLayoutInvalidationContext` 的实例。")
            return
        }

        controller.resetCachedAttributes()

        dontReturnAttributes = context.invalidateDataSourceCounts && !context.invalidateEverything

        if context.invalidateEverything {
            prepareActions.formUnion([.recreateSectionModels])
        }

        // 检查 `cachedCollectionViewWidth != collectionView.bounds.size.width` 是必要的，因为集合视图的宽度可以在没有 `contentSizeAdjustment` 发生的情况下变化。
        if context.contentSizeAdjustment.width != 0 || cachedCollectionViewSize != collectionView.bounds.size {
            prepareActions.formUnion([.cachePreviousWidth])
        }

        if cachedCollectionViewInset != adjustedContentInset {
            prepareActions.formUnion([.cachePreviousContentInsets])
        }

        if context.invalidateLayoutMetrics, !context.invalidateDataSourceCounts {
            prepareActions.formUnion([.updateLayoutMetrics])
        }

        if let currentPositionSnapshot {
            let contentHeight = controller.contentHeight(at: state)
            if let frame = controller.itemFrame(for: currentPositionSnapshot.indexPath.itemPath, kind: currentPositionSnapshot.kind, at: state, isFinal: true),
               contentHeight != 0,
               contentHeight > visibleBounds.size.height {
                let adjustedContentInset: UIEdgeInsets = collectionView.adjustedContentInset
                let maxAllowed = max(-adjustedContentInset.top, contentHeight - collectionView.frame.height + adjustedContentInset.bottom)
                switch currentPositionSnapshot.edge {
                case .top:
                    let desiredOffset = max(min(maxAllowed, frame.minY - currentPositionSnapshot.offset - adjustedContentInset.top - settings.additionalInsets.top), -adjustedContentInset.top)
                    context.contentOffsetAdjustment.y = desiredOffset - collectionView.contentOffset.y
                case .bottom:
                    let desiredOffset = max(min(maxAllowed, frame.maxY + currentPositionSnapshot.offset - collectionView.bounds.height + adjustedContentInset.bottom + settings.additionalInsets.bottom), -adjustedContentInset.top)
                    context.contentOffsetAdjustment.y = desiredOffset - collectionView.contentOffset.y
                }
            }
        }
        super.invalidateLayout(with: context)
    }

    /// 无效化当前布局并触发布局更新。
    open override func invalidateLayout() {
        super.invalidateLayout()
    }

    /// 检索在动画布局更新或更改后要使用的内容偏移。
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if controller.proposedCompensatingOffset != 0,
           let collectionView {
            let minPossibleContentOffset = -collectionView.adjustedContentInset.top
            let newProposedContentOffset = CGPoint(x: proposedContentOffset.x, y: max(minPossibleContentOffset, min(collectionView.contentOffset.y + controller.proposedCompensatingOffset, maxPossibleContentOffset.y)))
            invalidationActions.formUnion([.shouldInvalidateOnBoundsChange])
            if needsIOS15_1IssueFix {
                controller.proposedCompensatingOffset = 0
                collectionView.contentOffset = newProposedContentOffset
                return newProposedContentOffset
            } else {
                controller.proposedCompensatingOffset = 0
                return newProposedContentOffset
            }
        }
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }

    // MARK: 响应集合视图更新

    /// 通知布局对象集合视图的内容即将更改。
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        var changeItems = updateItems.compactMap { ChangeItem(with: $0) }
        changeItems.append(contentsOf: reconfigureItemsIndexPaths.map { .itemReconfigure(itemIndexPath: $0) })
        controller.process(changeItems: changeItems)
        state = .afterUpdate
        dontReturnAttributes = false

        if !reconfigureItemsIndexPaths.isEmpty,
           let collectionView {
            reconfigureItemsIndexPaths
                .filter { collectionView.indexPathsForVisibleItems.contains($0) && !controller.reloadedIndexes.contains($0) }
                .forEach { indexPath in
                    let cell = collectionView.cellForItem(at: indexPath)

                    if let originalAttributes = controller.itemAttributes(for: indexPath.itemPath, kind: .cell, at: .beforeUpdate),
                       let preferredAttributes = cell?.preferredLayoutAttributesFitting(originalAttributes.typedCopy()) as? ChatLayoutAttributes,
                       let itemIdentifierBeforeUpdate = controller.itemIdentifier(for: indexPath.itemPath, kind: .cell, at: .beforeUpdate),
                       let indexPathAfterUpdate = controller.itemPath(by: itemIdentifierBeforeUpdate, kind: .cell, at: .afterUpdate)?.indexPath,
                       let itemAfterUpdate = controller.item(for: indexPathAfterUpdate.itemPath, kind: .cell, at: .afterUpdate),
                       (itemAfterUpdate.size.height - preferredAttributes.size.height).rounded() != 0 {
                        originalAttributes.indexPath = indexPathAfterUpdate
                        preferredAttributes.indexPath = indexPathAfterUpdate
                        _ = invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
                    }
                }
            reconfigureItemsIndexPaths = []
        }

        super.prepare(forCollectionViewUpdates: updateItems)
    }

    /// 在集合视图更新期间执行任何额外的动画或清理。
    open override func finalizeCollectionViewUpdates() {
        controller.proposedCompensatingOffset = 0

        if keepContentOffsetAtBottomOnBatchUpdates,
           controller.isLayoutBiggerThanVisibleBounds(at: state),
           controller.batchUpdateCompensatingOffset != 0,
           let collectionView {
            let compensatingOffset: CGFloat
            if controller.contentSize(for: .beforeUpdate).height > visibleBounds.size.height {
                compensatingOffset = controller.batchUpdateCompensatingOffset
            } else {
                compensatingOffset = maxPossibleContentOffset.y - collectionView.contentOffset.y
            }
            controller.batchUpdateCompensatingOffset = 0
            let context = ChatLayoutInvalidationContext()
            context.contentOffsetAdjustment.y = compensatingOffset
            invalidateLayout(with: context)
        } else {
            controller.batchUpdateCompensatingOffset = 0
            let context = ChatLayoutInvalidationContext()
            invalidateLayout(with: context)
        }

        prepareActions.formUnion(.switchStates)
        super.finalizeCollectionViewUpdates()
    }

    // MARK: - 单元格外观动画

    /// 检索要插入集合视图的项目的起始布局信息。
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: ChatLayoutAttributes?

        let itemPath = itemIndexPath.itemPath
        if state == .afterUpdate {
            if controller.insertedIndexes.contains(itemIndexPath) || controller.insertedSectionsIndexes.contains(itemPath.section) {
                attributes = controller.itemAttributes(for: itemPath, kind: .cell, at: .afterUpdate)?.typedCopy()
                controller.offsetByTotalCompensation(attributes: attributes, for: state, backward: true)
                attributes.map { attributes in
                    guard let delegate else {
                        attributes.alpha = 0
                        return
                    }
                    delegate.initialLayoutAttributesForInsertedItem(self, of: .cell, at: itemIndexPath, modifying: attributes, on: .initial)
                }
                attributesForPendingAnimations[.cell]?[itemPath] = attributes
            } else if let itemIdentifier = controller.itemIdentifier(for: itemPath, kind: .cell, at: .afterUpdate),
                      let initialIndexPath = controller.itemPath(by: itemIdentifier, kind: .cell, at: .beforeUpdate) {
                attributes = controller.itemAttributes(for: initialIndexPath, kind: .cell, at: .beforeUpdate)?.typedCopy() ?? ChatLayoutAttributes(forCellWith: itemIndexPath)
                attributes?.indexPath = itemIndexPath
                if #unavailable(iOS 13.0) {
                    if controller.reloadedIndexes.contains(itemIndexPath) || controller.reconfiguredIndexes.contains(itemIndexPath) || controller.reloadedSectionsIndexes.contains(itemPath.section) {
                        // 在 ios 12 上需要将新单元格定位在旧单元格的中间
                        attributesForPendingAnimations[.cell]?[itemPath] = attributes
                    }
                }
            } else {
                attributes = controller.itemAttributes(for: itemPath, kind: .cell, at: .beforeUpdate)
            }
        } else {
            attributes = controller.itemAttributes(for: itemPath, kind: .cell, at: .beforeUpdate)
        }

        return attributes
    }

    /// 检索即将从集合视图中移除的项目的最终布局信息。
    open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: ChatLayoutAttributes?

        let itemPath = itemIndexPath.itemPath
        if state == .afterUpdate {
            if controller.deletedIndexes.contains(itemIndexPath) || controller.deletedSectionsIndexes.contains(itemPath.section) {
                attributes = controller.itemAttributes(for: itemPath, kind: .cell, at: .beforeUpdate)?.typedCopy() ?? ChatLayoutAttributes(forCellWith: itemIndexPath)
                controller.offsetByTotalCompensation(attributes: attributes, for: state, backward: false)
                if keepContentOffsetAtBottomOnBatchUpdates,
                   controller.isLayoutBiggerThanVisibleBounds(at: state),
                   let attributes {
                    attributes.frame = attributes.frame.offsetBy(dx: 0, dy: attributes.frame.height * 0.2)
                }
                attributes.map { attributes in
                    guard let delegate else {
                        attributes.alpha = 0
                        return
                    }
                    delegate.finalLayoutAttributesForDeletedItem(self, of: .cell, at: itemIndexPath, modifying: attributes)
                }
            } else if let itemIdentifier = controller.itemIdentifier(for: itemPath, kind: .cell, at: .beforeUpdate),
                      let finalIndexPath = controller.itemPath(by: itemIdentifier, kind: .cell, at: .afterUpdate) {
                if controller.movedIndexes.contains(itemIndexPath) || controller.movedSectionsIndexes.contains(itemPath.section) ||
                    controller.reloadedIndexes.contains(itemIndexPath) || controller.reconfiguredIndexes.contains(itemIndexPath) || controller.reloadedSectionsIndexes.contains(itemPath.section) {
                    attributes = controller.itemAttributes(for: finalIndexPath, kind: .cell, at: .afterUpdate)?.typedCopy()
                } else {
                    attributes = controller.itemAttributes(for: itemPath, kind: .cell, at: .beforeUpdate)?.typedCopy()
                }
                if invalidatedAttributes[.cell]?.contains(itemPath) ?? false {
                    attributes = nil
                }

                attributes?.indexPath = itemIndexPath
                attributesForPendingAnimations[.cell]?[itemPath] = attributes
                if controller.reloadedIndexes.contains(itemIndexPath) || controller.reloadedSectionsIndexes.contains(itemPath.section) {
                    attributes?.alpha = 0
                    attributes?.transform = CGAffineTransform(scaleX: 0, y: 0)
                }
            } else {
                attributes = controller.itemAttributes(for: itemPath, kind: .cell, at: .beforeUpdate)
            }
        } else {
            attributes = controller.itemAttributes(for: itemPath, kind: .cell, at: .beforeUpdate)
        }

        return attributes
    }

    // MARK: - 补充视图外观动画

    /// 检索要插入集合视图的补充视图的起始布局信息。
    open override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String,
                                                                               at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: ChatLayoutAttributes?

        let kind = ItemKind(elementKind)
        let elementPath = elementIndexPath.itemPath
        if state == .afterUpdate {
            if controller.insertedSectionsIndexes.contains(elementPath.section) {
                attributes = controller.itemAttributes(for: elementPath, kind: kind, at: .afterUpdate)?.typedCopy()
                controller.offsetByTotalCompensation(attributes: attributes, for: state, backward: true)
                attributes.map { attributes in
                    guard let delegate else {
                        attributes.alpha = 0
                        return
                    }
                    delegate.initialLayoutAttributesForInsertedItem(self, of: kind, at: elementIndexPath, modifying: attributes, on: .initial)
                }
                attributesForPendingAnimations[kind]?[elementPath] = attributes
            } else if let itemIdentifier = controller.itemIdentifier(for: elementPath, kind: kind, at: .afterUpdate),
                      let initialIndexPath = controller.itemPath(by: itemIdentifier, kind: kind, at: .beforeUpdate) {
                attributes = controller.itemAttributes(for: initialIndexPath, kind: kind, at: .beforeUpdate)?.typedCopy() ?? ChatLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: elementIndexPath)
                attributes?.indexPath = elementIndexPath

                if #unavailable(iOS 13.0) {
                    if controller.reloadedSectionsIndexes.contains(elementPath.section) {
                        // 在 ios 12 上需要将新单元格定位在旧单元格的中间
                        attributesForPendingAnimations[kind]?[elementPath] = attributes
                    }
                }
            } else {
                attributes = controller.itemAttributes(for: elementPath, kind: kind, at: .beforeUpdate)
            }
        } else {
            attributes = controller.itemAttributes(for: elementPath, kind: kind, at: .beforeUpdate)
        }

        return attributes
    }

    /// 检索即将从集合视图中移除的补充视图的最终布局信息。
    open override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String,
                                                                                at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attributes: ChatLayoutAttributes?

        let kind = ItemKind(elementKind)
        let elementPath = elementIndexPath.itemPath
        if state == .afterUpdate {
            if controller.deletedSectionsIndexes.contains(elementPath.section) {
                attributes = controller.itemAttributes(for: elementPath, kind: kind, at: .beforeUpdate)?.typedCopy() ?? ChatLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: elementIndexPath)
                controller.offsetByTotalCompensation(attributes: attributes, for: state, backward: false)
                if keepContentOffsetAtBottomOnBatchUpdates,
                   controller.isLayoutBiggerThanVisibleBounds(at: state),
                   let attributes {
                    attributes.frame = attributes.frame.offsetBy(dx: 0, dy: attributes.frame.height * 0.2)
                }
                attributes.map { attributes in
                    guard let delegate else {
                        attributes.alpha = 0
                        return
                    }
                    delegate.finalLayoutAttributesForDeletedItem(self, of: .cell, at: elementIndexPath, modifying: attributes)
                }
            } else if let itemIdentifier = controller.itemIdentifier(for: elementPath, kind: kind, at: .beforeUpdate),
                      let finalIndexPath = controller.itemPath(by: itemIdentifier, kind: kind, at: .afterUpdate) {
                if controller.movedSectionsIndexes.contains(elementPath.section) || controller.reloadedSectionsIndexes.contains(elementPath.section) {
                    attributes = controller.itemAttributes(for: finalIndexPath, kind: kind, at: .afterUpdate)?.typedCopy()
                } else {
                    attributes = controller.itemAttributes(for: elementPath, kind: kind, at: .beforeUpdate)?.typedCopy()
                }
                if invalidatedAttributes[kind]?.contains(elementPath) ?? false {
                    attributes = nil
                }

                attributes?.indexPath = elementIndexPath
                attributesForPendingAnimations[kind]?[elementPath] = attributes
                if controller.reloadedSectionsIndexes.contains(elementPath.section) {
                    attributes?.alpha = 0
                    attributes?.transform = CGAffineTransform(scaleX: 0, y: 0)
                }
            } else {
                attributes = controller.itemAttributes(for: elementPath, kind: kind, at: .beforeUpdate)
            }
        } else {
            attributes = controller.itemAttributes(for: elementPath, kind: kind, at: .beforeUpdate)
        }
        return attributes
    }
}

extension CollectionViewChatLayout {
    func configuration(for element: ItemKind, at indexPath: IndexPath) -> ItemModel.Configuration {
        let itemSize = estimatedSize(for: element, at: indexPath)
        let interItemSpacing: CGFloat
        if element == .cell {
            interItemSpacing = self.interItemSpacing(for: element, at: indexPath)
        } else {
            interItemSpacing = 0
        }
        return ItemModel.Configuration(alignment: alignment(for: element, at: indexPath), preferredSize: itemSize.estimated, calculatedSize: itemSize.exact, interItemSpacing: interItemSpacing)
    }

    private func estimatedSize(for element: ItemKind, at indexPath: IndexPath) -> (estimated: CGSize, exact: CGSize?) {
        guard let delegate else {
            return (estimated: estimatedItemSize, exact: nil)
        }

        let itemSize = delegate.sizeForItem(self, of: element, at: indexPath)

        switch itemSize {
        case .auto:
            return (estimated: estimatedItemSize, exact: nil)
        case let .estimated(size):
            return (estimated: size, exact: nil)
        case let .exact(size):
            return (estimated: size, exact: size)
        }
    }

    private func itemSize(with preferredAttributes: ChatLayoutAttributes) -> CGSize {
        let itemSize: CGSize
        if let delegate,
           case let .exact(size) = delegate.sizeForItem(self, of: preferredAttributes.kind, at: preferredAttributes.indexPath) {
            itemSize = size
        } else {
            itemSize = preferredAttributes.size
        }
        return itemSize
    }

    private func interItemSpacing(for kind: ItemKind, at indexPath: IndexPath) -> CGFloat {
        let interItemSpacing: CGFloat
        if let delegate,
           let customInterItemSpacing = delegate.interItemSpacing(self, of: kind, after: indexPath) {
            interItemSpacing = customInterItemSpacing
        } else {
            interItemSpacing = settings.interItemSpacing
        }
        return interItemSpacing
    }

    private func alignment(for element: ItemKind, at indexPath: IndexPath) -> ChatItemAlignment {
        guard let delegate else {
            return .fullWidth
        }
        return delegate.alignmentForItem(self, of: element, at: indexPath)
    }

    private var estimatedItemSize: CGSize {
        guard let estimatedItemSize = settings.estimatedItemSize else {
            guard collectionView != nil else {
                return .zero
            }
            return CGSize(width: layoutFrame.width, height: 40)
        }

        return estimatedItemSize
    }

    private func resetAttributesForPendingAnimations() {
        for kind in ItemKind.allCases {
            attributesForPendingAnimations[kind] = [:]
        }
    }

    private func resetInvalidatedAttributes() {
        for kind in ItemKind.allCases {
            invalidatedAttributes[kind] = []
        }
    }
}

extension CollectionViewChatLayout: ChatLayoutRepresentation {
    func numberOfItems(in section: Int) -> Int {
        guard let collectionView else {
            return .zero
        }
        return collectionView.numberOfItems(inSection: section)
    }

    func shouldPresentHeader(at sectionIndex: Int) -> Bool {
        delegate?.shouldPresentHeader(self, at: sectionIndex) ?? false
    }

    func shouldPresentFooter(at sectionIndex: Int) -> Bool {
        delegate?.shouldPresentFooter(self, at: sectionIndex) ?? false
    }

    func interSectionSpacing(at sectionIndex: Int) -> CGFloat {
        let interItemSpacing: CGFloat
        if let delegate,
           let customInterItemSpacing = delegate.interSectionSpacing(self, after: sectionIndex) {
            interItemSpacing = customInterItemSpacing
        } else {
            interItemSpacing = settings.interSectionSpacing
        }
        return interItemSpacing
    }
}

extension CollectionViewChatLayout {
    private var maxPossibleContentOffset: CGPoint {
        guard let collectionView else {
            return .zero
        }
        let maxContentOffset = max(0 - collectionView.adjustedContentInset.top, controller.contentHeight(at: state) - collectionView.frame.height + collectionView.adjustedContentInset.bottom)
        return CGPoint(x: 0, y: maxContentOffset)
    }

    private var isUserInitiatedScrolling: Bool {
        guard let collectionView else {
            return false
        }
        return collectionView.isDragging || collectionView.isDecelerating
    }
}
