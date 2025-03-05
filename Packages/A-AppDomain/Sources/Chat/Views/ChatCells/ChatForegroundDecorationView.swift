//
//  MessageBackgroundDecorationView.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/21.
//
import MagazineLayout
import UIKit
import AppFoundation
import SnapKit
import IQListKit

final class ChatForegroundDecorationView: MagazineLayoutCollectionReusableView {
    
    
    // MARK: Lifecycle
    
    public let container: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(container)
        container.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(0)
            make.trailing.equalToSuperview().inset(0)
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(0)
        }
        setupContextMenu()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContextMenu() {
        // 添加交互
//        let interaction = UIContextMenuInteraction(delegate: self)
//        container.addInteraction(interaction)
//        // 确保view可以交互
//        container.isUserInteractionEnabled = true
    }
    
    var model: ChatSection? {
        didSet {
            guard let model else {
                return
            }
            container.snp.updateConstraints { make in
                make.leading.equalToSuperview().inset(model.background.backgroundInsets.left)
                make.trailing.equalToSuperview().inset(model.background.backgroundInsets.right)
                make.top.equalToSuperview().inset(model.background.backgroundInsets.top)
                make.bottom.equalToSuperview().inset(model.background.backgroundInsets.bottom)
            }
            container.image = model.background.backgroundImage.stretchd
        }
    }
}

extension ChatForegroundDecorationView: EditNotifierDelegate {
    
    public func setIsEditing(_ isEditing: Bool, duration: ActionDuration) {
        guard let model else {
            return
        }
        let left = model.background.backgroundInsets.left
        let right = model.background.backgroundInsets.right
        // 更新 containerView 的约束
        container.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(isEditing ? left+36 : left)
            make.trailing.equalToSuperview().inset(isEditing ? right-36 : right)
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
}
