//
//  DBClient.swift
//  AppComponents
//
//  Created by 巩柯 on 2025/6/1.
//

import Foundation
import WCDBSwift
import AppServices
import AppInfra
import Combine
import AppFoundation

// MARK: - DBClient Implementation

public final class DBClient /*: DBClientProtocol*/ {
    
    public static let shared = DBClient()
    
    internal var database: Database?
    internal let databaseQueue = DispatchQueue(label: "com.deepseek.dbclient", qos: .userInitiated)
    internal let databasePath: String
    internal var isInitialized = false
    
    // Table names
    internal let messagesTableName = "chat_messages"
    internal let channelsTableName = "chat_channels" 
    internal let historyTableName = "chat_session_history"
    
    private init() {
        // Create database in Documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        databasePath = documentsPath.appendingPathComponent("deepseek_chat.db").path
        AppLogger.shared.info("DBClient: Database path: \(databasePath)")
    }
    
    // MARK: - Database Lifecycle
    
    public func initialize() throws {
        try databaseQueue.sync {
            do {
                database = Database(at: databasePath)
                guard let db = database else {
                    throw DBClientError.databaseNotInitialized
                }
                
                // Create tables
                try createTables(in: db)
                
                // Perform migrations if needed
                try performMigrations(in: db)
                
                isInitialized = true
                AppLogger.shared.info("DBClient: Database initialized successfully")
                
            } catch {
                AppLogger.shared.error("DBClient: Failed to initialize database: \(error)")
                throw DBClientError.migrationFailed(error)
            }
        }
    }
    
    public func close() {
        databaseQueue.sync {
            database?.close()
            database = nil
            isInitialized = false
            AppLogger.shared.info("DBClient: Database closed")
        }
    }
    
    private func createTables(in database: Database) throws {
        // Create chat messages table
        try database.create(table: messagesTableName, of: DBChatMessage.self)
        
        // Create chat channels table
        try database.create(table: channelsTableName, of: DBChatChannel.self)
        
        // Create session history table
        try database.create(table: historyTableName, of: DBChatSessionHistory.self)
        
        AppLogger.shared.info("DBClient: Tables created successfully")
    }
    
    private func performMigrations(in database: Database) throws {
        // Future migration logic would go here
        // For now, just log that migrations are complete
        AppLogger.shared.info("DBClient: Database migrations completed")
    }
    
    internal func ensureInitialized() throws {
        guard isInitialized, database != nil else {
            throw DBClientError.databaseNotInitialized
        }
    }
    
    /*
    // MARK: - Chat Messages
    
    public func insertMessage(_ message: ChatMessage) throws -> Int {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbMessage = DBChatMessage(from: message)
                try db.insert(dbMessage, intoTable: messagesTableName)
                AppLogger.shared.debug("DBClient: Inserted message \(message.id) into channel \(message.channelId)")
                return dbMessage.message_id
            } catch {
                AppLogger.shared.error("DBClient: Failed to insert message: \(error)")
                throw DBClientError.insertFailed(error)
            }
        }
    }
    
    public func insertMessages(_ messages: [ChatMessage]) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbMessages = messages.map { DBChatMessage(from: $0) }
                try db.insert(dbMessages, intoTable: messagesTableName)
                AppLogger.shared.debug("DBClient: Inserted \(messages.count) messages")
            } catch {
                AppLogger.shared.error("DBClient: Failed to insert messages: \(error)")
                throw DBClientError.insertFailed(error)
            }
        }
    }
    
    public func updateMessage(_ message: ChatMessage) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbMessage = DBChatMessage(from: message)
                dbMessage.updated_timestamp = Date().timeIntervalSince1970
                
                try db.update(table: messagesTableName,
                            on: DBChatMessage.Properties.all,
                            with: dbMessage,
                            where: DBChatMessage.Properties.id == message.id)
                
                AppLogger.shared.debug("DBClient: Updated message \(message.id)")
            } catch {
                AppLogger.shared.error("DBClient: Failed to update message: \(error)")
                throw DBClientError.updateFailed(error)
            }
        }
    }
    
    public func deleteMessage(messageId: String) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                try db.delete(fromTable: messagesTableName,
                            where: DBChatMessage.Properties.id == messageId)
                
                AppLogger.shared.debug("DBClient: Deleted message \(messageId)")
            } catch {
                AppLogger.shared.error("DBClient: Failed to delete message: \(error)")
                throw DBClientError.deleteFailed(error)
            }
        }
    }
    
    public func getMessage(messageId: String) throws -> ChatMessage? {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbMessage: DBChatMessage? = try db.getObject(
                    fromTable: messagesTableName,
                    where: DBChatMessage.Properties.id == messageId
                )
                
                return dbMessage?.toChatMessage()
            } catch {
                AppLogger.shared.error("DBClient: Failed to get message: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    public func getMessages(channelId: String, limit: Int? = nil, offset: Int? = nil) throws -> [ChatMessage] {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                var select = db.prepareSelect(of: DBChatMessage.self, fromTable: messagesTableName)
                    .where(DBChatMessage.Properties.channelId == channelId)
                    .order(by: DBChatMessage.Properties.created_timestamp.asOrder(.ascending))
                
                if let limit = limit {
                    select = select.limit(limit)
                }
                
                if let offset = offset {
                    select = select.offset(offset)
                }
                
                let dbMessages: [DBChatMessage] = try select.allObjects()
                return dbMessages.map { $0.toChatMessage() }
            } catch {
                AppLogger.shared.error("DBClient: Failed to get messages: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    public func getLatestMessages(channelId: String, count: Int) throws -> [ChatMessage] {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbMessages: [DBChatMessage] = try db.getObjects(
                    fromTable: messagesTableName,
                    where: DBChatMessage.Properties.channelId == channelId,
                    orderBy: [DBChatMessage.Properties.created_timestamp],
                    //.asOrder(.descending)
                    limit: count
                )
                
                // Reverse to get chronological order
                return dbMessages.reversed().map { $0.toChatMessage() }
            } catch {
                AppLogger.shared.error("DBClient: Failed to get latest messages: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    public func searchMessages(channelId: String? = nil, query: String, limit: Int? = nil) throws -> [ChatMessage] {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                var condition = DBChatMessage.Properties.content.like("%\(query)%")
                
                if let channelId = channelId {
                    condition = condition && DBChatMessage.Properties.channelId == channelId
                }
                
                var select = db.prepareSelect(of: DBChatMessage.self, fromTable: messagesTableName)
                    .where(condition)
                    .order(by: DBChatMessage.Properties.created_timestamp)
                /// .asOrder(.descending)
                
                if let limit = limit {
                    select = select.limit(limit)
                }
                
                let dbMessages: [DBChatMessage] = try select.allObjects()
                return dbMessages.map { $0.toChatMessage() }
            } catch {
                AppLogger.shared.error("DBClient: Failed to search messages: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    // MARK: - Chat Channels
    
    public func insertChannel(_ channel: ChatChannel) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbChannel = DBChatChannel(from: channel)
                try db.insertOrReplace(dbChannel, intoTable: channelsTableName)
                AppLogger.shared.debug("DBClient: Inserted/updated channel \(channel.id)")
            } catch {
                AppLogger.shared.error("DBClient: Failed to insert channel: \(error)")
                throw DBClientError.insertFailed(error)
            }
        }
    }
    
    public func updateChannel(_ channel: ChatChannel) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbChannel = DBChatChannel(from: channel)
                dbChannel.updated_timestamp = Date().timeIntervalSince1970
                
                try db.update(table: channelsTableName,
                            on: DBChatChannel.Properties.all,
                            with: dbChannel,
                            where: DBChatChannel.Properties.id == channel.id)
                
                AppLogger.shared.debug("DBClient: Updated channel \(channel.id)")
            } catch {
                AppLogger.shared.error("DBClient: Failed to update channel: \(error)")
                throw DBClientError.updateFailed(error)
            }
        }
    }
    
    public func deleteChannel(channelId: String) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                // Delete channel
                try db.delete(fromTable: channelsTableName,
                            where: DBChatChannel.Properties.id == channelId)
                
                // Also delete all messages in this channel
                try db.delete(fromTable: messagesTableName,
                            where: DBChatMessage.Properties.channelId == channelId)
                
                AppLogger.shared.debug("DBClient: Deleted channel \(channelId) and its messages")
            } catch {
                AppLogger.shared.error("DBClient: Failed to delete channel: \(error)")
                throw DBClientError.deleteFailed(error)
            }
        }
    }
    
    public func getChannel(channelId: String) throws -> ChatChannel? {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbChannel: DBChatChannel? = try db.getObject(
                    fromTable: channelsTableName,
                    where: DBChatChannel.Properties.id == channelId
                )
                
                return dbChannel?.toChatChannel()
            } catch {
                AppLogger.shared.error("DBClient: Failed to get channel: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    public func getAllChannels(limit: Int? = nil, offset: Int? = nil) throws -> [ChatChannel] {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                var select = db.prepareSelect(of: DBChatChannel.self, fromTable: channelsTableName)
                    .order(by: DBChatChannel.Properties.updated_at)
//                    .asOrder(.descending)
                if let limit = limit {
                    select = select.limit(limit)
                }
                
                if let offset = offset {
                    select = select.offset(offset)
                }
                
                let dbChannels: [DBChatChannel] = try select.allObjects()
                return dbChannels.map { $0.toChatChannel() }
            } catch {
                AppLogger.shared.error("DBClient: Failed to get all channels: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    public func getRecentChannels(limit: Int) throws -> [ChatChannel] {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbChannels: [DBChatChannel] = try db.getObjects(
                    fromTable: channelsTableName,
                    orderBy: [DBChatChannel.Properties.updated_at],
                    limit: limit
                )
//                    .asOrder(.descending)
                return dbChannels.map { $0.toChatChannel() }
            } catch {
                AppLogger.shared.error("DBClient: Failed to get recent channels: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    // MARK: - Chat Session History
    
    public func insertSessionHistory(_ history: ChatSessionHistory) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbHistory = DBChatSessionHistory(from: history)
                try db.insertOrReplace(dbHistory, intoTable: historyTableName)
                AppLogger.shared.debug("DBClient: Inserted/updated session history \(history.id)")
            } catch {
                AppLogger.shared.error("DBClient: Failed to insert session history: \(error)")
                throw DBClientError.insertFailed(error)
            }
        }
    }
    
    public func updateSessionHistory(_ history: ChatSessionHistory) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbHistory = DBChatSessionHistory(from: history)
                dbHistory.updated_timestamp = Date().timeIntervalSince1970
                
                try db.update(table: historyTableName,
                            on: DBChatSessionHistory.Properties.all,
                            with: dbHistory,
                            where: DBChatSessionHistory.Properties.id == history.id)
                
                AppLogger.shared.debug("DBClient: Updated session history \(history.id)")
            } catch {
                AppLogger.shared.error("DBClient: Failed to update session history: \(error)")
                throw DBClientError.updateFailed(error)
            }
        }
    }
    
    public func deleteSessionHistory(historyId: String) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                try db.delete(fromTable: historyTableName,
                            where: DBChatSessionHistory.Properties.id == historyId)
                
                AppLogger.shared.debug("DBClient: Deleted session history \(historyId)")
            } catch {
                AppLogger.shared.error("DBClient: Failed to delete session history: \(error)")
                throw DBClientError.deleteFailed(error)
            }
        }
    }
    
    public func getSessionHistory(historyId: String) throws -> ChatSessionHistory? {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let dbHistory: DBChatSessionHistory? = try db.getObject(
                    fromTable: historyTableName,
                    where: DBChatSessionHistory.Properties.id == historyId
                )
                
                return dbHistory?.toChatSessionHistory()
            } catch {
                AppLogger.shared.error("DBClient: Failed to get session history: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    public func getAllSessionHistory(limit: Int? = nil, offset: Int? = nil) throws -> [ChatSessionHistory] {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                var select = db.prepareSelect(of: DBChatSessionHistory.self, fromTable: historyTableName)
                    .order(by: DBChatSessionHistory.Properties.updatedAt)
                /// .asOrder(.descending)
                
                if let limit = limit {
                    select = select.limit(limit)
                }
                
                if let offset = offset {
                    select = select.offset(offset)
                }
                
                let dbHistories: [DBChatSessionHistory] = try select.allObjects()
                return dbHistories.map { $0.toChatSessionHistory() }
            } catch {
                AppLogger.shared.error("DBClient: Failed to get all session history: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    public func searchSessionHistory(query: String, limit: Int? = nil) throws -> [ChatSessionHistory] {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let condition = DBChatSessionHistory.Properties.title.like("%\(query)%") ||
                               DBChatSessionHistory.Properties.message.like("%\(query)%")
                
                var select = try db.prepareSelect(of: DBChatSessionHistory.self, fromTable: historyTableName)
                    .where(condition)
                    .order(by: DBChatSessionHistory.Properties.updatedAt)
//                    .asOrder(.descending)
                
                if let limit = limit {
                    select = select.limit(limit)
                }
                
                let dbHistories: [DBChatSessionHistory] = try select.allObjects()
                return dbHistories.map { $0.toChatSessionHistory() }
            } catch {
                AppLogger.shared.error("DBClient: Failed to search session history: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    // MARK: - Batch Operations
    
    public func deleteMessagesInChannel(channelId: String) throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                try db.delete(fromTable: messagesTableName,
                            where: DBChatMessage.Properties.channelId == channelId)
                
                AppLogger.shared.debug("DBClient: Deleted all messages in channel \(channelId)")
            } catch {
                AppLogger.shared.error("DBClient: Failed to delete messages in channel: \(error)")
                throw DBClientError.deleteFailed(error)
            }
        }
    }
    
    public func getMessageCount(channelId: String) throws -> Int {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let count: Int = try db.getValue(
                    on: Column.all().count(),
                    fromTable: messagesTableName,
                    where: DBChatMessage.Properties.channelId == channelId
                ) ?? 0
                
                return count
            } catch {
                AppLogger.shared.error("DBClient: Failed to get message count: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    public func getChannelCount() throws -> Int {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let count: Int = try db.getValue(
                    on: Column.all().count(),
                    fromTable: channelsTableName
                ) ?? 0
                
                return count
            } catch {
                AppLogger.shared.error("DBClient: Failed to get channel count: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    // MARK: - Database Maintenance
    
    public func vacuum() throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                _ = try db.vacuum()
                AppLogger.shared.info("DBClient: Database vacuum completed")
            } catch {
                AppLogger.shared.error("DBClient: Failed to vacuum database: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
    
    public func optimize() throws {
        try ensureInitialized()
        
        try databaseQueue.sync {
            guard let db = database else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                // Analyze tables for better query optimization
                try db.execute(StatementAnalyze())
                AppLogger.shared.info("DBClient: Database optimization completed")
            } catch {
                AppLogger.shared.error("DBClient: Failed to optimize database: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
     */
    
    public func getDatabaseSize() throws -> Int64 {
        try ensureInitialized()
        
        return try databaseQueue.sync {
            guard database != nil else {
                throw DBClientError.databaseNotInitialized
            }
            
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: databasePath)
                let fileSize = fileAttributes[.size] as? Int64 ?? 0
                return fileSize
            } catch {
                AppLogger.shared.error("DBClient: Failed to get database size: \(error)")
                throw DBClientError.queryFailed(error)
            }
        }
    }
}
