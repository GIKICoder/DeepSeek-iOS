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
public class ChatMDLaTexCell: ChatContentCell {

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()

    private let latexImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required public init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

    }

    func setupUI() {
        messageView.addSubview(scrollView)
        scrollView.addSubview(latexImageView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    public override func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        super.configure(section: section, layout: layout, index: index)
        if let layout = layout as? ChatMarkdownLayout,
           let image = layout.chunk.latexImage {
            latexImageView.image = image
            let top = (messageView.height -  image.size.height)*0.5
            latexImageView.frame = CGRect(x: 0, y: max(top,12), width: image.size.width, height: image.size.height)
            scrollView.contentSize = image.size
        }
    }
}

