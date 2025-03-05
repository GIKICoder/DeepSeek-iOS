//
//  DefaultMessageHandler.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/26.
//

import UIKit
import AppFoundation
import AppInfra
import AppServices

class DefaultMessageHandler: MessageHandler {
    
    public weak var dataCenter: ChatDataCenter?
    public weak var controller: ChatViewController?
    
    
    func handle(_ event: MessageEvent) -> HandlerResult {
        switch event.name {
        case .tap:
            return handleTap(event)
        case .longPress:
            return handleLongPress(event)
        case .regen:
            return handleRegen(event)
        case .stopGenerate:
            return handleStopGenerate(event)
        default:
            return .unhandled
        }
    }
    
    // MARK: - Handle Method
    
    private func handleTap(_ event: MessageEvent) -> HandlerResult {
        
        if let editNotifier = controller?.listContext.editNotifier,
           editNotifier.isEditing {
            return handleEditedTap(event)
        }
        if let qalayout = event.layout as? ChatQaMessageLayout {
            controller?.scrollToBottom()
            dataCenter?.sendMessageWith(text: qalayout.qaMessage,imageUrl: nil)
            return .handled
        }
        return .unhandled
    }
    
    private func handleEditedTap(_ event: MessageEvent) -> HandlerResult {
        if let editNotifier = controller?.listContext.editNotifier,
        let section = event.section {
            editNotifier.toggleSelection(for: section)
        }
        return .handled
    }
    
    private func handleLongPress(_ event: MessageEvent) -> HandlerResult {
        // 处理长按事件
        return .handled
    }
    
    private func handleRegen(_ event: MessageEvent) -> HandlerResult {
        
        guard let section = event.section else { return .unhandled }
        dataCenter?.regenMessage(section: section)
        return .handled
    }
    
    // MARK: - StopGenerate
    
    private func handleStopGenerate(_ event:MessageEvent) -> HandlerResult {
        dataCenter?.stopMessageGenerate()
        return .handled
    }
}
