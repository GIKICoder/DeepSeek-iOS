//
//  MessageContentCell.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/16.
//

import UIKit
import AppInfra
import IQListKit
import AppFoundation

public class ChatContentCell: UICollectionViewCell,
                              ChatCellModifiable {
    
    
    private let editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "pop_chat_un_select"), for: .normal)
        button.setImage(UIImage(named: "pop_chat_select"), for: .selected)
        return button
    }()
    
    public let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    public let avatarView: UIButton = {
        let imageView = UIButton()
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public let messageView: UIView = {
        let view = UIView()
        return view
    }()
    
    public typealias Model = ChatMessageLayout
    
    public private(set) var model: Model?
    public private(set) var section: ChatSection?
    public private(set) var index: Int?
    public private(set) var context: ChatContext?
    
    
    // Initializer
    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        messageView.backgroundColor = .clear
        containerView.backgroundColor = .clear
        _setupUI()
        _setupGuesture()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUI()
        _setupGuesture()
    }
    
    
    func _setupUI() {
        
        contentView.addSubview(editButton)
        editButton.isHidden = true
        editButton.isUserInteractionEnabled = false
        
        contentView.addSubview(containerView)
        containerView.addSubview(avatarView)
        containerView.addSubview(messageView)
        
        editButton.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.leading.equalTo(16)
            make.centerY.equalTo(avatarView.snp.centerY)
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(0)
            make.trailing.equalToSuperview().inset(0)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        avatarView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.top.equalTo(0)
            make.left.equalTo(16)
        }
        messageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(0)
            make.trailing.equalToSuperview().inset(0)
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(0)
        }
        
        messageView.backgroundColor = .random
    }
    
    func _setupGuesture() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapPress(_:)))
        addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPress.minimumPressDuration = 0.5
        tap.require(toFail: longPress)
        addGestureRecognizer(longPress)
    }
    
    public func configureContext(_ context: ChatContext?) {
        self.context = context
    }
    
    public func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        self.section = section
        self.index = index
        self.model = layout
        editButton.isHidden = true
        avatarView.isHidden = (index > 0)
        
        messageView.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.edgeInsets.left)
            make.trailing.equalToSuperview().inset(layout.edgeInsets.right)
            make.top.equalToSuperview().inset(layout.edgeInsets.top)
            make.bottom.equalToSuperview().inset(layout.edgeInsets.bottom)
        }
       
    }

}

extension ChatContentCell {
    
    @objc func handleTapPress(_ gesture: UILongPressGestureRecognizer) {
        let tapEvent = MessageEvent(name: .tap,section: section,layout: model,index: index)
        context?.handlerChain.dispatch(tapEvent)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        // 获取点击位置
        let location = gesture.location(in: self)
        
        // 触发震动反馈
        impact()
        
        showMenuPopover(from: self, location:location)
        
    }
}

extension ChatContentCell: EditNotifierDelegate {
    
    @objc func didTapEditAction() {
        editButton.isSelected = !editButton.isSelected
    }
    
    public func setIsEditing(_ isEditing: Bool, duration: ActionDuration) {
        
        editButton.isHidden = avatarView.isHidden ? true : !isEditing
        // 更新 containerView 的约束
        containerView.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(isEditing ? 36 : 0)
            make.trailing.equalToSuperview().inset(isEditing ? -36 : 0)
        }
        
        switch duration {
        case .notAnimated:
            self.layoutIfNeeded()
        case .animated(let duration):
            UIView.animate(withDuration: duration) {
                self.layoutIfNeeded()
            }
        }
    }
    
    public func didUpdateSelection(_ selectedItems: Set<ChatSection>) {
        guard let section, selectedItems.isNotEmpty else {
            editButton.isSelected = false
            return
        }
        editButton.isSelected = selectedItems.contains(section)
    }
}

extension ChatContentCell {
    
    func showMenuPopover(from sourceView: UIView, location: CGPoint) {
        
        // 创建顶部菜单动作
        let topMenus = createTopMenuActions()
        // 创建底部菜单动作
        let bottomMenus = createBottomMenuActions()
       
       
        // 显示菜单
        MenuPopoverController.present(
            from: self,
            at: location,
            with: topMenus,
            and: bottomMenus
        ) {
            print("Menu presented")
        }
    }
    
    private func createTopMenuActions() -> [MenuAction] {
        
        //                UIImage(systemName: "hand.thumbsup.fill")
        let likeIcon = UIImage.blackSystemImage("hand.thumbsup")
        let likeAction = MenuAction(
            title: NSLocalizedString("Like", comment: ""),
            image: likeIcon,
            handler: { [weak self] in
                self?.likeWithIndexPath()
            }
        )
        
        // Dislike Action UIImage(systemName: "hand.thumbsdown.fill")
        let dislikeIcon =  UIImage.blackSystemImage("hand.thumbsdown")
        let dislikeAction = MenuAction(
            title: NSLocalizedString("Dislike", comment: ""),
            image: dislikeIcon,
            handler: { [weak self] in
                self?.dislikeWithIndexPath()
            }
        )
        
        return [likeAction, dislikeAction]
    }
    
    private func createBottomMenuActions() -> [MenuAction] {
        var bottomMenus: [MenuAction] = []
        
        // Copy Action
        let copyAction = MenuAction(
            title: NSLocalizedString("Copy", comment: ""),
            image: UIImage.blackSystemImage( "doc.on.doc"),
            handler: { }
        )
        bottomMenus.append(copyAction)
        
        // Select Text Action
        let selectAction = MenuAction(
            title: NSLocalizedString("Select Text", comment: ""),
            image:UIImage.blackSystemImage("selection.pin.in.out"),
            handler: { [weak self] in
                self?.selectTextWithIndexPath()
            }
        )
        bottomMenus.append(selectAction)
        
        // Translate Action
        let translateAction = MenuAction(
            title: NSLocalizedString("Translate", comment: ""),
            image: UIImage.blackSystemImage("character.bubble.fill"),
            handler: { [weak self] in
                self?.translateWithIndexPath()
            }
        )
        bottomMenus.append(translateAction)
        
        // Regenerate Action
        let regenerateAction = MenuAction(
            title: NSLocalizedString("Regenerate response", comment: ""),
            image: UIImage.blackSystemImage("arrow.counterclockwise"),
            handler: { [weak self] in
                self?.regenerateResponse()
            }
        )
        bottomMenus.append(regenerateAction)
        
        return bottomMenus
    }
    
    // MARK: - Action Methods
    private func likeWithIndexPath() {
        // 处理点赞逻辑
    }
    
    private func dislikeWithIndexPath() {
        // 处理点踩逻辑
    }
    
    private func selectTextWithIndexPath() {
        // 处理文本选择逻辑
        
    }
    
    private func translateWithIndexPath() {
        // 处理翻译逻辑
    }
    
    private func regenerateResponse() {
        // 处理重新生成响应逻辑
    }
    
    
}

extension ChatContentCell {
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

