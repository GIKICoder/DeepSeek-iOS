//
//  DNestedScrollView.swift
//
//
//  Created by GIKI on 2024/6/24.
//

import UIKit

// MARK: - DNestedContainerInterface Protocol

@objc public protocol DNestedContainerInterface: AnyObject {
    /// 需要添加到 DNestedScrollView 上的 containerView
    @objc optional func nestedAttachView() -> UIView
    
    /// 需要处理事件监听的 ScrollView
    @objc optional func nestedScrollView() -> UIScrollView
    
    /// 当前返回的 'nestedScrollView' 是否需要根据 contentSize 的变化自动更新当前 container 的 Frame
    /// 需要实现了 'nestedScrollView'
    @objc optional func needUpdateFrameWhenContentSizeChanged() -> Bool
    
    /// 返回当前 nestedAttachView 的 height
    /// 如果为 0，则使用 'needUpdateFrameWhenContentSizeChanged' 根据 contentSize 获取自己高度
    @objc optional func customAttachViewHeight() -> CGFloat
    
    /// 当前返回的 'nestedScrollView' 是否需要 DNestedScrollView 接管手势
    /// 需要实现了 'nestedScrollView'
    /// 一般用于子 Container ScrollView 需要联动的 ScrollView
    @objc optional func needTakeoverScrollPanGesture() -> Bool
}

// MARK: - DNestedScrollViewDelegate Protocol
@MainActor
@objc public protocol DNestedScrollViewDelegate: AnyObject {
    /// 当 DNestedScrollView offset 更新
    @objc optional func nestedUpdateScrollOffset(_ offset: CGPoint)
    
    /// 当 DNestedScrollView 停止滚动
    @objc optional func nestedDidEndDecelerating(_ scrollView: UIScrollView)
    
    /// 当 DNestedScrollView 开始拖拽滚动
    @objc optional func nestedWillBeginDragging(_ scrollView: UIScrollView)
    
    /// 当 DNestedScrollView 停止拖动
    @objc optional func nestedDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool)
    
    /// 当 DNestedScrollView contentSize 更新
    @objc optional func nestedUpdateScrollContentSize(_ contentSize: CGSize)
    
    /// 返回当前 DNestedScrollView 悬停的坐标点
    /// 不实现默认 hover point 是处最后一个 scrollView 之前的所有高度
    @objc optional func nestedHoverHeight() -> CGFloat
    
    /// 可以通过 delegate 回调返回当前 container 需要处理事件监听的 ScrollView
    /// 优先级(小于 <) DNestedContainerInterface
    @objc optional func nestedScrollView(withContainer container: AnyObject) -> UIScrollView?
    
    /// 当前返回的 'nestedScrollView' 是否需要根据 contentSize 的变化自动更新当前 container 的 Frame
    /// 优先级(小于 <) DNestedContainerInterface
    @objc optional func needUpdateFrameWhenContentSizeChanged(_ container: AnyObject) -> Bool
    
    /// 返回当前 nestedAttachView 的 height
    /// 如果为 0，则使用 'needUpdateFrameWhenContentSizeChanged' 根据 contentSize 获取自己高度
    /// 优先级(大于 > needUpdateFrameWhenContentSizeChanged)
    @objc optional func customAttachViewHeight(_ container: AnyObject) -> CGFloat
    
    /// 当前返回的 'nestedScrollView' 是否需要 DNestedScrollView 接管手势
    /// 优先级(小于 <) DNestedContainerInterface
    @objc optional func needTakeoverScrollPanGesture(_ container: AnyObject) -> Bool
}

// MARK: - DNestedScrollView Class
@MainActor
public class DNestedScrollView: UIScrollView {
    
    // MARK: - Properties
    
    /// 初始化 nested containers
    /// - Parameter containers: 任意遵守 DNestedContainerInterface 的类型 或 UIView 类型
    public init(nestedContainers containers: [AnyObject]) {
        super.init(frame: .zero)
        commonInit()
        containers.forEach { addContainer($0) }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    deinit {
        
    }
    
    public override func didMoveToSuperview() {
         super.didMoveToSuperview()
         if superview != nil {
             // 视图被添加到父视图
         } else {
             // 视图从父视图中移除
             for container in containers {
                 removeObserver(from: container)
             }
             for scrollView in childScrollViews {
                 scrollView.removeObserver(self, forKeyPath: "contentSize")
             }
         }
     }
    
    private func commonInit() {
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        scrollsToTop = false
        childScrollPullWhenBounces = true
    }
    
    /// DNestedScrollViewDelegate
    public weak var nestedDelegate: AnyObject?
    
    /// overlay View，用于处理滑动手势的 ScrollView
    /// 刷新控件可添加到此 scrollView 上
    public private(set) lazy var overlayView: UIScrollView = {
        let overlay = UIScrollView()
        overlay.frame = frame
        overlay.delegate = self
        overlay.alwaysBounceVertical = true
        overlay.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        overlay.contentInsetAdjustmentBehavior = .never
        return overlay
    }()
    
    /// 放大效果背景图，当 needStretchHeader == true 生效
    public private(set) lazy var stretchView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// 背景图自定义 frame，默认为 nil，背景图按照首个 container 布局
    public var stretchCustomFrame: CGRect?
    
    /// 是否添加缩放 Header，默认：false
    public var needStretchHeader = false
    
    /// 当 DNestedScrollView bounces 状态下，是否允许子 scrollView 继续下拉操作
    /// self.bounces == false 时生效
    /// 默认：true
    /// 通常用于实现 Header 不拉伸，顶部固定，下面 listView 可下拉刷新
    public var childScrollPullWhenBounces = true
    
    
    // MARK: - Private Properties
    
    private var containers: [AnyObject] = []
    private var childScrollViews: [UIScrollView] = []
    private var childScrollViewsMap = NSMapTable<UIScrollView, NSNumber>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    private var originalRect = CGRect.zero
    
    /// 是否悬停Flags
    public var isHover = false
    
    /// 悬停锁定
    public  var hoverLockedMode = false
    /// 悬停锁定状态
    private var hoverLockedFlag = false
    private var resetHoverLocking = false
    
    // MARK: - Public Methods
    
    /// 添加一个 container
    public func addContainer(_ container: AnyObject) {
        containers.append(container)
        setNeedsUpdateContainer()
    }
    
    /// 在 index 位置插入一个 container
    public func insertContainer(_ container: AnyObject, at index: Int) {
        guard index >= 0 && index <= containers.count else {
            addContainer(container)
            return
        }
        containers.insert(container, at: index)
        setNeedsUpdateContainer()
    }
    
    /// 在 before container 前面添加一个 container
    public func addContainer(_ container: AnyObject, before: AnyObject) {
        if let index = indexOfContainer(before) {
            containers.insert(container, at: index)
        } else {
            addContainer(container)
        }
        setNeedsUpdateContainer()
    }
    
    /// 在 after container 后面添加一个 container
    public func addContainer(_ container: AnyObject, after: AnyObject) {
        if let index = indexOfContainer(after) {
            containers.insert(container, at: index + 1)
        } else {
            addContainer(container)
        }
        setNeedsUpdateContainer()
    }
    
    /// 移除某个 container
    public func removeContainer(_ container: AnyObject) {
        if let index = indexOfContainer(container) {
            containers.remove(at: index)
            if let attachView = fetchAttachView(withContainer: container) {
                attachView.removeFromSuperview()
            }
            setNeedsUpdateContainer()
        }
    }
    
    /// 移除所有的 container
    public func removeAllContainers() {
        for container in containers {
            if let attachView = fetchAttachView(withContainer: container) {
                attachView.removeFromSuperview()
            }
        }
        containers.removeAll()
        setNeedsUpdateContainer()
    }
    
    /// 是否包含某个 container
    public func contains(container: AnyObject) -> Bool {
        return containers.contains { $0 === container }
    }
    
    /// 获取所有的 container
    public func allContainers() -> [AnyObject] {
        return containers
    }
    
    /// 最后一个 container
    public func lastContainer() -> AnyObject? {
        return containers.last
    }
    
    /// 第一个 container
    public func firstContainer() -> AnyObject? {
        return containers.first
    }
    
    /// 滚动到对应的 container
    public func scrollToContainer(_ container: AnyObject, animated: Bool) {
        guard let attachView = fetchAttachView(withContainer: container) else { return }
        overlayView.setContentOffset(CGPoint(x: contentOffset.x, y: attachView.frame.origin.y), animated: animated)
    }
    
    /// 滚动到顶部
    public func scrollToTopContainer(animated: Bool) {
        overlayView.setContentOffset(.zero, animated: animated)
    }
    
    /// 添加子 scrollView 监听
    /// 一般用于多层横向嵌套的竖向 child scrollView
    public func addObserverChildScrollView(_ scrollView: UIScrollView) {
        guard childScrollViewsMap.object(forKey: scrollView) == nil else { return }
        childScrollViewsMap.setObject(0, forKey: scrollView)
        childScrollViews.append(scrollView)
        scrollView.panGestureRecognizer.require(toFail: overlayView.panGestureRecognizer)
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old], context: nil)
    }
    
    /// 更新 overlayView 的 contentSize
    /// 非横向嵌套 scrollView 的情况下无需调用
    /// 在横向嵌套的 scrollView pageIndex 更改时调用更新
    public func updateOverlayContentSize() {
        var topOrigin: CGFloat = 0
        for container in containers {
            if let attachView = fetchAttachView(withContainer: container) {
                if let adjustScrollView = fetchAdjustScrollView(withContainer: container) {
                    let contentHeight = adjustScrollView.contentSize.height + adjustScrollView.contentInset.top + adjustScrollView.contentInset.bottom
                    topOrigin += max(contentHeight, adjustScrollView.frame.size.height)
                } else {
                    topOrigin += attachView.frame.height
                }
            }
        }
        overlayView.contentSize = CGSize(width: contentSize.width, height: topOrigin)
        if let delegate = nestedDelegate as? (any DNestedScrollViewDelegate) {
            delegate.nestedUpdateScrollContentSize?(CGSize(width: contentSize.width, height: topOrigin))
        }
    }
    
    /// 重置接管手势
    public func resetTakeOverPanGesture(withContainer container: AnyObject) {
        guard let adjustScrollView = fetchAdjustScrollView(withContainer: container) else { return }
        let takeOver = fetchNeedTakeOverPanGesture(withContainer: container)
        if takeOver {
            adjustScrollView.panGestureRecognizer.require(toFail: overlayView.panGestureRecognizer)
        } else {
            // 无法直接移除手势依赖，可以根据业务需求重新创建手势，或者调整逻辑
            // 这里暂时不进行操作
            adjustScrollView.panGestureRecognizer.removeTarget(overlayView.panGestureRecognizer, action: nil)
        }
    }
    
    /// 标记需要更新 container
    public func setNeedsUpdateContainer() {
        updateContainers()
    }
    
    // MARK: - Private Methods
    
    private func indexOfContainer(_ container: AnyObject) -> Int? {
        return containers.firstIndex { $0 === container }
    }
    
    private func fetchAttachView(withContainer container: AnyObject) -> UIView? {
        if let container = container as? (any DNestedContainerInterface) {
            return container.nestedAttachView?()
        } else if let view = container as? UIView {
            return view
        }
        return nil
    }
    
    private func fetchAdjustScrollView(withContainer container: AnyObject) -> UIScrollView? {
        if let container = container as? (any DNestedContainerInterface) {
            if let scrollView = container.nestedScrollView?() {
                return scrollView
            }
        }
        if let delegate = nestedDelegate as? (any DNestedScrollViewDelegate) {
            return delegate.nestedScrollView?(withContainer: container)
        }
        return nil
    }
    
    private func fetchCustomAttachViewHeight(withContainer container: AnyObject) -> CGFloat {
        if let container = container as? (any DNestedContainerInterface), let height = container.customAttachViewHeight?() {
            return height
        } else if let delegate = nestedDelegate as? (any DNestedScrollViewDelegate), let height = delegate.customAttachViewHeight?(
            container
        ) {
            return height
        }
        return 0
    }
    
    private func fetchNeedUpdateFrame(withContainer container: AnyObject) -> Bool {
        if let container = container as? (any DNestedContainerInterface), let needUpdate = container.needUpdateFrameWhenContentSizeChanged?() {
            return needUpdate
        } else if let delegate = nestedDelegate as? (any DNestedScrollViewDelegate), let needUpdate = delegate.needUpdateFrameWhenContentSizeChanged?(
            container
        ) {
            return needUpdate
        }
        return false
    }
    
    private func fetchNeedTakeOverPanGesture(withContainer container: AnyObject) -> Bool {
        if let container = container as? (any DNestedContainerInterface), let needTakeOver = container.needTakeoverScrollPanGesture?() {
            return needTakeOver
        } else if let delegate = nestedDelegate as? (any DNestedScrollViewDelegate), let needTakeOver = delegate.needTakeoverScrollPanGesture?(
            container
        ) {
            return needTakeOver
        }
        return false
    }
    
    private func fetchTopContainerHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        let allContainers = self.allContainers()
        if allContainers.count > 1 {
            for index in 0..<(allContainers.count - 1) {
                let container = allContainers[index]
                if let view = fetchAttachView(withContainer: container) {
                    totalHeight += view.frame.height
                }
            }
        }
        return totalHeight
    }
    
    private func fetchHoverHeight() -> CGFloat {
        if let delegate = nestedDelegate as? (any DNestedScrollViewDelegate), let hoverHeight = delegate.nestedHoverHeight?() {
            return hoverHeight
        } else {
            return fetchTopContainerHeight()
        }
    }
    
    private func updateStretchHeader(offsetY: CGFloat) {
        guard needStretchHeader else { return }
        
        if offsetY >= 0 {
            stretchView.frame = CGRect(x: 0, y: 0, width: stretchView.frame.width, height: originalRect.height)
        } else {
            stretchView.frame = CGRect(x: 0, y: offsetY, width: stretchView.frame.width, height: originalRect.height - offsetY)
        }
    }
    
    private func updateContainers() {
        var topOrigin: CGFloat = 0
        for container in containers {
            guard let attachView = fetchAttachView(withContainer: container) else { continue }
            if attachView.superview == nil {
                addSubview(attachView)
                addObserver(to: container)
            }
            attachView.frame.origin.y = topOrigin
            topOrigin = attachView.frame.maxY
            
            if needStretchHeader, containers.first === container {
                if stretchView.superview == nil {
                    insertSubview(stretchView, at: 0)
                }
                stretchView.frame = stretchCustomFrame ?? attachView.bounds
                originalRect = stretchView.frame
            }
        }
        contentSize = CGSize(width: UIScreen.main.bounds.width, height: topOrigin)
        updateOverlayContentSize()
    }
    
    private func removeObserver(from container: AnyObject) {
        guard let attachView = fetchAttachView(withContainer: container) else { return }
        attachView.removeObserver(self, forKeyPath: "frame")
        attachView.removeObserver(self, forKeyPath: "bounds")
        
        if let adjustScrollView = fetchAdjustScrollView(withContainer: container) {
            adjustScrollView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    

    private func addObserver(to container: AnyObject) {
        guard let attachView = fetchAttachView(withContainer: container) else { return }
        attachView.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        attachView.addObserver(self, forKeyPath: "bounds", options: [.new, .old], context: nil)
        
        if let adjustScrollView = fetchAdjustScrollView(withContainer: container) {
            adjustScrollView.scrollsToTop = false
            let takeOver = fetchNeedTakeOverPanGesture(withContainer: container)
            if takeOver {
                adjustScrollView.panGestureRecognizer.require(toFail: overlayView.panGestureRecognizer)
            }
            adjustScrollView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old], context: nil)
        }
    }
    
    // MARK: - KVO
    @MainActor
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let keyPath = keyPath, let change = change else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if object is UIView, (keyPath == "frame" || keyPath == "bounds") {
            if let newRect = change[.newKey] as? CGRect,
               let oldRect = change[.oldKey] as? CGRect,
               !newRect.equalTo(oldRect) {
                updateContainers()
            }
        } else if object is UIScrollView, keyPath == "contentSize" {
            if let newSize = change[.newKey] as? CGSize,
               let oldSize = change[.oldKey] as? CGSize,
               !newSize.equalTo(oldSize) {
                updateOverlayContentSize()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Overrides
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if frame != overlayView.frame {
            overlayView.frame = frame
        }
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        overlayView.removeFromSuperview()
        if let newSuperview = newSuperview {
            newSuperview.insertSubview(overlayView, belowSubview: self)
            addGestureRecognizer(overlayView.panGestureRecognizer)
            addSubview(stretchView)
        }
    }
}

// MARK: - <#section#>
extension DNestedScrollView {
    
    public func removeOverlayGestureRecognizer() {
//        overlayView.panGestureRecognizer.state = .cancelled
        self.isScrollEnabled = false
        overlayView.isScrollEnabled = false
        self.removeGestureRecognizer(overlayView.panGestureRecognizer)
    }
    
    public func restoreOverlayGestureRecognizer() {
        hoverLockedFlag = false
        resetHoverLocking = true
        self.isScrollEnabled = true
        overlayView.isScrollEnabled = true
        
        if gestureRecognizers?.contains(overlayView.panGestureRecognizer) == false {
            addGestureRecognizer(overlayView.panGestureRecognizer)
        }
        
        for childScrollView in childScrollViews {
            childScrollView.panGestureRecognizer.require(toFail: overlayView.panGestureRecognizer)
        }
        hoverLockedFlag = false
        UIView.animate(withDuration: 0.25) {[weak self] in
            self?.scrollToTopContainer(animated: false)
        } completion: {[weak self] finish in
            self?.updateOverlayContentSize()
            self?.updateGestureScrollView()
        }
    }
    
    func updateGestureScrollView() {
        resetHoverLocking = false
        if gestureRecognizers?.contains(overlayView.panGestureRecognizer) == false {
            addGestureRecognizer(overlayView.panGestureRecognizer)
        }
        addGestureRecognizer(overlayView.panGestureRecognizer)
        for childScrollView in childScrollViews {
            childScrollView.panGestureRecognizer.require(toFail: overlayView.panGestureRecognizer)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension DNestedScrollView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        if offset == 0 {
            resetHoverLocking = false
        }
        if resetHoverLocking {
            return
        }
        
        let hoverHeight = fetchHoverHeight()
    
        if let delegate = nestedDelegate as? (any DNestedScrollViewDelegate) {
            delegate.nestedUpdateScrollOffset?(scrollView.contentOffset)
        }
        
        if hoverLockedFlag,isHover {
            /// 开启悬停锁定后.
            contentOffset = CGPoint(x: 0, y: hoverHeight)
            removeOverlayGestureRecognizer()
            return
        }
        
        if !bounces, offset <= 0 {
            isHover = false
            contentOffset = .zero
            if !childScrollPullWhenBounces {
                return
            }
            overlayView.contentOffset = .zero
            overlayView.panGestureRecognizer.state = .cancelled
            return
        }
        
        updateStretchHeader(offsetY: offset)
        
        if offset < hoverHeight {
            isHover = false
            contentOffset = scrollView.contentOffset
            if let container = lastContainer(),
               let adjustScrollView = fetchAdjustScrollView(withContainer: container) {
                adjustScrollView.contentOffset = .zero
                if let _ = childScrollViewsMap.object(forKey: adjustScrollView) {
                    childScrollViewsMap.setObject(0, forKey: adjustScrollView)
                }
                for childScrollView in childScrollViews {
                    childScrollView.contentOffset = .zero
                    childScrollViewsMap.setObject(0, forKey: childScrollView)
                }
            }
        } else {
            isHover = true
            if hoverLockedMode {
                hoverLockedFlag = true
            }
            contentOffset = CGPoint(x: 0, y: hoverHeight)
            if let container = lastContainer(),
               let adjustScrollView = fetchAdjustScrollView(withContainer: container) {
                adjustScrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y - contentOffset.y)
                if (childScrollViewsMap.object(forKey: adjustScrollView)?.floatValue) != nil {
                    childScrollViewsMap.setObject(NSNumber(value: Float(scrollView.contentOffset.y)), forKey: adjustScrollView)
                }
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let delegate = nestedDelegate as? (any DNestedScrollViewDelegate) {
            delegate.nestedWillBeginDragging?(scrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let delegate = nestedDelegate as? (any DNestedScrollViewDelegate) {
            delegate.nestedDidEndDecelerating?(scrollView)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let delegate = nestedDelegate as? (any DNestedScrollViewDelegate) {
            delegate.nestedDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
    }
}
