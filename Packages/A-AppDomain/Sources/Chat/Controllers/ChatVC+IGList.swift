//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/10.
//

import Foundation
import AppFoundation
import AppInfra
import IGListKit
import IGListDiffKit
import IGListSwiftKit

extension ChatViewController: ListAdapterDataSource {
    
    public func objects(for listAdapter: ListAdapter) -> [any ListDiffable] {
        return dataCenter.sections
    }
    
    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = MessageSectionController()
        sectionController.listContext = listContext
        return sectionController
    }
    
    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let view = ChatEmptyView()
        view.frame = CGRect(x: 0, y: 0, width: AppF.screenWidth, height: AppF.screenHeight)
        return view
    }
}

class ChatEmptyView: UIView {
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "dp_icon")
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "嗨! 我是DeepSeek"
        return label
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "我可以帮你搜索 答疑 写作 请把你的任务交给我把~"
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        let center = UIView()
        addSubview(center)
        center.addSubview(iconView)
        center.addSubview(titleLabel)
        center.addSubview(subTitleLabel)
        
        center.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(iconView)
            make.bottom.equalTo(subTitleLabel)
            make.centerY.equalToSuperview().offset(-120)
        }
        iconView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.size.equalTo(60)
            make.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconView.snp.bottom).offset(20)
            make.width.equalToSuperview().offset(-60)
        }
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
