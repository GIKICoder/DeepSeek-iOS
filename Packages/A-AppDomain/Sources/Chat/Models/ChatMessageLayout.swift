//
//  ChatMessageLayout.swift
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

public class ChatMessageLayout: NSObject {
    
    public let identifier: String
    public let message: ChatMessage
    
    open var itemSize: CGSize = .zero
    open var cellType: ChatContentCell.Type = ChatContentCell.self
    open var edgeInsets: UIEdgeInsets = .zero
    
    init(identifier: String = UUID().uuidString, message: ChatMessage) {
        self.identifier = identifier
        self.message = message
        super.init()
    }
    
}


extension ChatMessageLayout: ListDiffable {
    // MARK: - ListDiffable
    public func diffIdentifier() -> NSObjectProtocol {
        return identifier + message.messageId as NSString
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? ChatMessageLayout else {
            return false
        }
        return identifier == other.identifier
        && message.messageId == other.message.messageId
    }
}
