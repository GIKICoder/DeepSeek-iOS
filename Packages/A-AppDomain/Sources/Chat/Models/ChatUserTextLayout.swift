//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/20.
//

import Foundation
import AppFoundation
import MPITextKit
import GMarkdown
import IQListKit
import AppServices

public final class ChatUserTextLayout: ChatMessageLayout {
    
    override public var itemSize: CGSize {
        get { return calculator.cellSize(innerSize: textRender?.size() ?? .zero) }
        set { super.itemSize = newValue }
    }
    
    override public  var cellType: ChatContentCell.Type {
        get { return  ChatUserTextCell.self }
        set { super.cellType = newValue }
    }
    
    override public var edgeInsets: UIEdgeInsets {
        get { return calculator.message(innerSize: textRender?.size() ?? .zero) }
        set { super.edgeInsets = newValue }
    }
    
    public var backgrounds: UIEdgeInsets {
        calculator.background(innerSize: textRender?.size() ?? .zero)
    }
    
    public let style: MarkdownStyle
    public var attributedText: NSAttributedString = NSAttributedString.init(string: "")
    public var textRender: MPITextRenderer?
    public var calculator = CellSizeCalculator()
    
    init(message: ChatMessage, style:MarkdownStyle) {
        self.style = style
        super.init(identifier: UUID().uuidString, message: message)
        generateTextRender()
    }
    
    private func generateTextRender() {
        
        attributedText = GMarkupVisitor(style: style).buildAttributedText(from: message.content)
        let builder = MPITextRenderAttributesBuilder()
        builder.attributedText = attributedText
        builder.maximumNumberOfLines = 0
        let renderAttributes = MPITextRenderAttributes(builder: builder)
        textRender = MPITextRenderer(renderAttributes: renderAttributes, constrainedSize: CGSize(width: style.maxContainerWidth, height: CGFLOAT_MAX))
    }
}
