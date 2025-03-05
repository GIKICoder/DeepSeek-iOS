//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/11.
//

import Foundation
import UIKit
import Foundation
import GMarkdown
import AppFoundation
import AppInfra
import AppServices


public class ChatAssembly {
    
    static func assembleSection(_ message: ChatMessage,dataCenter:ChatDataCenter) -> ChatSection {
        if message.aiMessage || message.loadingMessage {
            return ChatAssembly.assembleAISection(message,dataCenter:dataCenter)
        } else {
            return ChatAssembly.assembleUserSection(message,dataCenter:dataCenter)
        }
    }
    
    
    
    static func assembleUserSection(_ message: ChatMessage,dataCenter:ChatDataCenter) -> ChatSection {
        
        let section = ChatSection(message: message)
        
        var contentPadding = CellSizeConstants.contentPadding
        var maxWidth = 0.0
        var imageLayout = false
        if message.imageUrls.isNotEmpty, let imageUrl = message.imageUrls.first {
            contentPadding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            imageLayout = true
            
            let photoLayout = ChatMessageLayout(identifier:imageUrl, message: message)
            let size = CGSize(width: 220, height: 220)
            photoLayout.itemSize = size
            photoLayout.cellType = ChatImageChatCell.self
            photoLayout.edgeInsets = CellSizeCalculator(contentPadding: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)).message(innerSize:size)
            section.addLayout(photoLayout)
            maxWidth = max(maxWidth, size.width)
        }
        
        if message.content.isNotEmpty {
            let mlayout = ChatUserTextLayout(message: message, style: style)
            mlayout.calculator = CellSizeCalculator(contentPadding: imageLayout ? contentPadding.dropEdge(.top) : contentPadding)
            section.addLayout(mlayout)
            maxWidth = max(maxWidth, mlayout.textRender?.size().width ?? 0)
        }
        let background = ChatSectionBackground(message: message)
        background.backgroundImage = userMessageBubble
        background.visibilityMode = true
        background.backgroundInsets = CellSizeCalculator(contentPadding: contentPadding).background(innerSize: CGSize(width: maxWidth, height: 0))
        section.background = background
        
        return section
    }
    
    static func assembleLoadingSection(_ message: ChatMessage,dataCenter:ChatDataCenter) -> ChatSection {
        
        let section = ChatSection(message: message)
        
        let identifier = message.messageId + "loading"
        let loadingLayout = ChatMessageLayout(identifier:identifier, message: message)
        loadingLayout.cellType = ChatLoadingCell.self
        let loadingSize = CGSize(width: 40, height: 24)
        let calculator = CellSizeCalculator()
        loadingLayout.itemSize = calculator.cellSize(innerSize: loadingSize)
        loadingLayout.edgeInsets = calculator.message(innerSize: loadingSize)
        section.addLayout(loadingLayout)
        
        section.background.visibilityMode = true
        section.background.backgroundImage = aiMessageBubble
        section.background.backgroundInsets = calculator.background(innerSize: loadingSize)
        return section
    }
    
    static func assembleAISection(_ message: ChatMessage,dataCenter:ChatDataCenter) -> ChatSection {
        
        /// loading cell
        if message.loadingMessage || (message.content.isEmpty && message.imageUrls.isEmpty) {
            return  assembleLoadingSection(message,dataCenter: dataCenter)
        }
        
        let section = ChatSection(message: message)
        /// markdown chunks
        let chunks = parseWithMarkdown(message: message)
        
        let layoutsWithWidth = chunks.enumerated().map { (index, chunk) -> (layout: ChatMarkdownLayout, width: CGFloat) in
            let layout = ChatMarkdownLayout(message: message, chunck: chunk)
            var maxWidth = chunk.itemSize.width
            if let textRender = chunk.textRender {
                maxWidth = textRender.size().width
            }
            return (layout, maxWidth)
        }
        let mdlayouts = layoutsWithWidth.map { $0.layout }
        let maxWidth = layoutsWithWidth.map { $0.width }.max() ?? 0
        
        mdlayouts.enumerated().forEach { (index,layout) in
            // 根据chunks数量和位置设置边距
            if mdlayouts.count > 1 {
                // 多个chunk时根据位置设置边距
                if index == 0 {
                    // 第一个chunk去掉底部边距
                    layout.calculator = CellSizeCalculator(contentPadding:CellSizeConstants.contentPadding.dropEdge(.bottom))
                } else if index == chunks.count - 1 {
                    // 最后一个chunk去掉顶部边距
                    layout.calculator = CellSizeCalculator(contentPadding:CellSizeConstants.contentPadding.dropEdge(.top))
                } else {
                    // 中间的chunk只保留水平边距
                    layout.calculator = CellSizeCalculator(contentPadding:CellSizeConstants.contentPadding.horizontalOnly)
                }
            }
        }
        section.addLayouts(mdlayouts)
        
        
        let sendState = dataCenter.currentSendState
        if sendState.isSuccess {
            /// action bar
            let barId = message.messageId + "ActionBar"
            let barLayout = ChatMessageLayout(identifier: barId, message: message)
            barLayout.cellType = ChatToolBarCell.self
            let contentPadding = CellSizeConstants.contentPadding.dropEdge(.top)
            let calculator = CellSizeCalculator(contentPadding:contentPadding)
            barLayout.edgeInsets = calculator.message(innerSize: CGSize(width: maxWidth, height: 0))
            barLayout.itemSize = CGSize(width: .zero, height: 20+contentPadding.verticalInsets)
            section.addLayout(barLayout)
        }
    
        /// qamessage
        var totalHeight: CGFloat = 0
        
        if message.qaMsg.count > 0 {
            let hint = message.messageId + "qahint"
            let hintLayout = ChatMessageLayout(identifier: hint, message: message)
            hintLayout.cellType = ChatQAHintCell.self
            let hintPadding = CellSizeConstants.contentPadding.verticalOnly.dropEdge(.bottom)
            let calculator = CellSizeCalculator(contentPadding:hintPadding)
            let hintHeight = 22.0
            hintLayout.itemSize = CGSizeMake(.zero, hintHeight+hintPadding.verticalInsets)
            hintLayout.edgeInsets = calculator.message(innerSize: CGSize(width: CellSizeConstants.maxMessageWidth, height: hintHeight))
            section.addLayout(hintLayout)
            totalHeight += hintLayout.itemSize.height
            
            message.qaMsg.enumerated().forEach { (index,qaMsg) in
                let mlayout = ChatQaMessageLayout(qaMessage: qaMsg, qaIndex: index, message: message, style: style)
                section.addLayout(mlayout)
                totalHeight += mlayout.itemSize.height
            }
        }

        section.background.backgroundImage = aiMessageBubble
        section.background.visibilityMode = true
        let backInsets = CellSizeCalculator().background(innerSize: CGSize(width: maxWidth, height: 0))
        section.background.backgroundInsets = backInsets.adding(totalHeight, to: .bottom)
        return section
    }
    
    static func parseWithMarkdown(message:ChatMessage) -> [GMarkChunk] {
        let parser = GMarkParser()
        let generator = GMarkChunkGenerator()
        generator.addImageHandler()
        generator.addLaTexHandler()
        generator.identifier = message.messageId
        generator.style = style
        generator.maxAttributedStringLength = 200
        generator.imageLoader = ChatMarkdownImageLoader()
        let processor = GMarkProcessor(parser:parser, chunkGenerator: generator)
        let chunks = processor.process(markdown: message.content)
        return chunks
    }
    
    static var aiMessageBubble: UIImage {
        return UIImage.image(withColor: UIColor(hex: "#F2F4F7"), size: CGSize(width: 25, height: 48), cornerRadius: 8)
    }
    
    static var userMessageBubble: UIImage {
        return UIImage.image(withColor: UIColor(hex: "#E8E7FF"), size: CGSize(width: 25, height: 48), cornerRadius: 8)
    }
    
    static var style: MarkdownStyle {
        var style = MarkdownStyle.defaultStyle()
        style.maxContainerWidth = CellSizeConstants.maxMessageWidth - CellSizeConstants.contentPadding.horizontalInsets
        style.fonts = ChatFontStyle()
        style.colors = ChatColorStyle()
        style.listStyle = ChatListStyle()
        style.useMPTextKit = true
        return style
    }
    
    struct ChatFontStyle: FontStyle {
        var current: UIFont = .systemFont(ofSize: 15, weight: .regular)
        var h1: UIFont = .systemFont(ofSize: 18, weight: .bold)
        var h2: UIFont = .systemFont(ofSize: 17, weight: .bold)
        var h3: UIFont = .systemFont(ofSize: 16, weight: .medium)
        var h4: UIFont = .systemFont(ofSize: 16, weight: .medium)
        var h5: UIFont = .systemFont(ofSize: 16, weight: .regular)
        var h6: UIFont = .systemFont(ofSize: 16, weight: .regular)
        var paragraph: UIFont = .systemFont(ofSize: 15, weight: .regular)
        var inlineCodeFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
        var quoteFont: UIFont = .systemFont(ofSize: 14, weight: .light)
    }
    
    struct ChatColorStyle: ColorStyle {
        var current: UIColor = .black.withAlphaComponent(0.88)
        var h1: UIColor = .black.withAlphaComponent(0.88)
        var h2: UIColor = .black.withAlphaComponent(0.88)
        var h3: UIColor = .black.withAlphaComponent(0.88)
        var h4: UIColor = .black.withAlphaComponent(0.88)
        var h5: UIColor = .black.withAlphaComponent(0.88)
        var h6: UIColor = .black.withAlphaComponent(0.88)
        var inlineCodeForeground: UIColor = .black.withAlphaComponent(0.88)
        var inlineCodeBackground: UIColor = UIColor.white.withAlphaComponent(0.88)
        var quoteBackground: UIColor = UIColor.white.withAlphaComponent(0.88)
        var quoteForeground: UIColor = .black.withAlphaComponent(0.88)
        var link: UIColor = .init(red: 0, green: 0.439, blue: 0.788, alpha: 1)
        var linkUnderline: UIColor = .systemBlue
        var paragraph: UIColor = .black.withAlphaComponent(0.88)
    }
    
    struct ChatListStyle: ListStyle {
        var bulletColor: UIColor = .black.withAlphaComponent(0.88)
        var indentation: CGFloat = 20
        var bulletFont: UIFont = .systemFont(ofSize: 15)
    }

}

class ChatMarkdownImageLoader: ImageLoader {
    
    func loadImage(from source: String, into imageView: UIImageView) {
        imageView.sd_setImage(with: URL(string: source))
    }
    
    func download(from source: String) async -> UIImage? {
        return nil
    }
    
}

extension UIEdgeInsets {
    /// 获取垂直方向上的内边距总和(top + bottom)
    var verticalInsets: CGFloat {
        return top + bottom
    }
    
    /// 获取水平方向上的内边距总和(left + right)
    var horizontalInsets: CGFloat {
        return left + right
    }
    
    /// 仅使用水平方向的内边距创建新的UIEdgeInsets(top和bottom为0)
    var horizontalOnly: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
    
    /// 仅使用垂直方向的内边距创建新的UIEdgeInsets(left和right为0)
    var verticalOnly: UIEdgeInsets {
        return UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
    }
    
    /// 替换某个方向的内边距值
    func replacing(_ edge: Edge, with value: CGFloat) -> UIEdgeInsets {
        switch edge {
        case .top:
            return UIEdgeInsets(top: value, left: left, bottom: bottom, right: right)
        case .left:
            return UIEdgeInsets(top: top, left: value, bottom: bottom, right: right)
        case .bottom:
            return UIEdgeInsets(top: top, left: left, bottom: value, right: right)
        case .right:
            return UIEdgeInsets(top: top, left: left, bottom: bottom, right: value)
        }
    }
    /// 去掉某个方向的内边距(将该方向设为0)
    func dropEdge(_ edge: Edge) -> UIEdgeInsets {
        replacing(edge, with: 0)
    }
    
    /// 在指定方向上增加值
    func adding(_ value: CGFloat, to edge: Edge) -> UIEdgeInsets {
        switch edge {
        case .top:
            return UIEdgeInsets(top: top + value, left: left, bottom: bottom, right: right)
        case .left:
            return UIEdgeInsets(top: top, left: left + value, bottom: bottom, right: right)
        case .bottom:
            return UIEdgeInsets(top: top, left: left, bottom: bottom + value, right: right)
        case .right:
            return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right + value)
        }
    }
    
    /// 在指定方向上减少值
    func subtracting(_ value: CGFloat, from edge: Edge) -> UIEdgeInsets {
        return adding(-value, to: edge)
    }
    
    /// 定义边缘方向的枚举
    enum Edge {
        case top
        case left
        case bottom
        case right
    }
}


