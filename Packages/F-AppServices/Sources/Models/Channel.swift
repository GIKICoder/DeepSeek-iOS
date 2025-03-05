//
//  Channel.swift
//  AppServices
//
//  Created by GIKI on 2025/1/11.
//

import Foundation
import ReerCodable

@Codable
public struct Channel: Codable, Sendable {
    /// channel的id
    public let id: String
    /// 1:订阅,0:取消订阅
    public var status: Int
    /// channel的名称
    public let name: String
    /// channel的描述
    public let description: String
    /// 顶部图片地址
    public let cover: String
    /// 详情页头部的tips文案
    public let headTips: String
    /// 最新更新标题
    public let lastTitle: String
    /// 最新更新时间
    public let lastUpdateTime: String
    /// 是否展示小红点: 1:展示,0:不展示
    public let redDot: Int
}
