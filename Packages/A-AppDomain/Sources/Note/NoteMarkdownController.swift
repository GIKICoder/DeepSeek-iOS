//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/6/4.
//

import Foundation
import UIKit
import AppComponents
import AppInfra
import GMarkdown
import AppFoundation

class NoteMarkdownController: AppViewController {
    
    let markdownView: GMarkdownMultiView = GMarkdownMultiView()
    let markdownText: String
    init(markdown: String) {
        self.markdownText = markdown
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackNavigationBar(title:"Note")
        view.backgroundColor = .white
        view.addSubview(markdownView)
        markdownView.frame = contentFrame
        Task {
            await setupMarkdown()
        }
    }
    

    func setupMarkdown() async {
        
        let chunks = await parseMarkdown(self.markdownText)
        
        DispatchQueue.main.async { [weak self] in
            self?.markdownView.updateMarkdown(chunks)
        }
    }
    
    func parseMarkdown(_ content: String) async -> [GMarkChunk] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let style = MarkdownStyle.defaultStyle()
                let generator = GMarkChunkGenerator()
                generator.style = style
                generator.addLaTexHandler()
                let processor = GMarkProcessor(parser: GMarkParser(), chunkGenerator: generator)
                let chunks = processor.process(markdown: content)
                continuation.resume(returning: chunks)
            }
        }
    }
}
