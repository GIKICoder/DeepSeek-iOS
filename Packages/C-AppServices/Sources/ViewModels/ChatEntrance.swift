//
//  File.swift
//  AppServices
//
//  Created by GIKI on 2025/2/13.
//

import Foundation


// MARK: - ChatEntrance
public class ChatEntrance {
    public var channel: ChatChannel?
    public var source: String?
    public var model: String = "Standard"
    public var templateId: String?
    public var fileURL: URL?
    public var uploadFileURL: String?
    
    public init(channel: ChatChannel? = nil, source: String? = nil) {
        self.channel = channel
        self.source = source
    }
}
