//
//  DBClientProtocol.swift
//  AppComponents
//
//  Created by 巩柯 on 2025/6/1.
//

import Foundation
import AppServices

// MARK: - DBClientProtocol

public protocol DBClientProtocol: AnyObject {
    // Database lifecycle
    func initialize() throws
    func close()
    
    // Chat Messages
    func insertMessage(_ message: ChatMessage) throws -> Int
    func insertMessages(_ messages: [ChatMessage]) throws
    func updateMessage(_ message: ChatMessage) throws
    func deleteMessage(messageId: String) throws
    func getMessage(messageId: String) throws -> ChatMessage?
    func getMessages(channelId: String, limit: Int?, offset: Int?) throws -> [ChatMessage]
    func getLatestMessages(channelId: String, count: Int) throws -> [ChatMessage]
    func searchMessages(channelId: String?, query: String, limit: Int?) throws -> [ChatMessage]
    
    // Chat Channels
    func insertChannel(_ channel: ChatChannel) throws
    func updateChannel(_ channel: ChatChannel) throws
    func deleteChannel(channelId: String) throws
    func getChannel(channelId: String) throws -> ChatChannel?
    func getAllChannels(limit: Int?, offset: Int?) throws -> [ChatChannel]
    func getRecentChannels(limit: Int) throws -> [ChatChannel]
    
    // Chat Session History
    func insertSessionHistory(_ history: ChatSessionHistory) throws
    func updateSessionHistory(_ history: ChatSessionHistory) throws
    func deleteSessionHistory(historyId: String) throws
    func getSessionHistory(historyId: String) throws -> ChatSessionHistory?
    func getAllSessionHistory(limit: Int?, offset: Int?) throws -> [ChatSessionHistory]
    func searchSessionHistory(query: String, limit: Int?) throws -> [ChatSessionHistory]
    
    // Batch operations
    func deleteMessagesInChannel(channelId: String) throws
    func getMessageCount(channelId: String) throws -> Int
    func getChannelCount() throws -> Int
    
    // Database maintenance
    func vacuum() throws
    func optimize() throws
    func getDatabaseSize() throws -> Int64
}
