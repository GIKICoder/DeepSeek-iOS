//
//  DBModelTests.swift
//  AppComponents
//
//  Created by GIKI on 2025/6/1.
//

import Testing
import Foundation
@testable import DBClient
@testable import AppServices

class DBModelTests {
    
    @Test("DBChatMessage conversion from ChatMessage")
    func testDBChatMessageConversionFromChatMessage() async throws {
        // Given
        var chatMessage = ChatMessage()
        chatMessage.id = "test-msg-1"
        chatMessage.channelId = "test-channel-1"
        chatMessage.role = "user"
        chatMessage.content = "Hello, world!"
        chatMessage.model = "deepseek-chat"
        chatMessage.status = "completed"
        chatMessage.thinking_enabled = true
        chatMessage.thinking_content = "Let me think..."
        chatMessage.thinking_elapsed_secs = 2.5
        chatMessage.ban_edit = false
        chatMessage.ban_regenerate = false
        chatMessage.accumulated_token_usage = 100
        chatMessage.files = ["file1.txt", "file2.pdf"]
        chatMessage.tips = ["tip1", "tip2"]
        chatMessage.search_enabled = true
        chatMessage.search_status = "completed"
        chatMessage.search_results = ["result1", "result2"]
        chatMessage.imageUrls = ["image1.jpg", "image2.png"]
        chatMessage.qaMsg = ["qa1", "qa2"]
        chatMessage.inserted_at = Date().timeIntervalSince1970
        
        // When
        let dbMessage = DBChatMessage(from: chatMessage)
        
        // Then
        #expect(dbMessage.id == chatMessage.id)
        #expect(dbMessage.channelId == chatMessage.channelId)
        #expect(dbMessage.role == chatMessage.role)
        #expect(dbMessage.content == chatMessage.content)
        #expect(dbMessage.model == chatMessage.model)
        #expect(dbMessage.status == chatMessage.status)
        #expect(dbMessage.thinking_enabled == chatMessage.thinking_enabled)
        #expect(dbMessage.thinking_content == chatMessage.thinking_content)
        #expect(dbMessage.thinking_elapsed_secs == chatMessage.thinking_elapsed_secs)
        #expect(dbMessage.ban_edit == chatMessage.ban_edit)
        #expect(dbMessage.ban_regenerate == chatMessage.ban_regenerate)
        #expect(dbMessage.accumulated_token_usage == chatMessage.accumulated_token_usage)
        #expect(dbMessage.search_enabled == chatMessage.search_enabled)
        #expect(dbMessage.search_status == chatMessage.search_status)
        #expect(dbMessage.inserted_at == chatMessage.inserted_at)
        #expect(dbMessage.created_timestamp > 0)
        #expect(dbMessage.updated_timestamp > 0)
        
        // Check JSON arrays
        #expect(dbMessage.files.contains("file1.txt"))
        #expect(dbMessage.tips.contains("tip1"))
        #expect(dbMessage.search_results.contains("result1"))
        #expect(dbMessage.imageUrls.contains("image1.jpg"))
        #expect(dbMessage.qaMsg.contains("qa1"))
    }
    
    @Test("DBChatMessage conversion to ChatMessage")
    func testDBChatMessageConversionToChatMessage() async throws {
        // Given
        let dbMessage = DBChatMessage()
        dbMessage.message_id = 123
        dbMessage.parent_id = 456
        dbMessage.id = "test-msg-2"
        dbMessage.channelId = "test-channel-2"
        dbMessage.role = "assistant"
        dbMessage.content = "How can I help you?"
        dbMessage.model = "deepseek-chat"
        dbMessage.status = "completed"
        dbMessage.thinking_enabled = false
        dbMessage.thinking_content = ""
        dbMessage.thinking_elapsed_secs = nil
        dbMessage.ban_edit = true
        dbMessage.ban_regenerate = true
        dbMessage.accumulated_token_usage = 250
        dbMessage.files = "[\"doc1.pdf\", \"doc2.txt\"]"
        dbMessage.tips = "[\"tip1\", \"tip2\", \"tip3\"]"
        dbMessage.search_enabled = false
        dbMessage.search_status = "disabled"
        dbMessage.search_results = "[\"search1\", \"search2\"]"
        dbMessage.imageUrls = "[\"img1.jpg\"]"
        dbMessage.qaMsg = "[\"question1\", \"answer1\"]"
        dbMessage.inserted_at = Date().timeIntervalSince1970
        
        // When
        let chatMessage = dbMessage.toChatMessage()
        
        // Then
        #expect(chatMessage.message_id == dbMessage.message_id)
        #expect(chatMessage.parent_id == dbMessage.parent_id)
        #expect(chatMessage.id == dbMessage.id)
        #expect(chatMessage.channelId == dbMessage.channelId)
        #expect(chatMessage.role == dbMessage.role)
        #expect(chatMessage.content == dbMessage.content)
        #expect(chatMessage.model == dbMessage.model)
        #expect(chatMessage.status == dbMessage.status)
        #expect(chatMessage.thinking_enabled == dbMessage.thinking_enabled)
        #expect(chatMessage.thinking_content == dbMessage.thinking_content)
        #expect(chatMessage.thinking_elapsed_secs == dbMessage.thinking_elapsed_secs)
        #expect(chatMessage.ban_edit == dbMessage.ban_edit)
        #expect(chatMessage.ban_regenerate == dbMessage.ban_regenerate)
        #expect(chatMessage.accumulated_token_usage == dbMessage.accumulated_token_usage)
        #expect(chatMessage.search_enabled == dbMessage.search_enabled)
        #expect(chatMessage.search_status == dbMessage.search_status)
        #expect(chatMessage.inserted_at == dbMessage.inserted_at)
        
        // Check arrays conversion
        #expect(chatMessage.files.count == 2)
        #expect(chatMessage.files.contains("doc1.pdf"))
        #expect(chatMessage.tips.count == 3)
        #expect(chatMessage.tips.contains("tip1"))
        #expect(chatMessage.search_results.count == 2)
        #expect(chatMessage.imageUrls.count == 1)
        #expect(chatMessage.qaMsg.count == 2)
    }
    
    @Test("DBChatChannel conversion from ChatChannel")
    func testDBChatChannelConversionFromChatChannel() async throws {
        // Given
        var chatChannel = ChatChannel()
        chatChannel.id = "test-channel-1"
        chatChannel.seq_id = 42
        chatChannel.agent = "deepseek-chat"
        chatChannel.character = "helpful"
        chatChannel.title = "Test Conversation"
        chatChannel.title_type = "auto"
        chatChannel.version = 1
        chatChannel.current_message_id = 100
        chatChannel.inserted_at = Date().timeIntervalSince1970
        chatChannel.updated_at = Date().timeIntervalSince1970
        chatChannel.model = "deepseek-chat"
        
        // When
        let dbChannel = DBChatChannel(from: chatChannel)
        
        // Then
        #expect(dbChannel.id == chatChannel.id)
        #expect(dbChannel.seq_id == chatChannel.seq_id)
        #expect(dbChannel.agent == chatChannel.agent)
        #expect(dbChannel.character == chatChannel.character)
        #expect(dbChannel.title == chatChannel.title)
        #expect(dbChannel.title_type == chatChannel.title_type)
        #expect(dbChannel.version == chatChannel.version)
        #expect(dbChannel.current_message_id == chatChannel.current_message_id)
        #expect(dbChannel.inserted_at == chatChannel.inserted_at)
        #expect(dbChannel.updated_at == chatChannel.updated_at)
        #expect(dbChannel.model == chatChannel.model)
        #expect(dbChannel.created_timestamp > 0)
        #expect(dbChannel.updated_timestamp > 0)
    }
    
    @Test("DBChatChannel conversion to ChatChannel")
    func testDBChatChannelConversionToChatChannel() async throws {
        // Given
        let dbChannel = DBChatChannel()
        dbChannel.channel_pk = 789
        dbChannel.id = "test-channel-2"
        dbChannel.seq_id = 84
        dbChannel.agent = "deepseek-coder"
        dbChannel.character = "coding-assistant"
        dbChannel.title = "Coding Help"
        dbChannel.title_type = "manual"
        dbChannel.version = 2
        dbChannel.current_message_id = 200
        dbChannel.inserted_at = Date().timeIntervalSince1970 - 3600
        dbChannel.updated_at = Date().timeIntervalSince1970
        dbChannel.model = "deepseek-coder"
        
        // When
        let chatChannel = dbChannel.toChatChannel()
        
        // Then
        #expect(chatChannel.id == dbChannel.id)
        #expect(chatChannel.seq_id == dbChannel.seq_id)
        #expect(chatChannel.agent == dbChannel.agent)
        #expect(chatChannel.character == dbChannel.character)
        #expect(chatChannel.title == dbChannel.title)
        #expect(chatChannel.title_type == dbChannel.title_type)
        #expect(chatChannel.version == dbChannel.version)
        #expect(chatChannel.current_message_id == dbChannel.current_message_id)
        #expect(chatChannel.inserted_at == dbChannel.inserted_at)
        #expect(chatChannel.updated_at == dbChannel.updated_at)
        #expect(chatChannel.model == dbChannel.model)
    }
    
    @Test("DBChatSessionHistory conversion from ChatSessionHistory")
    func testDBChatSessionHistoryConversionFromChatSessionHistory() async throws {
        // Given
        var sessionHistory = ChatSessionHistory()
        sessionHistory.id = "test-history-1"
        sessionHistory.seqId = 1
        sessionHistory.agent = "deepseek-chat"
        sessionHistory.title = "Previous Conversation"
        sessionHistory.titleType = "auto"
        sessionHistory.version = 1
        sessionHistory.currentMessageId = 50
        sessionHistory.insertedAt = Date().timeIntervalSince1970 - 7200
        sessionHistory.updatedAt = Date().timeIntervalSince1970 - 3600
        sessionHistory.character = "helpful"
        sessionHistory.message = "This was a great conversation about AI"
        
        // When
        let dbHistory = DBChatSessionHistory(from: sessionHistory)
        
        // Then
        #expect(dbHistory.id == sessionHistory.id)
        #expect(dbHistory.seqId == sessionHistory.seqId)
        #expect(dbHistory.agent == sessionHistory.agent)
        #expect(dbHistory.title == sessionHistory.title)
        #expect(dbHistory.titleType == sessionHistory.titleType)
        #expect(dbHistory.version == sessionHistory.version)
        #expect(dbHistory.currentMessageId == sessionHistory.currentMessageId)
        #expect(dbHistory.insertedAt == sessionHistory.insertedAt)
        #expect(dbHistory.updatedAt == sessionHistory.updatedAt)
        #expect(dbHistory.character == sessionHistory.character)
        #expect(dbHistory.message == sessionHistory.message)
        #expect(dbHistory.created_timestamp > 0)
        #expect(dbHistory.updated_timestamp > 0)
    }
    
    @Test("DBChatSessionHistory conversion to ChatSessionHistory")
    func testDBChatSessionHistoryConversionToChatSessionHistory() async throws {
        // Given
        let dbHistory = DBChatSessionHistory()
        dbHistory.history_pk = 999
        dbHistory.id = "test-history-2"
        dbHistory.seqId = 2
        dbHistory.agent = "deepseek-coder"
        dbHistory.title = "Coding Session"
        dbHistory.titleType = "manual"
        dbHistory.version = 3
        dbHistory.currentMessageId = 75
        dbHistory.insertedAt = Date().timeIntervalSince1970 - 14400
        dbHistory.updatedAt = Date().timeIntervalSince1970 - 1800
        dbHistory.character = "coding-expert"
        dbHistory.message = "We discussed advanced Swift patterns"
        
        // When
        let sessionHistory = dbHistory.toChatSessionHistory()
        
        // Then
        #expect(sessionHistory.id == dbHistory.id)
        #expect(sessionHistory.seqId == dbHistory.seqId)
        #expect(sessionHistory.agent == dbHistory.agent)
        #expect(sessionHistory.title == dbHistory.title)
        #expect(sessionHistory.titleType == dbHistory.titleType)
        #expect(sessionHistory.version == dbHistory.version)
        #expect(sessionHistory.currentMessageId == dbHistory.currentMessageId)
        #expect(sessionHistory.insertedAt == dbHistory.insertedAt)
        #expect(sessionHistory.updatedAt == dbHistory.updatedAt)
        #expect(sessionHistory.character == dbHistory.character)
        #expect(sessionHistory.message == dbHistory.message)
    }
    
    @Test("DBChatMessage JSON array conversion edge cases")
    func testDBChatMessageJSONArrayEdgeCases() async throws {
        // Given - ChatMessage with empty arrays
        var chatMessage = ChatMessage()
        chatMessage.id = "edge-case-msg"
        chatMessage.channelId = "edge-case-channel"
        chatMessage.role = "user"
        chatMessage.content = "Test edge cases"
        chatMessage.files = []
        chatMessage.tips = []
        chatMessage.search_results = []
        chatMessage.imageUrls = []
        chatMessage.qaMsg = []
        
        // When
        let dbMessage = DBChatMessage(from: chatMessage)
        let convertedBack = dbMessage.toChatMessage()
        
        // Then
        #expect(dbMessage.files == "[]")
        #expect(dbMessage.tips == "[]")
        #expect(dbMessage.search_results == "[]")
        #expect(dbMessage.imageUrls == "[]")
        #expect(dbMessage.qaMsg == "[]")
        
        #expect(convertedBack.files.isEmpty)
        #expect(convertedBack.tips.isEmpty)
        #expect(convertedBack.search_results.isEmpty)
        #expect(convertedBack.imageUrls.isEmpty)
        #expect(convertedBack.qaMsg.isEmpty)
    }
    
    @Test("DBChatMessage with invalid JSON handling")
    func testDBChatMessageInvalidJSONHandling() async throws {
        // Given - DBChatMessage with invalid JSON strings
        let dbMessage = DBChatMessage()
        dbMessage.id = "invalid-json-msg"
        dbMessage.channelId = "invalid-json-channel"
        dbMessage.role = "user"
        dbMessage.content = "Test invalid JSON"
        dbMessage.files = "invalid json string"
        dbMessage.tips = "{ not an array }"
        dbMessage.search_results = "[]" // Valid JSON
        dbMessage.imageUrls = "invalid"
        dbMessage.qaMsg = "null"
        
        // When
        let chatMessage = dbMessage.toChatMessage()
        
        // Then - Should handle invalid JSON gracefully
        #expect(chatMessage.files.isEmpty) // Invalid JSON should result in empty array
        #expect(chatMessage.tips.isEmpty) // Invalid JSON should result in empty array
        #expect(chatMessage.search_results.isEmpty) // Valid empty array should work
        #expect(chatMessage.imageUrls.isEmpty) // Invalid JSON should result in empty array
        #expect(chatMessage.qaMsg.isEmpty) // Invalid JSON should result in empty array
    }
}
