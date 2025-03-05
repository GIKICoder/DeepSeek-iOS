//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/10.
//

import Foundation
import UIKit
import AppInfra
import AppFoundation
import IQListKit
import AppServices

public extension ChatViewController {
    
    func initializeDatas() {
        dataCenter.initializeData()
    }
    
    func loadMoreDatas() {
        dataCenter.loadMoreMessages()
    }
    
    func setupBinding() {
        bindSectionsStream()
        bindSendStateStream()
    }
    
    private func bindSectionsStream() {
        dataCenter.sectionsStream
            .receive(on: RunLoop.main)
            .debounce(for: .milliseconds(10), scheduler: RunLoop.main)
            .sink { [weak self] sectionsState in
                guard let self = self else { return }
                self.setRefreshState()
                
                var scrollToBottom = false
                switch sectionsState.state {
                case .loaded(let initial):
                    scrollToBottom = initial
//                    self.performUpdates(scrollToBottom: scrollToBottom)
                    break
                case .updated(let sections):
//                    self.reloadDatas(sections)
                    break
                case .error(let error):
                    AppHUD.showToast(error.localizedDescription)
                    break
                default: break
                }
                self.performUpdates(scrollToBottom: scrollToBottom)
            }
            .store(in: &cancellables)
    }
    
    func bindSendStateStream() {
        dataCenter.sendStateStream
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .normal:
                    logUI("默认状态")
                    self.chatInputToolView.configureGenerateState(false)
                case .generating:
                    logUI("生成中")
                    self.chatInputToolView.configureGenerateState(true)
                case .finished:
                    logUI("生成完成")
                    self.chatInputToolView.configureGenerateState(false)
                case .error(let error):
                    logUI("生成错误: \(error)")
                    self.chatInputToolView.configureGenerateState(false)
                }
            }
            .store(in: &cancellables)

    }
    
    func performUpdates(scrollToBottom:Bool = false) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        adapter.performUpdates(animated: false) {[weak self] finish in
            if scrollToBottom {
                self?.scrollToBottom(animation: false)
            }
            CATransaction.commit()
        }
    }
    
    func reloadDatas(_ sections:[ChatSection]) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        adapter.reloadObjects(sections)
        CATransaction.commit()
    }
    
    func setRefreshState() {
        if dataCenter.hasMoreData {
            refreshHeader?.endRefreshing()
        } else {
            refreshHeader?.endRefreshingWithNoMoreData()
        }
    }
}

