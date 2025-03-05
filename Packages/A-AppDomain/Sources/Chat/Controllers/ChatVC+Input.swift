//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/10.
//

import UIKit
import MagazineLayout
import AppFoundation
import AppInfra

// MARK: - ChatInputToolViewDelegate

extension ChatViewController: ChatInputToolViewDelegate {
    
    func setupToolViews() {
        // 添加 ChatInputToolView
        view.addSubview(chatInputToolView)
        chatInputToolView.delegate = self
        chatInputToolView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    @objc private func didTapEmojiButton() {
        // 切换到自定义键盘
        chatInputToolView.showCustomKeyboardPanel()
    }
    
    
    // MARK: - Delegate Method
    public func chatInputToolView(_ inputToolView: ChatInputToolView, didChangeInputBarTopOffset offset: CGFloat, state: ChatInputToolViewState) {
        
        //        logUI("didChangeInputBarTopOffset: \(offset)")
        let newBottomInset = collectionView.frame.minY + collectionView.frame.size.height - offset - view.safeAreaInsets.bottom
        //        logUI("didChangeInputBarTopOffset After: \(newBottomInset)")
        adjustCollectionViewForKeyboard(newBottomInset: newBottomInset, shouldScrollToBottom: true)
    }
    
    public func chatInputToolView(_ inputToolView: ChatInputToolView, didReturnSend text: String?, imageUrl: String?) {
        
        guard (text != nil && !text!.isEmpty) || imageUrl != nil else {
            return
        }
        scrollToBottom()
        chatInputToolView.resetContent()
        dataCenter.sendMessageWith(text: text, imageUrl: imageUrl)
    }
    
    public func chatInputToolViewDidRequestStop(_ inputToolView: ChatInputToolView) {
        let event = MessageEvent(name: .stopGenerate)
        listContext.handlerChain.dispatch(event)
    }
}

extension ChatViewController {
    
    /// 处理键盘引起的 CollectionView 偏移调整
    /// - Parameters:
    ///   - newBottomInset: 新的底部间距
    ///   - shouldScrollToBottom: 是否需要滚动到底部
    ///   - completion: 完成回调（可选）
    func adjustCollectionViewForKeyboard(newBottomInset: CGFloat,
                                         shouldScrollToBottom: Bool,
                                         completion: (() -> Void)? = nil) {
        // 如果 newBottomInset 大于 0 且与当前底部间距不同
        if newBottomInset > 0,
           collectionView.contentInset.bottom != newBottomInset {
            
            // 批量更新 CollectionView 的 contentInset
            collectionView.performBatchUpdates({
                collectionView.contentInset.bottom = newBottomInset
                collectionView.verticalScrollIndicatorInsets.bottom = newBottomInset
            }, completion: { _ in
                completion?()
            })
            
            // iOS 13 以下版本需要手动调用 invalidateLayout
            if #available(iOS 13.0, *) {
            } else {
                collectionView.collectionViewLayout.invalidateLayout()
            }
            
            // 如果需要滚动到底部
            if shouldScrollToBottom {
                scrollToBottom()
            }
        }
    }
    
    func scrollToBottom(animation: Bool = true, completion: (() -> Void)? = nil) {
        let contentOffsetAtBottom = CGPoint(x: collectionView.contentOffset.x,
                                            y: chatLayout.collectionViewContentSize.height - collectionView.frame.height + collectionView.adjustedContentInset.bottom)
        
        guard contentOffsetAtBottom.y > collectionView.contentOffset.y else {
            completion?()
            return
        }
        
        if animation {
            let initialOffset = collectionView.contentOffset.y
            let delta = contentOffsetAtBottom.y - initialOffset
            if abs(delta) > collectionView.bounds.height {
                animator = ManualAnimator()
                animator?.animate(duration: TimeInterval(0.25), curve: .easeInOut) { [weak self] percentage in
                    guard let self else {
                        return
                    }
                    collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: initialOffset + (delta * percentage))
                    if percentage == 1.0 {
                        animator = nil
                        completion?()
                    }
                }
            } else {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.collectionView.setContentOffset(contentOffsetAtBottom, animated: true)
                }, completion: { _ in
                    completion?()
                })
            }
        } else {
            collectionView.setContentOffset(contentOffsetAtBottom, animated: false)
            completion?()
        }
    }
}
