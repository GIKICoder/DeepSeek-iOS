//
//  HistoryTableViewCell.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/22.
//

import UIKit
import AppFoundation
import AppInfra
import IQListKit
import AppServices

class HistoryTableViewCell: UITableViewCell,IQModelableCell {
    
    typealias Model = ChatChannelHistory
    
    
    // MARK: - Properties
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .white
        return view
    }()
    
    private let avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let centerView = UIView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black.withAlphaComponent(0.6)
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor(hex: "#F4F4F4")
        contentView.addSubview(container)
        container.addSubview(avatarView)
        container.addSubview(centerView)
        centerView.addSubview(nameLabel)
        centerView.addSubview(descLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapContainer))
        container.addGestureRecognizer(tap)
    }
    
    private func setupConstraints() {
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        }
        
        avatarView.snp.makeConstraints { make in
            make.size.equalTo(14)
            make.leading.equalTo(container).offset(16)
            make.centerY.equalTo(container)
        }
        
        centerView.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(12)
            make.centerY.equalTo(avatarView)
            make.trailing.equalTo(container).offset(-12)
            make.top.equalTo(nameLabel)
            make.bottom.equalTo(descLabel)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(0)
            make.trailing.equalTo(container).offset(-12)
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.trailing.equalTo(container).offset(-12)
        }
    }
    
    var model: Model? {
        didSet{
            guard let model = model else { return }
            
            descLabel.text = model.message?.content
        
        }
    }
    
    var colors: [String:UIColor] {
        return [
            "default" : UIColor(hex: "#3C38FF"),
            "pdf" : UIColor(hex: "#FF521C"),
            "doc" : UIColor(hex: "#1CA0FF"),
            "csv" : UIColor(hex: "#02B84A"),
            "ppt" : UIColor(hex: "#FF8B03"),
        ]
    }
    
    @objc func didTapContainer() {
        guard let model = model else {
            return
        }
//        let entrance = MessageEntrance()
//        entrance.channel = model.channel
//        let chat = MessageViewController(entrance: entrance)
//        self.navigationController?.pushViewController(chat, animated: true)
//        
        let chat = ChatViewController(entrance: ChatEntrance(channel:  model.channel))
        self.navigationController?.pushViewController(chat, animated: true)
    }
}

extension HistoryTableViewCell {
    static func privateSize(for model: AnyHashable, listView: IQListView) -> CGSize? {
        return CGSize(width: AppF.screenWidth, height: 64+8)
    }
}

extension HistoryTableViewCell {
    func trailingSwipeActions() -> [UIContextualAction]? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete".localized) { [weak self] (_, _, completionHandler) in
            completionHandler(true)
            guard let self = self, let model = self.model else {
                return
            }
            self.deleteChannelAction(model: model)
        }
        action.backgroundColor = UIColor(hex: "#eb4d3d")
        return [action]
    }
    
    func deleteChannelAction(model: Model) {
        
        guard let vc = self.topViewController else { return }
        let alertVC = UIAlertController(
            title: "Confirm Delete?".localized,
            message: "",
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Cancel"),
            style: .cancel
        ) { _ in
            // 取消操作的回调为空
        }
        alertVC.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("Delete", comment: ""),
            style: .destructive
        ) { [weak self]  _ in
            self?.deleteReal(model)
        }
        alertVC.addAction(deleteAction)
        
        // 针对 iPad 的特殊处理
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if let view = vc.view, let popoverController = alertVC.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(
                    x: view.bounds.midX,
                    y: view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popoverController.permittedArrowDirections = .any
            }
        }
        
        vc.present(alertVC, animated: true)
    }
    
    func deleteReal(_ model:Model) {
        
    }
}
