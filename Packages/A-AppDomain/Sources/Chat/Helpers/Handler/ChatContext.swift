//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/16.
//

import Foundation
import UIKit
import IGListKit

public class ChatContext {
    
    public weak var listAdapter: ListAdapter?
    public weak var controller: UIViewController?
    public weak var dataCenter: ChatDataCenter?
    public let editNotifier = EditNotifier()
    public let handlerChain = MessageHandlerChain()

    
    init(adapter: ListAdapter? = nil, controller: UIViewController? = nil, dataCenter: ChatDataCenter? = nil) {
        self.listAdapter = adapter
        self.controller = controller
        self.dataCenter = dataCenter
    }
}

