//
//  FeedListContext.swift
//  FeedListWrapper
//
//  Created by GIKI on 2024/8/31.
//

import Foundation
import IGListKit
import UIKit

// MARK: - FeedListContext

public class FeedListContext: NSObject {
    public weak var listAdapter: ListAdapter?
    public weak var controller: AnyFeedListBaseController?

    // Enable or disable throttling
    public var throttleReload: Bool = true

    // Task queue with a maximum capacity to prevent excessive memory usage
    private var tasks: [(Bool, Bool, (() -> Void)?)] = []
    private let maxTaskCount = 10

    // Flag to indicate if a reload is currently in progress
    private var isExecuting = false

    // Flags to handle drag state
    private var isDragging = false
    private var needsReloadAfterDrag = false

    // Throttling properties
    private var displayLink: CADisplayLink?
    private var lastExecutionTime: CFTimeInterval = 0
    private let throttleInterval: CFTimeInterval = 0.15
    // 当前运行循环模式
    private var currentRunLoopMode: RunLoop.Mode = .common
    
    public init(listAdapter: ListAdapter?, controller: AnyFeedListBaseController) {
        self.listAdapter = listAdapter
        self.controller = controller
        super.init()
        setupDisplayLink()
    }

    deinit {
        displayLink?.invalidate()
    }

    // Setup CADisplayLink for throttling reloads
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired))
        displayLink?.add(to: .main, forMode: currentRunLoopMode)
        displayLink?.isPaused = true
    }
    
    // 切换运行循环模式的方法
    private func updateRunLoopMode(to mode: RunLoop.Mode) {
        
        guard let displayLink = displayLink else { return }
        // 如果当前模式已是目标模式，则无需切换
        if currentRunLoopMode == mode {
            return
        }
        // 从当前模式中移除
        displayLink.remove(from: .main, forMode: currentRunLoopMode)
        // 添加到新的模式
        displayLink.add(to: .main, forMode: mode)
        // 更新当前模式
        currentRunLoopMode = mode
    }
    

    // Called every frame to check if it's time to execute the next task
    @objc private func displayLinkFired() {
        let currentTime = CACurrentMediaTime()
        if currentTime - lastExecutionTime >= throttleInterval {
            debugPrint("xxxx 刷新拉拉拉")
            executeNextTaskIfNeeded()
            lastExecutionTime = currentTime
        }
    }

    // Adds a reload task with optional cancellation of previous tasks
    public func addReloadTask(diff: Bool, animated: Bool, completion: (() -> Void)? = nil, cancelPrevious: Bool = false) {
        // Limit the number of pending tasks to prevent memory issues
        if tasks.count >= maxTaskCount {
            tasks.removeFirst()
        }

        if cancelPrevious {
            tasks.removeAll()
        }

        tasks.append((diff, animated, completion))

        if throttleReload {
            if displayLink?.isPaused == true {
                displayLink?.isPaused = false
            }
        } else {
            executeNextTaskIfNeeded()
        }
    }

    // Executes the next task in the queue if conditions permit
    private func executeNextTaskIfNeeded() {
      
        guard !isExecuting, !tasks.isEmpty else { return }

        isExecuting = true
        let (diff, animated, completion) = tasks.removeFirst()

        reloadData(diff: diff, animated: animated) { [weak self] in
            completion?()
            guard let self = self else { return }
            self.isExecuting = false
            if self.throttleReload == false {
                self.executeNextTaskIfNeeded()
            }
            if self.tasks.isEmpty {
                self.displayLink?.isPaused = true
            }
        }
    }

    // Performs the actual data reload using IGListKit
    private func reloadData(diff: Bool, animated: Bool, completion: @escaping () -> Void) {
        let performUpdate = { [weak self] in
            guard let self = self else { return }
        
            if diff {
                self.listAdapter?.performUpdates(animated: animated, completion: { _ in
                    completion()
                })
            } else {
                self.listAdapter?.reloadData(completion: { _ in
                    completion()
                })
            }
        }

        if animated {
            performUpdate()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            performUpdate()
            CATransaction.commit()
        }
    }

    // Determines whether reloads should be ignored based on dragging state and throttling
    private func shouldIgnoreReload() -> Bool {
        guard isDragging else { return false }
        guard throttleReload else { return false }
        return true
    }
}

// MARK: - UIScrollViewDelegate

extension FeedListContext: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.bounds.height
        let offsetY = scrollView.contentOffset.y
        
        guard contentHeight > visibleHeight else {
            updateRunLoopMode(to: .common)
            debugPrint("xxxx 切换回 .common 模式")
            return
        }
        debugPrint("offsetY + visibleHeight : \(offsetY + visibleHeight) content: \(contentHeight)")
        let isAtBottom = offsetY + visibleHeight >= contentHeight - 300 // 100 可根据需要调整
        if isAtBottom {
            // 切换回 .common 模式
            updateRunLoopMode(to: .common)
            debugPrint("xxxx 切换回 .common 模式")
        } else {
            //不在底部， 切换到 .default 模式
            updateRunLoopMode(to: .default)
            debugPrint("xxxx 切换回 .default 模式")
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView.contentSize.height > scrollView.bounds.height else { return }
//        isDragging = true
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
//            scrollDidStop(scrollView)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        scrollDidStop(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // No implementation needed
    }

    // Called when scrolling stops to determine if a reload is needed
    private func scrollDidStop(_ scrollView: UIScrollView) {
        guard shouldIgnoreReload() else { return }
        isDragging = false
        if needsReloadAfterDrag {
            needsReloadAfterDrag = false
            executeNextTaskIfNeeded()
        }
    }
}
