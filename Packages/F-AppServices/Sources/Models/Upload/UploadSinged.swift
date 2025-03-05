//
//  UploadSinged.swift
//  AppServices
//
//  Created by GIKI on 2025/1/27.
//

import UIKit
import ReerCodable

@Codable
public struct UploadSinged: Codable, Sendable {
    public var url: String = ""
    @CodingKey("fields.AWSAccessKeyId")
    public var AWSAccessKeyId: String = ""
    @CodingKey("fields.key")
    public var key: String = ""
    @CodingKey("fields.policy")
    public var policy: String = ""
    @CodingKey("fields.signature")
    public var signature: String = ""
    @CodingKey("fields.contentType")
    public var contentType: String = ""   
}
