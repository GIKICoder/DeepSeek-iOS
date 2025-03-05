//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/18.
//


import UIKit
import SnapKit
import AppFoundation
 
public class ChatQAHintCell: ChatContentCell {
    

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#525866")
        label.font = UIFont(name: "PopRegular", size: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "The questions you may ask:";
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        messageView.addSubview(hintLabel)
        
        hintLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    // MARK: - Public
    
    public override func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        super.configure(section: section, layout: layout, index: index)
        avatarView.isHidden = true        
    }

}
