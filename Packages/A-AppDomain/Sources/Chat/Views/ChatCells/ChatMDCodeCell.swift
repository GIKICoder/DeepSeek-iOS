//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/17.
//

import Foundation
import UIKit
import MPITextKit
import GMarkdown
import IQListKit
@MainActor
public class ChatMDCodeCell: ChatContentCell {

    private let codeView: GMarkdownCodeView = {
        let codeView = GMarkdownCodeView()
        return codeView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        codeView.backgroundColor = .clear
        messageView.addSubview(codeView)
        codeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        codeView.onCopy = { copyText in
            UIPasteboard.general.string = copyText
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        
    }

    @available(*, unavailable)
    required public init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        super.configure(section: section, layout: layout, index: index)
        if let layout = layout as? ChatMarkdownLayout {
            codeView.markChunk = layout.chunk
        }
    }
}
