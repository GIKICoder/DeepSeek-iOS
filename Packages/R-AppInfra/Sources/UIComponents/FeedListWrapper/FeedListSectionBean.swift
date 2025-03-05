//
//  FeedListSectionBean.swift
//  FeedListWrapper
//
//  Created by GIKI on 2024/8/31.
//

import IGListKit
import UIKit

// MARK: - Protocols

public protocol ListSectionBeanable: ListDiffable {
    var beanObject: any ListDiffable { get }
    var cellLayouts: [FeedListBaseCellLayout] { get }
    func generateLayouts(with beanObject: any ListDiffable)
}

// MARK: - FeedListSectionBean

open class FeedListSectionBean: ListSectionBeanable {
    public var beanObject: any ListDiffable
    public var cellLayouts: [FeedListBaseCellLayout] = []
    public var estimateHeight: CGFloat = 0.0

    public init(beanObject: any ListDiffable) {
        self.beanObject = beanObject
        generateLayouts(with: beanObject)
    }

    open func generateLayouts(with beanObject: any ListDiffable) {
        cellLayouts.removeAll()
        self.beanObject = beanObject
    }
    
    open func reGenerateLayouts() {
        generateLayouts(with: self.beanObject)
    }

    public func diffIdentifier() -> any NSObjectProtocol {
        return beanObject.diffIdentifier()
    }

    public func isEqual(toDiffableObject object: (any ListDiffable)?) -> Bool {
        guard let other = object as? FeedListSectionBean else { return false }
        return beanObject.isEqual(toDiffableObject: other.beanObject)
    }

    // MARK: - Additional methods

    open func layout(at index: Int) -> FeedListBaseCellLayout? {
        guard let layouts = cellLayouts as? [FeedListBaseCellLayout] else { return nil }
        objc_sync_enter(cellLayouts)
        defer { objc_sync_exit(cellLayouts) }

        guard index < cellLayouts.count else { return nil }
        return cellLayouts[index]
    }

    open func addLayout(_ layout: FeedListBaseCellLayout) {
        layout.currentSectionBean = self
        cellLayouts.append(layout)
    }

    open func insertLayout(_ layout: FeedListBaseCellLayout, at index: Int) {
        guard let layouts = cellLayouts as? [FeedListBaseCellLayout] else { return }
        objc_sync_enter(cellLayouts)
        defer { objc_sync_exit(cellLayouts) }

        if cellLayouts.isEmpty {
            cellLayouts.append(layout)
            return
        }

        guard index >= 0 && index < cellLayouts.count else { return }
        cellLayouts.insert(layout, at: index)
    }

    open func removeLayout(_ layout: FeedListBaseCellLayout) {
        guard let layouts = cellLayouts as? [FeedListBaseCellLayout] else { return }
        objc_sync_enter(cellLayouts)
        defer { objc_sync_exit(cellLayouts) }

        cellLayouts.removeAll { $0 === layout }
    }

    open func indexOfLayout(_ layout: FeedListBaseCellLayout) -> Int {
        guard let layouts = cellLayouts as? [FeedListBaseCellLayout] else { return -1 }

        objc_sync_enter(cellLayouts)
        defer { objc_sync_exit(cellLayouts) }

        return cellLayouts.firstIndex { $0 === layout } ?? -1
    }

    open func updateLayouts() {
        guard let layouts = cellLayouts as? [FeedListBaseCellLayout] else { return }
        objc_sync_enter(cellLayouts)
        defer { objc_sync_exit(cellLayouts) }

        estimateHeight = 0
        for layout in cellLayouts {
            if layout.currentSectionBean !== self {
                layout.generateLayout(with: layout.currentSectionBean?.beanObject ?? beanObject)
            } else {
                layout.generateLayout(with: beanObject)
            }
            estimateHeight += layout.cellSize.height
        }
        didUpdateLayouts()
    }

    open func updateLayout(at index: Int) {
        guard let layouts = cellLayouts as? [FeedListBaseCellLayout] else { return }
        objc_sync_enter(cellLayouts)
        defer { objc_sync_exit(cellLayouts) }

        guard index >= 0 && index < cellLayouts.count else { return }

        let layout = cellLayouts[index]
        if layout.currentSectionBean !== self {
            layout.generateLayout(with: layout.currentSectionBean?.beanObject ?? beanObject)
        } else {
            layout.generateLayout(with: beanObject)
        }

        didUpdateLayouts()
    }

    open func didUpdateLayouts() {
        // Override this method in subclasses if needed
    }

    open func updateLayouts(with beanObject: any ListDiffable) {
        self.beanObject = beanObject
        updateLayouts()
    }
}
