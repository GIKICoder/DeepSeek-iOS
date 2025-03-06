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

class HistoryTableViewCell: UICollectionViewCell,IQModelableCell {
    
    typealias Model = ChatSessionHistory
    
    
    // MARK: - Properties
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .white
        return view
    }()
    
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Initialization
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        setupUI()
//        setupConstraints()
//        setupContextMenu()
//    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupContextMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(container)
        container.addSubview(descLabel)
    
    }
    
    private func setupConstraints() {
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }
        
        descLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        }
    }
    
    private func setupContextMenu() {
        // 添加交互
        let interaction = UIContextMenuInteraction(delegate: self)
        container.addInteraction(interaction)
        container.isUserInteractionEnabled = true
    }
    
    var model: Model? {
        didSet{
            guard let model = model else { return }
            descLabel.text = model.title
        }
    }

}

extension HistoryTableViewCell {
    static func privateSize(for model: AnyHashable, listView: IQListView) -> CGSize? {
        return CGSize(width: AppF.screenWidth*0.7, height: 48)
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension HistoryTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        guard model != nil else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            // 重命名按钮
            let rename = UIAction(
                title: "重命名",
                image: UIImage(systemName: "pencil"), // 系统铅笔图标
                attributes: [],
                handler: { [weak self] _ in
                    // 处理重命名逻辑
                    print("点击了重命名")
                }
            )
            
            // 删除按钮
            let delete = UIAction(
                title: "删除",
                image: UIImage(systemName: "trash"), // 系统垃圾桶图标
                attributes: .destructive, // 设置为红色
                handler: { [weak self] _ in
                    // 处理删除逻辑
                    print("点击了删除")
                }
            )
            
            // 创建菜单
            return UIMenu(title: "", children: [rename, delete])
        }
    }
}
