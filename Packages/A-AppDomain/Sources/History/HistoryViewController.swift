//
//  HistoryViewController.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/22.
//

import AppFoundation
import AppInfra
import AppServices
import IQListKit
import UIKit

public class HistoryViewController: AppViewController {
    
    public var didSelectModelCallback: ((ChatSessionHistory) -> Void)?
    enum Section {
        case main
    }
    
    let provider = NetworkProvider<ChatApi>()
    var collectionView: UICollectionView!
    private lazy var list = IQList(
        listView: collectionView, delegateDataSource: self)
    
    private var page: Int = 1
    private var pageSize: Int = 200
    
    private var dataSource: [ChatSessionHistory] = []
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    private let avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "profile_default_icon"), for: .normal)
        return button
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = "GIKICoder"
        return label
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(bottomLine)
        view.addSubview(avatarButton)
        view.addSubview(nameLabel)
        avatarButton.addTarget(
            self, action: #selector(didTapAvatarAction), for: .touchUpInside)
        avatarButton.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.leading.equalTo(12)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                .offset(-10)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(avatarButton)
        }
        bottomLine.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalTo(avatarButton.snp.top).offset(-10)
        }
        
        setupCollectionView()
        list.removeDuplicates = true
        //        list.noItemStateView = customNoItemsView
        list.noItemStateView?.tintColor = UIColor.black
        list.noItemImage = UIImage(named: "dp_icon")
        list.noItemMessage = "No content yet~"
        list.noItemAction(
            title: "Reload", target: self, action: #selector(refreshData))
        loadDatas()
    }
    
}

extension HistoryViewController {
    
    func loadDatas() {
        
        list.isLoading = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            
            if let historys: ChatHistoryWarp = self.loadJSON(
                filename: "chat_session") as ChatHistoryWarp?
            {
                self.dataSource = historys.chat_sessions
            }
            DispatchQueue.main.async {
                self.reloadDataSource(false)
                self.list.isLoading = false
            }
        }
        
    }
    
    @objc func refreshData() {
        loadDatas()
    }
    
    @objc func didTapAvatarAction() {
        let setting = SettingViewController()
        self.present(setting, animated: true)
    }
}

extension HistoryViewController {
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: contentFrame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomLine.snp.top).offset(-10)
        }
    }
    
    func reloadDataSource(_ animation: Bool = true) {
        list.reloadData(
            { [dataSource = self.dataSource] builder in
                let section = IQSection(identifier: Section.main)
                builder.append([section])
                builder.append(HistoryTableViewCell.self, models: dataSource)
            }, animatingDifferences: animation)
    }
    
}

extension HistoryViewController: IQListViewDelegateDataSource {
    
    public func listView(
        _ listView: IQListView, modifyCell cell: some IQModelableCell,
        at indexPath: IndexPath
    ) {
        
    }
    
    public func listView(
        _ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath
    ) {
        guard let model = item.model as? ChatSessionHistory else {
            return
        }
        didSelectModelCallback?(model)
        logDebug("History didSelect")
    }
    
    public func listView(
        _ listView: IQListView, canEdit item: IQItem, at indexPath: IndexPath
    ) -> Bool? {
        return true
    }
    
    public func tableView(
        _ tableView: UITableView,
        shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath
    ) -> Bool {
        return true
    }
}

extension HistoryViewController {
    
    // 通过Bundle读取JSON文件
    public func loadJSON<T: Codable>(filename: String) -> T? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json")
        else {
            print("找不到文件: \(filename)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let result = try decoder.decode(DPResponse<T>.self, from: data)
            return result.data?.biz_data
        } catch {
            print("解码失败: \(error)")
            return nil
        }
    }
}
