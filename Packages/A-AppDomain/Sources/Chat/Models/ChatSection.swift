//
//  ChatSection.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/11.
//

import UIKit
import AppFoundation
import AppServices
import IGListKit
import IGListDiffKit
import IGListSwiftKit


public class ChatSection: NSObject {
    public let id: String
    public let message: ChatMessage
    public var messageLayouts: [ChatMessageLayout]
    public var background: ChatSectionBackground
    
    /// 通过 ChatMessage 初始化 ChatSection，默认 id 使用 messageId
    public init(message: ChatMessage,
                background: ChatSectionBackground? = nil,
                messageLayouts: [ChatMessageLayout] = [],
                id: String? = nil) {
        self.id = id ?? message.messageId
        self.message = message
        self.background = background ?? ChatSectionBackground(message: message)
        self.messageLayouts = messageLayouts
    }
    
    /// 支持自定义 id 的初始化方法
    public init(id: String,
                message: ChatMessage,
                background: ChatSectionBackground? = nil,
                messageLayouts: [ChatMessageLayout] = []) {
        self.id = id
        self.message = message
        self.background = background ?? ChatSectionBackground(message: message)
        self.messageLayouts = messageLayouts
    }
    
    /// 添加单个布局
    public func addLayout(_ layout: ChatMessageLayout) {
        messageLayouts.append(layout)
    }
    
    /// 添加多个布局
    public func addLayouts(_ layouts: [ChatMessageLayout]) {
        messageLayouts.append(contentsOf: layouts)
    }
}

extension ChatSection: ListDiffable {
    
    // MARK: - ListDiffable
    
    public func diffIdentifier() -> any NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: (any ListDiffable)?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? ChatSection else { return false }
        return id == object.id
        && background == object.background
        && messageLayouts == object.messageLayouts
    }
}

public class ChatSectionBackground: NSObject {
    
    public let id: String
    public var visibilityMode: Bool
    public var backgroundInsets: UIEdgeInsets
    public var backgroundImage: UIImage
    
    /// 通过 ChatMessage 初始化 SectionBackground
    public init(message: ChatMessage,
                visibilityMode: Bool = false,
                backgroundInsets: UIEdgeInsets = .zero,
                backgroundImage: UIImage = UIImage()) {
        self.id = message.messageId
        self.visibilityMode = visibilityMode
        self.backgroundInsets = backgroundInsets
        self.backgroundImage = backgroundImage
    }
    
    /// 支持自定义 id 的初始化方法
    public init(id: String,
                visibilityMode: Bool = false,
                backgroundInsets: UIEdgeInsets = .zero,
                backgroundImage: UIImage = UIImage()) {
        self.id = id
        self.visibilityMode = visibilityMode
        self.backgroundInsets = backgroundInsets
        self.backgroundImage = backgroundImage
    }
    
}



/// The public boxing API is provided by a protocol extension of `ListIdentifiable`.
public final class ChatSectionBox<Value: ListIdentifiable>: NSObject, ListDiffable {
    let value: Value

    init(value: Value) {
        self.value = value
    }

    // MARK: - ListDiffable
    public func diffIdentifier() -> NSObjectProtocol {
        return value.diffIdentifier
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? ChatSectionBox<Value> else {
            return false
        }
        return value == other.value
    }
}

