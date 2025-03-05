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
        if let fileURL = dataCenter.entrance.fileURL {
            uploadFile(fileURL)
        }
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

extension ChatViewController {
    
    private func uploadFile(_ fileURL:URL) {
        
        AppHUD.progress(0.1)
        Task {
            // 调用 ChatUploadCenter 上传图片并获取 uploadID
            let id = await ChatUploadCenter.shared.uploadFile(with: fileURL)
            
            // 更新 UI 和保存 uploadID，需要在主线程上执行
            await MainActor.run {
                self.currentUploadID = id
            }
            
            // 监听上传进度
            await ChatUploadCenter.shared.uploadProgressStream
                .filter { [weak self] (uploadID, _) in
                    return uploadID == self?.currentUploadID
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (_, progress) in
                    guard let self else { return }
                    AppHUD.progress(progress)
                }
                .store(in: &cancellables)
            
            // 监听上传完成
            await ChatUploadCenter.shared.uploadCompletionStream
                .filter { [weak self] (uploadID, _) in
                    return uploadID == self?.currentUploadID
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (_, result) in
                    guard let self else { return }
                    switch result {
                    case .success(let upload):
                        AppHUD.succeed("File Upload Succeed!")
                        self.createFileChat(upload: upload)
                        self.dataCenter.entrance.uploadFileURL = upload.uploadUrl
                    case .failure(let error):
                        AppHUD.failed(error.localizedDescription)
                    }
                    self.currentUploadID = nil
                }
                .store(in: &cancellables)
        }
        
    }
    
    // MARK: - 取消上传
    private func cancelUpload() {
        Task {
            guard let id = currentUploadID else { return }
            await ChatUploadCenter.shared.cancelUpload(with: id)
            currentUploadID = nil
        }
    }
    
    private func createFileChat(upload:ChatUploadResult) {
        Task {
            do {
                let params = CreateFileChannelParams(model:dataCenter.entrance.model,
                                                     md5:upload.md5 ?? "",
                                                     fileName:upload.fileName ?? "",
                                                     fileContentType: upload.fileContentType ?? "",
                                                     uploadTime: upload.uploadTime ?? 0)
                let channel = try await dataCenter.createFileChannel(params: params)
                logUI("file create chat success: \(channel)")
            } catch {
                logError("file create chat : \(error)")
            }
            
        }
    }
}

//public let md5: String
//public let fileName: String
//public let fileContentType: String
//public let uploadTime: Int
