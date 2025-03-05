//
//  FeedListBaseController.swift
//  FeedListWrapper
//
//  Created by GIKI on 2024/8/31.
//

import IGListKit
import UIKit

open class AnyFeedListBaseController: UIViewController {
    public lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()

    public lazy var adapter: ListAdapter = .init(updater: ListAdapterUpdater(), viewController: self)

    public let handlerChain = FeedHandlerChain()

    public lazy var context: FeedListContext = .init(listAdapter: adapter, controller: self)

    public var anyDataCenter: any FeedDataCenter { fatalError("This property must be overridden") }
}

// MARK: - FeedListBaseController

open class FeedListBaseController<T: FeedDataCenter>: AnyFeedListBaseController, ListAdapterDataSource {
    override public var anyDataCenter: any FeedDataCenter { dataCenter }
    open var dataCenter: T

    public init(dataCenter: T) {
        self.dataCenter = dataCenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupAdapter()
        setupHandlerChanins()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.alwaysBounceVertical = true
        collectionView.isPrefetchingEnabled = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private func setupAdapter() {
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    func setupHandlerChanins() {
        let baseEvent = FeedListEvent(context: context)
        handlerChain.addHandler(baseEvent)
    }

    // MARK: - ListAdapterDataSource

    open func objects(for _: ListAdapter) -> [any ListDiffable] {
        return dataCenter.currentSectionBeans()
    }

    open func listAdapter(_: ListAdapter, sectionControllerFor _: Any) -> ListSectionController {
        let sectionController = FeedListSectionController()
        sectionController.context = context
        sectionController.handlerChain = handlerChain
        return sectionController
    }

    public func emptyView(for _: ListAdapter) -> UIView? {
        return nil
    }
}
