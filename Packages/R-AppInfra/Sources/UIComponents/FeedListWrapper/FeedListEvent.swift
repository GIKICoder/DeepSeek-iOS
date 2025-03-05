//
//  FeedListEvent.swift
//
//
//  Created by GIKI on 2024/9/2.
//

import Foundation
import IGListKit
import UIKit

open class FeedListEvent: FeedHandleable {
    public weak var context: FeedListContext?

    init(context: FeedListContext) {
        self.context = context
    }

    public func canHandle(event: FeedEvent) -> Bool {
        switch event.type {
        case .custom, .itemTapped, .itemLongPress:
            return false
        default:
            return true
        }
    }

    public func handle(event: FeedEvent) {
        switch event.type {
        case let .reloadData(animate):
            handleReloadData(event: event, animate: animate)
        case let .reloadIndex(animate):
            handleReloadIndex(event: event, animate: animate)
        case let .performUpdates(animate):
            handlePerformUpdates(event: event, animate: animate)
        case let .reloadObjects(animate):
            handleReloadObjects(event: event, animate: animate)
        case .loadNewData:
            handleLoadNewData(event: event)
        case .loadMoreData:
            handleLoadMoreData(event: event)
        case .removeObjects:
            handleRemoveObjects(event: event)
        case .insertObjectsAtIndex:
            handleInsertObjectsAtIndex(event: event)
        default:
            break
        }
    }

    // MARK: - Individual event handlers

    open func handleReloadData(event: FeedEvent, animate _: Bool) {
        guard let listAdapter = context?.listAdapter else {
            return
        }
        listAdapter.reloadData { finish in
            event.callback?(.success(finish))
        }
    }

    open func handleReloadIndex(event _: FeedEvent, animate _: Bool) {
        // Empty implementation
    }

    open func handlePerformUpdates(event: FeedEvent, animate: Bool) {
        guard let listAdapter = context?.listAdapter else {
            return
        }
        listAdapter.performUpdates(animated: animate) { finish in
            event.callback?(.success(finish))
        }
    }

    open func handleReloadObjects(event _: FeedEvent, animate _: Bool) {
        // Empty implementation
    }

    open func handleLoadNewData(event: FeedEvent) {
        guard let dataCenter = context?.controller?.anyDataCenter else {
            return
        }
        dataCenter.loadData { result in
            switch result {
            case let .success(sectionBeans):
                event.callback?(.success(sectionBeans as! Any))
            case let .failure(error):
                event.callback?(.failure(error))
            }
        }
    }

    open func handleLoadMoreData(event: FeedEvent) {
        guard let dataCenter = context?.controller?.anyDataCenter else {
            return
        }
        dataCenter.loadMoreData { result in

            switch result {
            case let .success(sectionBeans):
                event.callback?(.success(sectionBeans as! Any))
            case let .failure(error):
                event.callback?(.failure(error))
            }
        }
    }

    open func handleRemoveObjects(event _: FeedEvent) {
        // Empty implementation
    }

    open func handleInsertObjectsAtIndex(event _: FeedEvent) {
        // Empty implementation
    }
}
