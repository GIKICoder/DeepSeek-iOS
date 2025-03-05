//
//  JXPhotoBrowserAnimatedTransitioning.swift
//  JXPhotoBrowser
//
//  Created by JiongXing on 2019/11/25.
//  Copyright © 2019 JiongXing. All rights reserved.
//

import UIKit

public protocol JXPhotoBrowserAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    var isForShow: Bool { get set }
    var photoBrowser: JXPhotoBrowser? { get set }
    var isNavigationAnimation: Bool { get set }
}

private var isForShowKey: Void?
private var photoBrowserKey: Void?

public extension JXPhotoBrowserAnimatedTransitioning {
    var isForShow: Bool {
        get {
            if let value = objc_getAssociatedObject(self, &isForShowKey) as? Bool {
                return value
            }
            return true
        }
        set {
            objc_setAssociatedObject(self, &isForShowKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    weak var photoBrowser: JXPhotoBrowser? {
        get {
            if let wrapper = objc_getAssociatedObject(self, &photoBrowserKey) as? JXPhotoBrowserWeakAssociationWrapper {
                return wrapper.target as? JXPhotoBrowser
            }
            return nil
        }
        set {
            let wrapper = JXPhotoBrowserWeakAssociationWrapper(target: newValue)
            objc_setAssociatedObject(self, &photoBrowserKey, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var isNavigationAnimation: Bool {
        get { return false }
        set {}
    }

    func snapshot(with view: UIView) -> UIView? {
        let snapshot = view.snapshotView(afterScreenUpdates: true)
        return snapshot
    }
}

struct JXPhotoBrowserWeakAssociationWrapper {
    weak var target: AnyObject?

    init(target: AnyObject? = nil) {
        self.target = target
    }
}
