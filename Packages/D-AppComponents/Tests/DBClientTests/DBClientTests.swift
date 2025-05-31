//
//  DBClientTests.swift
//  AppComponents
//
//  Created by 巩柯 on 2025/6/1.
//

import Testing
import Foundation
@testable import DBClient
@testable import AppServices

@testable import WCDBSwift

class DBClientTests {
    
    private var dbClient: DBClient!
    private var testDatabasePath: String!
    
    @Test("Database initialization")
    func testDatabaseInitialization() async throws {
        // Given
        dbClient = DBClient.shared
        
        // When & Then
        #expect(throws: Never.self) {
            try dbClient.initialize()
        }
        
        // Cleanup
        dbClient.close()
    }
    
    @Test("Insert and retrieve chat message")
    func testInsertAndRetrieveChatMessage() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        var testMessage = ChatMessage()
        testMessage.id = "test-message-1"
        testMessage.channelId = "test-channel-1"
        testMessage.role = "user"
        testMessage.content = "Hello, world!"
        testMessage.model = "deepseek-chat"
        testMessage.status = "completed"
        
        // When
        let messageId = try dbClient.insertMessage(testMessage)
        let retrievedMessage = try dbClient.getMessage(messageId: testMessage.id)
        
        // Then
        #expect(messageId > 0)
        #expect(retrievedMessage != nil)
        #expect(retrievedMessage?.id == testMessage.id)
        #expect(retrievedMessage?.content == testMessage.content)
        #expect(retrievedMessage?.role == testMessage.role)
        #expect(retrievedMessage?.channelId == testMessage.channelId)
        
        // Cleanup
        try dbClient.deleteMessage(messageId: testMessage.id)
        dbClient.close()
    }
    
    @Test("Insert and retrieve multiple messages")
    func testInsertAndRetrieveMultipleMessages() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        let channelId = "test-channel-multi"
        var messages: [ChatMessage] = []
        
        for i in 1...5 {
            var message = ChatMessage()
            message.id = "test-message-\(i)"
            message.channelId = channelId
            message.role = i % 2 == 0 ? "assistant" : "user"
            message.content = "Message content \(i)"
            message.model = "deepseek-chat"
            message.status = "completed"
            messages.append(message)
        }
        
        // When
        try dbClient.insertMessages(messages)
        let retrievedMessages = try dbClient.getMessages(channelId: channelId)
        
        // Then
        #expect(retrievedMessages.count == 5)
        #expect(retrievedMessages.first?.content == "Message content 1")
        #expect(retrievedMessages.last?.content == "Message content 5")
        
        // Cleanup
        try dbClient.deleteMessagesInChannel(channelId: channelId)
        dbClient.close()
    }
    
    @Test("Update chat message")
    func testUpdateChatMessage() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        var testMessage = ChatMessage()
        testMessage.id = "test-message-update"
        testMessage.channelId = "test-channel-update"
        testMessage.role = "user"
        testMessage.content = "Original content"
        testMessage.model = "deepseek-chat"
        testMessage.status = "pending"
        
        // When
        _ = try dbClient.insertMessage(testMessage)
        
        testMessage.content = "Updated content"
        testMessage.status = "completed"
        try dbClient.updateMessage(testMessage)
        
        let retrievedMessage = try dbClient.getMessage(messageId: testMessage.id)
        
        // Then
        #expect(retrievedMessage?.content == "Updated content")
        #expect(retrievedMessage?.status == "completed")
        
        // Cleanup
        try dbClient.deleteMessage(messageId: testMessage.id)
        dbClient.close()
    }
    
    @Test("Search messages")
    func testSearchMessages() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        let channelId = "test-channel-search"
        var messages: [ChatMessage] = []
        
        var message1 = ChatMessage()
        message1.id = "search-1"
        message1.channelId = channelId
        message1.role = "user"
        message1.content = "I love programming in Swift"
        message1.model = "deepseek-chat"
        messages.append(message1)
        
        var message2 = ChatMessage()
        message2.id = "search-2"
        message2.channelId = channelId
        message2.role = "assistant"
        message2.content = "Python is also a great language"
        message2.model = "deepseek-chat"
        messages.append(message2)
        
        var message3 = ChatMessage()
        message3.id = "search-3"
        message3.channelId = channelId
        message3.role = "user"
        message3.content = "Swift programming is fun"
        message3.model = "deepseek-chat"
        messages.append(message3)
        
        // When
        try dbClient.insertMessages(messages)
        let swiftResults = try dbClient.searchMessages(channelId: channelId, query: "Swift", limit: nil)
        let allResults = try dbClient.searchMessages(channelId: nil, query: "programming", limit: nil)
        
        // Then
        #expect(swiftResults.count == 2)
        #expect(allResults.count >= 2) // At least the 2 messages we inserted
        
        // Cleanup
        try dbClient.deleteMessagesInChannel(channelId: channelId)
        dbClient.close()
    }
    
    @Test("Insert and retrieve chat channel")
    func testInsertAndRetrieveChatChannel() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        var testChannel = ChatChannel()
        testChannel.id = "test-channel-1"
        testChannel.title = "Test Channel"
        testChannel.agent = "deepseek-chat"
        testChannel.model = "deepseek-chat"
        testChannel.seq_id = 1
        testChannel.version = 1
        testChannel.title_type = "auto"
        testChannel.inserted_at = Date().timeIntervalSince1970
        testChannel.updated_at = Date().timeIntervalSince1970
        
        // When
        try dbClient.insertChannel(testChannel)
        let retrievedChannel = try dbClient.getChannel(channelId: testChannel.id)
        
        // Then
        #expect(retrievedChannel != nil)
        #expect(retrievedChannel?.id == testChannel.id)
        #expect(retrievedChannel?.title == testChannel.title)
        #expect(retrievedChannel?.agent == testChannel.agent)
        
        // Cleanup
        try dbClient.deleteChannel(channelId: testChannel.id)
        dbClient.close()
    }
    
    @Test("Get all channels")
    func testGetAllChannels() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        var channels: [ChatChannel] = []
        
        for i in 1...3 {
            var channel = ChatChannel()
            channel.id = "test-channel-all-\(i)"
            channel.title = "Test Channel \(i)"
            channel.agent = "deepseek-chat"
            channel.model = "deepseek-chat"
            channel.seq_id = i
            channel.version = 1
            channel.title_type = "auto"
            channel.inserted_at = Date().timeIntervalSince1970
            channel.updated_at = Date().timeIntervalSince1970
            channels.append(channel)
        }
        
        // When
        for channel in channels {
            try dbClient.insertChannel(channel)
        }
        
        let allChannels = try dbClient.getAllChannels(limit: nil, offset: nil)
        let limitedChannels = try dbClient.getAllChannels(limit: 2, offset: nil)
        
        // Then
        #expect(allChannels.count >= 3)
        #expect(limitedChannels.count == 2)
        
        // Cleanup
        for channel in channels {
            try dbClient.deleteChannel(channelId: channel.id)
        }
        dbClient.close()
    }
    
    @Test("Insert and retrieve session history")
    func testInsertAndRetrieveSessionHistory() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        var testHistory = ChatSessionHistory()
        testHistory.id = "test-history-1"
        testHistory.title = "Test Session"
        testHistory.agent = "deepseek-chat"
        testHistory.titleType = "auto"
        testHistory.version = 1
        testHistory.seqId = 1
        testHistory.currentMessageId = 0
        testHistory.insertedAt = Date().timeIntervalSince1970
        testHistory.updatedAt = Date().timeIntervalSince1970
        testHistory.message = "Hello from session history"
        
        // When
        try dbClient.insertSessionHistory(testHistory)
        let retrievedHistory = try dbClient.getSessionHistory(historyId: testHistory.id)
        
        // Then
        #expect(retrievedHistory != nil)
        #expect(retrievedHistory?.id == testHistory.id)
        #expect(retrievedHistory?.title == testHistory.title)
        #expect(retrievedHistory?.message == testHistory.message)
        
        // Cleanup
        try dbClient.deleteSessionHistory(historyId: testHistory.id)
        dbClient.close()
    }
    
    @Test("Search session history")
    func testSearchSessionHistory() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        var histories: [ChatSessionHistory] = []
        
        var history1 = ChatSessionHistory()
        history1.id = "search-history-1"
        history1.title = "Swift Development Tips"
        history1.agent = "deepseek-chat"
        history1.message = "Discussion about Swift programming"
        histories.append(history1)
        
        var history2 = ChatSessionHistory()
        history2.id = "search-history-2"
        history2.title = "Python Tutorial"
        history2.agent = "deepseek-chat"
        history2.message = "Learning Python basics"
        histories.append(history2)
        
        var history3 = ChatSessionHistory()
        history3.id = "search-history-3"
        history3.title = "iOS Development"
        history3.agent = "deepseek-chat"
        history3.message = "Swift for iOS apps"
        histories.append(history3)
        
        // When
        for history in histories {
            try dbClient.insertSessionHistory(history)
        }
        
        let swiftResults = try dbClient.searchSessionHistory(query: "Swift", limit: nil)
        let developmentResults = try dbClient.searchSessionHistory(query: "Development", limit: 1)
        
        // Then
        #expect(swiftResults.count == 2)
        #expect(developmentResults.count == 1)
        
        // Cleanup
        for history in histories {
            try dbClient.deleteSessionHistory(historyId: history.id)
        }
        dbClient.close()
    }
    
    @Test("Get message count")
    func testGetMessageCount() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        let channelId = "test-channel-count"
        var messages: [ChatMessage] = []
        
        for i in 1...7 {
            var message = ChatMessage()
            message.id = "count-message-\(i)"
            message.channelId = channelId
            message.role = "user"
            message.content = "Message \(i)"
            message.model = "deepseek-chat"
            messages.append(message)
        }
        
        // When
        try dbClient.insertMessages(messages)
        let messageCount = try dbClient.getMessageCount(channelId: channelId)
        
        // Then
        #expect(messageCount == 7)
        
        // Cleanup
        try dbClient.deleteMessagesInChannel(channelId: channelId)
        dbClient.close()
    }
    
    @Test("Get channel count")
    func testGetChannelCount() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        let initialCount = try dbClient.getChannelCount()
        
        var channels: [ChatChannel] = []
        for i in 1...4 {
            var channel = ChatChannel()
            channel.id = "count-channel-\(i)"
            channel.title = "Count Channel \(i)"
            channel.agent = "deepseek-chat"
            channel.model = "deepseek-chat"
            channels.append(channel)
        }
        
        // When
        for channel in channels {
            try dbClient.insertChannel(channel)
        }
        
        let finalCount = try dbClient.getChannelCount()
        
        // Then
        #expect(finalCount == initialCount + 4)
        
        // Cleanup
        for channel in channels {
            try dbClient.deleteChannel(channelId: channel.id)
        }
        dbClient.close()
    }
    
    @Test("Database maintenance operations")
    func testDatabaseMaintenance() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        // When & Then
        #expect(throws: Never.self) {
            try dbClient.vacuum()
        }
        
        #expect(throws: Never.self) {
            try dbClient.optimize()
        }
        
        let databaseSize = try dbClient.getDatabaseSize()
        #expect(databaseSize > 0)
        
        // Cleanup
        dbClient.close()
    }
    
    @Test("Database statistics")
    func testDatabaseStatistics() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        // Insert some test data
        var testChannel = ChatChannel()
        testChannel.id = "stats-channel"
        testChannel.title = "Statistics Test"
        testChannel.agent = "deepseek-chat"
        try dbClient.insertChannel(testChannel)
        
        var testMessage = ChatMessage()
        testMessage.id = "stats-message"
        testMessage.channelId = "stats-channel"
        testMessage.role = "user"
        testMessage.content = "Test message for stats"
        testMessage.model = "deepseek-chat"
        _ = try dbClient.insertMessage(testMessage)
        
        var testHistory = ChatSessionHistory()
        testHistory.id = "stats-history"
        testHistory.title = "Statistics History"
        testHistory.agent = "deepseek-chat"
        try dbClient.insertSessionHistory(testHistory)
        
        // When
        let stats = try dbClient.getDatabaseStats()
        
        // Then
        #expect(stats["messageCount"] as? Int ?? 0 >= 1)
        #expect(stats["channelCount"] as? Int ?? 0 >= 1)
        #expect(stats["historyCount"] as? Int ?? 0 >= 1)
        #expect(stats["databaseSize"] as? Int64 ?? 0 > 0)
        #expect(stats["databasePath"] != nil)
        
        // Cleanup
        try dbClient.deleteMessage(messageId: testMessage.id)
        try dbClient.deleteChannel(channelId: testChannel.id)
        try dbClient.deleteSessionHistory(historyId: testHistory.id)
        dbClient.close()
    }
    
    @Test("Export and import channel data")
    func testExportImportChannelData() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        let channelId = "export-import-channel"
        
        var testChannel = ChatChannel()
        testChannel.id = channelId
        testChannel.title = "Export Import Test"
        testChannel.agent = "deepseek-chat"
        testChannel.model = "deepseek-chat"
        
        var messages: [ChatMessage] = []
        for i in 1...3 {
            var message = ChatMessage()
            message.id = "export-message-\(i)"
            message.channelId = channelId
            message.role = i % 2 == 0 ? "assistant" : "user"
            message.content = "Export test message \(i)"
            message.model = "deepseek-chat"
            messages.append(message)
        }
        
        try dbClient.insertChannel(testChannel)
        try dbClient.insertMessages(messages)
        
        // When - Export
        let (exportedChannel, exportedMessages) = try dbClient.exportChannelData(channelId: channelId)
        
        // Clean up original data
        try dbClient.deleteChannel(channelId: channelId)
        
        // Import back
        guard let channelToImport = exportedChannel else {
            throw DBClientError.invalidData("No channel to import")
        }
        try dbClient.importChannelData(channel: channelToImport, messages: exportedMessages)
        
        // Then - Verify imported data
        let reimportedChannel = try dbClient.getChannel(channelId: channelId)
        let reimportedMessages = try dbClient.getMessages(channelId: channelId)
        
        #expect(reimportedChannel?.id == testChannel.id)
        #expect(reimportedChannel?.title == testChannel.title)
        #expect(reimportedMessages.count == 3)
        
        // Cleanup
        try dbClient.deleteChannel(channelId: channelId)
        dbClient.close()
    }
    
    @Test("Error handling - Database not initialized")
    func testErrorHandlingDatabaseNotInitialized() async throws {
        // Given
        dbClient = DBClient.shared
        // Note: Not calling initialize()
        
        var testMessage = ChatMessage()
        testMessage.id = "error-test-message"
        testMessage.channelId = "error-test-channel"
        testMessage.role = "user"
        testMessage.content = "This should fail"
        
        // When & Then
        #expect(throws: DBClientError.databaseNotInitialized) {
            _ = try dbClient.insertMessage(testMessage)
        }
        
        #expect(throws: DBClientError.databaseNotInitialized) {
            _ = try dbClient.getMessage(messageId: "non-existent")
        }
    }
    
    @Test("Get latest messages")
    func testGetLatestMessages() async throws {
        // Given
        dbClient = DBClient.shared
        try dbClient.initialize()
        
        let channelId = "latest-messages-channel"
        var messages: [ChatMessage] = []
        
        for i in 1...10 {
            var message = ChatMessage()
            message.id = "latest-message-\(i)"
            message.channelId = channelId
            message.role = "user"
            message.content = "Latest message \(i)"
            message.model = "deepseek-chat"
            message.inserted_at = Date().timeIntervalSince1970 + Double(i)
            messages.append(message)
        }
        
        // When
        try dbClient.insertMessages(messages)
        let latestMessages = try dbClient.getLatestMessages(channelId: channelId, count: 3)
        
        // Then
        #expect(latestMessages.count == 3)
        // Should be in chronological order (oldest first)
        #expect(latestMessages.first?.content.contains("8") == true)
        #expect(latestMessages.last?.content.contains("10") == true)
        
        // Cleanup
        try dbClient.deleteMessagesInChannel(channelId: channelId)
        dbClient.close()
    }
}
