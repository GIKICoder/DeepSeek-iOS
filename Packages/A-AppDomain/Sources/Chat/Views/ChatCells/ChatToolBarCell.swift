//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/21.
//

import UIKit
import SnapKit
import AppFoundation
import AppInfra

public class ChatToolBarCell: ChatContentCell {
    
    // MARK: - 属性
    
    private let dislikeButton: UIButton = {
        let button = TouchExpandedButton(type: .custom)
        button.setImage(UIImage(named: "message_dislike_ic"), for: .normal)
        button.setImage(UIImage(named: "message_dislike_ic_hl"), for: .selected)
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = TouchExpandedButton(type: .custom)
        button.setImage(UIImage(named: "message_like_ic"), for: .normal)
        button.setImage(UIImage(named: "message_like_ic_hl"), for: .selected)
        return button
    }()
    
    private let regenButton: UIButton = {
        let button = TouchExpandedButton(type: .custom)
        button.setImage(UIImage(named: "message_regen_ic"), for: .normal)
        button.isHidden = false
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = TouchExpandedButton(type: .custom)
        button.setImage(UIImage(named: "message_copy_ic"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public override func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        super.configure(section: section, layout: layout, index: index)
        avatarView.isHidden = true
    }
   
    
    // MARK: - 设置视图
    
    private func setupViews() {
        messageView.addSubview(dislikeButton)
        messageView.addSubview(likeButton)
        messageView.addSubview(regenButton)
        messageView.addSubview(moreButton)
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        
        moreButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(0)
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
        }
        regenButton.snp.makeConstraints { make in
            make.leading.equalTo(moreButton.snp.trailing).offset(12)
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
        }
        likeButton.snp.makeConstraints { make in
            make.leading.equalTo(regenButton.snp.trailing).offset(12)
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
        }
        dislikeButton.snp.makeConstraints { make in
            make.leading.equalTo(likeButton.snp.trailing).offset(12)
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupActions() {
        dislikeButton.addTarget(self, action: #selector(dislikeAction), for: .touchUpInside)
        regenButton.addTarget(self, action: #selector(regenAction), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
    }
    
    // MARK: - 动作方法
    
    @objc private func dislikeAction() {
        let event = MessageEvent(name: .dislike, section: section,layout: model,index: index)
        context?.handlerChain.dispatch(event)
    }
    
    @objc private func regenAction() {
        let event = MessageEvent(name: .regen, section: section,layout: model,index: index)
        context?.handlerChain.dispatch(event)
    }
    
    @objc private func moreAction() {
        let event = MessageEvent(name: .copy, section: section,layout: model,index: index)
        context?.handlerChain.dispatch(event)
    }
}
