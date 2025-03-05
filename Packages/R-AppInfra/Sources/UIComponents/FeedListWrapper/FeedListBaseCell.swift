//
//  FeedListBaseCell.swift
//  FeedListWrapper
//
//  Created by GIKI on 2024/8/31.
//

import IGListKit
import UIKit

// MARK: - Protocols

public protocol FeedListBaseCellProtocol: AnyObject {
    func configureContext(_ context: FeedListContext)
    func configureHandlerChain(_ handlerChain: FeedHandlerChain)
    func configure(sectionBean: FeedListSectionBean, layout: FeedListBaseCellLayout, index: Int)

    func willDisplay(sectionBean: FeedListSectionBean, layout: FeedListBaseCellLayout, index: Int)
    func didEndDisplaying(sectionBean: FeedListSectionBean, layout: FeedListBaseCellLayout, index: Int)
}

// MARK: - FeedListBaseCell

open class FeedListBaseCell: UICollectionViewCell, FeedListBaseCellProtocol {
    public var context: FeedListContext?
    public var handlerChain: FeedHandlerChain?
    public var sectionBean: FeedListSectionBean?
    public var layout: FeedListBaseCellLayout?
    public var index: Int = 0

    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
#if DEBUG
//        contentView.backgroundColor = .random
#endif
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func configureContext(_ context: FeedListContext) {
        self.context = context
    }

    open func configureHandlerChain(_ handlerChain: FeedHandlerChain) {
        self.handlerChain = handlerChain
    }

    open func configure(sectionBean: FeedListSectionBean, layout: FeedListBaseCellLayout, index: Int) {
        self.sectionBean = sectionBean
        self.layout = layout
        self.index = index
    }

    open func willDisplay(sectionBean _: FeedListSectionBean, layout _: FeedListBaseCellLayout, index _: Int) {}

    open func didEndDisplaying(sectionBean _: FeedListSectionBean, layout _: FeedListBaseCellLayout, index _: Int) {}
}

// MARK: - FeedListActionCell

open class FeedListActionCell: FeedListBaseCell {
    public var tapGesture: UITapGestureRecognizer?
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setActionHandler()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setActionHandler() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }

    @objc private func cellTapped() {
        let event = FeedEvent(type: .itemTapped, sectionBean: sectionBean, index: index)
        handlerChain?.handleFirst(event)
    }
}

// MARK: - FeedListBaseCellLayout

open class FeedListBaseCellLayout {
    open var cellSize: CGSize
    open var cellClass: AnyClass
    open var edgeInsets: UIEdgeInsets
    open var beanObject: (any ListDiffable)?
    open weak var currentSectionBean: FeedListSectionBean?

    public init(cellSize: CGSize = CGSize(width: 0.0, height: 0.0), edgeInsets: UIEdgeInsets = .zero, cellClass: AnyClass) {
        self.cellSize = cellSize
        self.cellClass = cellClass
        self.edgeInsets = edgeInsets
    }

    open func generateLayout(with beanObject: any ListDiffable) {
        self.beanObject = beanObject
        // Override in subclass if needed
    }
}
