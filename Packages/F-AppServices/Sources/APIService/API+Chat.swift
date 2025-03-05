//
//  File.swift
//  C-AppServices
//
//  Created by GIKI on 2025/1/14.
//

import Foundation
import Moya
import AppInfra

public struct MessagesParams {
    let channelId: String
    let id: Int64
    let beforeMessageId: String?
    var pageSize: Int
    
    public init(channelId: String, id: Int64, beforeMessageId: String? = nil, pageSize: Int = 20) {
        self.channelId = channelId
        self.id = id
        self.beforeMessageId = beforeMessageId
        self.pageSize = pageSize
    }
}

public struct CreateChannelParams {
    public let model: String
    public let message: String
    public let channelId: String?
    public let templateId: String?
    public var extra: [String: Any]?
    
    public init(
            model: String,
            message: String,
            channelId: String? = nil,
            templateId: String? = nil,
            extra: [String: Any]? = nil
        ) {
            self.model = model
            self.message = message
            self.channelId = channelId
            self.templateId = templateId
            self.extra = extra
        }
}

public struct CreateFileChannelParams {
    public let model: String
    public let md5: String
    public let fileName: String
    public let fileContentType: String
    public let uploadTime: Int
    
    public init(model: String, md5: String, fileName: String, fileContentType: String, uploadTime: Int) {
        self.model = model
        self.md5 = md5
        self.fileName = fileName
        self.fileContentType = fileContentType
        self.uploadTime = uploadTime
    }
}



extension MessagesParams: JSONParameter {
    public func toJSON() -> [String: Any] {
        var params: [String: Any] = [
            "channelId": channelId,
            "id": id,
            "pageSize": pageSize
        ]
        if let beforeMessageId = beforeMessageId {
            params["beforeMessageId"] = beforeMessageId
        }
        return params
    }
}

extension CreateFileChannelParams: JSONParameter {
    public func toJSON() -> [String: Any] {
        let params: [String: Any] = [
            "model": model,
            "md5": md5,
            "fileName" : fileName,
            "fileContentType" : fileContentType,
            "uploadTime" : uploadTime,
        ]
        return params
    }
}

extension CreateChannelParams: JSONParameter {
    public func toJSON() -> [String: Any] {
        var params: [String: Any] = [
            "model": model,
            "message": message
        ]
        if let channelId = channelId { params["channelId"] = channelId }
        if let templateId = templateId { params["templateId"] = templateId }
        if let extra = extra { params["extra"] = extra }
        return params
    }
}

// MARK: - Chat API

public enum ChatApi {
    case messages(MessagesParams)
    case createChannel(CreateChannelParams)
    case createFileChannel(CreateFileChannelParams)
    case channelHistory(page: Int, pageSize: Int = 20)
    case saveMessage(messageId: String, content: String)
}


extension ChatApi: NetworkAPI {
    
    public var customHeaders: [String: String] {
        [:]
    }
    public var path: String {
        switch self {
        case .messages:
            return "/api/v1/xxxxx"
        case .createChannel:
            return "/api/v1/xxxx"
        case .createFileChannel:
            return "/py/api/v1/xxxxx"
        case .channelHistory:
            return "/api/v1/xxxx"
        case .saveMessage:
            return "/api/v1/xxxx"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .messages,.channelHistory:
            return .get
        case .createChannel,.saveMessage,.createFileChannel:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .messages(let params):
            let jsonParams = params.toJSON()
            return encodeParameters(jsonParams)
        case .createChannel(let params):
            let jsonParams = params.toJSON()
            return encodeParameters(jsonParams)
        case .createFileChannel(let params):
            let jsonParams = params.toJSON()
            return encodeParameters(jsonParams)
        case .channelHistory(let page, let pageSize):
            return encodeParameters([
                "page": page,
                "pageSize": pageSize
            ])
            
        case .saveMessage(let messageId, let content):
            return encodeParameters([
                "messageId": messageId,
                "content": content
            ])
        }
    }
    
    //    public var sampleData: Data {
    //        switch self {
    //        case .authDeviceId(_):
    //            return """
    //                        {
    //                            "code": 200,
    //                            "message": "Success",
    //                            "data": {
    //                            }
    //                        }
    //                        """.data(using: .utf8)!
    //        }
    //    }
    
   
}
