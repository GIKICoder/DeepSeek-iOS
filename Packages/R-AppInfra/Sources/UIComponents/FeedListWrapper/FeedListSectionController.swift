//
//  FeedListSectionController.swift
//  FeedListWrapper
//
//  Created by GIKI on 2024/8/31.
//

import IGListKit
import UIKit

// MARK: - FeedListSectionController

open class FeedListSectionController: ListSectionController {
    public var sectionBean: FeedListSectionBean?
    public weak var context: FeedListContext?
    public var handlerChain: FeedHandlerChain?
    public var isUserInteractionEnabled: Bool = true

    override public init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        displayDelegate = self
    }

    override open func numberOfItems() -> Int {
        return sectionBean?.cellLayouts.count ?? 0
    }

    override open func sizeForItem(at index: Int) -> CGSize {
        return sectionBean?.cellLayouts[index].cellSize ?? CGSizeMake(UIScreen.main.bounds.size.width, 0.01)
    }

    override open func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let layout = sectionBean?.cellLayouts[index],
              let cell = collectionContext?.dequeueReusableCell(of: layout.cellClass, for: self, at: index) as? (any FeedListBaseCellProtocol)
        else {
            return UICollectionViewCell()
        }

        if let context = context {
            cell.configureContext(context)
        }

        if let handlerChain = handlerChain {
            cell.configureHandlerChain(handlerChain)
        }

        if let sectionBean = sectionBean {
            cell.configure(sectionBean: sectionBean, layout: layout, index: index)
        }
        
        
        if let cell2 = cell as? UICollectionViewCell {
            cell2.isUserInteractionEnabled = isUserInteractionEnabled
        }

        return cell as! UICollectionViewCell
    }

    override open func didUpdate(to object: Any) {
        sectionBean = object as? FeedListSectionBean
    }
}

extension FeedListSectionController: ListDisplayDelegate {
    public func listAdapter(_: ListAdapter, willDisplay _: ListSectionController) {}

    public func listAdapter(_: ListAdapter, didEndDisplaying _: ListSectionController) {}

    public func listAdapter(_: ListAdapter, willDisplay _: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        guard let cell = cell as? (any FeedListBaseCellProtocol) else {
            return
        }
        if let sectionBean = sectionBean, let layout = sectionBean.cellLayouts[index] as? FeedListBaseCellLayout {
            cell.willDisplay(sectionBean: sectionBean, layout: layout, index: index)
        }
    }

    public func listAdapter(_: ListAdapter, didEndDisplaying _: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        guard let cell = cell as? (any FeedListBaseCellProtocol) else {
            return
        }
        if let sectionBean = sectionBean, let layout = sectionBean.cellLayouts[safe: index] {
            cell.didEndDisplaying(sectionBean: sectionBean, layout: layout, index: index)
        }
    }
}
