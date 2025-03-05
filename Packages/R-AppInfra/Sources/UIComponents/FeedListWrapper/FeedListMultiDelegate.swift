//
//  FeedListMultiDelegate.swift
//
//
//  Created by GIKI on 2024/9/9.
//

import Foundation

public class FeedListMultiDelegate: NSObject {
    private var _delegates: NSPointerArray
    var delegates: NSPointerArray { _delegates }
    var silentWhenEmpty: Bool = true

    override public init() {
        _delegates = NSPointerArray.weakObjects()
        super.init()
    }

    public init(delegates: [AnyObject]) {
        _delegates = NSPointerArray.weakObjects()
        super.init()
        for delegate in delegates {
            _delegates.addPointer(Unmanaged.passUnretained(delegate).toOpaque())
        }
    }

    public func addDelegate(_ delegate: AnyObject) {
        _delegates.addPointer(Unmanaged.passUnretained(delegate).toOpaque())
    }

    public func addDelegate(_ delegate: AnyObject, beforeDelegate otherDelegate: AnyObject) {
        let index = indexOfDelegate(otherDelegate)
        if index == NSNotFound {
            _delegates.addPointer(Unmanaged.passUnretained(delegate).toOpaque())
        } else {
            _delegates.insertPointer(Unmanaged.passUnretained(delegate).toOpaque(), at: index)
        }
    }

    public func addDelegate(_ delegate: AnyObject, afterDelegate otherDelegate: AnyObject) {
        let index = indexOfDelegate(otherDelegate)
        if index == NSNotFound {
            _delegates.insertPointer(Unmanaged.passUnretained(delegate).toOpaque(), at: 0)
        } else {
            _delegates.insertPointer(Unmanaged.passUnretained(delegate).toOpaque(), at: index + 1)
        }
    }

    public func removeDelegate(_ delegate: AnyObject) {
        let index = indexOfDelegate(delegate)
        if index != NSNotFound {
            _delegates.removePointer(at: index)
        }
        _delegates.compact()
    }

    public func removeAllDelegates() {
        for i in (0 ..< _delegates.count).reversed() {
            _delegates.removePointer(at: i)
        }
    }

    public var lastDelegate: AnyObject? {
        return _delegates.allObjects.last as AnyObject?
    }

    public func indexOfDelegate(_ delegate: AnyObject) -> Int {
        for i in 0 ..< _delegates.count {
            if _delegates.pointer(at: i) == Unmanaged.passUnretained(delegate).toOpaque() {
                return i
            }
        }
        return NSNotFound
    }

    override public func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }

        for delegate in _delegates.allObjects {
            if let delegate = delegate as AnyObject?, delegate.responds(to: aSelector) {
                return true
            }
        }

        return false
    }

    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        for delegate in _delegates.allObjects {
            if let delegate = delegate as AnyObject?, delegate.responds(to: aSelector) {
                return delegate
            }
        }

        return nil
    }

    override public func method(for aSelector: Selector!) -> IMP? {
        if let method = super.method(for: aSelector) {
            return method
        }

        _delegates.compact()
        if silentWhenEmpty && _delegates.count == 0 {
            return super.method(for: #selector(getter: description))
        }

        for delegate in _delegates.allObjects {
            if let delegate = delegate as AnyObject?,
               let method = delegate.method(for: aSelector)
            {
                return method
            }
        }

        return nil
    }
}
