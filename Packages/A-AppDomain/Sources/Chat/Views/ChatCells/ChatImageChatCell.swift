//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/18.
//

import Foundation
import UIKit
import SnapKit
import AppFoundation
import AppInfra


public class ChatImageChatCell: ChatContentCell {
    
    private let imageView: SkeletonImageView = {
        let imageView = SkeletonImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.black.withAlphaComponent(0.12).cgColor
        return imageView
    }()
    
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        messageView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(tapFileAction), for: .touchUpInside)
        contentView.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
    }
    
    @objc private func tapFileAction() {
        // Implement tap action here
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        super.configure(section: section, layout: layout, index: index)
        avatarView.isHidden = false
        if let imageUrl = layout.message.imageUrls.first {
            imageView.showSkeleton()
            imageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
}
