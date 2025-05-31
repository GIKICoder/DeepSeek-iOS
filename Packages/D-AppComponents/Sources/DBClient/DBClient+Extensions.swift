//
//  DBClient+Extensions.swift
//  AppComponents
//
//  Created by 巩柯 on 2025/6/1.
//

import Foundation
import WCDBSwift
import AppServices
import AppInfra
import AppFoundation

// MARK: - DBClient Extensions

public extension DBClient {
    /*
    /// Get database statistics
    func getDatabaseStats() throws -> [String: Any] {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
//                let messageCount: Int = try db.getValue(on: Column.all().count(), fromTable: messagesTableName) ?? 0
                let messageCount: Int = 0
                let channelCount: Int = 0 // try db.getValue(on: Column.all().count(), fromTable: channelsTableName) ?? 0
                let historyCount: Int = 0 // try db.getValue(on: Column.all().count(), fromTable: historyTableName) ?? 0
                let databaseSize = try getDatabaseSize()
                
                return [
                    "messageCount": messageCount,
                    "channelCount": channelCount,
                    "historyCount": historyCount,
                    "databaseSize": databaseSize,
                    "databasePath": databasePath
                ]
            } catch {
                AppLogger.shared.error("DBClient: Failed to get database stats: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    /// Export data for backup
    func exportChannelData(channelId: String) throws -> (ChatChannel?, [ChatMessage]) {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            let channel = try getChannel(channelId: channelId)
            let messages = try getMessages(channelId: channelId)
            return (channel, messages)
        }
    }
    
    /// Import data from backup
    func importChannelData(channel: ChatChannel, messages: [ChatMessage]) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            try db.run(transaction: {_ in 
                try self.insertChannel(channel)
                try self.insertMessages(messages)
            })
            
            AppLogger.shared.info("DBClient: Imported channel \(channel.id) with \(messages.count) messages")
        }
    }
     */
}
