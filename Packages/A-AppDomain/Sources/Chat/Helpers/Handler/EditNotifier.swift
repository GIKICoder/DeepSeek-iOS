//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/18.
//
import Foundation
import UIKit


final public class EditNotifier {
    private(set) var isEditing = false
    // 存储选中的消息
    private(set) var selectedItems: Set<ChatSection> = []
    
    private var delegates = NSHashTable<AnyObject>.weakObjects()
    
    // MARK: - Delegate Management
    
    func add(delegate: EditNotifierDelegate) {
        let exists = delegates.allObjects.contains { existingDelegate in
            return existingDelegate === delegate as AnyObject
        }
        
        if !exists {
            delegates.add(delegate)
        }
    }
    
    func remove(delegate: EditNotifierDelegate) {
        delegates.remove(delegate)
    }
    
    // MARK: - Editing State
    
    func setIsEditing(_ isEditing: Bool, duration: ActionDuration) {
        self.isEditing = isEditing
        if !isEditing {
            // 退出编辑模式时清空选择
            selectedItems.removeAll()
        }
        delegates.allObjects.compactMap { $0 as? EditNotifierDelegate }.forEach { delegate in
            delegate.setIsEditing(isEditing, duration: duration)
            delegate.didUpdateSelection(selectedItems)
        }
    }
    
    // MARK: - Selection Management
    
    /// 选择或取消选择
    func toggleSelection(for item: ChatSection) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
        notifyDelegates()
    }

    /// 选择
    func select(item: ChatSection) {
        selectedItems.insert(item)
        notifyDelegates()
    }
    
    /// 取消选择
    func deselect(item: ChatSection) {
        selectedItems.remove(item)
        notifyDelegates()
    }
    
    /// 全选
    func selectAll(items: [ChatSection]) {
        selectedItems = Set(items)
        notifyDelegates()
    }
    
    /// 取消全选
    func deselectAll() {
        selectedItems.removeAll()
        notifyDelegates()
    }
    
    /// 检查项目是否被选中
    func isSelected(_ item: ChatSection) -> Bool {
        return selectedItems.contains(item)
    }
    
    /// 获取选中项目数量
    var selectedCount: Int {
        return selectedItems.count
    }
    
    // MARK: - Private Methods
    
    private func notifyDelegates() {
        delegates.allObjects.compactMap { $0 as? EditNotifierDelegate }.forEach { delegate in
            delegate.setIsEditing(isEditing, duration: .notAnimated)
            delegate.didUpdateSelection(selectedItems)
        }
    }
}
