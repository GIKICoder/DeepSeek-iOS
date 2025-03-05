//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/18.
//

import Foundation
import AppFoundation
import MPITextKit
import AppServices
import GMarkdown

public final class ChatQaMessageLayout: ChatMessageLayout {
    override public var itemSize: CGSize {
        get {
            let size = calculator.cellSize(innerSize: innerSize)
            logUI("Markdown Type: QaMessage, size: \(size)")
            return size
        }
        set { super.itemSize = newValue }
    }
    
    override public  var cellType: ChatContentCell.Type {
        get { return  ChatQAChatCell.self }
        set { super.cellType = newValue }
    }
    
    override public var edgeInsets: UIEdgeInsets {
        get { return  calculator.message(innerSize: innerSize) }
        set { super.edgeInsets = newValue }
    }

    
    public let qaMessage: String
    public let qaIndex: Int
    public let style: MarkdownStyle
    public var attributedText: NSAttributedString?
    public var textRender: MPITextRenderer?
    
    public var calculator:CellSizeCalculator {
        CellSizeCalculator(contentPadding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0))
    }
    
    var innerSize:CGSize {
        guard let size = textRender?.size() else {
            return .zero
        }
        return CGSize(width: size.width+24, height: size.height+24)
    }
    
    init(qaMessage:String, qaIndex:Int, message: ChatMessage, style:MarkdownStyle) {
        self.qaMessage = qaMessage
        self.qaIndex = qaIndex
        self.style = style
        let identifier = "\(qaMessage.md5) + \(qaIndex)"
        super.init(identifier: identifier, message: message)
        generateTextRender()
    }
    
    private func generateTextRender() {
        
        attributedText = GMarkupVisitor(style: style).buildAttributedText(from: qaMessage)
        let builder = MPITextRenderAttributesBuilder()
        builder.attributedText = attributedText
        builder.maximumNumberOfLines = 0
        let renderAttributes = MPITextRenderAttributes(builder: builder)
        textRender = MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: CGSize(width: style.maxContainerWidth, height: CGFLOAT_MAX))
    }
    
    
}
