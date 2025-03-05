//
//  API+Upload.swift
//  AppServices
//
//  Created by GIKI on 2025/1/27.
//

import UIKit
import Foundation
import Moya
import AppInfra

public struct PresignedParams {
    let bucket: String
    let md5: String
    let contentType: String?
    
    public init(bucket: String, md5: String, contentType: String?) {
        self.bucket = bucket
        self.md5 = md5
        self.contentType = contentType
    }
}

extension PresignedParams: JSONParameter {
    public func toJSON() -> [String: Any] {
        var params: [String: Any] = [
            "bucket": bucket,
            "md5": md5
        ]
        if let contentType {
            params["contentType"] = contentType
        }
        return params
    }
}

public enum UploadApi {
    case getPresignedPost(PresignedParams)
    case uploadData(data: Data, signed: UploadSinged)
    case uploadFileURL(fileURL: URL, signed: UploadSinged)
}


extension UploadApi: NetworkAPI {
    
    public var headers: [String: String]?  {
        switch self {
        case .uploadData, .uploadFileURL:
            return [:]
        default:
            return NetworkClient.shared.getHeaders()
        }
    }
    
    public var baseURL: URL {
        switch self {
        case .uploadData(_, let signed):
            return URL(string:signed.url)!
        case .uploadFileURL(_, let signed):
            return URL(string:signed.url)!
        default:
            return URL(string: NetworkClient.shared.currentBaseURL)!
        }
    }
    public var path: String {
        switch self {
        case .getPresignedPost:
            return "xxxxxx"
        case .uploadData, .uploadFileURL:
            return ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getPresignedPost:
            return .get
        case .uploadData, .uploadFileURL:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .getPresignedPost(let params):
            let jsonParams = params.toJSON()
            return encodeParameters(jsonParams)
        case .uploadData(let data, let signed):
            // 构建MultipartFormBodyPart
            var formData: [MultipartFormBodyPart] = []
            
            // 添加普通字段
            if !signed.contentType.isEmpty {
                let part = MultipartFormBodyPart(provider: .data(signed.contentType.data(using: .utf8)!), name: "Content-Type")
                formData.append(part)
//                formData.append(MultipartFormBodyPart(provider: .data(signed.contentType.data(using: .utf8)!),
//                                                  name: "Content-Type"))
            }
            
            if !signed.key.isEmpty {
                formData.append(MultipartFormBodyPart(provider: .data(signed.key.data(using: .utf8)!),
                                                  name: "key"))
            }
            
            if !signed.AWSAccessKeyId.isEmpty {
                formData.append(MultipartFormBodyPart(provider: .data(signed.AWSAccessKeyId.data(using: .utf8)!),
                                                  name: "AWSAccessKeyId"))
            }
            
            if !signed.policy.isEmpty {
                formData.append(MultipartFormBodyPart(provider: .data(signed.policy.data(using: .utf8)!),
                                                  name: "policy"))
            }
            
            if !signed.signature.isEmpty {
                formData.append(MultipartFormBodyPart(provider: .data(signed.signature.data(using: .utf8)!),
                                                  name: "signature"))
            }
            
            // 添加文件数据
            formData.append(MultipartFormBodyPart(provider: .data(data),
                                              name: "file",
                                              fileName: "filename.jpg",
                                              mimeType: signed.contentType))
            
            return .uploadMultipart(formData)
        case .uploadFileURL(let fileURL, let signed):
            // 构建MultipartFormBodyPart
            var formData: [MultipartFormBodyPart] = []
            
            // 添加普通字段
            if !signed.contentType.isEmpty {
                formData.append(MultipartFormBodyPart(provider: .data(signed.contentType.data(using: .utf8)!),
                                                  name: "Content-Type"))
            }
            
            if !signed.key.isEmpty {
                formData.append(MultipartFormBodyPart(provider: .data(signed.key.data(using: .utf8)!),
                                                  name: "key"))
            }
            
            if !signed.AWSAccessKeyId.isEmpty {
                formData.append(MultipartFormBodyPart(provider: .data(signed.AWSAccessKeyId.data(using: .utf8)!),
                                                  name: "AWSAccessKeyId"))
            }
            
            if !signed.policy.isEmpty {
                formData.append(MultipartFormBodyPart(provider: .data(signed.policy.data(using: .utf8)!),
                                                  name: "policy"))
            }
            
            if !signed.signature.isEmpty {
                formData.append(MultipartFormBodyPart(provider: .data(signed.signature.data(using: .utf8)!),
                                                  name: "signature"))
            }
            
            let fileName = fileURL.lastPathComponent
            // 添加文件数据
            formData.append(MultipartFormBodyPart(provider: .file(fileURL as URL),
                                              name: "file",
                                              fileName: fileName,
                                              mimeType: "application/octet-stream"))
            
            return .uploadMultipart(formData)
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
