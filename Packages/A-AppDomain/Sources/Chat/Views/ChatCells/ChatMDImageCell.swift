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
import SDWebImage
import IQListKit
import AppInfra
@MainActor
public class ChatMDImageCell: ChatContentCell {

    private let imageView: SkeletonImageView = {
        let imageView = SkeletonImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        messageView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        if let layout = layout as? ChatMarkdownLayout,
           layout.chunk.source.isNotEmpty, layout.chunk.source.hasPrefix("http") {
            imageView.showSkeleton()
            imageView.sd_setImage(with: URL(string: layout.chunk.source))
        }
    }
}
