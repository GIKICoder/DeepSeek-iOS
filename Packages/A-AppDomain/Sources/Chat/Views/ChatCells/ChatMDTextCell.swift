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
import AppFoundation

@MainActor
public class ChatMDTextCell: ChatContentCell {

    private let textLabel: MPILabel = {
        let label = MPILabel()
        label.fadeOnAsynchronouslyDisplay = false
        label.clearContentsBeforeAsynchronouslyDisplay = true
        label.displaysAsynchronously = false
        label.backgroundColor = .clear
        return label
    }()
    
    private let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.isEditable = false
        view.textContainerInset = .zero
        view.isScrollEnabled = false
        view.isSelectable = false
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        messageView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        messageView.addSubview(textView)
//        textView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    public override func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        super.configure(section: section, layout: layout, index: index)
        if let layout = layout as? ChatMarkdownLayout {
            textLabel.textRenderer = layout.chunk.textRender
        } else if let layout = layout as? ChatUserTextLayout {
            textLabel.textRenderer = layout.textRender
        }
    }
}
