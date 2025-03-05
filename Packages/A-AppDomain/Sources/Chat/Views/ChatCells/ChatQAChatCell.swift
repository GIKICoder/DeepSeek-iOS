//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/18.
//

import UIKit
import SnapKit
import AppFoundation
import MPITextKit
 
public class ChatQAChatCell: ChatContentCell {
    
    private let qaContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "#E4E6EB").cgColor
        return view
    }()
    
    private let qaLabel: MPILabel = {
        let label = MPILabel()
        label.textColor = UIColor(hex: "#081226")
        label.font = UIFont(name: "PopRegular", size: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        messageView.addSubview(qaContainer)
        qaContainer.addSubview(qaLabel)
        
        qaContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        qaLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }
       
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public override func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        super.configure(section: section, layout: layout, index: index)
        avatarView.isHidden = true
        if let layout = layout as? ChatQaMessageLayout {
            qaLabel.textRenderer = layout.textRender
        }
    }
}
