//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/11.
//

import Foundation
import GMarkdown
import UIKit
import IQListKit
import AppFoundation
import AppServices

public final class ChatMarkdownLayout: ChatMessageLayout {

    override public var itemSize: CGSize {
        get {
            let size = calculator.cellSize(innerSize: chunk.cellSize)
            logUI("Markdown Type: \(chunk.chunkType), size: \(size)")
            return size
        }
        set { super.itemSize = newValue }
    }
    
    override public  var cellType: ChatContentCell.Type {
        get {
            logUI("Markdown Type: cellType\(chunk.cellType)")
            return chunk.cellType
        }
        set { super.cellType = newValue }
    }
    
    override public var edgeInsets: UIEdgeInsets {
        get { return calculator.message(innerSize: chunk.cellSize) }
        set { super.edgeInsets = newValue }
    }

    public let chunk: GMarkChunk
    
    public var calculator:CellSizeCalculator
    
    init(message: ChatMessage, chunck:GMarkChunk,calculator:CellSizeCalculator = CellSizeCalculator()) {
        self.chunk = chunck
        self.calculator = calculator
        super.init(identifier: chunk.layoutId, message: message)
    }
    
}


extension GMarkChunk {

    fileprivate var layoutId: String {
        return combineHash()
    }
    fileprivate var cellSize: CGSize {
        switch chunkType {
        case .Image:
            return CGSize(width: 180, height: 180)
        default:
            return itemSize
        }
    }
    
    fileprivate var cellType: ChatContentCell.Type {
        switch chunkType {
        case .Text:
            ChatMDTextCell.self
        case .Code:
            ChatMDCodeCell.self
        case .Image:
            ChatMDImageCell.self
        case .Table:
            ChatMDTableCell.self
        case .Latex:
            ChatMDLaTexCell.self
        case .Thematic:
            ChatMDThematicCell.self
        default:
            ChatMDTextCell.self
        }
    }
    
}
